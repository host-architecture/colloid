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
#include <numaif.h>

#define LOG_INTERVAL_MS 1000
#define MAX_THREADS 32
#define STATS_ITERATIONS 10

#define LOCAL_NUMA 1
#define REMOTE_NUMA 0

// #define WSS 103079215104ULL
#define WSS 77309411328ULL
// //#define HOTSS 25769803776ULL
// #define HOTSS 21474836480ULL
// #define WSS 2147483648ULL
// #define HOTSS 1073741824ULL
// #define CHUNK_SIZE 4096
#define CHUNK_SIZE 2097152

// int TSC_ratio;
// uint64_t begin_ts;

size_t pg_size;

char *a;
uint32_t *indices;
size_t num_samples;

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
    int idx;
    size_t buf_size;
    size_t hot_size;
    _Atomic uint64_t *count_ptr;
    int manual_placement;
    size_t local_hot_pages;
    int reset_mbind;
    _Atomic int finish;
} ThreadArgs;

void *thread_function(void *arg) {
    ThreadArgs *args = (ThreadArgs *)arg;
    
    uint64_t cur_ts=0, prev_ts=0;
    cur_ts = rdtscp();
    prev_ts = cur_ts;

    // uint64_t x = 432437644 + args->thread_id;
    uint64_t idx = args->idx;
    uint64_t count = 0, prev_count = 0;
    __m512i sum = _mm512_set_epi32(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    __m512i val = _mm512_set_epi32(1995, 1995, 2002, 2002, 1995, 1995, 2002, 2002, 1995, 1995, 2002, 2002, 1995, 1995, 2002, 2002);
    int i;
    while(count < 999999999999999ULL) {
        for(i = 0; i < STATS_ITERATIONS; i++) {
            char *start;
            size_t slots;
            start = a;
            slots = args->buf_size/CHUNK_SIZE;
            char *chunk = start + ((size_t)CHUNK_SIZE)*((size_t)(indices[idx]));
            // printf("a: %p\n", a);
            // printf("chunk: %p\n", chunk);
            int k;
            for(k = 0; k < (CHUNK_SIZE/64); k++) {
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
            idx = (idx+1)%num_samples;
        }
        atomic_store(args->count_ptr, count);
        if(atomic_load(&(args->finish))) {
            return NULL;
        }
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
    pg_size = 4096ULL;
    if(getenv("GUPS_HUGEPAGES") != NULL) {
        pg_size = 2ULL*1024ULL*1024ULL;
    }
    size_t align_sz = (CHUNK_SIZE > pg_size)?(CHUNK_SIZE):(pg_size);
    setbuf(stdout, NULL);
    int cores[32] = {1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45,47,49,51,53,55,57,59,61,63};
    // int cores[8] = {1,5,9,13,17,21,25,29};
    if (argc < 4) {
        fprintf(stderr, "Usage: %s <num_threads> <nsamples> <distribution-file>\n", argv[0]);
        return 1;
    }

    int num_threads = atoi(argv[1]);
    if (num_threads <= 0 || num_threads > MAX_THREADS) {
        fprintf(stderr, "Number of threads invalid\n");
        return 1;
    }

    num_samples = atoi(argv[2]);
    indices = (uint32_t *)malloc(num_samples * sizeof(uint32_t));
    if(indices == NULL) {
        fprintf(stderr, "indices allocation failed\n");
        return 1;
    }

    FILE *dist_file;
    dist_file = fopen(argv[3], "r");
    if(dist_file == NULL) {
        fprintf(stderr, "Failed to open distribution file\n");
        return 1;
    }

    int count = 0;
    while (fscanf(dist_file, "%u", &indices[count]) == 1) {
        count++;
        if (count > num_samples) {
            fprintf(stderr, "Exceeded num samples: %u\n", count);
            return 1;
        }
    }
    if(count != num_samples) {
        fprintf(stderr, "samples in file mistmatch num_samples\n");
        return 1;
    }

    // Allocate and intialize buffer
    int mmap_flags =  MAP_PRIVATE |  MAP_ANONYMOUS;
    if(getenv("GUPS_HUGEPAGES") != NULL) {
        mmap_flags |= MAP_HUGETLB;
    }
    size_t buf_size = ((WSS/align_sz))*align_sz;
    a = NULL;
    a = mmap(0, buf_size, PROT_READ | PROT_WRITE, mmap_flags, -1, 0);
    if(a == NULL) {
        printf("mmap failed\n");
        return -1;
    }
    memset(a, 'm', buf_size);
	printf("memset done\n");

    asm volatile("" : : : "memory");

    _Atomic uint64_t thread_counts[MAX_THREADS];
    pthread_t threads[MAX_THREADS];
    ThreadArgs thread_args[MAX_THREADS];
    cpu_set_t cpuset;

    for (int i = 0; i < num_threads; ++i) {
        thread_args[i].thread_id = i;
        thread_args[i].idx = (num_samples/num_threads)*i;
        thread_args[i].buf_size = buf_size;
        // thread_args[i].hot_size = ((HOTSS/pg_size)/((size_t)num_threads))*pg_size;
        thread_args[i].hot_size = 0;
        atomic_init(&thread_counts[i], 0);
        thread_args[i].count_ptr = &thread_counts[i];
        thread_args[i].manual_placement = 0;
        thread_args[i].reset_mbind = 0;
        atomic_init(&(thread_args[i].finish), 0);
        
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
    int elapsed = 0;
    int max_duration = 100000;
    if(getenv("GUPS_DURATION") != NULL) {
        max_duration = atoi(getenv("GUPS_DURATION"));
    }
    while(elapsed < max_duration) {
        sleep(1);
        uint64_t cur_op_count = 0;
        for(int i = 0; i < num_threads; i++) {
            cur_op_count += atomic_load(&thread_counts[i]);
        }
        printf("%lu\n", cur_op_count - prev_op_count);
        prev_op_count = cur_op_count;
        elapsed++;
    }

    for(int i = 0; i < num_threads; i++) {
        atomic_store(&(thread_args[i].finish), 1);
    }

    for (int i = 0; i < num_threads; ++i) {
        if (pthread_join(threads[i], NULL) != 0) {
            perror("pthread_join");
            return 1;
        }
    }

    return 0;
}
