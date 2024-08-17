CC = gcc
CFLAGS = -O3 -msse4 -g -march=native -funroll-loops
CFLAGSOPT = -O3 -msse4 -g -march=native

all: gups-r gups-rw gups-2to1 gups-3to1 gups64-rw gups64-r gups64-2to1 gups64-3to1 gups256-rw gups1024-rw

gups-r:
	$(CC) -DCHUNK_SIZE=4096 -DCL_PER_CHUNK=64 -DWORKLOAD_READ $(CFLAGS) gups.c -o gups-r -lpthread -lnuma

gups-rw:
	$(CC) -DCHUNK_SIZE=4096 -DCL_PER_CHUNK=64 -DWORKLOAD_READWRITE $(CFLAGS) gups.c -o gups-rw -lpthread -lnuma

gups-2to1:
	$(CC) -DCHUNK_SIZE=4096 -DCL_PER_CHUNK=64 -DWORKLOAD_2TO1 $(CFLAGS) gups.c -o gups-2to1 -lpthread -lnuma

gups-3to1:
	$(CC) -DCHUNK_SIZE=4096 -DCL_PER_CHUNK=64 -DWORKLOAD_3TO1 $(CFLAGS) gups.c -o gups-3to1 -lpthread -lnuma

gups64-rw:
	$(CC) -DCHUNK_SIZE=64 -DCL_PER_CHUNK=1 -DWORKLOAD_READWRITE $(CFLAGS) gups-opt.c -o gups64-rw -lpthread -lnuma

gups64-r:
	$(CC) -DCHUNK_SIZE=64 -DCL_PER_CHUNK=1 -DWORKLOAD_READ $(CFLAGS) gups-opt.c -o gups64-r -lpthread -lnuma

gups64-2to1:
	$(CC) -DCHUNK_SIZE=64 -DCL_PER_CHUNK=1 -DWORKLOAD_2TO1 $(CFLAGS) gups-opt.c -o gups64-2to1 -lpthread -lnuma

gups64-3to1:
	$(CC) -DCHUNK_SIZE=64 -DCL_PER_CHUNK=1 -DWORKLOAD_3TO1 $(CFLAGS) gups-opt.c -o gups64-3to1 -lpthread -lnuma

gups256-rw:
	$(CC) -DCHUNK_SIZE=256 -DCL_PER_CHUNK=4 -DWORKLOAD_READWRITE $(CFLAGS) gups-256.c -o gups256-rw -lpthread -lnuma

gups1024-rw:
	$(CC) -DCHUNK_SIZE=1024 -DCL_PER_CHUNK=16 -DWORKLOAD_READWRITE $(CFLAGS) gups-1024.c -o gups1024-rw -lpthread -lnuma


clean:
	rm -f gups-r gups-rw gups-2to1 gups-3to1 gups64-rw gups64-r gups64-2to1 gups64-3to1 gups256-rw gups1024-rw *.o
