#!/bin/bash

# GAPBS

scripts_path="${BASH_SOURCE%/*}/../../scripts"

source $scripts_path/config.sh

for b in 0 5 10 15; do
    start_time=$(date +%s)
    DRAMSIZE=4404019200 $scripts_path/linux.sh tpp-gapbs-twitter-1to2-app15-bg$b 0 15 $b -- taskset -c 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29 $gapbs_path/pr -f $gapbs_path/benchmark/graphs/twitter.sg -i1000 -t1e-4 -n20;
    end_time=$(date +%s)
    elapsed_time=$(($end_time - $start_time))
    echo "Took $elapsed_time seconds" >> $stats_path/tpp-gapbs-twitter-1to2-app15-bg$b.time.txt
done;

for b in 0 5 10 15; do
    start_time=$(date +%s)
    DRAMSIZE=4404019200 $scripts_path/linux-colloid.sh tpp-colloid-gapbs-twitter-1to2-app15-bg$b 0 15 $b -- taskset -c 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29 $gapbs_path/pr -f $gapbs_path/benchmark/graphs/twitter.sg -i1000 -t1e-4 -n20; 
    end_time=$(date +%s)
    elapsed_time=$(($end_time - $start_time))
    echo "Took $elapsed_time seconds" >> $stats_path/tpp-colloid-gapbs-twitter-1to2-app15-bg$b.time.txt
done;


