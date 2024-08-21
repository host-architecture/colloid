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

