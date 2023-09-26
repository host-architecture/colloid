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
	{ 0x7e2f38b6, "next_demotion_node" },
	{ 0x122c3a7e, "_printk" },
	{ 0x5949bc4b, "alloc_memory_type" },
	{ 0x449b58ad, "colloid_clear_memory_tier" },
	{ 0x6c65b5a6, "colloid_get_default_dram_memtype" },
	{ 0xf8bc0beb, "clear_node_memory_type" },
	{ 0x39bf59a9, "init_node_memory_type" },
	{ 0x572fd75, "colloid_init_memory_tier" },
	{ 0x9f044c77, "node_is_toptier" },
	{ 0x5b8239ca, "__x86_return_thunk" },
	{ 0x84f98b55, "destroy_memory_type" },
	{ 0xbe617108, "module_layout" },
};

MODULE_INFO(depends, "");


MODULE_INFO(srcversion, "BDDAA669B255C4096FC2D2B");
