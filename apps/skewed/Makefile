CC = gcc
CFLAGS = -O3 -msse4 -g -march=native -funroll-loops

all: skewed-r skewed-rw skewed-shared-rw skewed-shared-r

skewed-r:
	$(CC) -DWORKLOAD_READ $(CFLAGS) skewed.c -o skewed-r -lpthread -lnuma

skewed-rw:
	$(CC) -DWORKLOAD_READWRITE $(CFLAGS) skewed.c -o skewed-rw -lpthread -lnuma

skewed-shared-rw:
	$(CC) -DWORKLOAD_READWRITE $(CFLAGS) skewed-shared.c -o skewed-shared-rw -lpthread -lnuma

skewed-shared-r:
	$(CC) -DWORKLOAD_READ $(CFLAGS) skewed-shared.c -o skewed-shared-r -lpthread -lnuma


clean:
	rm -f skewed-r skewed-rw skewed-shared-rw skewed-shared-r *.o
