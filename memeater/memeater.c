#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/debugfs.h>
#include <linux/slab.h>
#include <linux/version.h>
#include <linux/mm.h>
#include <linux/vmalloc.h>
#include <linux/gfp.h>
#include <linux/moduleparam.h>
#include <linux/memory-tiers.h>

#define FARMEM_NUMA 0
#define LOCAL_NUMA 1


static int sizeMiB = 0;
module_param(sizeMiB, int, 0);

static int PGSIZE = 4096;
module_param(PGSIZE, int, 0);

static int PGORDER = 0;
module_param(PGORDER, int, 0);

static size_t size;
static struct page **page_list;
 
static int memeater_init(void)
{
    int i;
    size_t num_pages;
    size = sizeMiB*1024ULL*1024ULL;
    if(size == 0) {
        pr_info("sizeMiB not specified or invalid");
        return -1;
    }
    
    num_pages = size/((size_t)PGSIZE);
    page_list = vmalloc(num_pages * sizeof(struct page *));
    if(page_list == NULL) {
        pr_info("failed to allocate page_list");
        return -1;
    }
    for(i = 0; i < num_pages; i++) {
        page_list[i] = NULL;
    }

    // allocate the pages
    for(i = 0; i < num_pages; i++) {
        // page_list[i] = alloc_pages_exact_nid(LOCAL_NUMA, 4096, GFP_KERNEL);
        page_list[i] = alloc_pages_node(LOCAL_NUMA, GFP_KERNEL, PGORDER);
        if(page_list[i] == NULL) {
            pr_info("alloc_pages failed");
            goto err;
        }
    }

    pr_info("memeater init done");
    return 0;

err:
    for(i = 0; i < num_pages; i++) {
        if(page_list[i] != NULL) {
            __free_pages(page_list[i], PGORDER);
        }
    }
    vfree(page_list);
    return -1;
}
 
static void memeater_exit(void)
{
    int i;
    size_t num_pages;
    
    num_pages = size/((size_t)PGSIZE);
    for(i = 0; i < num_pages; i++) {
        if(page_list[i] != NULL) {
            __free_pages(page_list[i], PGORDER);
        }
    }

    vfree(page_list);

   
    pr_info("memeater exit done");
}
 
module_init(memeater_init);
module_exit(memeater_exit);
MODULE_AUTHOR("Midhul");
MODULE_LICENSE("GPL");
