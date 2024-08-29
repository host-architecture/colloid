# HeMem + colloid

This directory contains implementation of [colloid](https://github.com/webglider/colloid/) on top of TPP.

## Overview

This directory is organized as follows:
* `linux-6.3/`: Contains a fork of Linux kernel v6.3 (which contains upstreamed version of TPP) with colloid integration
* `colloid-mon/`: Contains kernel module for colloid (loaded) access latency measurement. This modules measures access latency using CHA hardware counters and exposes the information to the core kernel via global variables.


This directory also containts additional infrastructure useful for bootstrapping the system and running experiments:
* `tierinit/`: Kernel module to setup NUMA nodes as memory tiers
* `memeater/`: Kernel module that allocates a certain amount of physical memory (input parameter) and holds it until the module is unloaded. This is useful to emulate different capacities of the memory tiers
* `kswapdrst/`: Kernel module that preiodically resets `kswapd_failure` counter. When running TPP with Transparent Huge Pages (THP), sometimes, page demotions get stalled due because the `kswapd_failures` counter exceeds the maximum threshold. This module periodically resets the counter to avoid pesistently stalling page demotions

### Building TPP + colloid

The following instructions assume a dual-socket server (Intel Ice Lake architecture) where one of the NUMA nodes is used as the default tier, and the other is used as the alternate tier. In the remainder of this document, we are going to assume NUMA 1 is the default tier, and NUMA 0 is the alternate tier (easily interchangeable). We have tested the following on Ubuntu 20.04 and gcc 9.

#### Requirements

Install prerequisites for compiling linux kernel:

```
sudo apt install build-essential libncurses-dev bison flex libssl-dev libelf-dev fakeroot
sudo apt install dwarves
```

#### Building kernel (and booting)

Compile the kernel

```
cd linux-6.3
cp /boot/config-$(uname -r) .config
make olddefconfig
```

Edit ".config" file to include name in the kernel version.

```
vi .config
(in the file)
...
CONFIG_LOCALVERSION="-colloid"
...
```

Compile and install (update -j with number of cores you want to use):

```
make -j32 bzImage
make -j32 modules
sudo make modules_install
sudo make install
```

To boot the new kernel:

Edit "/etc/default/grub" to boot with your new kernel by default. For example:

```
...
#GRUB_DEFAULT=0 
GRUB_DEFAULT="1>Ubuntu, with Linux 6.3.0-colloid"
...
```

Then udpate grub and reboot

```
sudo update-grub
sudo reboot
```

#### Building colloid-mon kernel module

In `colloid-mon/colloid-mon.c`, update `CORE_MON` to the core on which loaded latency measurement should be performed (this should ideally be a dedicated core). Also update `LOCAL_NUMA` to the NUMA node number corresponding to the default tier in your setup.

The to compile simply run:

```
make
```

You should see `colloid-mon.ko` being generated in the directory.

### Building other modules

To build `tierinit`, cd into `tierinit/`, edit `LOCAL_NUMA` to the NUMA node number of the default tier, and `FARMEM_NUMA` to the NUMA node number of the alternate tier in `tierinit.c`, and run `make` to compile.

To build `memeater`, cd into `memeater/`, edit `LOCAL_NUMA` to the NUMA node number of the default tier, and `FARMEM_NUMA` to the NUMA node number of the alternate tier in `memeater.c`, and run `make` to compile.

To build `kswapdsrt`, cd into `kswapdrst/`, edit `LOCAL_NUMA` to the NUMA node number of the default tier, and `FARMEM_NUMA` to the NUMA node number of the alternate tier in `kswapdrst.c`, and run `make` to compile.

### Running TPP + colloid

First, intialize the memory tiers by running:

```
sudo insmod tierinit/tierinit.ko
```

If succesful, you should be able to see the two tiers as directories in `ls /sys/devices/virtual/memory_tiering/`. Check the nodelist file of each tier to make sure that the correct NUMA nodes correspond to each of the tiers (e.g., using `cat /sys/devices/virtual/memory_tiering/memory_tier4/nodelist`)

Then, load colloid-mon kernel module:

```
sudo insmod colloid-mon/colloid-mon.ko
```

Enable memory tiering and colloid:

```
swapoff -a # Disable swap
echo 1 > /sys/kernel/mm/numa/demotion_enabled # Enable page demotion
echo 6 > /proc/sys/kernel/numa_balancing # Enable colloid
```

Now, the system is setup and running. You can go ahead and run any application you want.




