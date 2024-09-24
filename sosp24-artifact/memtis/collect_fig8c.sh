#!/bin/bash

scripts_path="${BASH_SOURCE%/*}/../../scripts"
i=15 # no. of app cores

source $scripts_path/config.sh

results_path=$memtis_path/memtis-userspace/results/cachelib

prefix="run2-memtis"

printf "%-15s %-15s %-15s %-15s\n" "Intensity" "memtis" "memtis+colloid" "Perf. Improvement (%)"

for b in 0 5 10 15; do
    memtis_output=$(cat $results_path/$prefix-cachelib-hememkv-app15-bg$b/output.log | grep -i "get       :" | awk '{print $3}' | tr -d '/,s')
    memtis_colloid_output=$(cat $results_path/$prefix-colloid-cachelib-hememkv-app15-bg$b/output.log | grep -i "get       :" | awk '{print $3}' | tr -d '/,s')
    impr=$(awk -v num="$memtis_colloid_output" -v den="$memtis_output" 'BEGIN {print (num/den - 1.0)*100.0;}')
    printf "%-15s %-15s %-15s %-15s\n" "$(($b/5))x" "$memtis_output" "$memtis_colloid_output" "$impr"
done
