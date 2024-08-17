#!/bin/bash

# Full spectrum
# for b in 0 5 10 15; do for i in $(seq 5 5 $((30-$b))); do ENABLE_THP="y" ./linux-colloid.sh icx-eval-linux-thp-colloid-gups64-rw-app$i-bg$b 600 $i $b -- /home/midhul/colloid/apps/gups/gups64-rw $i; done; done;

# Varying RW
for b in 0 5 10 15; do for i in 15; do for w in "r" "3to1" "2to1"; do ENABLE_THP="y" ./linux.sh icx-eval-linux-thp-gups64-$w-app$i-bg$b 600 $i $b -- /home/midhul/colloid/apps/gups/gups64-$w $i; done; done; done;
for b in 0 5 10 15; do for i in 15; do for w in "r" "3to1" "2to1"; do ENABLE_THP="y" ./linux-colloid.sh icx-eval-linux-thp-colloid-gups64-$w-app$i-bg$b 600 $i $b -- /home/midhul/colloid/apps/gups/gups64-$w $i; done; done; done;

# Varying size
#rmmod colloid-mon
# for b in 0 5 10 15; do for i in 15; do for w in "256" "1024" ""; do ENABLE_THP="y" ./linux.sh icx-eval-linux-thp-gups$w-rw-app$i-bg$b 600 $i $b -- /home/midhul/colloid/apps/gups/gups$w-rw $i; done; done; done;
# for b in 0 5 10 15; do for i in 15; do for w in "256" "1024" ""; do ENABLE_THP="y" ./linux-colloid.sh icx-eval-linux-thp-colloid-gups$w-rw-app$i-bg$b 600 $i $b -- /home/midhul/colloid/apps/gups/gups$w-rw $i; done; done; done;

# Varying latency
#rmmod colloid-mon
for b in 0 5 10 15; do for i in 15; do for u in 0x70e 0x50a 0x408; do wrmsr -p 0 0x620 $u; echo "$( rdmsr -p 0 0x620)"; ENABLE_THP="y" ./linux.sh icx-eval-linux-thp-unc$u-gups64-rw-app$i-bg$b 600 $i $b -- /home/midhul/colloid/apps/gups/gups64-rw $i; done; done; done; wrmsr -p 0 0x620 0x818;
for b in 0 5 10 15; do for i in 15; do for u in 0x70e 0x50a 0x408; do wrmsr -p 0 0x620 $u; echo "$( rdmsr -p 0 0x620)"; ENABLE_THP="y" ./linux-colloid.sh icx-eval-linux-thp-colloid-unc$u-gups64-rw-app$i-bg$b 600 $i $b -- /home/midhul/colloid/apps/gups/gups64-rw $i; done; done; done; wrmsr -p 0 0x620 0x818;

# Dynamic workloads
#ENABLE_THP="y" ./linux.sh icx-eval-hotsetmove-linux-thp-gups64-rw-app15-bg0 900 15 0 -- /home/midhul/colloid/apps/gups/gups64-rw 15 move 450
#ENABLE_THP="y" ./linux-colloid.sh icx-eval-hotsetmove-linux-thp-colloid-gups64-rw-app15-bg0 900 15 0 -- /home/midhul/colloid/apps/gups/gups64-rw 15 move 450

#ENABLE_THP="y" ./linux.sh icx-eval-hotsetmove-linux-thp-gups64-rw-app15-bg15 900 15 15 -- /home/midhul/colloid/apps/gups/gups64-rw 15 move 450
# ENABLE_THP="y" ./linux-colloid.sh icx-eval-hotsetmove-linux-thp-colloid-gups64-rw-app15-bg15 900 15 15 -- /home/midhul/colloid/apps/gups/gups64-rw 15 move 450

echo "done :)"


