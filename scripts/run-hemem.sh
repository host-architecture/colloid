#!/bin/bash

# TODO: Make sure to switch to gcc version 8 for compiling HeMem kernel and HeMem
# Make sure /dev/dax devices are setup and HeMem + Hoard libraries are compiled
# TODO: Make sure to run run_perf.sh script from hemem directory in background
# Dump of command lines from example run
# sudo LD_LIBRARY_PATH=/home/midhul/hemem/src:/home/midhul/hemem/Hoard/src LD_PRELOAD=/home/midhul/hemem/src/libhemem.so ./gups-r 4
# sudo python3 -m mio ezzz --ant_cpus 19,23,27 --ant_num_cores 3 --ant_mem_numa 3 --ant stream --ant_writefrac 50 --ant_inst_size 64 --ant_duration 10000
# sudo ./run_perf.sh

config=$1
gups_path=/home/midhul/colloid/apps/gups
mio_path=/home/midhul/mio-colloid
record_path=/home/midhul/colloid/colloid-stats
stats_path=/home/midhul/membw-eval
lib_path="/home/midhul/hemem/src:/home/midhul/hemem/Hoard/src"
hemem_lib="/home/midhul/hemem/src/libhemem.so"
gups_workload=$2
gups_cores=4
stream_num_cores=3
stream_core_list="19,23,27,31"
duration=500

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

# Make sure swap is disabled
swapoff -a

# Run GUPS in isolation
echo "Running $config-iso"
LD_LIBRARY_PATH=$lib_path LD_PRELOAD=$hemem_lib $gups_path/$gups_workload $gups_cores > $stats_path/$config-iso.gups.txt 2> $stats_path/$config-iso.hemem.txt &
pid_gups=$!;
taskset -c 0 $record_path/record_stats > $stats_path/$config-iso.stats.txt 2>&1 &
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
