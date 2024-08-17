#!/bin/bash

echo "madvise" > /sys/kernel/mm/transparent_hugepage/enabled
echo "madvise" > /sys/kernel/mm/transparent_hugepage/defrag
echo 10 > /proc/sys/vm/watermark_scale_factor