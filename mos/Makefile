AS=vasmm68k_mot.exe
ASFLAGS=-pic -m68008 -spaces -ldots -I ../includes -D MACH_BEEB=1 -D MACH_CHIPKIT=0
ASFLAGS2=-m68008 -spaces -ldots -I ../includes -D MACH_BEEB=1 -D MACH_CHIPKIT=0

TARGETS=mos68k.bin mos68k.noi
DEPS=../includes/mos.inc ../includes/oslib.inc ../hardware.inc

OBJS=	font.o \
	vdu.o \
	kernel.o \
	kernel_swi.o \
	romheader.o \
	romvectors.o \
	deice.o \
	defaultosvectors.o \
	keyboard.o \
	defaultsysvars.o \
	kernel_reset.o \
	kernel_interrupts.o \
	kernel_events.o \
	kernel_sound.o \
	kernel_buffers.o

OBJS2=$(addprefix obj/, $(OBJS))

HOSTFSDIR=~/hostfs/test68008

all:: $(TARGETS)

hostfs:: all
	cp $(TARGETS) $(HOSTFSDIR)


mos68k.bin: $(OBJS2) debugsyms.noi mos68k.lnk.txt 
	vlink -M -T mos68k.lnk.txt -b rawbin1 -o $@ $(OBJS2) > mos68k.sym
	../scripts/getsymbols.pl <$(basename $@).sym >$(basename $@).noi
	if [[ -e debugsyms.noi ]]; then \
		cat $(basename $@).noi debugsyms.noi >tmp.noi; \
		mv tmp.noi $(basename $@).noi; \
	fi

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
	

