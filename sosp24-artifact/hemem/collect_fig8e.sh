#!/bin/bash

scripts_path="${BASH_SOURCE%/*}/../../scripts"
i=15 # no. of app cores

source $scripts_path/config.sh

cat $stats_path/hemem-cachelib-hememkv-app15-varybg-pulse10s-100ms.app.txt | grep -i ". hit ratio  " | awk '{print $2}' | tr -d 'M' | awk '{print $1 -x; x = $1}' > $stats_path/fig8e-hemem.tsv
cat $stats_path/hemem-colloid-cachelib-hememkv-app15-varybg-pulse10s-100ms.app.txt | grep -i ". hit ratio  " | awk '{print $2}' | tr -d 'M' | awk '{print $1 -x; x = $1}' > $stats_path/fig8e-hemem-colloid.tsv
