#!/bin/bash

# Make sure memory tiering is enabled
#TODO: Make sure to update bpf trace addresses

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
    echo "Cleaned up";
}

trap cleanup EXIT

cleanup;

# Make sure tiering is enabled
swapoff -a
echo 1 > /sys/kernel/mm/numa/demotion_enabled
echo 2 > /proc/sys/kernel/numa_balancing

# Run GUPS with varying percentage of hot set in local memory
for x in 0 0.2 0.4 0.6 0.8 1; do
    echo "Running $config-iso-x$x";
    $gups_path/$gups_workload $gups_cores manual $x distribute reset > $stats_path/$config-iso-x$x.gups.txt 2>&1 &
    pid_gups=$!;
    taskset -c 0 $record_path/record_stats > $stats_path/$config-iso-x$x.stats.txt 2>&1 &
    pid_stats=$!;
    bpftrace -e 'BEGIN {@start = nsecs;} interval:s:1 {printf("%ld, colloid_local_lat_gt_remote: %d, local: %lu, remote: %lu\n", (nsecs-@start)/1e9, *kaddr("colloid_local_lat_gt_remote"), *(0xffffffffc1a5b7d0), *(0xffffffffc1a5b7c0));}' > $stats_path/$config-iso-x$x.mon.txt 2>&1 &
    pid_bpf=$!;
    sleep $duration;
    killall record_stats;
    while kill -0 $pid_stats; do
        sleep 1;
    done;
    killall bpftrace;
    while kill -0 $pid_bpf; do
        sleep 1;
    done;
    killall $gups_workload;
    while kill -0 $pid_gups; do
        sleep 1;
    done;
done;


echo "Done";
