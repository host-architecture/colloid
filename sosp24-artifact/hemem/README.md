# Reproducing HeMem (+ colloid) results [Estimated time: 3.5 hours]

Note: If not already done, we recommend testing the functionality of HeMem+colloid (see [here](test.md)), before trying to reproduce the paper results.

Note: The server provided for artifact evaluation already has HeMem+colloid compiled and configured, so you can run experiments directly by following the below instructions. If you are using a different server/setup, make sure to setup and configure HeMem+colloid before proceeding by following the documentation in `../../hemem/README.md`.  

`cd` into this directory

Boot into HeMem kernel (if not already)

```
sudo cp ../grub/hemem.grub /etc/default/grub
sudo update-grub
sudo reboot 
```

`ssh` will be disconnected and the server will take a few mins to reboot (5-10 mins), after which it will come back up. After connecting again, check the kernel version using `uname -a`. It should be `5.1.0-rc4-hemem+`

Perform initialization for HeMem (+ colloid).

```
sudo ./init.sh
```

The results can be reproduced figure-by-figure via the subsequent instructions.

### Figure 4 (Time: 15 mins)

Run the Figure 4 experiment using:

```
sudo ./run_fig4.sh
```

Once complete, the results can be queried using:

```
./collect_fig4.sh
```

The output shows the throughput for HeMem and HeMem+colloid. These numbers correspond to the HeMem and HeMem+colloid bars in Fig 4a.

### Figure 6 (Time: 10 mins)

Note: The paper shows results for different combinations of background load and unloaded latency. To minimize artifact evaluation time, we recommend fixing the background load to a given value and varying the unloaded latency (i.e., a single row in Fig 6 plots). To that end, the below scripts take the desired background load as an argument (0 => 0x, 1 => 1x, 2 => 2x, 3 => 3x). The invocations below will run the experiments for the 3x load case. If desired, you can run the other load combinations as well by re-running the below with arguments `0`, `1`, `2`; the time taken will scale accordingly. 

Run the experiments using:

```
sudo ./run_fig6.sh 3
```

Once complete, the results can be queried using:

```
./collect_fig6.sh 3
```

The output shows the throughput for HeMem and HeMem+colloid, along with the relative performance improvement (HeMem+colloid throughput / HeMem throughput). The latter set of numbers correspond to the values shown in the Fig 6a plot.

Since, the Fig 6a heatmap may be difficult to read, for reference, we provide the aboslute numbers presented in the paper below (columns correspond to different BG loads). If you ran the above with argument of 3, then the output should match the last column below.  

| Unloaded latency | 0x       | 1x       | 2x       | **3x**    |
|------------------|----------|----------|----------|-----------|
| 135ns            | 1.007752 | 1.173469 | 1.652047 | **2.36087**  |
| 148ns            | 0.995732 | 1.089532 | 1.536287 | **2.191315** |
| 168ns            | 0.993329 | 1.022539 | 1.373172 | **1.973035** |
| 192ns            | 0.992476 | 1.014174 | 1.254353 | **1.764588** |


### Figure 7 (Time: 20 mins)

The following runs experiments for Figs 7a, 7b, 7c:

```
sudo ./run_fig7.sh
```

Once complete, the results can be compiled using:

```
./collect_fig7.sh
```

Use the following script to plot the graph of throughput over time (using gnuplot):

```
./plot_fig7.sh
```

The output plots are generated at `~/colloid-eval/fig7a.pdf`, `~/colloid-eval/fig7b.pdf`, `~/colloid-eval/fig7c.pdf`. You can copy these images onto your laptop/workstation (e.g. via scp), and view them locally.

### Figure 8a (Time: 45 mins)

The following runs the GAPBS experiments for Fig 8a:

```
sudo ./run_fig8a.sh
```

Once complete, the results can be compiled using:

```
./collect_fig8a.sh
```

The output shows the performance of HeMem and HeMem+colloid along with relative performance improvement (in percentage). Note that performance here is the execution time of GAPBS, and hence, lower is better. The performance improvement numbers correspond to the HeMem+colloid bars in Fig 8a.

### Figure 8b (Time: 40 mins)

The following runs the Silo experiments for Fig 8b:

```
sudo ./run_fig8b.sh
```

Once complete, the results can be compiled using:

```
./collect_fig8b.sh
```

The output shows the performance of HeMem and HeMem+colloid along with relative performance improvement (in percentage). Note that performance here is the throughput achieved by Silo, and hence, higher is better. The performance improvement numbers correspond to the HeMem+colloid bars in Fig 8b.

Note: For the above Silo experiments, in some rare scenarios, we have found that the kernel crashes at the end of an experiment run when the application is exiting. This does not impact the results. If this happens, the server will automatically reboot, and your ssh will get disconnected. You should be able to log back in once it is back up (in 5-10 minutes). Once back online, just run `sudo ./init.sh`, and re-run the above scripts.

### Figure 8c (Time: 50 mins)

The following runs the CacheLib experiments for Fig 8c:

```
sudo ./run_fig8c.sh
```

Once complete, the results can be compiled using:

```
./collect_fig8c.sh
```

The output shows the performance of HeMem and HeMem+colloid along with relative performance improvement (in percentage). Note that performance here is the throughput achieved by CacheLib, and hence, higher is better. The performance improvement numbers correspond to the HeMem+colloid bars in Fig 8c.

### Figure 8e (Time: 10 mins)

The following runs the CacheLib dynamic workload experiments for Fig 8e:

```
sudo ./run_fig8e.sh
```

Once complete, the results can be compiled using:

```
./collect_fig8e.sh
```

Use the following script to plot the graph of throughput over time (using gnuplot):

```
./plot_fig8e.sh
```

The output plots is generated at `~/colloid-eval/fig8e.pdf`. You can copy this image onto your laptop/workstation (e.g. via scp), and view it locally.


