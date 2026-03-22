	include ../Makefile.defs

SUBDIRS:=test-mos

SSD=$(SSDS)/test68k.ssd

.PHONY: clean all $(SUBDIRS)

all: $(SUBDIRS)

ssd: all $(SSD)

clean: $(SUBDIRS)
	-rm $(SSD)	

$(SUBDIRS): 
	$(MAKE) -C $@ $(MAKECMDGOALS)


$(SSD): 
	dfs form -80 $(SSD)
	dfs title $(SSD) "test68k"
	dfs add $(SSD) extras/*.inf
	dfs add $(SSD) $(BUILD)/test-mos/*.inf
	dfs opt4 -3 $(SSD)

deploy: ssd
	mkdir -p $(DEPLOY_TOP)/test68k
	dfs read -i -d $(DEPLOY_TOP)/test68k $(SSD)



