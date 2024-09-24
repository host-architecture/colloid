#!/bin/bash

function resetme() {
    wrmsr -p 0 0x620 0x818; # Resent uncore frequency to default incase we exit in the middle
}

trap resetme EXIT

scripts_path="${BASH_SOURCE%/*}/../../scripts"
gups_path="${BASH_SOURCE%/*}/../../apps/gups"
duration=120
i=15 # no. of app cores
# bg_cores=$(($1*5)) #background traffic cores (0x => 0, 1x => 5, 2x => 10, 3x => 15)
source $scripts_path/config.sh

prefix="run2-memtis"
ns_arg=""
if [ -n "${MEMTIS_NS}" ]; then
    echo "Disabling page size determination";
    prefix="memtis-ns"
    ns_arg="-NS"
fi

# MEMTIS
echo "Running MEMTIS"
for u in 0x70e 0x50a 0x408; do 
    wrmsr -p 0 0x620 $u; 
    echo "uncore freq register: $(sudo rdmsr -p 0 0x620)"; 
    for b in 0 5 10 15; do
        MEMTIS_GUPS_CORES=$i MEMTIS_GUPS_DURATION=$duration $scripts_path/memtis.sh $prefix-unc$u-gups64-rw-app$i-bg$b $i $b -- $memtis_path/memtis-userspace/scripts/run_bench.sh -B gups -R gups64-rw --cxl $ns_arg -V $prefix-unc$u-gups64-rw-app$i-bg$b
    done; 
done; 
wrmsr -p 0 0x620 0x818;

# HeMem+colloid
echo "Running MEMTIS+colloid"
for u in 0x70e 0x50a 0x408; do 
    wrmsr -p 0 0x620 $u; 
    echo "uncore freq register: $(sudo rdmsr -p 0 0x620)"; 
    for b in 0 5 10 15; do 
        MEMTIS_GUPS_CORES=$i MEMTIS_GUPS_DURATION=$duration $scripts_path/memtis-colloid.sh $prefix-colloid-unc$u-gups64-rw-app$i-bg$b $i $b -- $memtis_path/memtis-userspace/scripts/run_bench.sh -B gups -R gups64-rw --cxl $ns_arg -V $prefix-colloid-unc$u-gups64-rw-app$i-bg$b 
    done; 
done; 
wrmsr -p 0 0x620 0x818;
