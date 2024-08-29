#!/bin/bash

function resetme() {
    wrmsr -p 0 0x620 0x818; # Resent uncore frequency to default incase we exit in the middle
}

trap resetme EXIT

scripts_path="${BASH_SOURCE%/*}/../../scripts"
gups_path="${BASH_SOURCE%/*}/../../apps/gups"
duration=600
i=15 # no. of app cores
bg_cores=$(($1*5)) #background traffic cores (0x => 0, 1x => 5, 2x => 10, 3x => 15)

# TPP
echo "Running TPP"
for u in 0x70e 0x50a 0x408; do 
    wrmsr -p 0 0x620 $u; 
    echo "uncore freq register: $(sudo rdmsr -p 0 0x620)"; 
    for b in $bg_cores; do 
        ENABLE_THP="y" $scripts_path/linux.sh tpp-thp-unc$u-gups64-rw-app$i-bg$b $duration $i $b -- $gups_path/gups64-rw $i; 
    done; 
done; 
wrmsr -p 0 0x620 0x818;

# tpp+colloid
echo "Running tpp+colloid"
for u in 0x70e 0x50a 0x408; do 
    wrmsr -p 0 0x620 $u; 
    echo "uncore freq register: $(sudo rdmsr -p 0 0x620)"; 
    for b in $bg_cores; do 
        ENABLE_THP="y" $scripts_path/linux-colloid.sh tpp-thp-colloid-unc$u-gups64-rw-app$i-bg$b $duration $i $b -- $gups_path/gups64-rw $i; 
    done; 
done; 
wrmsr -p 0 0x620 0x818;