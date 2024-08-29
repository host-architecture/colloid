#!/bin/bash

cur_path="${BASH_SOURCE%/*}"
scripts_path="${BASH_SOURCE%/*}/../../scripts"

source $scripts_path/config.sh

gnuplot $cur_path/plot_fig7.gnu
inkscape --export-pdf=$stats_path/fig7a.pdf $stats_path/fig7a.eps
inkscape --export-pdf=$stats_path/fig7b.pdf $stats_path/fig7b.eps
inkscape --export-pdf=$stats_path/fig7c.pdf $stats_path/fig7c.eps