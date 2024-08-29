#!/bin/bash

# CacheLib

scripts_path="${BASH_SOURCE%/*}/../../scripts"
workloads_path="${BASH_SOURCE%/*}/../../workloads"

source $scripts_path/config.sh

for b in 0 5 10 15; do
    start_time=$(date +%s)
    $scripts_path/linux.sh tpp-cachelib-hememkv-app15-bg$b 0 15 $b -- taskset -c 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29 $cachelib_path/opt/cachelib/bin/cachebench --json_test_config $workloads_path/cachelib/hememkv/config.json --progress 1;
    end_time=$(date +%s)
    elapsed_time=$(($end_time - $start_time))
    echo "Took $elapsed_time seconds" >> $stats_path/tpp-cachelib-hememkv-app15-bg$b.time.txt
done;

for b in 0 5 10 15; do
    start_time=$(date +%s)
    $scripts_path/linux-colloid.sh tpp-colloid-cachelib-hememkv-app15-bg$b 0 15 $b -- taskset -c 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29 $cachelib_path/opt/cachelib/bin/cachebench --json_test_config $workloads_path/cachelib/hememkv/config.json --progress 1;
    end_time=$(date +%s)
    elapsed_time=$(($end_time - $start_time))
    echo "Took $elapsed_time seconds" >> $stats_path/tpp-colloid-cachelib-hememkv-app15-bg$b.time.txt
done;


