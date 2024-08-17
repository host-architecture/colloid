obj-m   := tierinit.o
KDIR    := /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd) 
  
all: 
		$(MAKE) -C $(KDIR) M=${PWD} SUBDIRS=$(PWD) modules

clean:
		rm -f *.ko *.o *.mod *.mod.c modules.order Module.symvers test