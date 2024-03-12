CC = gcc
CFLAGS = -O3 -msse4 -g -march=native -funroll-loops

all: gups-r gups-rw gups-2to1 gups-3to1

gups-r:
	$(CC) -DWORKLOAD_READ $(CFLAGS) gups.c -o gups-r -lpthread -lnuma

gups-rw:
	$(CC) -DWORKLOAD_READWRITE $(CFLAGS) gups.c -o gups-rw -lpthread -lnuma

gups-2to1:
	$(CC) -DWORKLOAD_2TO1 $(CFLAGS) gups.c -o gups-2to1 -lpthread -lnuma

gups-3to1:
	$(CC) -DWORKLOAD_3TO1 $(CFLAGS) gups.c -o gups-3to1 -lpthread -lnuma


clean:
	rm -f gups-r gups-rw gups-2to1 gups-3to1 *.o
