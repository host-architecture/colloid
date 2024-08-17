#!/bin/bash

# Make sure tiering is initialized

config=$1
# gups_path=/home/midhul/colloid/apps/gups
mio_path=/home/midhul/mio
record_path=/home/midhul/colloid/colloid-stats
stats_path=/home/midhul/membw-eval
memeater_path=/home/midhul/colloid/tpp/memeater
kswapdrst_path=/home/midhul/colloid/tpp/kswapdrst
colloidmon_path=/home/midhul/colloid/tpp/colloid-mon
scripts_path=/home/midhul/colloid/scripts
local_numa=1
local_size=32768
# gups_workload=$2
# gups_cores=4
# stream_num_cores=3
duration=$2
app_cores=$3
bg_cores=$4

if [ -z "${DRAMSIZE}" ]; then
    echo "DRAM size default: $local_size MB"
else
    local_size=$(($DRAMSIZE/1048576));
	echo "DRAM size set: $local_size MB";
fi

all_core_list="1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45,47,49,51,53,55,57,59"
bg_core_list=$(echo "$all_core_list" | cut -d ',' -f $((app_cores + 1))-)
echo $bg_core_list

index=0
for arg in "$@"; do
    ((index++))
    if [ "$arg" == "--" ]; then
        break
    fi
done

# Extract all arguments after "--"
shift $index
args_after_double_dash=("$@")

all_pids=()

function cleanup() {
    for pid in "${all_pids[@]}"; do
        kill -9 $pid;
    done;
    killall perf
    killall python3
    killall stream
    killall bpftrace
    rmmod memeater.ko
    rmmod kswapdrst.ko
    rmmod colloid-mon.ko
    $scripts_path/disable_thp.sh
    echo "Cleaned up";
}

trap cleanup EXIT

cleanup;

sync;
echo 3 > /proc/sys/vm/drop_caches

if [ -n "${ENABLE_THP}" ]; then
    echo "Enabling THP";
    $scripts_path/enable_thp.sh;
fi

# Run kswapd reset module
insmod $kswapdrst_path/kswapdrst.ko

insmod $colloidmon_path/colloid-mon.ko

# Make sure colloid-mon kernel module is loaded
if ! lsmod | grep -q "colloid_mon"; then
    echo "colloid-mon not loaded";
    exit 1;
fi

addr_occ_local=$(cat /proc/kallsyms | grep smoothed_occ_local | awk '{print "0x"$1}')
addr_occ_remote=$(cat /proc/kallsyms | grep smoothed_occ_remote | awk '{print "0x"$1}')
addr_lat_local=$(cat /proc/kallsyms | grep smoothed_lat_local | awk '{print "0x"$1}')
addr_lat_remote=$(cat /proc/kallsyms | grep smoothed_lat_remote | awk '{print "0x"$1}')
addr_inserts_local=$(cat /proc/kallsyms | grep smoothed_inserts_local | awk '{print "0x"$1}')
addr_inserts_remote=$(cat /proc/kallsyms | grep smoothed_inserts_remote | awk '{print "0x"$1}')


# Make sure tiering + colloid is enabled
swapoff -a
echo 1 > /sys/kernel/mm/numa/demotion_enabled
echo 6 > /proc/sys/kernel/numa_balancing

mio_opts=( $MIO_STATS )

if [ $bg_cores -gt 0 ]; then
	echo "Running bg traffic on $bg_cores"
	PYTHONPATH=$PYTHONPATH:$mio_path python3 -m mio $config-mio --ant_cpus $bg_core_list --ant_num_cores $bg_cores --ant_mem_numa 1 --ant stream --ant_writefrac 50 --ant_inst_size 64 --ant_duration 10000 "${mio_opts[@]}" &
	pid_mio=$!;
	all_pids+=($pid_mio);
	sleep 7;
elif [ "${#mio_opts[@]}" -gt 0 ]; then
    echo "Running mio"
    PYTHONPATH=$PYTHONPATH:$mio_path python3 -m mio $config-mio "${mio_opts[@]}" &
    pid_mio=$!;
	all_pids+=($pid_mio);
	sleep 7;
fi

# Set local memory capacity
if [ -n "${ENABLE_THP}" ]; then
    echo "memeater THP"; 
    insmod $memeater_path/memeater.ko sizeMiB=$(numastat -m | grep MemFree | awk -v nidx=$local_numa -v sz=$local_size '{print int($(2+nidx)-sz)}') PGSIZE=2097152 PGORDER=9;
