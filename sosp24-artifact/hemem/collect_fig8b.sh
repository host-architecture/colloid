#!/bin/bash

scripts_path="${BASH_SOURCE%/*}/../../scripts"
i=15 # no. of app cores

source $scripts_path/config.sh

printf "%-15s %-15s %-15s %-15s\n" "Intensity" "HeMem" "HeMem+colloid" "Perf. Improvement (%)"

for b in 0 5 10 15; do
    hemem_output=$(cat $stats_path/hemem-silo-ycsb-app15-bg$b.app.txt | grep -iv 'total' | awk '{print $1}')
    hemem_colloid_output=$(cat $stats_path/hemem-colloid-silo-ycsb-app15-bg$b.app.txt | grep -iv 'total' | awk '{print $1}')
    impr=$(awk -v num="$hemem_colloid_output" -v den="$hemem_output" 'BEGIN {print (num/den - 1.0)*100.0;}')
    printf "%-15s %-15s %-15s %-15s\n" "$(($b/5))x" "$hemem_output" "$hemem_colloid_output" "$impr"
done