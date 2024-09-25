#!/bin/bash

scripts_path="${BASH_SOURCE%/*}/../../scripts"
gups_path="${BASH_SOURCE%/*}/../../apps/gups"
duration=180
i=15 # no. of app cores

source $scripts_path/config.sh

prefix="mbm4-memtis"
if [ -n "$PREFIX" ]; then
	prefix="$PREFIX"
	echo "prefix: $prefix";
fi

ns_arg=""
if [ -n "${MEMTIS_NS}" ]; then
    echo "Disabling page size determination";
    prefix="memtis-ns"
    ns_arg="-NS"
fi


# memtis
echo "Running memtis"
for b in 0 5 10 15; 
    do MIO_STATS="--stats_colloid_mbm --stats_colloid_wait 130" MEMTIS_GUPS_CORES=$i MEMTIS_GUPS_DURATION=$duration $scripts_path/memtis.sh $prefix-gups64-rw-app$i-bg$b $i $b -- $memtis_path/memtis-userspace/scripts/run_bench.sh -B gups -R gups64-rw --cxl $ns_arg -V $prefix-gups64-rw-app15-bg$b
done;

# memtis+colloid
echo "Running memtis+colloid"
for b in 0 5 10 15; 
    do MIO_STATS="--stats_colloid_mbm --stats_colloid_wait 130" MEMTIS_GUPS_CORES=$i MEMTIS_GUPS_DURATION=$duration $scripts_path/memtis-colloid.sh $prefix-colloid-gups64-rw-app$i-bg$b $i $b -- $memtis_path/memtis-userspace/scripts/run_bench.sh -B gups -R gups64-rw --cxl $ns_arg -V $prefix-colloid-gups64-rw-app15-bg$b
done;
