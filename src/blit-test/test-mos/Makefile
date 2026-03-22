include ../../Makefile.defs

TARGETS=testmos68k.bin testmos68k.noi
DEPS=$(INC)/mos.inc $(INC)/oslib.inc $(INC)/hardware.inc

OBJS=	romheader.o \
	romvectors.o \
	kernel_reset.o \
	test-mos.o
	
OBJS_B=$(addprefix $(BUILD)/, $(OBJS))
TARGETS_B=$(addprefix $(BUILD)/, $(TARGETS))

all: $(TARGETS_B)

$(BUILD)/testmos68k.noi: $(BUILD)/testmos68k.bin
	$(SCRIPTS)/getsymbols.pl <$(basename $@).sym >$(basename $@).noi

$(BUILD)/testmos68k.bin: $(OBJS_B) testmos68k.lnk.txt 
	$(LD) $(LDFLAGS) -M -T testmos68k.lnk.txt -b rawbin1 -o $@ $(OBJS_B) > $(BUILD)/testmos68k.sym
	echo "M.TEST68K FF7D0000 FFFFFFFF" >$@.inf

$(BUILD)/%.o: $(DEPS)
$(BUILD)/%.o: %.asm 
	$(AS) $(ASFLAGS) -Fvobj -o $@ -L $(basename $@).lst $<

ssd:all
deploy:ssd

clean::
	-rm $(TARGETS_B) 
	-rm $(OBJS_B) 
	-rm $(addsuffix .lst, $(basename $(OBJS_B)))
	-rm $(addsuffix .sym, $(basename $(TARGETS_B)))
	-rm $(addsuffix .noi, $(basename $(TARGETS_B)))
	

