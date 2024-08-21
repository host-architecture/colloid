# Testing HeMem+colloid

Note: The server provided for artifact evaluation already has HeMem+colloid compiled and configured, so you can run experiments directly by following the below instructions. If you are using a different server/setup, make sure to setup and configure HeMem+colloid before proceeding by following the documentation in `../../hemem/README.md`.  

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

Run the following to perform the necessary initialization before running HeMem+colloid.

```
sudo ./init.sh
```

If successful, the command will output the JSON configuration of the devdax devices setup for HeMem. Example output:

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

Now we are all set to run an actual experiment with HeMem+colloid. The below command runs the GUPS application (used in the paper) with HeMem+colloid for 60 seconds:

```
sudo ./run-test.sh
```

Expected output:

```shell
Cleaned up
Running test-hemem-colloid
```

The above indicates that the experiment is running. It will run for 60 seconds, and once finished, it will print `Done`.

Once complete, you can check the output (stdout) of the application using:

```
cat ~/colloid-eval/test-hemem-colloid.app.txt
```

This application periodically outputs its throughput. So if it runs successfully, you should see a series of numbers printed one per line. For example:

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

We can also check the stats logged by HeMem using:

```
cat ~/colloid-eval/test-hemem-colloid.hemem.txt | tail
```

A successful run should yield an output similar to the one shown below (numbers will not match exactly, of course): 

```shell
pid: [339728]	mem_allocated: [77290536960]	pages_allocated: [0]	missing_faults_handled: [0]	bytes_migrated: [52579794944]	migrations_up: [93]	migrations_down: [93]	migration_waits: [15963]
	occ_local: [1.667088]	 occ_remote: [0.148766]
	dram_hot_list.numentries: [3634]	dram_cold_list.numentries: [9166]	nvm_hot_list.numentries: [0]	nvm_cold_list.numentries: [24055]	hemem_pages: [105762]	total_pages: [105794]	zero_pages: [0]	throttle/unthrottle_cnt: [0/0]	cools: [92]
	dram_accesses: [100913]	nvm_accesses: [4851]	samples: [6950 7328 5530 7145 7314 7359 7281 7042 6901 7042 7337 7012 7041 7235 7265 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ]	total_samples: [105783]
```

`mem_allocated` shows the total amount of memory allocated by the system so far. This should be equal to the working set size of the application (roughly 75GB in this case). `bytes_migrated` shows the total number of bytes migrated so far: a non-zero value indicates that the page migration mechanism is working. `total_samples` shows the number PEBS samples collected during the current time quantum: a non-zero value indicates that PEBS sampling is functional.

Finally, we can also check the stats logged specifically by colloid:

```
cat ~/colloid-eval/test-hemem-colloid.hemem-colloid.log | tail
```

Example output (numbers will not match exactly, of course):

```shell
occ_local=1.655294,occ_remote=0.151341,inserts_local=177419.754931,inserts_remote=12455.680504,inst_occ_local=1.654391,inst_occ_remote=0.153914,inst_inserts_local=177292.000000,inst_inserts_remote=12675.000000,target_delta=0.014449,total_accesses=60359,top_freq_i=18,top_freq_j=1,migrate_limit=3160512,p_lo=0.000000,p_hi=1.000000,pairs=|best_i:0;best_j:23995;best_delta:0.000017,hit-migration-limit,migrated_bytes=4194304,remaining_delta=0.014432
```

Non-zero values of `occ_local` and `occ_remote` indicate that colloid's loaded latency measurement mechanism is functional.
