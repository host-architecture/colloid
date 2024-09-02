# Reproducing TPP (+ colloid) results [Estimated time: 5.5 hrs]

Note: If not already done, we recommend testing the functionality of TPP+colloid (see [here](test.md)), before trying to reproduce the paper results.

Note: The server provided for artifact evaluation already has TPP+colloid compiled and configured, so you can run experiments directly by following the below instructions. If you are using a different server/setup, make sure to setup and configure TPP+colloid before proceeding by following the documentation in `../../tpp/README.md`.  

`cd` into this directory

Boot into TPP kernel (if not already)

```
sudo cp ../grub/tpp.grub /etc/default/grub
sudo update-grub
sudo reboot 
```

`ssh` will be disconnected and the server will take a few mins to reboot (5-10 mins), after which it will come back up. After connecting again, check the kernel version using `uname -a`. It should be `6.3.0-colloid`

Perform initialization for TPP (+ colloid).

```
sudo ./init.sh
```

### Running all experiments

Since the below experiments are relatively long-running, to ease evaluator burden, we provide a script that will run all of them one after another without the need for manual intervention. If running this script, please make sure to use `tmux`/`screen` to prevent ssh disconnection from disrupting the experiments (see [here](../docs/tmux-usage.md) for a crash course on `tmux` usage). Use the following to run all the experiments:

```
sudo ./run_all.sh
```

Once complete, you can query the results figure-by-figure via the subsequent instructions. You can also run them figure-by-figure if you chose (via below instructions).

### Figure 4 (Time: 80 mins)

(if not using `run_all.sh`) Run the Figure 4 experiment using:

```
sudo ./run_fig4.sh
```

The results can be queried using:

```
./collect_fig4.sh
```

The output shows the throughput for TPP and TPP+colloid. These numbers correspond to the TPP and TPP+colloid bars in Fig 4b.

### Figure 6 (Time: 60 mins)

Note: The paper shows results for different combinations of background load and unloaded latency. To minimize artifact evaluation time, we recommend fixing the background load to a given value and varying the unloaded latency (i.e., a single row in Fig 6 plots). To that end, the below scripts take the desired background load as an argument (0 => 0x, 1 => 1x, 2 => 2x, 3 => 3x). The invocations below will run the experiments for the 3x load case. If desired, you can run the other load combinations as well by re-running the below with arguments `0`, `1`, `2`; the time taken will scale accordingly. 

(if not using `run_all.sh`) Run the experiments using:

```
sudo ./run_fig6.sh 3
```

The results can be queried using:

```
./collect_fig6.sh 3
```

The output shows the throughput for TPP and TPP+colloid, along with the relative performance improvement (TPP+colloid throughput / TPP throughput). The latter set of numbers correspond to the values shown in the Fig 6c plot.

Since, the Fig 6c heatmap may be difficult to read, for reference, we provide the aboslute numbers presented in the paper below (columns correspond to different BG loads). If you ran the above with argument of 3, then the output should match the last column below.  

| Unloaded latency | 0x       | 1x       | 2x       | **3x**    |
|------------------|----------|----------|----------|-----------|
| 135ns            | 1.025145 | 1.101156 | 1.424125 | **1.805556**  |
| 148ns            | 1.010675 | 1.066978 | 1.329049 | **1.716613** |
| 168ns            | 1.016325 | 1.015162 | 1.226774 | **1.58904**  |
| 192ns            | 1.002607 | 1.01176  | 1.14426  | **1.497136**  |



### Figure 8a (Time: 60 mins)

(if not using `run_all.sh`) The following runs the GAPBS experiments for Fig 8a:

```
sudo ./run_fig8a.sh
```

The results can be compiled using:

```
./collect_fig8a.sh
```

The output shows the performance of TPP and TPP+colloid along with relative performance improvement (in percentage). Note that performance here is the execution time of GAPBS, and hence, lower is better. The performance improvement numbers correspond to the TPP+colloid bars in Fig 8a.

### Figure 8b (Time: 60 mins)

(if not using `run_all.sh`) The following runs the Silo experiments for Fig 8b:

```
sudo ./run_fig8b.sh
```

The results can be compiled using:

```
./collect_fig8b.sh
```

The output shows the performance of TPP and TPP+colloid along with relative performance improvement (in percentage). Note that performance here is the throughput achieved by Silo, and hence, higher is better. The performance improvement numbers correspond to the purple bars in Fig 8b (The TPP+colloid and TPP w/ THP+colloid bars were swapped by mistake in Fig 8b of the submission).

Note: In this particular experiment, we observe some variation (up to ~15%) in TPP and TPP+colloid performance across runs, so the results may not match exactly (we plan to show error bars in the final version of the paper to account for this). For reference, we provide the absolute performance numbers from Fig 8b result below (you can check TPP and TPP+colloid performance numbers individually):

| BG intensity | TPP       | TPP+colloid | Improvement (%) |
|----------|-----------|-------------|-----------------|
| 0x        | 1.11E+07  | 1.11E+07    | 0.50            |
| 1x        | 9.07E+06  | 9.32E+06    | 2.78            |
| 2x       | 7.85E+06  | 8.56E+06    | 9.03            |
| 3x       | 5.99E+06  | 7.49E+06    | 25.08           |




### Figure 8c (Time: 60 mins)

(if not using `run_all.sh`) The following runs the CacheLib experiments for Fig 8c:

```
sudo ./run_fig8c.sh
```

The results can be compiled using:

```
./collect_fig8c.sh
```

The output shows the performance of TPP and TPP+colloid along with relative performance improvement (in percentage). Note that performance here is the throughput achieved by CacheLib, and hence, higher is better. The performance improvement numbers correspond to the TPP+colloid bars in Fig 8c.



