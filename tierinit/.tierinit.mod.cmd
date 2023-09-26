savedcmd_/home/midhul/colloid/tierinit/tierinit.mod := printf '%s\n'   tierinit.o | awk '!x[$$0]++ { print("/home/midhul/colloid/tierinit/"$$0) }' > /home/midhul/colloid/tierinit/tierinit.mod
