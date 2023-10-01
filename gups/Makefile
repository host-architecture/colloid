CC = gcc
CFLAGS = -O3 -msse4 -g -march=native -funroll-loops

all: gups-r gups-rw

gups-r:
	$(CC) -DWORKLOAD_READ $(CFLAGS) gups.c -o gups-r -lpthread -lnuma

gups-rw:
	$(CC) -DWORKLOAD_READWRITE $(CFLAGS) gups.c -o gups-rw -lpthread -lnuma


clean:
	rm -f gups-r gups-rw *.o
