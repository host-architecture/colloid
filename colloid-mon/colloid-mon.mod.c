#include <linux/module.h>
#define INCLUDE_VERMAGIC
#include <linux/build-salt.h>
#include <linux/elfnote-lto.h>
#include <linux/export-internal.h>
#include <linux/vermagic.h>
#include <linux/compiler.h>

BUILD_SALT;
BUILD_LTO_INFO;

MODULE_INFO(vermagic, VERMAGIC_STRING);
MODULE_INFO(name, KBUILD_MODNAME);

__visible struct module __this_module
__section(".gnu.linkonce.this_module") = {
	.name = KBUILD_MODNAME,
	.init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
	.exit = cleanup_module,
#endif
	.arch = MODULE_ARCH_INIT,
};

#ifdef CONFIG_RETPOLINE
MODULE_INFO(retpoline, "Y");
#endif


static const struct modversion_info ____versions[]
__used __section("__versions") = {
	{ 0xbdfb6dbb, "__fentry__" },
	{ 0xf9a482f9, "msleep" },
	{ 0x9166fc03, "__flush_workqueue" },
	{ 0x8c03d20c, "destroy_workqueue" },
	{ 0x122c3a7e, "_printk" },
	{ 0x5b8239ca, "__x86_return_thunk" },
	{ 0x49cd25ed, "alloc_workqueue" },
	{ 0x23d1b90, "wrmsr_on_cpu" },
	{ 0x20ba4f3e, "rdmsr_on_cpu" },
	{ 0xc5b6f236, "queue_work_on" },
	{ 0xa837590d, "colloid_nid_of_interest" },
	{ 0xa19b956, "__stack_chk_fail" },
	{ 0xd5bd3839, "colloid_local_lat_gt_remote" },
	{ 0xbe617108, "module_layout" },
};

MODULE_INFO(depends, "");


MODULE_INFO(srcversion, "DEE7F335059C22256AD4C08");
