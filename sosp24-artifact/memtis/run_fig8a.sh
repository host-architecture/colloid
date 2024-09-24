#!/bin/bash

# GAPBS

scripts_path="${BASH_SOURCE%/*}/../../scripts"

source $scripts_path/config.sh

prefix="run3-memtis"
ns_arg=""
if [ -n "${MEMTIS_NS}" ]; then
    echo "Disabling page size determination";
    prefix="memtis-ns"
    ns_arg="-NS"
fi

for b in 0 5 10 15; do
    start_time=$(date +%s)
    $scripts_path/memtis.sh $prefix-gapbs-twitter-1to2-app15-bg$b 15 $b -- $memtis_path/memtis-userspace/scripts/run_bench.sh -B gapbs-pr -R 1:2 --cxl $ns_arg -V $prefix-gapbs-twitter-1to2-app15-bg$b
    end_time=$(date +%s)
    elapsed_time=$(($end_time - $start_time))
    echo "Took $elapsed_time seconds" >> $stats_path/memtis-gapbs-twitter-1to2-app15-bg$b.time.txt
done;

for b in 0 5 10 15; do
    start_time=$(date +%s)
    $scripts_path/memtis-colloid.sh $prefix-colloid-gapbs-twitter-1to2-app15-bg$b 15 $b -- $memtis_path/memtis-userspace/scripts/run_bench.sh -B gapbs-pr -R 1:2 --cxl $ns_arg -V $prefix-colloid-gapbs-twitter-1to2-app15-bg$b 
    end_time=$(date +%s)
    elapsed_time=$(($end_time - $start_time))
    echo "Took $elapsed_time seconds" >> $stats_path/memtis-colloid-gapbs-twitter-1to2-app15-bg$b.time.txt
done;


