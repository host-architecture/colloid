# Testing TPP+colloid

Note: The server provided for artifact evaluation already has TPP+colloid compiled and configured, so you can run experiments directly by following the below instructions. If you are using a different server/setup, make sure to setup and configure TPP+colloid before proceeding by following the documentation in `../../tpp/README.md`.  

`cd` into this directory

Boot into TPP kernel

```
sudo cp ../grub/tpp.grub /etc/default/grub
sudo update-grub
sudo reboot 
```

`ssh` will be disconnected and the server will take a few mins to reboot (5-10 mins), after which it will come back up. After connecting again, check the kernel version using:

```
uname -a
```

It should be `6.3.0-colloid`

Run the following to perform the necessary initialization before running TPP+colloid.

```
sudo ./init.sh
```

If successful, the script should just output "Successful".

Now we are all set to run an actual experiment with TPP+colloid. The below command runs the GUPS application (used in the paper) with TPP+colloid for 60 seconds:

```
sudo ./run-test.sh
```

It will run for 60 seconds, and once finished, it will print `Done`.

Once complete, you can check the output (stdout) of the application using:

```
cat ~/colloid-eval/test-tpp-colloid.app.txt
```

This application periodically outputs its throughput. So if it runs successfully, you should see a series of numbers printed one per line. For example:

```shell
sosp24ae@genie13:~/colloid/sosp24-artifact/tpp$ cat ~/colloid-eval/test-tpp-colloid.app.txt | tail
354680832
354942976
348782592
344326144
345636864
348389376
355074048
358088704
384434176
387579904
```

To check whether page migrations are working, we can check the vmstat log:

```
cat ~/colloid-eval/test-tpp-colloid.before_vmstat.txt | grep pgpromote_success
cat ~/colloid-eval/test-tpp-colloid.after_vmstat.txt | grep pgpromote_success
```

The difference between the before and after values shows the number of successful page promotions during the experiment. If this is non-zero, then it indicates that page migrations are being executed

To check that colloid functionality is working, we can check the colloid stats log:

```
cat ~/colloid-eval/test-tpp-colloid.mon.txt | tail
```

Example output:
```
sosp24ae@genie13:~/colloid/sosp24-artifact/tpp$ cat ~/colloid-eval/test-tpp-colloid.mon.txt | tail
53, colloid_local_lat_gt_remote: 0, local_lat: 20, remote_lat: 40, local_occ: 153571, remote_occ: 1373993, local_inserts: 7617, remote_inserts: 34074, kswapd_failues: 0
54, colloid_local_lat_gt_remote: 0, local_lat: 21, remote_lat: 40, local_occ: 142178, remote_occ: 1315619, local_inserts: 6673, remote_inserts: 32705, kswapd_failues: 0
55, colloid_local_lat_gt_remote: 0, local_lat: 21, remote_lat: 40, local_occ: 167175, remote_occ: 1237960, local_inserts: 7774, remote_inserts: 30813, kswapd_failues: 0
56, colloid_local_lat_gt_remote: 0, local_lat: 21, remote_lat: 39, local_occ: 171475, remote_occ: 1239986, local_inserts: 8033, remote_inserts: 31162, kswapd_failues: 0
57, colloid_local_lat_gt_remote: 0, local_lat: 21, remote_lat: 39, local_occ: 171438, remote_occ: 1255231, local_inserts: 7943, remote_inserts: 31586, kswapd_failues: 0
58, colloid_local_lat_gt_remote: 0, local_lat: 20, remote_lat: 39, local_occ: 189697, remote_occ: 1243862, local_inserts: 9347, remote_inserts: 31186, kswapd_failues: 0
59, colloid_local_lat_gt_remote: 0, local_lat: 21, remote_lat: 40, local_occ: 213809, remote_occ: 1301030, local_inserts: 10116, remote_inserts: 32078, kswapd_failues: 0
```

Non-zero values of `local_lat` and `remote_lat` indicate that colloid loaded latency monitoring is working.

