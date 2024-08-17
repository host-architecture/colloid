#!/bin/bash

# For hugepages make sure to reserve
# echo 15900 | sudo tee /sys/devices/system/node/node3/hugepages/hugepages-2048kB/nr_hugepages
# echo 46080 | sudo tee /sys/devices/system/node/node2/hugepages/hugepages-2048kB/nr_hugepages
# TODO: GUPS_HUGEPAGES is currently enabled
# TODO: Remember to reduce reserved huge pages when running background traffic

config=$1
gups_path=/home/midhul/colloid/apps/gups
mio_path=/home/midhul/mio-colloid
record_path=/home/midhul/colloid/colloid-stats
stats_path=/home/midhul/membw-eval
gups_workload=$2
gups_cores=4
stream_num_cores=3
stream_core_list="19,23,27,31"
duration=120

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

# Make sure tiering is disabled
swapoff -a
echo 0 > /sys/kernel/mm/numa/demotion_enabled
echo 0 > /proc/sys/kernel/numa_balancing

# Run GUPS with varying percentage of hot set in local memory
# for x in 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1; do
#     echo "Running $config-iso-x$x";
#     GUPS_HUGEPAGES=1 $gups_path/$gups_workload $gups_cores manual $x distribute > $stats_path/$config-iso-x$x.gups.txt 2>&1 &
#     pid_gups=$!;
#     taskset -c 0 $record_path/record_stats > $stats_path/$config-iso-x$x.stats.txt 2>&1 &
#     pid_stats=$!;
#     sleep $duration;
#     killall record_stats;
#     while kill -0 $pid_stats; do
#         sleep 1;
#     done;
#     killall $gups_workload;
#     while kill -0 $pid_gups; do
#         sleep 1;
#     done;
# done;

# Run GUPS with varying percentage of hot set in local memory + background traffic
for x in 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1; do
# for x in 0.5; do
    echo "Running $config-bg-x$x";
    PYTHONPATH=$PYTHONPATH:$mio_path python3 -m mio $config-bg-x$x --ant_cpus $stream_core_list --ant_num_cores $stream_num_cores --ant_mem_numa 3 --ant stream --ant_writefrac 50 --ant_inst_size 64 --ant_duration $(($duration+20)) &
    pid_mio=$!;
    sleep 10;
    GUPS_HUGEPAGES=1 $gups_path/$gups_workload $gups_cores manual $x distribute > $stats_path/$config-bg-x$x.gups.txt 2>&1 &
    pid_gups=$!;
    taskset -c 0 $record_path/record_stats > $stats_path/$config-bg-x$x.stats.txt 2>&1 &
    pid_stats=$!;
    sleep $duration;
    killall record_stats;
    while kill -0 $pid_stats; do
        sleep 1;
    done;
    killall $gups_workload;
    while kill -0 $pid_gups; do
        sleep 1;
    done;
    wait $pid_mio;
done;

echo "Done";
