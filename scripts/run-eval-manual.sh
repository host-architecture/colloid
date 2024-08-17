#!/bin/bash

for b in 0 5 10 15; do for i in 15; do sudo MIO_STATS="--stats_colloid --stats_colloid_cha --stats_colloid_wait 18" ./run-manual-icelake.sh icx-eval-manual-gups64-r-app$i-bg$b gups64-r $i $b; done; done;
for b in 0 5 10 15; do for i in 15; do sudo MIO_STATS="--stats_colloid --stats_colloid_cha --stats_colloid_wait 18" ./run-manual-icelake.sh icx-eval-manual-gups64-3to1-app$i-bg$b gups64-3to1 $i $b; done; done;
for b in 0 5 10 15; do for i in 15; do sudo MIO_STATS="--stats_colloid --stats_colloid_cha --stats_colloid_wait 18" ./run-manual-icelake.sh icx-eval-manual-gups64-2to1-app$i-bg$b gups64-2to1 $i $b; done; done;

for b in 0 5 10 15; do for i in 15; do sudo MIO_STATS="--stats_colloid --stats_colloid_cha --stats_colloid_wait 18" ./run-manual-icelake.sh icx-eval-manual-gups256-rw-app$i-bg$b gups256-rw $i $b; done; done;
for b in 0 5 10 15; do for i in 15; do sudo MIO_STATS="--stats_colloid --stats_colloid_cha --stats_colloid_wait 18" ./run-manual-icelake.sh icx-eval-manual-gups1024-rw-app$i-bg$b gups1024-rw $i $b; done; done;
for b in 0 5 10 15; do for i in 15; do sudo MIO_STATS="--stats_colloid --stats_colloid_cha --stats_colloid_wait 18" ./run-manual-icelake.sh icx-eval-manual-gups-rw-app$i-bg$b gups-rw $i $b; done; done;

