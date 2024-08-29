#!/bin/bash

# CacheLib

scripts_path="${BASH_SOURCE%/*}/../../scripts"
workloads_path="${BASH_SOURCE%/*}/../../workloads"

source $scripts_path/config.sh

echo "Running HeMem"
MMAP_PRE_POPULATE=1 HEMEM_BASELINE="y" MIO_STATS="--ant_vary_load $workloads_path/cachelib/bg/vary-pulse10s.txt" $scripts_path/hemem.sh hemem-cachelib-hememkv-app15-varybg-pulse10s-100ms 0 15 15 -- taskset -c 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29 $cachelib_path/opt/cachelib/bin/cachebench --json_test_config $workloads_path/cachelib/hememkv/config-long.json --progress 100 --timeout_seconds 260;

echo "Running HeMem+colloid"
MMAP_PRE_POPULATE=1 MIO_STATS="--ant_vary_load $workloads_path/cachelib/bg/vary-pulse10s.txt" $scripts_path/hemem.sh hemem-colloid-cachelib-hememkv-app15-varybg-pulse10s-100ms 0 15 15 -- taskset -c 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29 $cachelib_path/opt/cachelib/bin/cachebench --json_test_config $workloads_path/cachelib/hememkv/config-long.json --progress 100 --timeout_seconds 260;


