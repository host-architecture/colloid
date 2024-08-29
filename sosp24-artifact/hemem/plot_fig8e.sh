#!/bin/bash

cur_path="${BASH_SOURCE%/*}"
scripts_path="${BASH_SOURCE%/*}/../../scripts"

source $scripts_path/config.sh

gnuplot $cur_path/plot_fig8e.gnu
inkscape --export-pdf=$stats_path/fig8e.pdf $stats_path/fig8e.eps
