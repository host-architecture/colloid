#!/bin/bash

config=$1
# gups_path=/home/midhul/colloid/apps/gups
mio_path=/home/midhul/mio
record_path=/home/midhul/colloid/colloid-stats
stats_path=/home/midhul/membw-eval
colloidmon_path=/home/midhul/memtis/colloid-mon
# gups_workload=$2
# gups_cores=4
# stream_num_cores=3
#duration=$2
app_cores=$2
bg_cores=$3

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
    killall python3
    killall stream
    killall bpftrace > /dev/null 2>&1;
    rmmod colloid-mon.ko > /dev/null 2>&1;
    echo "Cleaned up";
}

trap cleanup EXIT

cleanup;

insmod $colloidmon_path/colloid-mon.ko

# Make sure colloid-mon kernel module is loaded
if ! lsmod | grep -q "colloid_mon"; then
    echo "colloid-mon not loaded";
    exit 1;
fi

# Trace colloid-mon
addr_occ_local=$(cat /proc/kallsyms | grep smoothed_occ_local | awk '{print "0x"$1}')
addr_occ_remote=$(cat /proc/kallsyms | grep smoothed_occ_remote | awk '{print "0x"$1}')
addr_inserts_local=$(cat /proc/kallsyms | grep smoothed_inserts_local | awk '{print "0x"$1}')
addr_inserts_remote=$(cat /proc/kallsyms | grep smoothed_inserts_remote | awk '{print "0x"$1}')
addr_p_lo=$(cat /proc/kallsyms | grep p_lo | grep colloid | awk '{print "0x"$1}')
addr_p_hi=$(cat /proc/kallsyms | grep p_hi | grep colloid | awk '{print "0x"$1}')

# Make sure swap is disabled
swapoff -a
# Enable colloid
echo "enabled" > /sys/kernel/mm/htmm/htmm_colloid

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

echo "running bpftrace for logging";
bpftrace -e "BEGIN {@start = nsecs;} interval:s:1 {printf(\"colloid-moin, %ld, colloid_local_lat_gt_remote: %d, local_occ: %lu, remote_occ: %lu, local_inserts: %lu, remote_inserts: %lu, p_lo: %lu, p_hi: %lu, delta_p=%lu, dynlimit=%lu\n\", (nsecs-@start)/1e9, *kaddr(\"colloid_local_lat_gt_remote\"), *($addr_occ_local), *($addr_occ_remote), *($addr_inserts_local), *($addr_inserts_remote), *($addr_p_lo), *($addr_p_hi), *kaddr(\"colloid_delta_p\"), *kaddr(\"colloid_dynlimit\"));} tracepoint:colloid:colloid_migrate {printf("colloid migrate, nr_migrated=%lu, promotion=%d, nr_to_scan=%lu, delta_p=%lu, migrate_limit=%lu, overall_accesses=%lu \n", args.nr_migrated, args.promotion, args.nr_to_scan, args.delta_p, args.migrate_limit, args.overall_accesses);}" > $stats_path/$config.mon.txt 2>&1 &
pid_bpf=$!;

# Start CPU usage monitoring with sar
sar_logfile="$stats_path/$config.sar.txt"
sar -u -P ALL 1 > $sar_logfile 2>&1 &
pid_sar=$!;
all_pids+=($pid_sar);

# run actual app
echo "Running $config"
"${args_after_double_dash[@]}";
# pid_app=$!;
# all_pids+=($pid_app);

# Stop sar monitoring
kill $pid_sar > /dev/null 2>&1;
while kill -0 $pid_sar > /dev/null 2>&1; do
    sleep 1;
done;
killall sar > /dev/null 2>&1;

if [ $bg_cores -gt 0 ] || [ "${#mio_opts[@]}" -gt 0 ]; then
	kill $pid_mio;
	while kill -0 $pid_mio; do
    		sleep 1;
	done;
	killall python3
	killall stream
fi

killall bpftrace > /dev/null 2>&1;
while kill -0 $pid_bpf > /dev/null 2>&1; do
    sleep 1;
done;

rmmod colloid-mon.ko > /dev/null 2>&1;



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
