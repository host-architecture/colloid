#!/bin/bash

colloid_mon_path="/home/midhul/colloid/tpp/colloid-mon"

# Varying size
#rmmod colloid-mon
#for b in 0 5 10 15; do for i in 15; do for w in "256" "1024" ""; do ./linux.sh icx-eval-linux-gups$w-rw-app$i-bg$b 600 $i $b -- /home/midhul/colloid/apps/gups/gups$w-rw $i; done; done; done;

insmod $colloid_mon_path/colloid-mon.ko
for b in 0 5 10 15; do for i in 15; do for w in "256" "1024" ""; do ./linux-colloid.sh icx-eval-linux-colloid-gups$w-rw-app$i-bg$b 600 $i $b -- /home/midhul/colloid/apps/gups/gups$w-rw $i; done; done; done;
rmmod colloid-mon

# Varying latency
#rmmod colloid-mon
#for b in 0 5 10 15; do for i in 15; do for u in 0x70e 0x50a 0x408; do wrmsr -p 0 0x620 $u; echo "$( rdmsr -p 0 0x620)"; ./linux.sh icx-eval-linux-unc$u-gups64-rw-app$i-bg$b 600 $i $b -- /home/midhul/colloid/apps/gups/gups64-rw $i; done; done; done; wrmsr -p 0 0x620 0x818;

insmod $colloid_mon_path/colloid-mon.ko
for b in 0 5 10 15; do for i in 15; do for u in 0x70e 0x50a 0x408; do wrmsr -p 0 0x620 $u; echo "$( rdmsr -p 0 0x620)"; ./linux-colloid.sh icx-eval-linux-colloid-unc$u-gups64-rw-app$i-bg$b 600 $i $b -- /home/midhul/colloid/apps/gups/gups64-rw $i; done; done; done; wrmsr -p 0 0x620 0x818;
rmmod colloid-mon

echo "done :)"


