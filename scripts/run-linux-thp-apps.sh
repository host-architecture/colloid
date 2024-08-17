#!/bin/bash

# for b in 0 5 10 15; do ENABLE_THP="y" DRAMSIZE=4404019200 ./linux.sh icx-eval-linux-thp-gapbs-twitter-1to2-app15-bg$b 0 15 $b -- taskset -c 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29 /home/midhul/gapbs/pr -f /home/midhul/gapbs/benchmark/graphs/twitter.sg -i1000 -t1e-4 -n20; done;
# for b in 0 5 10 15; do ENABLE_THP="y" DRAMSIZE=4404019200 ./linux-colloid.sh icx-eval-linux-thp-colloid-gapbs-twitter-1to2-app15-bg$b 0 15 $b -- taskset -c 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29 /home/midhul/gapbs/pr -f /home/midhul/gapbs/benchmark/graphs/twitter.sg -i1000 -t1e-4 -n20; done;

#for b in 0 5 10 15; do DRAMSIZE=13805551616 ENABLE_THP="y" ./linux.sh icx-eval-linux-thp-gapbs-1to2-app15-bg$b 0 15 $b -- taskset -c 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29 /home/midhul/gapbs/bc -g 28; done;
#for b in 0 5 10 15; do DRAMSIZE=13805551616 ENABLE_THP="y" ./linux-colloid.sh icx-eval-linux-thp-colloid-gapbs-1to2-app15-bg$b 0 15 $b -- taskset -c 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29 /home/midhul/gapbs/bc -g 28; done;

#for b in 0 5 10 15; do DRAMSIZE=26843545600 ENABLE_THP="y" ./linux.sh icx-eval-linux-thp-cachelib-hememkv-app15-bg$b 0 15 $b -- taskset -c 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29 /home/midhul/CacheLib/opt/cachelib/bin/cachebench --json_test_config /home/midhul/colloid/workloads/cachelib/hememkv/config.json --progress 1000; done;
#for b in 0 5 10 15; do DRAMSIZE=26843545600 ENABLE_THP="y" ./linux-colloid.sh icx-eval-linux-thp-colloid-cachelib-hememkv-app15-bg$b 0 15 $b -- taskset -c 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29 /home/midhul/CacheLib/opt/cachelib/bin/cachebench --json_test_config /home/midhul/colloid/workloads/cachelib/hememkv/config.json --progress 1000; done;

# for b in 0 5 10 15; do DRAMSIZE=26843545600 ENABLE_THP="y" ./linux.sh icx-eval-linux-thp-cachelib-kvcache-app15-bg$b 0 15 $b -- taskset -c 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29 /home/midhul/CacheLib/opt/cachelib/bin/cachebench --json_test_config /home/midhul/colloid/workloads/cachelib/kvcache_reg/config.json --progress 1000; done;
# for b in 0 5 10 15; do DRAMSIZE=26843545600 ENABLE_THP="y" ./linux-colloid.sh icx-eval-linux-thp-colloid-cachelib-kvcache-app15-bg$b 0 15 $b -- taskset -c 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29 /home/midhul/CacheLib/opt/cachelib/bin/cachebench --json_test_config /home/midhul/colloid/workloads/cachelib/kvcache_reg/config.json --progress 1000; done;

for b in 0 5 10 15; do sudo DRAMSIZE=20761804800 ENABLE_THP="y" ./linux.sh icx-eval-linux-thp-silo-ycsb-app15-bg$b 0 15 $b -- taskset -c 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29 /home/midhul/memtis/memtis-userspace/bench_dir/silo/out-perf.masstree/benchmarks/dbtest --verbose --bench ycsb --num-threads 15 --scale-factor 400005 --ops-per-worker=100000000 --slow-exit; done;
for b in 0 5 10 15; do sudo DRAMSIZE=20761804800 ENABLE_THP="y" ./linux-colloid.sh icx-eval-linux-thp-colloid-silo-ycsb-app15-bg$b 0 15 $b -- taskset -c 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29 /home/midhul/memtis/memtis-userspace/bench_dir/silo/out-perf.masstree/benchmarks/dbtest --verbose --bench ycsb --num-threads 15 --scale-factor 400005 --ops-per-worker=100000000 --slow-exit; done;

for b in 0 5 10 15; do sudo DRAMSIZE=26843545600 ENABLE_THP="y" ./linux.sh icx-eval-linux-thp-silo-tpcc-app15-bg$b 0 15 $b -- taskset -c 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29 /home/midhul/hemem/apps/silo/silo/out-perf.masstree/benchmarks/dbtest --verbose --bench tpcc --num-threads 15 --scale-factor 240 --runtime 60 --slow-exit; done;
for b in 0 5 10 15; do sudo DRAMSIZE=26843545600 ENABLE_THP="y" ./linux-colloid.sh icx-eval-linux-thp-colloid-silo-tpcc-app15-bg$b 0 15 $b -- taskset -c 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29 /home/midhul/hemem/apps/silo/silo/out-perf.masstree/benchmarks/dbtest --verbose --bench tpcc --num-threads 15 --scale-factor 240 --runtime 60 --slow-exit; done;

echo "done :)"


