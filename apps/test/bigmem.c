#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUFFER_SIZE 103079215104ULL
#define HOT_SIZE 1073741824ULL

int main() {

    char *a = (char *) malloc(BUFFER_SIZE);
    if(a == NULL) {
        printf("Error: failed to allocate buffer\n");
        return -1;
    }

    memset(a, 'm', BUFFER_SIZE);
    printf("memset complete\n");

    size_t start_offset = BUFFER_SIZE - HOT_SIZE;
    unsigned long long acc = 0;
    size_t offset = 0;
    while(acc < 184467440737095516ULL) {
        for(offset = start_offset; offset < BUFFER_SIZE; offset++) {
            acc += (unsigned long long)(a[offset]);
        }
    }

    printf("done: %llu\n", acc);

    return 0;
}