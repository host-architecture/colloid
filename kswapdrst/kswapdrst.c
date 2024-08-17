#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/debugfs.h>
#include <linux/slab.h>
#include <linux/version.h>
#include <linux/mm.h>
#include <linux/mmzone.h>
#include <linux/memory-tiers.h>
#include <linux/delay.h>

#define FARMEM_NUMA 0
#define LOCAL_NUMA 1
#define CORE 0
#define INTERVAL_MS 5000

void thread_fun_kswapd_reset(struct work_struct *);
struct workqueue_struct *kswapd_reset_queue;
DECLARE_DELAYED_WORK(kswapd_reset, thread_fun_kswapd_reset);

int terminate_mon;

void thread_fun_kswapd_reset(struct work_struct *work) {
    // Reset kswapd failure count
    struct pglist_data *n = NODE_DATA(LOCAL_NUMA);
    WRITE_ONCE(n->kswapd_failures, 0);

    if(!READ_ONCE(terminate_mon)){
        queue_delayed_work_on(CORE, kswapd_reset_queue, &kswapd_reset, msecs_to_jiffies(INTERVAL_MS));
    }
    else{
        return;
    }
}
 
static int kswapdrst_init(void)
{
    struct pglist_data *n = NODE_DATA(LOCAL_NUMA);
    pr_info("kswapd_failures: %d", n->kswapd_failures);
    pr_info("Done :)");

    kswapd_reset_queue = alloc_workqueue("kswapd_reset_queue",  WQ_HIGHPRI | WQ_CPU_INTENSIVE, 0);
    if (!kswapd_reset_queue) {
        printk(KERN_ERR "Failed to create kswapd reset work queue\n");
        return -ENOMEM;
    }

    INIT_DELAYED_WORK(&kswapd_reset, thread_fun_kswapd_reset);

    WRITE_ONCE(terminate_mon, 0);

    queue_delayed_work_on(CORE, kswapd_reset_queue, &kswapd_reset, msecs_to_jiffies(INTERVAL_MS));
    
    return 0;
}
 
static void kswapdrst_exit(void)
{
    WRITE_ONCE(terminate_mon, 1);
    msleep(5000);
    flush_workqueue(kswapd_reset_queue);
    destroy_workqueue(kswapd_reset_queue);

    pr_info("kswapdrst exit");
}
 
module_init(kswapdrst_init);
module_exit(kswapdrst_exit);
MODULE_AUTHOR("Midhul");
MODULE_LICENSE("GPL");
