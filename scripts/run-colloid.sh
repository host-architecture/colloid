#!/bin/bash

config=$1
gups_path=/home/midhul/colloid/apps/gups
mio_path=/home/midhul/mio-colloid
record_path=/home/midhul/colloid/colloid-stats
stats_path=/home/midhul/membw-eval
gups_workload=$2
gups_cores=4
stream_num_cores=3
stream_core_list="19,23,27,31"
duration=1000

function cleanup() {
    killall gups-r;
    killall gups-rw;
    killall record_stats;
    killall stream;
    killall python3;
    killall bpftrace;
    echo "Cleaned up";
}

trap cleanup EXIT

cleanup;

# Make sure colloid-mon kernel module is loaded
if ! lsmod | grep -q "colloid_mon"; then
    echo "colloid-mon not loaded";
    exit 1;
fi

addr_local=$(cat /proc/kallsyms | grep smoothed_occ_local | awk '{print "0x"$1}')
addr_remote=$(cat /proc/kallsyms | grep smoothed_occ_remote | awk '{print "0x"$1}')

# Make sure tiering + colloid is enabled
swapoff -a
echo 1 > /sys/kernel/mm/numa/demotion_enabled
echo 6 > /proc/sys/kernel/numa_balancing

# Run GUPS in isolation
echo "Running $config-iso"
$gups_path/$gups_workload $gups_cores > $stats_path/$config-iso.gups.txt 2>&1 &
pid_gups=$!;
taskset -c 0 $record_path/record_stats > $stats_path/$config-iso.stats.txt 2>&1 &
pid_stats=$!;
bpftrace -e "BEGIN {@start = nsecs;} interval:s:1 {printf(\"%ld, colloid_local_lat_gt_remote: %d, local: %lu, remote: %lu\n\", (nsecs-@start)/1e9, *kaddr(\"colloid_local_lat_gt_remote\"), *($addr_local), *($addr_remote));}" > $stats_path/$config-iso.mon.txt 2>&1 &
pid_bpf=$!;
sleep $duration;
killall bpftrace;
while kill -0 $pid_bpf; do
    sleep 1;
done;
killall record_stats;
while kill -0 $pid_stats; do
    sleep 1;
done;
killall $gups_workload;
while kill -0 $pid_gups; do
    sleep 1;
done;

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
