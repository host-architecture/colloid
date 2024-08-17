#!/bin/bash


config=$1
gups_path=/home/midhul/colloid/apps/gups
mio_path=/home/midhul/mio
record_path=/home/midhul/colloid/colloid-stats
stats_path=/home/midhul/membw-eval
memeater_path=/home/midhul/colloid/tpp/memeater
local_numa=1
local_size=32768
gups_workload=$2
gups_cores=$3
stream_num_cores=$4
all_core_list="1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45,47,49,51,53,55,57,59"
stream_core_list=$(echo "$all_core_list" | cut -d ',' -f $((gups_cores + 1))-)
echo $stream_core_list
duration=45

mio_opts=( $MIO_STATS )

function cleanup() {
    killall gups-r;
    killall gups-rw;
    killall gups64-rw;
    killall record_stats;
    killall stream;
    killall python3;
    rmmod memeater.ko;
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

# Set local memory capacity
insmod $memeater_path/memeater.ko sizeMiB=$(numastat -m | grep MemFree | awk -v nidx=$local_numa -v sz=$local_size -v b=$stream_num_cores '{print int($(2+nidx)-sz-b*512)}');
echo "Local mem size"
echo $(numastat -m | grep MemFree)

# Run GUPS with varying percentage of hot set in local memory + background traffic
for x in 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1; do
#for x in 1.0; do
    echo "Running $config-bg-x$x";
    pid_mio=-1;
    if [ $stream_num_cores -gt 0 ]; then
    	PYTHONPATH=$PYTHONPATH:$mio_path python3 -m mio $config-x$x-mio --ant_cpus $stream_core_list --ant_num_cores $stream_num_cores --ant_mem_numa 1 --ant stream --ant_writefrac 50 --ant_inst_size 64 --ant_duration 10000 "${mio_opts[@]}" &
    	pid_mio=$!;
    elif [ "${#mio_opts[@]}" -gt 0 ]; then
        PYTHONPATH=$PYTHONPATH:$mio_path python3 -m mio $config-x$x-mio "${mio_opts[@]}" &
    	pid_mio=$!;
    fi
    sleep 3;

    echo $(numastat -m | grep MemFree)
    echo $(numastat -m | grep MemFree) > $stats_path/$config-x$x.memfree.txt

    numactl --membind 0 $gups_path/$gups_workload $gups_cores manual $x distribute > $stats_path/$config-x$x.app.txt 2>&1 &
    pid_gups=$!;
    #taskset -c 0 $record_path/record_stats > $stats_path/$config-bg-x$x.stats.txt 2>&1 &
    #pid_stats=$!;
    sleep $duration;
    #killall record_stats;
    #while kill -0 $pid_stats; do
     #   sleep 1;
    #done;
    killall $gups_workload;
    while kill -0 $pid_gups; do
        sleep 1;
    done;
    if [ $stream_num_cores -gt 0 ] || [ "${#mio_opts[@]}" -gt 0 ]; then
    	killall python3;
    	killall stream;
	sleep 1;
   fi
done;

rmmod memeater.ko;

echo "Done";
