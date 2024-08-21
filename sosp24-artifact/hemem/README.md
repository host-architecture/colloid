# Testing HeMem+colloid

Note: On our server (provided for artifact evaluation), HeMem (+colloid) is already compiled and configured, so you can run experiments directly by following the below instructions. If you are using a different server/setup, make sure to setup and configure HeMem (+colloid) before proceeding by following the documentation in `../../hemem/README.md`.  

`cd` into this directory

Boot into HeMem kernel

```
sudo cp ../grub/hemem.grub /etc/default/grub
sudo update-grub
sudo reboot 
```

`ssh` will be disconnected and the server will take a few mins to reboot (5-10 mins), after which it will come back up. After connecting again, check the kernel version using:

```
uname -a
```

It should be `5.1.0-rc4-hemem+`

Initialization before running HeMem (+ colloid)

```
sudo ./init.sh
```

Output:
```shell
[
  {
    "dev":"namespace1.0",
    "mode":"devdax",
    "map":"dev",
    "size":33820770304,
    "uuid":"c6a3c9f1-3941-456b-8a7c-1cf5b441c666",
    "chardev":"dax1.0",
    "align":2097152
  },
  {
    "dev":"namespace0.0",
    "mode":"devdax",
    "map":"dev",
    "size":101466505216,
    "uuid":"f34ba61b-1ca3-41c2-9e18-059862ef8fa4",
    "chardev":"dax0.0",
    "align":2097152
  }
]
```

Run

```
sudo ./run-test.sh
```

Output

```shell
Cleaned up
Running test-hemem-colloid
```

Experiment running (can check `htop` to see CPUs being used). Will run for 60 seconds, and one finished it will print `Done`.

Check app output

```
cat ~/colloid-eval/test-hemem-colloid.app.txt | tail
```

Example output

```shell
sosp24ae@genie13:~/colloid/sosp24-artifact/hemem$ cat ~/colloid-eval/test-hemem-colloid.app.txt | tail
606732288
607387648
606863360
606732288
607518720
606208000
606863360
607256576
607125504
606732288
```

HeMem stats

```
cat ~/colloid-eval/test-hemem-colloid.hemem.txt | tail
```

```shell
pid: [339728]	mem_allocated: [77290536960]	pages_allocated: [0]	missing_faults_handled: [0]	bytes_migrated: [52579794944]	migrations_up: [93]	migrations_down: [93]	migration_waits: [15963]
	occ_local: [1.667088]	 occ_remote: [0.148766]
	dram_hot_list.numentries: [3634]	dram_cold_list.numentries: [9166]	nvm_hot_list.numentries: [0]	nvm_cold_list.numentries: [24055]	hemem_pages: [105762]	total_pages: [105794]	zero_pages: [0]	throttle/unthrottle_cnt: [0/0]	cools: [92]
	dram_accesses: [100913]	nvm_accesses: [4851]	samples: [6950 7328 5530 7145 7314 7359 7281 7042 6901 7042 7337 7012 7041 7235 7265 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ]	total_samples: [105783]
```
