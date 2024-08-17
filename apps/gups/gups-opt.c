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
#include <numa.h>

#define LOG_INTERVAL_MS 1000
#define MAX_THREADS 32

#define LOCAL_NUMA 1
#define REMOTE_NUMA 0

// #define WSS 103079215104ULL
#define WSS 77309411328ULL
//#define WSS 1073741824ULL
//#define WSS 21474836480ULL
// #define HOTSS 25769803776ULL
#define HOTSS 21474836480ULL
//#define HOTSS 1073741824ULL
// #define WSS 2147483648ULL
// #define HOTSS 1073741824ULL
// #define CHUNK_SIZE 4096
// #define CL_PER_CHUNK 64

// int TSC_ratio;
// uint64_t begin_ts;

size_t pg_size;

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
    int manual_placement;
    size_t local_hot_pages;
    int reset_mbind;
    size_t local_free;
    _Atomic int finish;
} ThreadArgs;

#define MAP_HUGE_1GB (30 << MAP_HUGE_SHIFT)

_Atomic int g_move_hotset;

void *thread_function(void *arg) {
    ThreadArgs *args = (ThreadArgs *)arg;
    // char *a = (char *)malloc(args->buf_size);
    int mmap_flags =  MAP_PRIVATE |  MAP_ANONYMOUS;
    if(getenv("GUPS_HUGEPAGES") != NULL) {
        mmap_flags |= MAP_HUGETLB;
    }
    if(getenv("GUPS_HUGEPAGES_1GB") != NULL) {
        mmap_flags |= MAP_HUGETLB;
        mmap_flags |= MAP_HUGE_1GB;
    }
    char *a = mmap(0, args->buf_size, PROT_READ | PROT_WRITE, mmap_flags, -1, 0);
    if(a == NULL) {
        printf("mmap failed\n");
        return NULL;
    }

    uint64_t cur_ts=0, prev_ts=0;
    cur_ts = rdtscp();
    prev_ts = cur_ts;

    if(args->manual_placement) {
        unsigned long local_nodemask = (1UL << LOCAL_NUMA);
        unsigned long remote_nodemask = (1UL << REMOTE_NUMA);

        // New manual placement mechanism

        // Set mbind policy for hot set
        if(args->local_hot_pages > 0){
            if(mbind(a + args->buf_size - args->hot_size, args->local_hot_pages*pg_size, MPOL_BIND, &local_nodemask, sizeof(local_nodemask)*8, MPOL_MF_STRICT) != 0) {
                fprintf(stderr, "second mbind failed\n");
                return NULL;
            }
        }
        if(mbind(a + args->buf_size - args->hot_size + args->local_hot_pages*pg_size, args->hot_size - args->local_hot_pages*pg_size, MPOL_BIND, &remote_nodemask, sizeof(remote_nodemask)*8, MPOL_MF_STRICT) != 0) {
            fprintf(stderr, "third mbind failed\n");
            return NULL;
        }

        // Set mbind policy for cold set
        size_t cold_in_local = args->local_free - args->hot_size;
        if(cold_in_local > args->buf_size - args->hot_size) {
            cold_in_local = args->buf_size - args->hot_size;
        }
        // printf("fourth mbind, cold_in_local: %lu\n", cold_in_local);
        if(cold_in_local > 0 && mbind(a, cold_in_local, MPOL_BIND, &local_nodemask, sizeof(local_nodemask)*8, MPOL_MF_STRICT) != 0) {
            fprintf(stderr, "fourth mbind failed\n");
            return NULL;
        }
        if(cold_in_local < args->buf_size - args->hot_size && mbind(a + cold_in_local, args->buf_size - args->hot_size - cold_in_local, MPOL_BIND, &remote_nodemask, sizeof(remote_nodemask)*8, MPOL_MF_STRICT) != 0) {
            fprintf(stderr, "fifth mbind failed\n");
            return NULL;
        }

        // Old manual placement mechanism
        //if(mbind(a, args->buf_size - args->hot_size, MPOL_BIND, &remote_nodemask, sizeof(remote_nodemask)*8, MPOL_MF_STRICT) != 0) {
        //     fprintf(stderr, "first mbind failed\n");
        //     return NULL;
        //}
        // Setting mbind policy only for hot set. cold set will be allocated in remaining space
        // if(args->local_hot_pages > 0){
        //     if(mbind(a + args->buf_size - args->hot_size, args->local_hot_pages*pg_size, MPOL_BIND, &local_nodemask, sizeof(local_nodemask)*8, MPOL_MF_STRICT) != 0) {
        //         fprintf(stderr, "second mbind failed\n");
        //         return NULL;
        //     }
        // }
        // if(mbind(a + args->buf_size - args->hot_size + args->local_hot_pages*pg_size, args->hot_size - args->local_hot_pages*pg_size, MPOL_BIND, &remote_nodemask, sizeof(remote_nodemask)*8, MPOL_MF_STRICT) != 0) {
        //     fprintf(stderr, "third mbind failed\n");
        //     return NULL;
        // }
    }
    
    // printf("allocated %lu buf\n", args->buf_size);
    // memset(a, 'm', args->buf_size);
    // Fill buffer in reverse order, so that hot set pages fault and are allocated first (so that mbind policy can be satisfied)
    // Remaining memory will be used to opportunistically allocate cold set pages
    if(args->manual_placement) {
        // for(char *p = a + args->buf_size-1; p >= a; p--) {
            // *p = 'm';
            // asm volatile("" : : : "memory");
        // }
        memset(a, 'm', args->buf_size);
    } else {
        memset(a, 'm', args->buf_size);
    }

    asm volatile("" : : : "memory");
    
    if(args->manual_placement && args->reset_mbind) {
        // reset mbind policy to default
        if(mbind(a, args->buf_size, MPOL_DEFAULT, NULL, 0, 0) != 0) {
                fprintf(stderr, "reset mbind failed\n");
                return NULL;
        }
        fprintf(stderr, "resent mbind\n");
    }

    asm volatile("" : : : "memory");
    

    // Prevent compiler reordering
    

    // Perform manual placement if needed
    // if(args->manual_placement) {
    //     size_t pg_count = (args->buf_size)/4096ULL;
    //     size_t hot_pg_count = (args->hot_size)/4096ULL;
    //     void **page_ptrs = (void **)malloc(pg_count*sizeof(void *));
    //     int *target_nodes = (int *)malloc(pg_count*sizeof(int));
    //     int *move_status = (int *)malloc(pg_count*sizeof(int));
    //     if(!page_ptrs || !target_nodes || !move_status) {
    //         fprintf(stderr, "malloc failed in manual memory placement\n");
    //         return NULL;
    //     }
    //     for(int pg_idx = 0; pg_idx < pg_count; pg_idx++) {
    //         page_ptrs[pg_idx] = a + pg_idx*4096;
    //         move_status[pg_idx] = 1024;
    //     }
    //     // Get current locations of pages
    //     if(move_pages(0, pg_count, page_ptrs, NULL, move_status, 0) != 0) {
    //         fprintf(stderr, "move_pages to remote failed\n");
    //         return NULL;
    //     }
    //     size_t status_local = 0, status_remote = 0, status_fault = 0;
    //     for(int pg_idx = 0; pg_idx < pg_count; pg_idx++) {
    //         if(move_status[pg_idx] == LOCAL_NUMA) status_local += 1;
    //         else if (move_status[pg_idx] == REMOTE_NUMA) status_remote += 1;
    //         else if (move_status[pg_idx] == -14) status_fault += 1;
    //         else {
    //             printf("Different status: %d\n", move_status[pg_idx]);
    //         }
    //     }
    //     printf("status local: %lu, status remote: %lu, status_fault: %lu\n", status_local, status_remote, status_fault);
    //     // All pages in remote except required number of hot pages in local
    //     size_t local_pg_count = 0;
    //     for(int pg_idx = 0; pg_idx < pg_count; pg_idx++) {
    //         int in_local = (pg_idx >= pg_count - hot_pg_count && pg_idx < pg_count - hot_pg_count + args->local_hot_pages);
    //         target_nodes[pg_idx] = (in_local)?(LOCAL_NUMA):(REMOTE_NUMA);
    //         if(in_local) local_pg_count += 1;
    //     }
    //     printf("local_pg_count: %lu\n", local_pg_count);
    //     if(move_pages(0, pg_count, page_ptrs, target_nodes, move_status, MPOL_MF_MOVE) != 0) {
    //         fprintf(stderr, "move_pages to remote failed\n");
    //         return NULL;
    //     }
    //     status_local = 0; status_remote = 0; status_fault = 0;
    //     for(int pg_idx = 0; pg_idx < pg_count; pg_idx++) {
    //         if(move_status[pg_idx] == LOCAL_NUMA) status_local += 1;
    //         else if (move_status[pg_idx] == REMOTE_NUMA) status_remote += 1;
    //         else if (move_status[pg_idx] == -14) status_fault += 1;
    //         else {
    //             printf("Different status: %d\n", move_status[pg_idx]);
    //         }
    //     }
    //     printf("status local: %lu, status remote: %lu, status_fault: %lu\n", status_local, status_remote, status_fault);
    //     free(page_ptrs);
    //     free(target_nodes);
    //     free(move_status);
    // }

    uint64_t x = 432437644 + args->thread_id;
    uint64_t count = 0, prev_count = 0;
    __m512i sum = _mm512_set_epi32(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    __m512i val = _mm512_set_epi32(1995, 1995, 2002, 2002, 1995, 1995, 2002, 2002, 1995, 1995, 2002, 2002, 1995, 1995, 2002, 2002);
    int i;
    char *hot_start = a + (args->buf_size - args->hot_size);
    // char *cold_start = a;
    size_t hot_slots = args->hot_size / 64;
    size_t cold_slots = (args->buf_size)/64;
    char *start;
    size_t slots;
    char *chunk;
    while(count < 999999999999999ULL) {
        #if defined(WORKLOAD_READWRITE)
        for(i = 0; i < 131072; i++) {
            x ^= x << 13;
            x ^= x >> 7;
            x ^= x << 17;
            start = (x%100 < 90)?(hot_start):(a);
            slots = (x%100 < 90)?(hot_slots):(cold_slots);
            x ^= x << 13;
            x ^= x >> 7;
            x ^= x << 17;
            chunk = start + 64*(x%slots);
            __m512i mm_a = _mm512_load_si512(chunk);
            _mm512_store_si512(chunk, _mm512_add_epi32(mm_a, val));
            count++;
        }
        #elif defined(WORKLOAD_READ)
        for(i = 0; i < 131072; i++) {
            x ^= x << 13;
            x ^= x >> 7;
            x ^= x << 17;
            start = (x%100 < 90)?(hot_start):(a);
            slots = (x%100 < 90)?(hot_slots):(cold_slots);
            x ^= x << 13;
            x ^= x >> 7;
            x ^= x << 17;
            chunk = start + 64*(x%slots);
            __m512i mm_a = _mm512_load_si512(chunk);
            sum = _mm512_add_epi32(sum, mm_a);
            count++;
        }
        #elif defined(WORKLOAD_2TO1)
        for(i = 0; i < 65536; i++) {
            x ^= x << 13;
            x ^= x >> 7;
            x ^= x << 17;
            start = (x%100 < 90)?(hot_start):(a);
            slots = (x%100 < 90)?(hot_slots):(cold_slots);
            x ^= x << 13;
            x ^= x >> 7;
            x ^= x << 17;
            chunk = start + 64*(x%slots);
            __m512i mm_a = _mm512_load_si512(chunk);
            sum = _mm512_add_epi32(sum, mm_a);
            count++;
            x ^= x << 13;
            x ^= x >> 7;
            x ^= x << 17;
            start = (x%100 < 90)?(hot_start):(a);
            slots = (x%100 < 90)?(hot_slots):(cold_slots);
            x ^= x << 13;
            x ^= x >> 7;
            x ^= x << 17;
            chunk = start + 64*(x%slots);
            mm_a = _mm512_load_si512(chunk);
            _mm512_store_si512(chunk, _mm512_add_epi32(mm_a, val));
            count++;
        }
        #elif defined(WORKLOAD_3TO1)
        for(i = 0; i < 45000; i++) {
            x ^= x << 13;
            x ^= x >> 7;
            x ^= x << 17;
            start = (x%100 < 90)?(hot_start):(a);
            slots = (x%100 < 90)?(hot_slots):(cold_slots);
            x ^= x << 13;
            x ^= x >> 7;
            x ^= x << 17;
            chunk = start + 64*(x%slots);
            __m512i mm_a = _mm512_load_si512(chunk);
            sum = _mm512_add_epi32(sum, mm_a);
            count++;
            x ^= x << 13;
            x ^= x >> 7;
            x ^= x << 17;
            start = (x%100 < 90)?(hot_start):(a);
            slots = (x%100 < 90)?(hot_slots):(cold_slots);
            x ^= x << 13;
            x ^= x >> 7;
            x ^= x << 17;
            chunk = start + 64*(x%slots);
            mm_a = _mm512_load_si512(chunk);
            sum = _mm512_add_epi32(sum, mm_a);
            count++;
            x ^= x << 13;
            x ^= x >> 7;
            x ^= x << 17;
            start = (x%100 < 90)?(hot_start):(a);
            slots = (x%100 < 90)?(hot_slots):(cold_slots);
            x ^= x << 13;
            x ^= x >> 7;
            x ^= x << 17;
            chunk = start + 64*(x%slots);
            mm_a = _mm512_load_si512(chunk);
            _mm512_store_si512(chunk, _mm512_add_epi32(mm_a, val));
            count++;
        }
        #else
            #error "Define WORKLOAD"
        #endif

        
        atomic_store(args->count_ptr, count);
        if(atomic_load(&(g_move_hotset))) {
            hot_start = a;
        }
        if(atomic_load(&(args->finish))) {
            if(munmap(a, args->buf_size) != 0) {
                printf("munmap failed\n");
            }
		    return NULL;
        }
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
    //pg_size = 4096ULL;
    pg_size = 2ULL*1024ULL*1024ULL;
    if(getenv("GUPS_HUGEPAGES") != NULL) {
        pg_size = 2ULL*1024ULL*1024ULL;
    }
    setbuf(stdout, NULL);
    int cores[32] = {1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45,47,49,51,53,55,57,59,61,63};
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <num_threads> [manual] [fraction of hotset in local] [distribute/localize] [reset]\n", argv[0]);
        return 1;
    }

    int num_threads = atoi(argv[1]);
    if (num_threads <= 0 || num_threads > MAX_THREADS) {
        fprintf(stderr, "Number of threads invalid\n");
        return 1;
    }

    int manual_placement = 0;
    float hotset_local_frac = 0.0;
    int placement_mode = 0;
    int reset_mbind = 0;
    size_t local_free = 0;
    enum {
        PLACEMENT_DISTRIBUTE,
        PLACEMENT_LOCALIZE
    };
    if(argc >= 3 && strncmp(argv[2], "manual", sizeof("manual")) == 0) {
        if(argc < 5) {
            fprintf(stderr, "Usage: %s <num_threads> [manual] [fraction of hotset in local] [distribute/localize] [reset]\n", argv[0]);
            return 1;
        }
        manual_placement = 1;
        hotset_local_frac = atof(argv[3]);
        if(strncmp(argv[4], "distribute", sizeof("distribute")) == 0) {
            placement_mode = PLACEMENT_DISTRIBUTE;
        } else if(strncmp(argv[4], "localize", sizeof("localize")) == 0) {
            placement_mode = PLACEMENT_LOCALIZE;
        } else {
            fprintf(stderr, "Unknown manual placement mode\n");
            return 1;
        }
        if(argc >= 6 && strncmp(argv[5], "reset", sizeof("reset")) == 0) {
            reset_mbind = 1;
        }

        numa_node_size(LOCAL_NUMA, &local_free);
        printf("Free size: %lu\n", local_free);
        local_free -= 10*pg_size; // Leave buffer
    }

    int move_hotset = 0;
    int move_time = 0;

    if(argc >= 3 && strncmp(argv[2], "move", sizeof("move")) == 0) {
        if(argc < 4) {
            fprintf(stderr, "Usage: %s <num_threads> [move] [move time]\n", argv[0]);
            return 1;
        }
        move_hotset = 1;
        move_time = atoi(argv[3]);
    }
    atomic_init(&g_move_hotset, 0);

    // Get TSC frequency
    // int msr_fd;
    // ssize_t ret;
    // uint64_t msr_val;
    // msr_fd = open("/dev/cpu/0/msr", O_RDWR);
    // if(msr_fd == -1) {
    //     fprintf(stderr, "An error occurred while opening msr file.\n");
	// 	return EXIT_FAILURE;
    // }
    // ret = pread(msr_fd, &msr_val, sizeof(msr_val), 0xCEL);
    // TSC_ratio = (msr_val & 0x000000000000ff00L) >> 8;

    _Atomic uint64_t thread_counts[MAX_THREADS];
    pthread_t threads[MAX_THREADS];
    ThreadArgs thread_args[MAX_THREADS];
    cpu_set_t cpuset;

    if(manual_placement && placement_mode == PLACEMENT_DISTRIBUTE) {
        for(int i = 0; i < num_threads; i++) {
            thread_args[i].local_hot_pages = (int)(hotset_local_frac*((HOTSS/pg_size)/((size_t)num_threads)));
        }
    } else if(manual_placement && placement_mode == PLACEMENT_LOCALIZE) {
        size_t total_local_pages = (int)(hotset_local_frac*(HOTSS/pg_size));
        size_t per_thread_hot_pages = ((HOTSS/pg_size)/((size_t)num_threads));
        for(int i = 0; i < num_threads; i++) {
            if(total_local_pages > 0){
                size_t num_pages = (total_local_pages < per_thread_hot_pages)?(total_local_pages):(per_thread_hot_pages);
                thread_args[i].local_hot_pages = num_pages;
                total_local_pages -= num_pages; 
            } else {
                thread_args[i].local_hot_pages = 0;
            }
        }
    }

    for (int i = 0; i < num_threads; ++i) {
        thread_args[i].thread_id = i;
        thread_args[i].buf_size = ((WSS/pg_size)/((size_t)num_threads))*pg_size;
        thread_args[i].hot_size = ((HOTSS/pg_size)/((size_t)num_threads))*pg_size;
        atomic_init(&thread_counts[i], 0);
        thread_args[i].count_ptr = &thread_counts[i];
        thread_args[i].manual_placement = manual_placement;
        thread_args[i].reset_mbind = reset_mbind;
        thread_args[i].local_free = ((local_free/pg_size)/((size_t)num_threads))*pg_size;
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
        if(elapsed == move_time) {
            printf("moved hotset\n");
            atomic_store(&g_move_hotset, 1);
        }
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
