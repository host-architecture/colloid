#!/bin/bash

# TODO: Make sure to switch to gcc version 8 for compiling HeMem kernel and HeMem
# Make sure /dev/dax devices are setup and HeMem + Hoard libraries are compiled
# TODO: Make sure to run run_perf.sh script from hemem directory in background
# Dump of command lines from example run
# sudo LD_LIBRARY_PATH=/home/midhul/hemem/src:/home/midhul/hemem/Hoard/src LD_PRELOAD=/home/midhul/hemem/src/libhemem.so ./gups-r 4
# sudo python3 -m mio ezzz --ant_cpus 19,23,27 --ant_num_cores 3 --ant_mem_numa 3 --ant stream --ant_writefrac 50 --ant_inst_size 64 --ant_duration 10000
# sudo ./run_perf.sh

config=$1
# gups_path=/home/midhul/colloid/apps/gups
mio_path=/home/midhul/mio
record_path=/home/midhul/colloid/colloid-stats
stats_path=/home/midhul/membw-eval
hemem_colloid_path="/home/midhul/colloid/hemem"
hemem_baseline_path="/home/midhul/hemem"
hemem_path=$hemem_colloid_path
if [ -n "${HEMEM_BASELINE}" ]; then
    echo "Baseline HeMem";
    hemem_path=$hemem_baseline_path
fi

lib_path="$hemem_path/src:$hemem_path/Hoard/src"
hemem_lib="$hemem_path/src/libhemem.so"
perfsh_path="$hemem_path/run_perf.sh"
# gups_workload=$2
# gups_cores=4
# stream_num_cores=3
# Duration value of 0 implies run app to completion
duration=$2
app_cores=$3
bg_cores=$4

all_core_list="1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45,47,49,51,53,55,57,59"
bg_core_list=$(echo "$all_core_list" | cut -d ',' -f $((app_cores + 1))-)
#echo $bg_core_list

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
        kill -9 $pid > /dev/null 2>&1;
    done;
    killall perf > /dev/null 2>&1;
    killall python3 > /dev/null 2>&1;
    killall stream > /dev/null 2>&1;
    echo "Cleaned up";
}

trap cleanup EXIT

cleanup;

# Make sure swap is disabled
swapoff -a

# run perf script
$perfsh_path &
pid_perf=$!;
all_pids+=($pid_perf);
sleep 3;

mio_opts=( $MIO_STATS )
delay_bg=0
if [ -z "${DELAY_BG}" ]; then
    delay_bg=0;
else
    echo "delay bg: ${DELAY_BG}"; 
    delay_bg=$DELAY_BG;
fi

if [ $delay_bg -eq 0 ]; then
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
fi

# Start CPU usage monitoring with sar
sar_logfile="$stats_path/$config.sar.txt"
sar -u -P ALL 1 > $sar_logfile 2>&1 &
pid_sar=$!;
all_pids+=($pid_sar);

# run actual app
echo "Running $config"
LD_LIBRARY_PATH=$lib_path LD_PRELOAD=$hemem_lib "${args_after_double_dash[@]}" > $stats_path/$config.app.txt 2> $stats_path/$config.hemem.txt &
pid_app=$!;
all_pids+=($pid_app);

if [ $delay_bg -gt 0 ] && [ $bg_cores -gt 0 ]; then
    sleep $delay_bg;
    echo "Running bg traffic on $bg_cores"
    PYTHONPATH=$PYTHONPATH:$mio_path python3 -m mio $config-mio --ant_cpus $bg_core_list --ant_num_cores $bg_cores --ant_mem_numa 1 --ant stream --ant_writefrac 50 --ant_inst_size 64 --ant_duration 10000 "${mio_opts[@]}" &
    pid_mio=$!;
    all_pids+=($pid_mio);
    if [ $duration -gt 0 ]; then
        sleep $(($duration-$delay_bg));
    fi
else
    if [ $duration -gt 0 ]; then
        sleep $duration;
    fi
fi

if [ $duration -gt 0 ]; then
    kill $pid_app > /dev/null 2>&1;
    while kill -0 $pid_app > /dev/null 2>&1; do
        sleep 1;
    done;
else
    wait $pid_app;
fi

# Stop sar monitoring
kill $pid_sar > /dev/null 2>&1;
while kill -0 $pid_sar > /dev/null 2>&1; do
    sleep 1;
done;
killall sar > /dev/null 2>&1;

head -n -1 /tmp/hemem-colloid.log > $stats_path/$config.hemem-colloid.log

if [ $bg_cores -gt 0 ] || [ "${#mio_opts[@]}" -gt 0 ]; then
	kill $pid_mio > /dev/null 2>&1;
	while kill -0 $pid_mio > /dev/null 2>&1; do
    		sleep 1;
	done;
	killall python3 > /dev/null 2>&1;
	killall stream > /dev/null 2>&1;
fi

kill $pid_perf > /dev/null 2>&1;
while kill -0 $pid_perf > /dev/null 2>&1; do
    sleep 1;
done;
killall perf > /dev/null 2>&1;



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
