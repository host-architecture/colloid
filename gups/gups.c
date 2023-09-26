#define _GNU_SOURCE
#include <stdio.h>
#include <unistd.h>
#include <math.h>
#include <float.h>
#include <limits.h>
#include <sys/time.h>
#include <stdint.h>
#include <string.h>
#include <sys/mman.h>
#include <immintrin.h>
#include <fcntl.h>
#include <sched.h>
#include <pthread.h>

// #define WSS 103079215104ULL
#define WSS 77309411328ULL
#define HOTSS 25769803776ULL
// #define WSS 2147483648ULL
// #define HOTSS 1073741824ULL

typedef struct {
    int thread_id;
    size_t buf_size;
    size_t hot_size;
} ThreadArgs;

void *thread_function(void *arg) {
    ThreadArgs *args = (ThreadArgs *)arg;
    // char *a = (char *)malloc(args->buf_size);
    char *a = mmap(0, args->buf_size, PROT_READ | PROT_WRITE, MAP_PRIVATE |  MAP_ANONYMOUS, -1, 0);
    if(a == NULL) {
        printf("mmap failed\n");
        return NULL;
    }
    
    // printf("allocated %lu buf\n", args->buf_size);
    memset(a, 'm', args->buf_size);
    uint64_t x = 432437644 + args->thread_id;
    uint64_t count = 0;
    __m512i sum = _mm512_set_epi32(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    __m512i val = _mm512_set_epi32(1995, 1995, 2002, 2002, 1995, 1995, 2002, 2002, 1995, 1995, 2002, 2002, 1995, 1995, 2002, 2002);
    while(count < 999999999999999ULL) {
        char *start;
        size_t slots;
        x ^= x << 13;
		x ^= x >> 7;
		x ^= x << 17;
        if(x%100 < 90) {
            // access hot region
            start = a + (args->buf_size - args->hot_size);
            slots = args->hot_size / 4096;
        } else {
            start = a;
            slots = (args->buf_size - args->hot_size)/4096;
        }

        // access random slot
        x ^= x << 13;
		x ^= x >> 7;
		x ^= x << 17;
        char *chunk = start + 4096*(x%slots);
        // printf("a: %p\n", a);
        // printf("chunk: %p\n", chunk);
        int k;
        for(k = 0; k < 64; k++) {
            #if defined(WORKLOAD_READWRITE)
			__m512i mm_a = _mm512_load_si512(&chunk[64*k]);
		    _mm512_store_si512(&chunk[64*k], _mm512_add_epi32(mm_a, val));
            #elif defined(WORKLOAD_READ)
            __m512i mm_a = _mm512_load_si512(&chunk[64*k]);
		    sum = _mm512_add_epi32(sum, mm_a);
            #else
            #error "Define WORKLOAD"
            #endif
		}
        count++;
    }


        uint64_t read_checksum;
        int chx0, chx1, chx2, chx3;
        __m128i chx;
        chx = _mm512_extracti32x4_epi32(sum, 0);
        chx0 = _mm_extract_epi32(chx, 0);
        chx1 = _mm_extract_epi32(chx, 1);
        chx2 = _mm_extract_epi32(chx, 2);
        chx3 = _mm_extract_epi32(chx, 3);
        read_checksum += chx0 + chx1 + chx2 + chx3;
        chx = _mm512_extracti32x4_epi32(sum, 1);
        chx0 = _mm_extract_epi32(chx, 0);
        chx1 = _mm_extract_epi32(chx, 1);
        chx2 = _mm_extract_epi32(chx, 2);
        chx3 = _mm_extract_epi32(chx, 3);
        read_checksum += chx0 + chx1 + chx2 + chx3;
        chx = _mm512_extracti32x4_epi32(sum, 2);
        chx0 = _mm_extract_epi32(chx, 0);
        chx1 = _mm_extract_epi32(chx, 1);
        chx2 = _mm_extract_epi32(chx, 2);
        chx3 = _mm_extract_epi32(chx, 3);
        read_checksum += chx0 + chx1 + chx2 + chx3;
        chx = _mm512_extracti32x4_epi32(sum, 3);
        chx0 = _mm_extract_epi32(chx, 0);
        chx1 = _mm_extract_epi32(chx, 1);
        chx2 = _mm_extract_epi32(chx, 2);
        chx3 = _mm_extract_epi32(chx, 3);
        read_checksum += chx0 + chx1 + chx2 + chx3;
        printf("checksum reached: %lu\n", read_checksum);
        int xyz;
        uint64_t wrchk = 0;
        for(xyz = 0; xyz < args->buf_size; xyz++) {
            wrchk += (int)(a[xyz]);
        }
        printf("wrchk: %lu\n", wrchk);
    
    return NULL;
}

int main(int argc, char *argv[]) {
    int cores[8] = {3,7,11,15,19,23,27,31};
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <num_threads>\n", argv[0]);
        return 1;
    }

    int num_threads = atoi(argv[1]);
    if (num_threads <= 0) {
        fprintf(stderr, "Number of threads must be a positive integer\n");
        return 1;
    }

    pthread_t threads[num_threads];
    ThreadArgs thread_args[num_threads];
    cpu_set_t cpuset;

    for (int i = 0; i < num_threads; ++i) {
        thread_args[i].thread_id = i;
        thread_args[i].buf_size = ((WSS/4096ULL)/((size_t)num_threads))*4096ULL;
        thread_args[i].hot_size = ((HOTSS/4096ULL)/((size_t)num_threads))*4096ULL;
        
        CPU_ZERO(&cpuset);
        CPU_SET(cores[i], &cpuset);

        if (pthread_create(&threads[i], NULL, thread_function, &thread_args[i]) != 0) {
            perror("pthread_create");
            return 1;
        }

        if (pthread_setaffinity_np(threads[i], sizeof(cpu_set_t), &cpuset) != 0) {
            perror("pthread_setaffinity_np");
            return 1;
        }
    }

    for (int i = 0; i < num_threads; ++i) {
        if (pthread_join(threads[i], NULL) != 0) {
            perror("pthread_join");
            return 1;
        }
    }

    return 0;
}