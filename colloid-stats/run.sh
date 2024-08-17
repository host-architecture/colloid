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
    for lmem in 24576 19661 14746 9830 4915; do
        echo "Running $config_rw-cores$i-lmem$lmem"
        eatmem=$(($local_capacity_mib-$lmem))
        insmod /home/midhul/colloid/tpp/memeater/memeater.ko sizeMiB=$eatmem;
        cat /sys/devices/system/node/node3/meminfo | grep "MemFree";
        /home/midhul/colloid/apps/gups/gups-rw $i &
        pid_gups=$!;
        taskset -c 0 /home/midhul/colloid/colloid-stats/record_stats > /home/midhul/membw-eval/$config_rw-cores$i-lmem$lmem.stats.txt 2>&1 &
        pid_stats=$!;
        sleep 1000;
        killall record_stats;
        while kill -0 $pid_stats; do
            sleep 1;
        done;
        killall gups-rw;
        while kill -0 $pid_gups; do
            sleep 1;
        done;
        rmmod memeater;
        cat /sys/devices/system/node/node3/meminfo | grep "MemFree";
    done;
done;

for i in 8 4 2 1; do
    for lmem in 24576 19661 14746 9830 4915; do
        echo "Running $config_r-cores$i-lmem$lmem"
        eatmem=$(($local_capacity_mib-$lmem))
        insmod /home/midhul/colloid/tpp/memeater/memeater.ko sizeMiB=$eatmem;
        cat /sys/devices/system/node/node3/meminfo | grep "MemFree";
        /home/midhul/colloid/apps/gups/gups-r $i &
        pid_gups=$!;
        taskset -c 0 /home/midhul/colloid/colloid-stats/record_stats > /home/midhul/membw-eval/$config_r-cores$i-lmem$lmem.stats.txt 2>&1 &
        pid_stats=$!;
        sleep 1000;
        killall record_stats;
        while kill -0 $pid_stats; do
            sleep 1;
        done;
        killall gups-r;
        while kill -0 $pid_gups; do
            sleep 1;
        done;
        rmmod memeater;
        cat /sys/devices/system/node/node3/meminfo | grep "MemFree";
    done;
done;