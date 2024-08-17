#!/bin/bash

# pushd /home/midhul/hemem
# git checkout exp-icelake
# cd src
# make clean && make
# popd

for b in 0 5 10 15; do for i in 15; do sudo ./hemem.sh icx-eval-hemem-colloid-gups256-rw-app$i-bg$b 180 $i $b -- /home/midhul/colloid/apps/gups/gups256-rw $i; done; done;

for b in 0 5 10 15; do for i in 15; do sudo ./hemem.sh icx-eval-hemem-colloid-gups1024-rw-app$i-bg$b 180 $i $b -- /home/midhul/colloid/apps/gups/gups1024-rw $i; done; done;

for b in 0 5 10 15; do for i in 15; do sudo ./hemem.sh icx-eval-hemem-colloid-gups-rw-app$i-bg$b 180 $i $b -- /home/midhul/colloid/apps/gups/gups-rw $i; done; done;


# for b in 0 5 10 15 20 25; do for i in $(seq 5 5 $((30-$b))); do sudo ./hemem.sh icx-eval-hemem-colloid-gups256-rw-app$i-bg$b 180 $i $b -- /home/midhul/colloid/apps/gups/gups256-rw $i; done; done;

# for b in 0 5 10 15 20 25; do for i in $(seq 5 5 $((30-$b))); do sudo ./hemem.sh icx-eval-hemem-colloid-gups1024-rw-app$i-bg$b 180 $i $b -- /home/midhul/colloid/apps/gups/gups1024-rw $i; done; done;

# for b in 0 5 10 15 20 25; do for i in $(seq 5 5 $((30-$b))); do sudo ./hemem.sh icx-eval-hemem-colloid-gups-rw-app$i-bg$b 180 $i $b -- /home/midhul/colloid/apps/gups/gups-rw $i; done; done;

# pushd /home/midhul/hemem
# git checkout baseline-hemem-icelake
# cd src
# make clean && make
# popd

# for b in 0 5 10 15; do for i in 15; do sudo MIO_STATS="--stats_colloid --stats_colloid_cha --stats_colloid_wait 140" ./hemem.sh icx-eval-hemem-gups256-rw-app$i-bg$b 180 $i $b -- /home/midhul/colloid/apps/gups/gups256-rw $i; done; done;

# for b in 0 5 10 15; do for i in 15; do sudo MIO_STATS="--stats_colloid --stats_colloid_cha --stats_colloid_wait 140" ./hemem.sh icx-eval-hemem-gups1024-rw-app$i-bg$b 180 $i $b -- /home/midhul/colloid/apps/gups/gups1024-rw $i; done; done;

# for b in 0 5 10 15; do for i in 15; do sudo MIO_STATS="--stats_colloid --stats_colloid_cha --stats_colloid_wait 140" ./hemem.sh icx-eval-hemem-gups-rw-app$i-bg$b 180 $i $b -- /home/midhul/colloid/apps/gups/gups-rw $i; done; done;

# for b in 0 5 10 15 20 25; do for i in $(seq 5 5 $((30-$b))); do sudo ./hemem.sh icx-eval-hemem-gups-rw-app$i-bg$b 180 $i $b -- /home/midhul/colloid/apps/gups/gups-rw $i; done; done;



