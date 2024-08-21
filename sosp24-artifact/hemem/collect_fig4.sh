#!/bin/bash

scripts_path="${BASH_SOURCE%/*}/../../scripts"
i=15 # no. of app cores

# paste <(echo "Intensity") <(echo "HeMem") <(echo "HeMem+colloid") | column -t
# for b in 0 5 10 15; do
#     paste <(echo "$(($b/5))x" ) <(python3 $scripts_path/collect_ts.py hemem-gups64-rw-app$i-bg$b gups | tail -n 30 | awk '{s += $1;} END {print (s/NR)*64*2/1e9;}') <(python3 $scripts_path/collect_ts.py hemem-colloid-gups64-rw-app$i-bg$b gups | tail -n 30 | awk '{s += $1;} END {print (s/NR)*64*2/1e9;}') |column -t;
# done;

printf "%-10s %-10s %-10s\n" "Intensity" "HeMem" "HeMem+colloid"

for b in 0 5 10 15; do
    hemem_output=$(python3 $scripts_path/collect_ts.py hemem-gups64-rw-app$i-bg$b gups | tail -n 30 | awk '{s += $1;} END {print (s/NR)*64*2/1e9;}')
    hemem_colloid_output=$(python3 $scripts_path/collect_ts.py hemem-colloid-gups64-rw-app$i-bg$b gups | tail -n 30 | awk '{s += $1;} END {print (s/NR)*64*2/1e9;}')
    
    printf "%-10s %-10s %-10s\n" "$(($b/5))x" "$hemem_output" "$hemem_colloid_output"
done