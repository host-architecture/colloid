#!/bin/bash

scripts_path="${BASH_SOURCE%/*}/../../scripts"
gups_path="${BASH_SOURCE%/*}/../../apps/gups"

# Run simple test with HeMem+colloid
# The below runs GUPS workload on 15 cores for 60 seconds
sudo $scripts_path/hemem.sh test-hemem-colloid 60 15 0 -- $gups_path/gups64-rw 15

