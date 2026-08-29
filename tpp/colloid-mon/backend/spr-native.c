#include "backend_iface.h"
#include <linux/kernel.h>
#include <asm/msr.h>

#define CHA_BOX_STRIDE           0x10ULL
#define CHA_MSR_PMON_BASE        0x2000ULL
#define CHA_MSR_CTL0_BASE        0x2002ULL
#define CHA_MSR_CTR0_BASE        0x2008ULL
#define CHA_MSR_FILTER0_BASE     0x200EULL
#define CHA_MSR_STATUS_BASE      0x2001ULL


#define NUM_CHA_BOXES 34
#define NUM_CHA_COUNTERS 4

static int core_mon;

int backend_init(struct backend_config* config) {
    int cha, ret;
    u32 msr_num;
    u64 msr_val;

    if (!config) 
        printk(KERN_ERR "spr-native: invalid backend_config passed\n");
        return -1;
    }

    core_mon = config->core;
    pr_info("colloid: core mon %d\n", core_mon);

    for (cha = 0; cha < NUM_CHA_BOXES; cha++) {
        msr_num = CHA_MSR_FILTER0_BASE + (CHA_BOX_STRIDE * cha); // Filter0
        msr_val = 0x00000000; // default; no filtering
        ret = wrmsr_on_cpu(core_mon, msr_num, msr_val & 0xFFFFFFFF, msr_val >> 32);
        if (ret != 0) {
            printk(KERN_ERR "spr-native: wrmsr FILTER0 failed\n");
            return -1;
        }

        msr_num = CHA_MSR_CTL0_BASE + (CHA_BOX_STRIDE * cha) + 0; // counter 0
        msr_val = (cha%2==0)?(0x00c8168600000136):(0x00c8170600000136); // TOR Occupancy, DRd, Miss, local/remote on even/odd CHA boxes
        ret = wrmsr_on_cpu(core_mon, msr_num, msr_val & 0xFFFFFFFF, msr_val >> 32);
        if(ret != 0) {
            printk(KERN_ERR "spr-native: wrmsr COUNTER 0 failed\n");
            return -1;
        }

        msr_num = CHA_MSR_CTL0_BASE + (CHA_BOX_STRIDE * cha) + 1; // counter 1
        msr_val = (cha%2==0)?(0x00c8168600000135):(0x00c8170600000135); // TOR Inserts, DRd, Miss, local/remote on even/odd CHA boxes
        ret = wrmsr_on_cpu(core_mon, msr_num, msr_val & 0xFFFFFFFF, msr_val >> 32);
        if(ret != 0) {
            printk(KERN_ERR " spr-native: wrmsr COUNTER 1 failed\n");
            return -1;
        }

        msr_num = CHA_MSR_CTL0_BASE + (CHA_BOX_STRIDE * cha) + 2; // counter 2
        msr_val = 0x1; // CLOCKTICKS
        ret = wrmsr_on_cpu(core_mon, msr_num, msr_val & 0xFFFFFFFF, msr_val >> 32);
        if(ret != 0) {
            printk(KERN_ERR "spr-native: wrmsr COUNTER 2 failed\n");
            return -1;
        }
    }

    return 0;
}

int backend_destroy() {
    return 0;
}


u64 backend_read_occupancy(int tier) {
    int cha, ctr;
    u32 msr_num, msr_high, msr_low;
    cha = tier; // Default tier on CHA slice 0, Alternate tier on CHA slice 1
    ctr = 0; // Occupancy
    msr_num = CHA_MSR_CTR0_BASE + (CHA_BOX_STRIDE * cha) + ctr;    
    rdmsr_on_cpu(core_mon, msr_num, &msr_low, &msr_high);
    return ((((u64)msr_high) << 32) | ((u64)msr_low));
}

u64 backend_read_inserts(int tier) {
    int cha, ctr;
    u32 msr_num, msr_high, msr_low;
    cha = tier; // Default tier on CHA slice 0, Alternate tier on CHA slice 1
    ctr = 1; // Inserts
    msr_num = CHA_MSR_CTR0_BASE + (CHA_BOX_STRIDE * cha) + ctr;    
    rdmsr_on_cpu(core_mon, msr_num, &msr_low, &msr_high);
    return ((((u64)msr_high) << 32) | ((u64)msr_low));
}

