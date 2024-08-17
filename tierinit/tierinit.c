#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/debugfs.h>
#include <linux/slab.h>
#include <linux/version.h>
#include <linux/mm.h>
#include <linux/memory-tiers.h>

#define MEMTIER_DEFAULT_FARMEM_ADISTANCE	(MEMTIER_ADISTANCE_DRAM * 10)
#define FARMEM_NUMA 0
#define LOCAL_NUMA 1

static struct memory_dev_type *farmem_type;
 
static int tierinit_init(void)
{
    pr_info("next_demotion_node[%d]=%d", LOCAL_NUMA, next_demotion_node(LOCAL_NUMA));
    
    farmem_type = alloc_memory_type(MEMTIER_DEFAULT_FARMEM_ADISTANCE);
    if(IS_ERR(farmem_type)) {
        pr_info("Error creating memory type");
        return -1;
    }

    colloid_clear_memory_tier(FARMEM_NUMA);
    pr_info("cleared NUMA node from memory tier");
    clear_node_memory_type(FARMEM_NUMA, colloid_get_default_dram_memtype());
    pr_info("cleared NUMA node from default DRAM mem type");
    init_node_memory_type(FARMEM_NUMA, farmem_type);
    pr_info("init numa node to farmem type");
    colloid_init_memory_tier(FARMEM_NUMA);
    pr_info("init numa node to new memory tier");

    pr_info("next_demotion_node[%d]=%d", LOCAL_NUMA, next_demotion_node(LOCAL_NUMA));
    if(node_is_toptier(FARMEM_NUMA)) {
        pr_info("farmem node is top tier :(");
    } else {
        pr_info("farmem node is not top tier :)");
    }
    pr_info("Done :)");
    
    return 0;
}
 
static void tierinit_exit(void)
{
    // Reset to normal DRAM mem type
    colloid_clear_memory_tier(FARMEM_NUMA);
    pr_info("cleared NUMA node from new memory tier");
    clear_node_memory_type(FARMEM_NUMA, farmem_type);
    pr_info("cleared NUMA node from farmem type");
    // NOTE: We should not call init_node_memory_type for default dram memtype
    // since it is already called internally in set_node_memory_tier
    // If we do, map_count will be spuriously double incremented
    //init_node_memory_type(FARMEM_NUMA, colloid_get_default_dram_memtype());
    //pr_info("init numa node to default dram mem type");
    colloid_init_memory_tier(FARMEM_NUMA);
    pr_info("init numa node to original memory tier");

    pr_info("next_demotion_node[%d]=%d", LOCAL_NUMA, next_demotion_node(LOCAL_NUMA));
    if(node_is_toptier(FARMEM_NUMA)) {
        pr_info("farmem node is top tier :)");
    } else {
        pr_info("farmem node is not top tier :(");
    }

    destroy_memory_type(farmem_type);
    pr_info("tierinit exit");
}
 
module_init(tierinit_init);
module_exit(tierinit_exit);
MODULE_AUTHOR("Midhul");
MODULE_LICENSE("GPL");
