#!/bin/bash

scripts_path="${BASH_SOURCE%/*}/../../scripts"
gups_path="${BASH_SOURCE%/*}/../../apps/gups"
workloads_path="${BASH_SOURCE%/*}/../../workloads"

source $scripts_path/config.sh

prefix="run2-memtis"
ns_arg=""
if [ -n "${MEMTIS_NS}" ]; then
    echo "Disabling page size determination";
    prefix="memtis-ns"
    ns_arg="-NS"
fi

# Fig 7a
echo "Running 7a memtis"
MEMTIS_GUPS_CORES=15 MEMTIS_GUPS_DURATION=200 MEMTIS_GUPS_MOVE=100 $scripts_path/memtis.sh hotsetmove-$prefix-gups64-rw-app15-bg0 15 0 -- $memtis_path/memtis-userspace/scripts/run_bench.sh -B gups -R gups64-rw --cxl $ns_arg -V hotsetmove-$prefix-gups64-rw-app15-bg0
#echo "Running 7a memtis+colloid"
MEMTIS_GUPS_CORES=15 MEMTIS_GUPS_DURATION=200 MEMTIS_GUPS_MOVE=100 $scripts_path/memtis-colloid.sh hotsetmove-$prefix-colloid-gups64-rw-app15-bg0 15 0 -- $memtis_path/memtis-userspace/scripts/run_bench.sh -B gups -R gups64-rw --cxl $ns_arg -V hotsetmove-$prefix-colloid-gups64-rw-app15-bg0

# Fig 7b
echo "Running 7b memtis"
MEMTIS_GUPS_CORES=15 MEMTIS_GUPS_DURATION=200 MEMTIS_GUPS_MOVE=100 $scripts_path/memtis.sh hotsetmove-$prefix-gups64-rw-app15-bg15 15 15 -- $memtis_path/memtis-userspace/scripts/run_bench.sh -B gups -R gups64-rw --cxl $ns_arg -V hotsetmove-$prefix-gups64-rw-app15-bg15
echo "Running 7b memtis+colloid"
MEMTIS_GUPS_CORES=15 MEMTIS_GUPS_DURATION=200 MEMTIS_GUPS_MOVE=100 $scripts_path/memtis-colloid.sh hotsetmove-$prefix-colloid-gups64-rw-app15-bg15 15 15 -- $memtis_path/memtis-userspace/scripts/run_bench.sh -B gups -R gups64-rw --cxl $ns_arg -V hotsetmove-$prefix-colloid-gups64-rw-app15-bg15

# Fig 7c
echo "Running 7c memtis"
MEMTIS_GUPS_CORES=15 MEMTIS_GUPS_DURATION=200 MIO_STATS="--ant_vary_load $workloads_path/delaybg100.txt" $scripts_path/memtis.sh dynbg-$prefix-gups64-rw-app15-bg15 15 15 -- $memtis_path/memtis-userspace/scripts/run_bench.sh -B gups -R gups64-rw --cxl $ns_arg -V dynbg-$prefix-gups64-rw-app15-bg15
echo "Running 7c memtis+colloid"
MEMTIS_GUPS_CORES=15 MEMTIS_GUPS_DURATION=200 MIO_STATS="--ant_vary_load $workloads_path/delaybg100.txt" $scripts_path/memtis-colloid.sh dynbg-$prefix-colloid-gups64-rw-app15-bg15 15 15 -- $memtis_path/memtis-userspace/scripts/run_bench.sh -B gups -R gups64-rw --cxl $ns_arg -V dynbg-$prefix-colloid-gups64-rw-app15-bg15
