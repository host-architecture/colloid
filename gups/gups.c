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
#include <stdatomic.h>

#define LOG_INTERVAL_MS 1000
#define MAX_THREADS 8

// #define WSS 103079215104ULL
#define WSS 77309411328ULL
#define HOTSS 25769803776ULL
// #define WSS 2147483648ULL
// #define HOTSS 1073741824ULL

int TSC_ratio;
uint64_t begin_ts;

static inline __attribute__((always_inline)) unsigned long rdtsc()
{
   unsigned long a, d;

   __asm__ volatile("rdtsc" : "=a" (a), "=d" (d));

   return (a | (d << 32));
}


static inline __attribute__((always_inline)) unsigned long rdtscp()
{
   unsigned long a, d, c;

   __asm__ volatile("rdtscp" : "=a" (a), "=d" (d), "=c" (c));

   return (a | (d << 32));
}

typedef struct {
    int thread_id;
    size_t buf_size;
    size_t hot_size;
    _Atomic uint64_t *count_ptr;
} ThreadArgs;

void *thread_function(void *arg) {
    ThreadArgs *args = (ThreadArgs *)arg;
    // char *a = (char *)malloc(args->buf_size);
    char *a = mmap(0, args->buf_size, PROT_READ | PROT_WRITE, MAP_PRIVATE |  MAP_ANONYMOUS, -1, 0);
    if(a == NULL) {
        printf("mmap failed\n");
        return NULL;
    }

    uint64_t cur_ts=0, prev_ts=0;
    cur_ts = rdtscp();
    prev_ts = cur_ts;
    
    // printf("allocated %lu buf\n", args->buf_size);
    memset(a, 'm', args->buf_size);
    uint64_t x = 432437644 + args->thread_id;
    uint64_t count = 0, prev_count = 0;
    __m512i sum = _mm512_set_epi32(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    __m512i val = _mm512_set_epi32(1995, 1995, 2002, 2002, 1995, 1995, 2002, 2002, 1995, 1995, 2002, 2002, 1995, 1995, 2002, 2002);
    int i;
    while(count < 999999999999999ULL) {
        for(i = 0; i < 1024; i++) {
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
        atomic_store(args->count_ptr, count);
        // cur_ts = rdtscp();
        // printf("cur_ts: %lu, prev_ts: %lu\n", cur_ts, prev_ts);
        // if(cur_ts - prev_ts >= LOG_INTERVAL_MS*TSC_ratio*100*1e3) {
        //     printf("%lu %lu\n", cur_ts-begin_ts, count - prev_count);
        //     prev_ts = cur_ts;
        //     prev_count = count;
        // }
        // if(__builtin_expect(count % 1000 == 0, 0)) {
        //     cur_ts = rdtscp();
        //     if(__builtin_expect(cur_ts - prev_ts >= LOG_INTERVAL_MS*TSC_ratio*100*1e3, 0)) {
        //         printf("%lu %lu\n", cur_ts-begin_ts, count - prev_count);
        //         prev_ts = cur_ts;
        //         prev_count = count;
        //     }
        // }
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
        fprintf(stderr, "Usage: %s <num_threads> <stats-path>\n", argv[0]);
        return 1;
    }

    int num_threads = atoi(argv[1]);
    if (num_threads <= 0 || num_threads > MAX_THREADS) {
        fprintf(stderr, "Number of threads invalid\n");
        return 1;
    }

    // Get TSC frequency
    int msr_fd;
    ssize_t ret;
    uint64_t msr_val;
    msr_fd = open("/dev/cpu/0/msr", O_RDWR);
    if(msr_fd == -1) {
        fprintf(stderr, "An error occurred while opening msr file.\n");
		return EXIT_FAILURE;
    }
    ret = pread(msr_fd, &msr_val, sizeof(msr_val), 0xCEL);
    TSC_ratio = (msr_val & 0x000000000000ff00L) >> 8;

    _Atomic uint64_t thread_counts[MAX_THREADS];
    pthread_t threads[MAX_THREADS];
    ThreadArgs thread_args[MAX_THREADS];
    cpu_set_t cpuset;

    for (int i = 0; i < num_threads; ++i) {
        thread_args[i].thread_id = i;
        thread_args[i].buf_size = ((WSS/4096ULL)/((size_t)num_threads))*4096ULL;
        thread_args[i].hot_size = ((HOTSS/4096ULL)/((size_t)num_threads))*4096ULL;
        atomic_init(&thread_counts[i], 0);
        thread_args[i].count_ptr = &thread_counts[i];
        
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

    uint64_t prev_op_count = 0;
    while(1) {
        sleep(1);
        uint64_t cur_op_count = 0;
        for(int i = 0; i < num_threads; i++) {
            cur_op_count += atomic_load(&thread_counts[i]);
        }
        printf("%lu\n", cur_op_count - prev_op_count);
        prev_op_count = cur_op_count;
    }

    for (int i = 0; i < num_threads; ++i) {
        if (pthread_join(threads[i], NULL) != 0) {
            perror("pthread_join");
            return 1;
        }
    }

    return 0;
}