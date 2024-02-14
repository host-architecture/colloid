cmd_/home/midhul/colloid/colloid-mon/modules.order := {   echo /home/midhul/colloid/colloid-mon/colloid-mon.ko; :; } | awk '!x[$$0]++' - > /home/midhul/colloid/colloid-mon/modules.order
