#!/bin/bash

# Silo

scripts_path="${BASH_SOURCE%/*}/../../scripts"

source $scripts_path/config.sh

for b in 0 5 10 15; do
    start_time=$(date +%s)
    DRAMSIZE=20761804800 HEMEM_BASELINE="y" $scripts_path/hemem.sh hemem-silo-ycsb-app15-bg$b 0 15 $b -- taskset -c 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29 $silo_path/out-perf.masstree/benchmarks/dbtest --verbose --bench ycsb --num-threads 15 --scale-factor 400005 --ops-per-worker=100000000 --slow-exit --numa-memory 60G;
    end_time=$(date +%s)
    elapsed_time=$(($end_time - $start_time))
    echo "Took $elapsed_time seconds" >> $stats_path/hemem-silo-ycsb-app15-bg$b.time.txt
done;

for b in 0 5 10 15; do
    start_time=$(date +%s)
    DRAMSIZE=20761804800 $scripts_path/hemem.sh hemem-colloid-silo-ycsb-app15-bg$b 0 15 $b -- taskset -c 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29 $silo_path/out-perf.masstree/benchmarks/dbtest --verbose --bench ycsb --num-threads 15 --scale-factor 400005 --ops-per-worker=100000000 --slow-exit --numa-memory 60G;
    end_time=$(date +%s)
    elapsed_time=$(($end_time - $start_time))
    echo "Took $elapsed_time seconds" >> $stats_path/hemem-colloid-silo-ycsb-app15-bg$b.time.txt
done;


