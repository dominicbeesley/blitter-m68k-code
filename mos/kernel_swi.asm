;; (c) 2021 Dossytronics, Dominic Beesley
;
;
; As of 3/1/2021 - now uses the ABI as outlined for CiscOS - see:
; - http://mdfs.net/Software/Tube/68000/
; - http://beebwiki.mdfs.net/68000_Second_Processor




		include "mos.inc"
		include "oslib.inc"
		include "hardware.inc"
		include "kernel_defs.inc"
		include "deice.inc"
		include "macros.inc"


		xdef kernel_swi_handle

		SECTION "code"


********************************************************************************
* SWI dispatch and handling                                                    *
*                                                                              *
;;;* SWIs are emulated using TRAPS#1 and #2, #1 is a shortcut for the longer      *
;;;* #2 form with but uses fewer bytes in the program as the SWI number is        *
;;;* encoded in fewer (16 bits) instead of 24                                     *
;;;*                                                                              *
;;;* TRAP #2                                                                      *
;;;* dc.l 24 bit SWI number (in 32bit field)                                      *
;;;*                                                                              *
;;;* TRAP #1                                                                      *
;;;* dc.w 16 bit SWI number (encoded bit 15=X flag, 14..0 as SWI no)              *
;;;*                                                                              *
;;;* All SWI parameters are passed in D0..D7                                      *
;;;* All Address register should be preserved                                     *
;;;*                                                                              *
* SWIs are handled via Trap 12 with the SWI number in A0 (as per CiscOS)       *
*                                                                              *
*                                                                              *
*                                                                              *
********************************************************************************

