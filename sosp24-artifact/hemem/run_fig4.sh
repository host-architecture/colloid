#!/bin/bash

scripts_path="${BASH_SOURCE%/*}/../../scripts"
gups_path="${BASH_SOURCE%/*}/../../apps/gups"
duration=120
i=15 # no. of app cores

prefix="hemem"
if [ -n "$PREFIX" ]; then
	prefix="$PREFIX"
	echo "prefix: $prefix";
fi

# HeMem
echo "Running HeMem"
for b in 0 5 10 15; 
    do MIO_STATS="--stats_colloid_mbm --stats_colloid_wait 90" MMAP_PRE_POPULATE=1 HEMEM_BASELINE="y" $scripts_path/hemem.sh $prefix-gups64-rw-app$i-bg$b $duration $i $b -- $gups_path/gups64-rw $i; 
done;

# HeMem+colloid
echo "Running HeMem+colloid"
for b in 0 5 10 15; 
    do MIO_STATS="--stats_colloid_mbm --stats_colloid_wait 90" MMAP_PRE_POPULATE=1 $scripts_path/hemem.sh $prefix-colloid-gups64-rw-app$i-bg$b $duration $i $b -- $gups_path/gups64-rw $i; 
done;
