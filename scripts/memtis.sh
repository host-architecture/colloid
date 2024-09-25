#!/bin/bash

config=$1
# gups_path=/home/midhul/colloid/apps/gups
mio_path=/home/midhul/mio
record_path=/home/midhul/colloid/colloid-stats
stats_path=/home/midhul/membw-eval
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
    echo "Cleaned up";
}

trap cleanup EXIT

cleanup;

# Make sure swap is disabled
swapoff -a
# Disable colloid
echo "disabled" > /sys/kernel/mm/htmm/htmm_colloid

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