kernel_swi_handle

	;STACK:
	;+-----+---+----------------------------------------+
	;| +2  | l | Original PC (points at SWI number WORD |
	;+-----+---+----------------------------------------+
	;| +0  | w | Original SR                            |
	;+-----+---+----------------------------------------+
	; A0 contains the SWI number


		movem.l	D0/A0,-(SP)		
		move.l  A0,D0
	;STACK:
	;+-----+---+----------------------------------------+
	;| +10 | l | Original PC (points at SWI number WORD |
	;+-----+---+----------------------------------------+
	;| +8  | w | Original SR                            |
	;+-----+---+----------------------------------------+
	;| +4  | l | A0 = SWI Number                        |
	;+-----+---+----------------------------------------+
	;| +0  | l | Original D0                            |
	;+-----+---+----------------------------------------+
	; A0 = original SWI number
	; D0 = SWI Number masked

		and.l	#$00FDFFFF, D0			; mask off X and trim to 24 bits
		cmp.l	#SWI_TABLE_LOW_COUNT,D0
		blo	low_swi
		cmp.l	#256, D0
		blo	SWI_UKSwi_restore_D0
		cmp.l	#512, D0
		blo	SWI_OS_WriteI
		bra	SWI_UKSwi_restore_D0

low_swi:	asl.l	#1,D0

	;STACK:
	;+-----+---+----------------------------------------+
	;| +10 | l | Original PC (points at SWI number WORD |
	;+-----+---+----------------------------------------+
	;| +8  | w | Original SR                            |
	;+-----+---+----------------------------------------+
	;| +4  | l | A0 = SWI Number                        |
	;+-----+---+----------------------------------------+
	;| +0  | l | Original D0                            |
	;+-----+---+----------------------------------------+
	; A0 = original SWI number
	; D0 = SWI Number * 2

		lea.l	SWI_TABLE_LOW(PC),A0
		lea.l	(A0,D0.w),A0			; A0 points at table entry
		move.w	(A0),D0				; D0 contains table entry (which is an offset from the table entry)
		lea.l	(A0,D0.w),A0			; add the table entry to A0

		move.l	(SP)+,D0			; get back saved D0

	;STACK:
	;+-----+---+----------------------------------------+
	;| +6  | l | Original PC (points at SWI number WORD |
	;+-----+---+----------------------------------------+
	;| +4  | w | Original SR                            |
	;+-----+---+----------------------------------------+
	;| +0  | l | A0 = SWI Number                        |
	;+-----+---+----------------------------------------+
	; A0 = Address of handler routine
		jsr	(A0)				; call the swi

swi_exit:	exg	D0,A0				; swap A0,D0 and retain flags
		movem.l	(SP)+,D0			; get back swi number (not use movem to retain flags)
		bvs	kernel_swi_handle_err_check
kernok:		exg	D0,A0
		; now need to get V,C into stacked SR
		move.w	D0,-(SP)
		move.w	SR,D0
		move.b	D0,3(SP)
		move.w	(SP)+,D0
		rte

kernel_swi_handle_err_check:
		btst	#17, D0
		bne	kernok				; X bit is set, return with VS	

		; an error has occurred and X was not set, generate an error
		lea.l	10(SP),SP
		move.l	(BRKV),A0
		jmp	(A0)


SWI_TABLE_LOW_COUNT	EQU	$20
SWI_TABLE_LOW	dc.w	SWI_OS_WriteC-*			; 00
		dc.w	SWI_OS_WriteS-*			; 01
		dc.w	SWI_OS_Write0-*			; 02
		dc.w	SWI_OS_NewLine-*		; 03
		dc.w	SWI_NOWT-*			; 04
		dc.w	SWI_NOWT-*			; 05
		dc.w	SWI_NOWT-*			; 06
		dc.w	SWI_UKSwi-*			; 07
		dc.w	SWI_UKSwi-*			; 08
		dc.w	SWI_UKSwi-*			; 09
		dc.w	SWI_UKSwi-*			; 0A
		dc.w	SWI_UKSwi-*			; 0B
		dc.w	SWI_UKSwi-*			; 0C
		dc.w	SWI_UKSwi-*			; 0D
		dc.w	SWI_UKSwi-*			; 0E
		dc.w	SWI_UKSwi-*			; 0F
		dc.w	SWI_UKSwi-*			; 10
		dc.w	SWI_UKSwi-*			; 11
		dc.w	SWI_UKSwi-*			; 12
		dc.w	SWI_OS_IntOn-*			; 13
		dc.w	SWI_OS_IntOff-*			; 14
		dc.w	SWI_UKSwi-*			; 15
		dc.w	SWI_UKSwi-*			; 16
		dc.w	SWI_UKSwi-*			; 17
		dc.w	SWI_UKSwi-*			; 18
		dc.w	SWI_UKSwi-*			; 19
		dc.w	SWI_UKSwi-*			; 1A
		dc.w	SWI_UKSwi-*			; 1B
		dc.w	SWI_UKSwi-*			; 1C
		dc.w	SWI_UKSwi-*			; 1D
		dc.w	SWI_UKSwi-*			; 1E
		dc.w	SWI_UKSwi-*			; 1F
		dc.w	SWI_UKSwi-*			; 20
		dc.w	SWI_UKSwi-*			; 21
		dc.w	SWI_UKSwi-*			; 22
		dc.w	SWI_UKSwi-*			; 23
		dc.w	SWI_UKSwi-*			; 24
		dc.w	SWI_UKSwi-*			; 25
		dc.w	SWI_UKSwi-*			; 26
		dc.w	SWI_UKSwi-*			; 27
		dc.w	SWI_UKSwi-*			; 28
		dc.w	SWI_UKSwi-*			; 29
		dc.w	SWI_UKSwi-*			; 2A
		dc.w	SWI_UKSwi-*			; 2B
		dc.w	SWI_OS_GenerateError-*		; 2C
		dc.w	SWI_UKSwi-*			; 2D
		dc.w	SWI_UKSwi-*			; 2E
		dc.w	SWI_UKSwi-*			; 2F



SWI_Exit_Error	; an error occurred work out if original SWI was an error returning one
		; swi number should be TOS
		btst.b	#1,1(SP)			; check error returning bit (bit #17 of SWI number)
		beq	CallErrorV
		bset	#1,$05(SP)			; set V flag
		lea.l	4(SP),SP
		rte

CallErrorV	move.l	(BRKV),A1
		jmp	(A1)


SWI_OS_GenerateError
		SEV
		rts

SWI_OS_IntOn	andi.w	#$F8FF,8(SP)
		rts
SWI_OS_IntOff	ori.w	#$0700,8(SP)
		rts

;; TODO: remove this when all implemented
; this is a "do nothing" vs the UKSwi's throw an error
SWI_NOWT:
		CLV
		rts

	;STACK:
	;+-----+---+----------------------------------------+
	;| +10 | l | Original PC (points at SWI number WORD |
	;+-----+---+----------------------------------------+
	;| +8  | w | Original SR                            |
	;+-----+---+----------------------------------------+
	;| +4  | l | A0 = SWI Number                        |
	;+-----+---+----------------------------------------+
	;| +0  | l | Original D0                            |
	;+-----+---+----------------------------------------+
	; A0 = original SWI number
	; D0 = SWI Number masked

SWI_UKSwi_restore_D0:
		move.l	(SP)+,D0
SWI_UKSwi
		lea.l	ErrBlk_UKSwi(PC),A0
		move.l	A0,D0		
		SEV
		rts

ErrBlk_UKSwi	dc.l	$1e6
		dc.b    "No Such SWI", 0


SWI_OS_WriteC	bsr	callWRCHV
		CLV
		rts

SWI_OS_WriteS	
		move.l	D0,-(SP)
	;STACK:
	;+-----+---+----------------------------------------+
	;| +14 | l | Original PC (points at SWI number WORD |
	;+-----+---+----------------------------------------+
	;| +12 | w | Original SR                            |
	;+-----+---+----------------------------------------+
	;| +8  | l | A0 = SWI Number                        |
	;+-----+---+----------------------------------------+
	;| +4  | l | Handler return                         |
	;+-----+---+----------------------------------------+	
	;| +0  | l | Saved D0.l	                            |
	;+-----+---+----------------------------------------+	

		; set A0 to point at original PC
		move.l	14(SP),A0
.lp		move.b  (A0)+,D0
		beq	.s1
		bsr	callWRCHV
		bra	.lp
.s1		; update SWI return address
		move.l	A0,D0
		addq.l	#1,D0
		bclr	#0,D0
		move.l	D0,14(SP)		; this clears V
		movem.l	(SP)+,D0
		rts

SWI_OS_Write0	move.l	D0,A0
.lp		move.b  (A0)+,D0
		beq	.s1
		bsr	callWRCHV
		bra	.lp
.s1		move.l	D0,A0
		rts

SWI_OS_NewLine	move.l	D0,-(SP)
		moveq	#13,D0
		bsr	callWRCHV
		moveq	#10,D0
		bsr	callWRCHV
		move.l	(SP)+,D0
		rts

		;;;;; CAUTION OS_WriteI is special!

SWI_OS_WriteI	
	;STACK:
	;+-----+---+----------------------------------------+
	;| +10 | l | Original PC (points at SWI number WORD |
	;+-----+---+----------------------------------------+
	;| +8  | w | Original SR                            |
	;+-----+---+----------------------------------------+
	;| +4  | l | A0 = SWI Number                        |
	;+-----+---+----------------------------------------+
	;| +0  | l | Original D0                            |
	;+-----+---+----------------------------------------+
	; A0 = original SWI number
	; D0 = SWI Number masked
		bsr	callWRCHV
		move.l	(SP)+,D0
		bra	swi_exit

