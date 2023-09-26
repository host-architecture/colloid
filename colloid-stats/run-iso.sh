#!/bin/bash

config_rw="lmt-v6-readwrite"
config_r="lmt-v6-read"
local_capacity_mib=$((30*1024))

function cleanup() {
    killall gups-r;
    killall gups-rw;
    killall record_stats;
    rmmod memeater;
    echo "Cleaned up";
}

trap cleanup EXIT

rmmod memeater;
killall gups-r;
killall gups-rw;
killall record_stats;

for i in 8 4 2 1; do
    echo "Running $config_r-cores$i-baseline"
    cat /sys/devices/system/node/node3/meminfo | grep "MemFree";
    /home/midhul/mio-colloid/gups/gups-r $i &
    pid_gups=$!;
    taskset -c 0 /home/midhul/mio-colloid/colloid-stats/record_stats > /home/midhul/membw-eval/$config_r-cores$i-baseline.stats.txt 2>&1 &
    pid_stats=$!;
    sleep 80;
    killall record_stats;
    while kill -0 $pid_stats; do
        sleep 1;
    done;
    killall gups-r;
    while kill -0 $pid_gups; do
        sleep 1;
    done;
    cat /sys/devices/system/node/node3/meminfo | grep "MemFree";
done;

for i in 8 4 2 1; do
    echo "Running $config_r-cores$i-lmem0"
    cat /sys/devices/system/node/node3/meminfo | grep "MemFree";
    numactl --membind 2 /home/midhul/mio-colloid/gups/gups-r $i &
    pid_gups=$!;
    taskset -c 0 /home/midhul/mio-colloid/colloid-stats/record_stats > /home/midhul/membw-eval/$config_r-cores$i-lmem0.stats.txt 2>&1 &
    pid_stats=$!;
    sleep 80;
    killall record_stats;
    while kill -0 $pid_stats; do
        sleep 1;
    done;
    killall gups-r;
    while kill -0 $pid_gups; do
        sleep 1;
    done;
    cat /sys/devices/system/node/node3/meminfo | grep "MemFree";
done;
