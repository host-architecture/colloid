#!/bin/bash

config="hugepageslat-manual-gupsrw"
gups_path=/home/midhul/colloid/apps/gups
mio_path=/home/midhul/mio-colloid
record_path=/home/midhul/colloid/colloid-stats
stats_path=/home/midhul/membw-eval

echo "App Throughput, no background traffic"
for x in 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1; do
    cat $stats_path/$config-iso-x$x.gups.txt | tail -n 30 | awk '{sum+=$1} END {print (sum/NR)*2*4096/1e9;}'
done;

echo "App Throughput, with background traffic"
for x in 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1; do
    cat $stats_path/$config-bg-x$x.gups.txt | tail -n 30 | awk '{sum+=$1} END {print (sum/NR)*2*4096/1e9;}'
done;

# Local DRAM BW usage
echo "Local DRAM BW usage, no background traffic"
for x in 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1; do
    paste <(cat $stats_path/$config-iso-x$x.gups.txt | tail -n 30) <(cat $stats_path/$config-iso-x$x.stats.txt | tail -n 30) | awk '{sum += ($4+$5)} END {print (sum/NR)*64/1e9}'
done;
echo "Local DRAM BW usage, with background traffic (app, background)"
for x in 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1; do
    paste <(cat $stats_path/$config-bg-x$x.gups.txt | tail -n 30) <(cat $stats_path/$config-bg-x$x.stats.txt | tail -n 30) | awk '{print ($1*4096 - $6*64 -$7*64)/1e9, ($4*64+$5*64-$1*4096 + $6*64 + $7*64)/1e9}' | awk '{sum1 += $1; sum2 += $2} END {print sum1/NR, sum2/NR}';
done;

# UPI Rx BW usage
echo "UPI Rx BW usage, no background traffic (data, non-data)"
for x in 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1; do
    cat $stats_path/$config-iso-x$x.stats.txt | tail -n 30 | awk '{print $5*64/1e9, $7*64/1e9}' | awk '{sum1 += $1; sum2 += $2} END {print sum1/NR, sum2/NR;}'
done;
echo "UPI Rx BW usage, with background traffic (data, non-data)"
for x in 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1; do
    cat $stats_path/$config-bg-x$x.stats.txt | tail -n 30 | awk '{print $5*64/1e9, $7*64/1e9}' | awk '{sum1 += $1; sum2 += $2} END {print sum1/NR, sum2/NR;}'
done;

# UPI Tx BW usage
echo "UPI Tx BW usage, no background traffic (data, non-data)"
for x in 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1; do
    cat $stats_path/$config-iso-x$x.stats.txt | tail -n 30 | awk '{print $6*64/1e9, $8*64/1e9}' | awk '{sum1 += $1; sum2 += $2} END {print sum1/NR, sum2/NR;}'
done;
echo "UPI Tx BW usage, with background traffic (data, non-data)"
for x in 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1; do
    cat $stats_path/$config-bg-x$x.stats.txt | tail -n 30 | awk '{print $6*64/1e9, $8*64/1e9}' | awk '{sum1 += $1; sum2 += $2} END {print sum1/NR, sum2/NR;}'
done;

# App hit rate
echo "App hit rate, no background traffic"
for x in 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1; do
    paste <(cat $stats_path/$config-iso-x$x.gups.txt | tail -n 30) <(cat $stats_path/$config-iso-x$x.stats.txt | tail -n 30) | awk '{print ($1*4096 - $6*64 -$7*64)/($1*4096)}' | awk '{sum1 += $1;} END {print sum1/NR}';
done;
echo "App hit rate, with background traffic"
for x in 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1; do
    paste <(cat $stats_path/$config-bg-x$x.gups.txt | tail -n 30) <(cat $stats_path/$config-bg-x$x.stats.txt | tail -n 30) | awk '{print ($1*4096 - $6*64 -$7*64)/($1*4096)}' | awk '{sum1 += $1;} END {print sum1/NR}';
done;

