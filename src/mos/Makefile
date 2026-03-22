include ../Makefile.defs


TARGETS=mos68k.bin mos68k.noi
DEPS=$(INC)/mos.inc $(INC)/oslib.inc $(INC)/hardware.inc

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
	kernel_buffers.o \
	kernel_errors.o

OBJS_B=$(addprefix $(BUILD)/, $(OBJS))
TARGETS_B=$(addprefix $(BUILD)/, $(TARGETS))

all: $(TARGETS_B)


$(BUILD)/mos68k.noi: $(BUILD)/mos68k.bin debugsyms.noi 
	$(SCRIPTS)/getsymbols.pl <$(basename $@).sym >$(basename $@).noi
	if [ -e debugsyms.noi ]; then \
		cat $(basename $@).noi debugsyms.noi >tmp.noi; \
		mv tmp.noi $(basename $@).noi; \
	fi

$(BUILD)/mos68k.bin: $(OBJS_B) mos68k.lnk.txt 
	vlink -M -T mos68k.lnk.txt -b rawbin1 -o $@ $(OBJS_B) > $(BUILD)/mos68k.sym
	echo "M.MOS68K FF7D0000 FFFFFFFF" >$@.inf


$(BUILD)/%.o: $(DEPS)
$(BUILD)/%.o: %.asm 
	$(AS) $(ASFLAGS) -Fvobj -o $@ -L $(basename $@).lst $<

clean::
	-rm $(TARGETS_B) 
	-rm $(OBJS_B) 
	-rm $(addsuffix .lst, $(basename $(OBJS_B)))
	-rm $(addsuffix .sym, $(basename $(TARGETS_B)))
	-rm $(addsuffix .noi, $(basename $(TARGETS_B)))
	

