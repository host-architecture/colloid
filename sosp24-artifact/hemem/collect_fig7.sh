#!/bin/bash

scripts_path="${BASH_SOURCE%/*}/../../scripts"
i=15 # no. of app cores

source $scripts_path/config.sh

python3 $scripts_path/collect_ts.py hotsetmove-hemem-gups64-rw-app15-bg0 gups > $stats_path/fig7a-hemem.tsv
python3 $scripts_path/collect_ts.py hotsetmove-hemem-colloid-gups64-rw-app15-bg0 gups > $stats_path/fig7a-hemem-colloid.tsv

python3 $scripts_path/collect_ts.py hotsetmove-hemem-gups64-rw-app15-bg15 gups > $stats_path/fig7b-hemem.tsv
python3 $scripts_path/collect_ts.py hotsetmove-hemem-colloid-gups64-rw-app15-bg15 gups > $stats_path/fig7b-hemem-colloid.tsv

python3 $scripts_path/collect_ts.py dynbg-hemem-gups64-rw-app15-bg15 gups > $stats_path/fig7c-hemem.tsv
python3 $scripts_path/collect_ts.py dynbg-hemem-colloid-gups64-rw-app15-bg15 gups > $stats_path/fig7c-hemem-colloid.tsv