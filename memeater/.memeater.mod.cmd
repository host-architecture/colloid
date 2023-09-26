savedcmd_/home/midhul/colloid/memeater/memeater.mod := printf '%s\n'   memeater.o | awk '!x[$$0]++ { print("/home/midhul/colloid/memeater/"$$0) }' > /home/midhul/colloid/memeater/memeater.mod
