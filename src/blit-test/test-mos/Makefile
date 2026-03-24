include ../../Makefile.defs

TARGETS=testmos68k.bin
DEPS=$(INC)/mos.inc $(INC)/oslib.inc $(INC)/hardware.inc

OBJS=	romheader.o \
	romvectors.o \
	kernel_reset.o \
	test-mos.o
	
OBJS_B=$(addprefix $(BUILD)/, $(OBJS))
TARGETS_B=$(addprefix $(BUILD)/, $(TARGETS))

all: $(TARGETS_B)


$(BUILD)/%.bin: $(BUILD)/%.elf
	$(OBJCOPY) -O binary $< $@
	echo "M.TEST68K FF7D0000 FFFFFFFF" >$@.inf

$(BUILD)/testmos68k.elf: $(OBJS_B) testmos68k.lnk.txt
	$(LD) $(LDFLAGS) -Os -nostartfiles -nostdlib -Wl,-Map=$(basename $@).map,--cref -T $(filter %.lnk.txt, $^) --entry=START -o $@ $(filter %.o, $^)
	$(SCRIPTS)/getsymbols_gnu.pl $(basename $@).map $(OBJS_B:%.o=%.lst) >$(basename $@).noi

$(BUILD)/%.o: $(DEPS)
$(BUILD)/%.o: %.S 
	$(AS) $(ASFLAGS) -o $@ -Wa,-acglms=$(addsuffix .lst,$(basename $@)) $<

ssd:all
deploy:ssd

clean::
	-rm $(TARGETS_B) 
	-rm $(TARGETS_B:%.bin=%.elf) 
	-rm $(addsuffix .inf, $(TARGETS_B))
	-rm $(OBJS_B) 
	-rm $(addsuffix .lst, $(basename $(OBJS_B)))
	-rm $(addsuffix .sym, $(basename $(TARGETS_B)))
	-rm $(addsuffix .noi, $(basename $(TARGETS_B)))
	

