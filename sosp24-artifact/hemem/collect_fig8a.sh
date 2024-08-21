#!/bin/bash

scripts_path="${BASH_SOURCE%/*}/../../scripts"
i=15 # no. of app cores

source $scripts_path/config.sh

printf "%-15s %-15s %-15s %-15s\n" "Intensity" "HeMem" "HeMem+colloid" "Perf. Improvement (%)"

for b in 0 5 10 15; do
    hemem_output=$(cat $stats_path/hemem-gapbs-twitter-1to2-app15-bg$b.app.txt | grep -i average | awk '{print $3}')
    hemem_colloid_output=$(cat $stats_path/hemem-colloid-gapbs-twitter-1to2-app15-bg$b.app.txt | grep -i average | awk '{print $3}')
    impr=$(awk -v num="$hemem_output" -v den="$hemem_colloid_output" 'BEGIN {print (num/den - 1.0)*100.0;}')
    printf "%-15s %-15s %-15s %-15s\n" "$(($b/5))x" "$hemem_output" "$hemem_colloid_output" "$impr"
done