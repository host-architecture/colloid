savedcmd_/home/midhul/colloid/colloid-mon/colloid-mon.mod := printf '%s\n'   colloid-mon.o | awk '!x[$$0]++ { print("/home/midhul/colloid/colloid-mon/"$$0) }' > /home/midhul/colloid/colloid-mon/colloid-mon.mod
