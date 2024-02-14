CC = gcc
CFLAGS = -O3 -msse4 -g -march=native -funroll-loops

all: skewed-r skewed-rw

skewed-r:
	$(CC) -DWORKLOAD_READ $(CFLAGS) skewed.c -o skewed-r -lpthread -lnuma

skewed-rw:
	$(CC) -DWORKLOAD_READWRITE $(CFLAGS) skewed.c -o skewed-rw -lpthread -lnuma


clean:
	rm -f skewed-r skewed-rw *.o
