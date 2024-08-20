# Script to initialize HeMem (+ colloid) for experiments

echo 1000000 > /proc/sys/vm/max_map_count

# Setup /dev/dax devices
sudo ndctl create-namespace -f -e namespace1.0 --mode=devdax --align 2M
sudo ndctl create-namespace -f -e namespace0.0 --mode=devdax --align 2M