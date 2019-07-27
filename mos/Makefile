AS=vasmm68k_mot_win32.exe
ASFLAGS=-m68008 -spaces -ldots -I ../includes -D MACH_BEEB=1 -D MACH_CHIPKIT=0

TARGETS=mos68k.bin

OBJS=font.o vdu.o kernel.o romheader.o romvectors.o
OBJS2=$(addprefix obj/, $(OBJS))

all:: $(TARGETS)

mos68k.bin: $(OBJS2)
	vlink -M -T mos68k.lnk.txt -b rawbin1 -o $@ $^ > mos68k.sym
	cp $@ /cygdrive/d/cygwin64/home/dominic/hostfs/test68008


obj/%.o: %.asm
	$(AS) $(ASFLAGS) -Fvobj -o $@ -L $(basename $@).lst $<

clean::
	-rm $(TARGETS) 
	-rm $(OBJS2) 
	-rm $(addprefix obj/, $(addsuffix .lst, $(basename $(OBJS))))
	-rm $(addsuffix .sym, $(basename $(TARGETS)))
	

