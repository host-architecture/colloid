#!/bin/bash

scripts_path="${BASH_SOURCE%/*}/../../scripts"
gups_path="${BASH_SOURCE%/*}/../../apps/gups"
duration=120
i=15 # no. of app cores
# bg_cores=$(($1*5)) #background traffic cores (0x => 0, 1x => 5, 2x => 10, 3x => 15)
source $scripts_path/config.sh

prefix="memtis"
ns_arg=""
if [ -n "${MEMTIS_NS}" ]; then
    echo "Disabling page size determination";
    prefix="memtis-ns"
    ns_arg="-NS"
fi

# MEMTIS
echo "Running MEMTIS"
for sz in 256 1024 ""; do
#for sz in ""; do
    for b in 0 5 10 15; do
        MEMTIS_GUPS_CORES=$i MEMTIS_GUPS_DURATION=$duration $scripts_path/memtis.sh $prefix-gups$sz-rw-app$i-bg$b $i $b -- $memtis_path/memtis-userspace/scripts/run_bench.sh -B gups -R gups$sz-rw --cxl $ns_arg -V $prefix-gups$sz-rw-app$i-bg$b
    done; 
done;

# HeMem+colloid
echo "Running MEMTIS+colloid"
for sz in 256 1024 ""; do 
#for sz in ""; do
    for b in 0 5 10 15; do
        MEMTIS_GUPS_CORES=$i MEMTIS_GUPS_DURATION=$duration $scripts_path/memtis-colloid.sh $prefix-colloid-gups$sz-rw-app$i-bg$b $i $b -- $memtis_path/memtis-userspace/scripts/run_bench.sh -B gups -R gups$sz-rw --cxl $ns_arg -V $prefix-colloid-gups$sz-rw-app$i-bg$b
    done; 
done;
