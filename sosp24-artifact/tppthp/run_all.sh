#!/bin/bash

cur_path="${BASH_SOURCE%/*}"

# Run all TPP experiments
$cur_path/run_fig4.sh
$cur_path/run_fig6.sh 3
$cur_path/run_fig8a.sh
$cur_path/run_fig8b.sh
$cur_path/run_fig8c.sh
