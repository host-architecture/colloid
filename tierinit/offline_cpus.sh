for i in 2 6 10 14 18 22 26 30 34 38 42 46 50 54 58 62; do
	echo 0 > /sys/devices/system/cpu/cpu$i/online
done
