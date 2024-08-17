#!/bin/bash

#for b in 0 5 10 15 20 25; do
#	for i in $(seq 5 5 $((30-$b))); do
#		MIO_STATS="--stats_colloid --stats_colloid_cha --stats_colloid_wait 560" ./linux.sh icx-mtv-linux-gups64-rw-app$i-bg$b 600 $i $b -- /home/midhul/colloid/apps/gups/gups64-rw $i;
#	done;
#done;

echo "running manual placement";

for b in 0 5 10 15 20 25; do
	for i in $(seq 5 5 $((30-$b))); do
		MIO_STATS="--stats_colloid --stats_colloid_cha --stats_colloid_wait 18" ./run-manual-icelake-4k.sh icx-mtv-manual-4k-gups64-rw-app$i-bg$b gups64-rw $i $b;
	done;
done;

echo "done :)"


