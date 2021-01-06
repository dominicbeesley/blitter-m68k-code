

		include "mos.inc"
		include "oslib.inc"
		include "hardware.inc"
		include "kernel_defs.inc"
		include "deice.inc"
		include "macros.inc"

		xdef 	keyb_check_key_code_API
		xdef	x_Turn_on_Keyboard_indicators_API
		xdef 	mos_enter_keyboard_routines

		SECTION "code"


; : Turn on Keyboard indicators
; no longer mucks about with flags in D0(A)! instead just preserves them
x_Turn_on_Keyboard_indicators_API			; LEEEB
		move.w	SR,-(SP)
		move.w	D0,-(SP)
		move.b	sysvar_KEYB_STATUS,D0		;read keyboard status;
							;Bit 7  =1 shift enabled
							;Bit 6  =1 control pressed
							;bit 5  =0 shift lock
							;Bit 4  =0 Caps lock
							;Bit 3  =1 shift pressed    
		lsr.b	#1,D0				;shift Caps bit into bit 3
		andi.b	#$18,D0				;mask out all but 4 and 3
		ori.b	#$06,D0				;returns 6 if caps lock OFF &E if on
		move.b	D0,sheila_SYSVIA_orb		;turn on or off caps light if required
		lsr.b	#1,D0				;bring shift bit into bit 3
		ori.b	#$07,D0				;
		move.b	D0,sheila_SYSVIA_orb		;turn on or off shift  lock light
		bsr	keyb_hw_enable_scan		;set keyboard counter
		move.w	(SP)+,D0
		rtr




;; ----------------------------------------------------------------------------
;; Interrogate Keyboard routine;
		; NOTE: API change D1 now contains key code to scan, D0 is preserved
		; NB: needs to preserve carry!
keyb_check_key_code_API
		move.w	SR,-(A7)
		move.b	#$03,sheila_SYSVIA_orb		;stop Auto scan by writing to system VIA
		move.b	#$7F,sheila_SYSVIA_ddra		;set bits 0 to 6 of port A to input on bit 7
							;output on bits 0 to 6
		move.b	D1,sheila_SYSVIA_ora_nh		;write X to Port A system VIA
		move.b	sheila_SYSVIA_ora_nh,D1		;read back &80 if key pressed (M set)
		move.w	(A7)+,CCR
		rts					;and return


keyb_hw_enable_scan
		move.b	#$0B,sheila_SYSVIA_orb
		rts

mos_enter_keyboard_routines
		rts
