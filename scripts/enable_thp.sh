#!/bin/bash

echo "always" > /sys/kernel/mm/transparent_hugepage/enabled
echo "always" > /sys/kernel/mm/transparent_hugepage/defrag
echo 100 > /proc/sys/vm/watermark_scale_factor
