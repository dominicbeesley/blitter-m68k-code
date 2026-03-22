;; (c) 2019 Dossytronics, Dominic Beesley	

		include "mos.inc"
		include "oslib.inc"
		include "hardware.inc"
;;
;; This file provides a phony BBC/MOS rom header so that the rom shows up in *ROMS
;;


		SECTION "romheader"
base:
;phony rom header so we can see ourself in *ROMS
		dcb.b	6, $00
		dc.b	$68				; special 68k mos type
		dc.b	copy-base
		dc.b	$00
		dc.b	"m68k MOS",0,"v0.00"

copy:		dc.b	0, "(C) Dossytronics 2019", 0