else
    insmod $memeater_path/memeater.ko sizeMiB=$(numastat -m | grep MemFree | awk -v nidx=$local_numa -v sz=$local_size '{print int($(2+nidx)-sz)}');
fi

echo "Local mem size"
echo $(numastat -m | grep MemFree)
echo $(numastat -m | grep MemFree) > $stats_path/$config.memfree.txt

cat /proc/vmstat > $stats_path/$config.before_vmstat.txt

# run actual app
echo "Running $config"
"${args_after_double_dash[@]}" > $stats_path/$config.app.txt 2> $stats_path/$config.stderr.txt &
pid_app=$!;
all_pids+=($pid_app);

echo "running bpftrace";
bpftrace -e "BEGIN {@start = nsecs;} interval:s:1 {printf(\"%ld, colloid_local_lat_gt_remote: %d, local_lat: %lu, remote_lat: %lu, local_occ: %lu, remote_occ: %lu, local_inserts: %lu, remote_inserts: %lu, kswapd_failues: %d\n\", (nsecs-@start)/1e9, *kaddr(\"colloid_local_lat_gt_remote\"), *($addr_lat_local), *($addr_lat_remote), *($addr_occ_local), *($addr_occ_remote), *($addr_inserts_local), *($addr_inserts_remote), ((struct pglist_data *)(*(kaddr(\"node_data\") + 8*1)))->kswapd_failures);}" > $stats_path/$config.mon.txt 2>&1 &
pid_bpf=$!;

# record vm stats for duration
rm $stats_path/$config.vmstat.txt
if [ $duration -gt 0 ]; then
    for i in $(seq 1 1 $duration); do
        grep -E "pgdemote|pgpromote|pgmigrate|thp_migration" /proc/vmstat >> $stats_path/$config.vmstat.txt
        sleep 1;
    done;
else
    while kill -0 $pid_app; do
        grep -E "pgdemote|pgpromote|pgmigrate|thp_migration" /proc/vmstat >> $stats_path/$config.vmstat.txt
        sleep 1;
    done;
fi

killall bpftrace;
while kill -0 $pid_bpf; do
    sleep 1;
done;

if [ $duration -gt 0 ]; then
    kill $pid_app;
    while kill -0 $pid_app; do
        sleep 1;
    done;
fi

cat /proc/vmstat > $stats_path/$config.after_vmstat.txt

if [ $bg_cores -gt 0 ] || [ "${#mio_opts[@]}" -gt 0 ]; then
	kill $pid_mio;
	while kill -0 $pid_mio; do
    		sleep 1;
	done;
	killall python3
	killall stream
fi

rmmod memeater.ko
rmmod kswapdrst.ko
rmmod colloid-mon.ko

$scripts_path/disable_thp.sh



# Run GUPS in isolation
# echo "Running $config-iso"
# LD_LIBRARY_PATH=$lib_path LD_PRELOAD=$hemem_lib $gups_path/$gups_workload $gups_cores > $stats_path/$config-iso.gups.txt 2> $stats_path/$config-iso.hemem.txt &
# pid_gups=$!;
# taskset -c 0 $record_path/record_stats > $stats_path/$config-iso.stats.txt 2>&1 &
# pid_stats=$!;
# sleep $duration;
# killall record_stats;
# while kill -0 $pid_stats; do
#     sleep 1;
# done;
# killall $gups_workload;
# while kill -0 $pid_gups; do
#     sleep 1;
# done;

# Run GUPS with background traffic
#echo "Running $config-bg"
#PYTHONPATH=$PYTHONPATH:$mio_path python3 -m mio $config-bg --ant_cpus $stream_core_list --ant_num_cores $stream_num_cores --ant_mem_numa 3 --ant stream --ant_writefrac 50 --ant_inst_size 64 --ant_duration $(($duration+20)) &
#pid_mio=$!;
#sleep 10;
#$gups_path/$gups_workload $gups_cores > $stats_path/$config-bg.gups.txt 2>&1 &
#pid_gups=$!;
#taskset -c 0 $record_path/record_stats > $stats_path/$config-bg.stats.txt 2>&1 &
#pid_stats=$!;
#sleep $duration;
#killall record_stats;
#while kill -0 $pid_stats; do
#    sleep 1;
#done;
#killall $gups_workload;
#while kill -0 $pid_gups; do
#    sleep 1;
#done;
#wait $pid_mio;

echo "Done";