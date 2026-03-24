/* (c) 2019 Dossytronics, Dominic Beesley */

/*
 This file provides a phony BBC/MOS rom header so that the rom shows up in *ROMS
*/


		.SECTION romheader, "ax", @progbits
base:
/* phony rom header so we can see ourself in *ROMS */
		.dcb.b	6, 0x00
		dc.b	0x68				/* special 68k mos type */
		dc.b	copy-base
		dc.b	0x00
		.ascii	"m68k TEST MOS"
		dc.b	0
		.ascii	"v0.00"

copy:		dc.b	0
		.asciz	"(C) Dossytronics 2026"

