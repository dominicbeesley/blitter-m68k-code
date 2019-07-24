AS=vasmm68k_mot_win32.exe
ASFLAGS=-m68008 -spaces -ldots -I ../includes -D MACH_BEEB=1 -D MACH_CHIPKIT=0

TARGETS=mos68k.bin

all:: $(TARGETS)


%.bin: %.asm
	$(AS) $(ASFLAGS) -Fbin -o $@ -L $(basename $@).lst $<
	cp $@ /cygdrive/d/cygwin64/home/dominic/hostfs/test68008

clean::
	rm $(TARGETS)
	

