#!/bin/bash

scripts_path="${BASH_SOURCE%/*}/../../scripts"
i=15 # no. of app cores

source $scripts_path/config.sh

printf "%-15s %-15s %-15s %-15s\n" "Intensity" "tpp" "tpp+colloid" "Perf. Improvement (%)"

for b in 0 5 10 15; do
    tpp_output=$(cat $stats_path/tpp-cachelib-hememkv-app15-bg$b.app.txt | grep -i "get       :" | awk '{print $3}' | tr -d '/,s')
    tpp_colloid_output=$(cat $stats_path/tpp-colloid-cachelib-hememkv-app15-bg$b.app.txt | grep -i "get       :" | awk '{print $3}' | tr -d '/,s')
    impr=$(awk -v num="$tpp_colloid_output" -v den="$tpp_output" 'BEGIN {print (num/den - 1.0)*100.0;}')
    printf "%-15s %-15s %-15s %-15s\n" "$(($b/5))x" "$tpp_output" "$tpp_colloid_output" "$impr"
done