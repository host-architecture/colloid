#!/bin/bash

function resetme() {
    wrmsr -p 0 0x620 0x818; # Resent uncore frequency to default incase we exit in the middle
}

trap resetme EXIT

scripts_path="${BASH_SOURCE%/*}/../../scripts"
gups_path="${BASH_SOURCE%/*}/../../apps/gups"
duration=100
i=15 # no. of app cores
bg_cores=$(($1*5)) #background traffic cores (0x => 0, 1x => 5, 2x => 10, 3x => 15)

# HeMem
echo "Running HeMem"
for u in 0x70e 0x50a 0x408; do 
    wrmsr -p 0 0x620 $u; 
    echo "uncore freq register: $(sudo rdmsr -p 0 0x620)"; 
    for b in $bg_cores; do 
        MMAP_PRE_POPULATE=1 HEMEM_BASELINE="y" $scripts_path/hemem.sh hemem-unc$u-gups64-rw-app$i-bg$b $duration $i $b -- $gups_path/gups64-rw $i; 
    done; 
done; 
wrmsr -p 0 0x620 0x818;

# HeMem+colloid
echo "Running HeMem+colloid"
for u in 0x70e 0x50a 0x408; do 
    wrmsr -p 0 0x620 $u; 
    echo "uncore freq register: $(sudo rdmsr -p 0 0x620)"; 
    for b in $bg_cores; do 
        MMAP_PRE_POPULATE=1 $scripts_path/hemem.sh hemem-colloid-unc$u-gups64-rw-app$i-bg$b $duration $i $b -- $gups_path/gups64-rw $i; 
    done; 
done; 
wrmsr -p 0 0x620 0x818;