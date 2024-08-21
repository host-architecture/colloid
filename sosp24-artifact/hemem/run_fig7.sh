#!/bin/bash

scripts_path="${BASH_SOURCE%/*}/../../scripts"
gups_path="${BASH_SOURCE%/*}/../../apps/gups"

# Fig 7a
echo "Running 7a HeMem"
MMAP_PRE_POPULATE=1 HEMEM_BASELINE="y" $scripts_path/hemem.sh hotsetmove-hemem-gups64-rw-app15-bg0 200 15 0 -- $gups_path/gups64-rw 15 move 100;
echo "Running 7a HeMem+colloid"
MMAP_PRE_POPULATE=1 $scripts_path/hemem.sh hotsetmove-hemem-colloid-gups64-rw-app15-bg0 200 15 0 -- $gups_path/gups64-rw 15 move 100;

# Fig 7b
echo "Running 7b HeMem"
MMAP_PRE_POPULATE=1 HEMEM_BASELINE="y" $scripts_path/hemem.sh hotsetmove-hemem-gups64-rw-app15-bg15 200 15 15 -- $gups_path/gups64-rw 15 move 100;
echo "Running 7b HeMem+colloid"
MMAP_PRE_POPULATE=1 $scripts_path/hemem.sh hotsetmove-hemem-colloid-gups64-rw-app15-bg15 200 15 15 -- $gups_path/gups64-rw 15 move 100;

# Fig 7c
echo "Running 7c HeMem"
DELAY_BG=100 MMAP_PRE_POPULATE=1 HEMEM_BASELINE="y" $scripts_path/hemem.sh dynbg-hemem-gups64-rw-app15-bg15 200 15 15 -- $gups_path/gups64-rw 15
echo "Running 7c HeMem+colloid"
DELAY_BG=100 MMAP_PRE_POPULATE=1 $scripts_path/hemem.sh dynbg-hemem-colloid-gups64-rw-app15-bg15 200 15 15 -- $gups_path/gups64-rw 15
