#!/bin/bash

scripts_path="${BASH_SOURCE%/*}/../../scripts"
i=15 # no. of app cores

# paste <(echo "Intensity") <(echo "tpp") <(echo "tpp+colloid") | column -t
# for b in 0 5 10 15; do
#     paste <(echo "$(($b/5))x" ) <(python3 $scripts_path/collect_ts.py tpp-gups64-rw-app$i-bg$b gups | tail -n 30 | awk '{s += $1;} END {print (s/NR)*64*2/1e9;}') <(python3 $scripts_path/collect_ts.py tpp-colloid-gups64-rw-app$i-bg$b gups | tail -n 30 | awk '{s += $1;} END {print (s/NR)*64*2/1e9;}') |column -t;
# done;

printf "%-10s %-10s %-10s\n" "Intensity" "TPP" "TPP+colloid"

for b in 0 5 10 15; do
    tpp_output=$(python3 $scripts_path/collect_ts.py tpp-gups64-rw-app$i-bg$b gups | tail -n 30 | awk '{s += $1;} END {print (s/NR)*64*2/1e9;}')
    tpp_colloid_output=$(python3 $scripts_path/collect_ts.py tpp-colloid-gups64-rw-app$i-bg$b gups | tail -n 30 | awk '{s += $1;} END {print (s/NR)*64*2/1e9;}')
    
    printf "%-10s %-10s %-10s\n" "$(($b/5))x" "$tpp_output" "$tpp_colloid_output"
done