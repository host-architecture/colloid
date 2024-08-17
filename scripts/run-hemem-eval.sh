#!/bin/bash

pushd /home/midhul/hemem
git checkout exp-icelake
cd src
make clean && make
popd


#for b in 0 5 10 15 20 25; do for i in $(seq 5 5 $((30-$b))); do sudo ./hemem.sh icx-eval-hemem-colloid-gups64-r-app$i-bg$b 180 $i $b -- /home/midhul/colloid/apps/gups/gups64-r $i; done; done;

#for b in 0 5 10 15 20 25; do for i in $(seq 5 5 $((30-$b))); do sudo ./hemem.sh icx-eval-hemem-colloid-gups64-2to1-app$i-bg$b 180 $i $b -- /home/midhul/colloid/apps/gups/gups64-2to1 $i; done; done;

for b in 0 5 10 15 20 25; do for i in $(seq 5 5 $((30-$b))); do sudo ./hemem.sh icx-eval-hemem-colloid-gups64-3to1-app$i-bg$b 180 $i $b -- /home/midhul/colloid/apps/gups/gups64-3to1 $i; done; done;

pushd /home/midhul/hemem
git checkout baseline-hemem-icelake
cd src
make clean && make
popd

for b in 0 5 10 15 20 25; do for i in $(seq 5 5 $((30-$b))); do sudo MIO_STATS="--stats_colloid --stats_colloid_cha --stats_colloid_wait 140" ./hemem.sh icx-eval-hemem-gups64-r-app$i-bg$b 180 $i $b -- /home/midhul/colloid/apps/gups/gups64-r $i; done; done;

for b in 0 5 10 15 20 25; do for i in $(seq 5 5 $((30-$b))); do sudo MIO_STATS="--stats_colloid --stats_colloid_cha --stats_colloid_wait 140" ./hemem.sh icx-eval-hemem-gups64-2to1-app$i-bg$b 180 $i $b -- /home/midhul/colloid/apps/gups/gups64-2to1 $i; done; done;

for b in 0 5 10 15 20 25; do for i in $(seq 5 5 $((30-$b))); do sudo MIO_STATS="--stats_colloid --stats_colloid_cha --stats_colloid_wait 140" ./hemem.sh icx-eval-hemem-gups64-3to1-app$i-bg$b 180 $i $b -- /home/midhul/colloid/apps/gups/gups64-3to1 $i; done; done;



