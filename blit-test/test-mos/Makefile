AS=vasmm68k_mot.exe
ASFLAGS=-m68008 -spaces -ldots -I ../../includes -D MACH_BEEB=1 -D MACH_CHIPKIT=0
ASFLAGS2=-m68008 -spaces -ldots -I ../../includes -D MACH_BEEB=1 -D MACH_CHIPKIT=0

TARGETS=testmos68k.bin testmos68k.noi
DEPS=../../includes/mos.inc ../../includes/oslib.inc ../../hardware.inc

OBJS=	romheader.o \
	romvectors.o \
	kernel_reset.o \
	test-mos.o
	
OBJS2=$(addprefix obj/, $(OBJS))

HOSTFSDIR=~/hostfs/test68008

all:: $(TARGETS)

hostfs:: all
	cp $(TARGETS) $(HOSTFSDIR)


testmos68k.bin: $(OBJS2) testmos68k.lnk.txt 
	vlink -M -T testmos68k.lnk.txt -b rawbin1 -o $@ $(OBJS2) > testmos68k.sym
	../../scripts/getsymbols.pl <$(basename $@).sym >$(basename $@).noi

obj/%.o: $(DEPS)
obj/%.o: %.asm 
	$(AS) $(ASFLAGS) -Fvobj -o $@ -L $(basename $@).lst $<

obj/romvectors.o: romvectors.asm 
	$(AS) $(ASFLAGS2) -Fvobj -o $@ -L $(basename $@).lst $<


clean::
	-rm $(TARGETS) 
	-rm $(OBJS2) 
	-rm $(addprefix obj/, $(addsuffix .lst, $(basename $(OBJS))))
	-rm $(addsuffix .sym, $(basename $(TARGETS)))
	-rm $(addsuffix .noi, $(basename $(TARGETS)))
	

