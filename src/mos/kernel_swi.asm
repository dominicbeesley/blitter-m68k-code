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
* SWIs are emulated using TRAP #12 with SWI number in A0 and ARM registers     *
* mapped as at http://beebwiki.mdfs.net/68000_Second_Processor                 *
*                                                                              *
*                                                                              *
********************************************************************************

kernel_swi_handle

	;STACK:
	;+-----+---+----------------------------------------+
	;| +2  | l | Original PC 			    |
	;+-----+---+----------------------------------------+
	;| +0  | w | Original SR                            |
	;+-----+---+----------------------------------------+
	; A0 contains the SWI number


		movem.l	D0/A0,-(SP)		
		move.l  A0,D0
	;STACK:
	;+-----+---+----------------------------------------+
	;| +10 | l | Original PC                            |
	;+-----+---+----------------------------------------+
	;| +8  | w | Original SR                            |
	;+-----+---+----------------------------------------+
	;| +4  | l | A0 = SWI Number                        |
	;+-----+---+----------------------------------------+
	;| +0  | l | Original D0                            |
	;+-----+---+----------------------------------------+
	; A0 = original SWI number

		and.l	#$00FDFFFF, D0			; mask off X and trim to 24 bits

	; D0 = SWI Number masked

		cmp.l	#SWI_TABLE_LOW_COUNT,D0
		blo	low_swi
		cmp.l	#256, D0
		blo	kernel_swi_pop_UkSWI
		cmp.l	#512, D0
		blo	SWI_OS_WriteI
		bra	kernel_swi_pop_UkSWI

low_swi:	asl.l	#1,D0

	;STACK:
	;+-----+---+----------------------------------------+
	;| +10 | l | Original PC                            |
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
	;| +6  | l | Original PC 			    |
	;+-----+---+----------------------------------------+
	;| +4  | w | Original SR                            |
	;+-----+---+----------------------------------------+
	;| +0  | l | A0 = SWI Number                        |
	;+-----+---+----------------------------------------+
	; A0 = Address of handler routine
		jsr	(A0)				; call the swi

swi_exit:	exg	D0,A0				; swap A0,D0 and retain flags
		movem.l	(SP)+,D0			; get back swi number (note use movem to retain flags)
		bvs	kernel_swi_handle_err_check
kernok:		exg	D0,A0
		; now need to get V,C into stacked SR
		movem.l	D0,-(SP)			; note: needs to be a movem to preserve carry!
		move.w	SR,D0
		move.b	D0,5(SP)
		move.l	(SP)+,D0
		rte

kernel_swi_handle_err_check:
		btst	#17, D0
		bne	kernok				; X bit is set, return with VS	

		exg.l	A0, D0
		; an error has occurred and X was not set, generate an error
		bra	callBRKV


SWI_TABLE_LOW_COUNT	EQU	$80
SWI_TABLE_LOW	dc.w	SWI_OS_WriteC-*			; 00
		dc.w	SWI_OS_WriteS-*			; 01
		dc.w	SWI_OS_Write0-*			; 02
		dc.w	SWI_OS_NewLine-*		; 03
		dc.w	SWI_OS_ReadC-*			; 04
		dc.w	SWI_OS_CLI-*			; 05
		dc.w	SWI_OS_Byte-*			; 06
		dc.w	SWI_OS_Word-*			; 07
		dc.w	SWI_UKSwi-*			; 08
		dc.w	SWI_UKSwi-*			; 09
		dc.w	SWI_UKSwi-*			; 0A
		dc.w	SWI_UKSwi-*			; 0B
		dc.w	SWI_UKSwi-*			; 0C
		dc.w	SWI_UKSwi-*			; 0D
		dc.w	SWI_OS_ReadLine-*		; 0E
		dc.w	SWI_OS_Control-*		; 0F
		dc.w	SWI_UKSwi-*			; 10
		dc.w	SWI_OS_Exit-*			; 11
		dc.w	SWI_OS_SetEnv-*			; 12
		dc.w	SWI_OS_IntOn-*			; 13
		dc.w	SWI_OS_IntOff-*			; 14
		dc.w	SWI_OS_CallBack-*		; 15
		dc.w	SWI_OS_EnterOS-*		; 16
		dc.w	SWI_UKSwi-*			; 17
		dc.w	SWI_OS_BreakCtrl-*		; 18
		dc.w	SWI_UKSwi-*			; 19
		dc.w	SWI_UKSwi-*			; 1A
		dc.w	SWI_UKSwi-*			; 1B
		dc.w	SWI_UKSwi-*			; 1C
		dc.w	SWI_UKSwi-*			; 1D
		dc.w	SWI_UKSwi-*			; 1E
		dc.w	SWI_UKSwi-*			; 1F
		dc.w	SWI_UKSwi-*			; 20
		dc.w	SWI_OS_ReadUnsigned-*		; 21
		dc.w	SWI_UKSwi-*			; 22
		dc.w	SWI_UKSwi-*			; 23
		dc.w	SWI_UKSwi-*			; 24
		dc.w	SWI_UKSwi-*			; 25
		dc.w	SWI_UKSwi-*			; 26
		dc.w	SWI_UKSwi-*			; 27
		dc.w	SWI_UKSwi-*			; 28
		dc.w	SWI_UKSwi-*			; 29
		dc.w	SWI_UKSwi-*			; 2A
		dc.w	SWI_OS_GenerateError-*		; 2B
		dc.w	SWI_UKSwi-*			; 2C
		dc.w	SWI_UKSwi-*			; 2D
		dc.w	SWI_UKSwi-*			; 2E
		dc.w	SWI_UKSwi-*			; 2F


		dc.w	SWI_NOWT-*			; 30
		dc.w	SWI_UKSwi-*			; 31
		dc.w	SWI_UKSwi-*			; 32
		dc.w	SWI_UKSwi-*			; 33
		dc.w	SWI_UKSwi-*			; 34
		dc.w	SWI_UKSwi-*			; 35
		dc.w	SWI_UKSwi-*			; 36
		dc.w	SWI_UKSwi-*			; 37
		dc.w	SWI_UKSwi-*			; 38
		dc.w	SWI_UKSwi-*			; 39
		dc.w	SWI_UKSwi-*			; 3A
		dc.w	SWI_UKSwi-*			; 3B
		dc.w	SWI_UKSwi-*			; 3C
		dc.w	SWI_UKSwi-*			; 3D
		dc.w	SWI_UKSwi-*			; 3E
		dc.w	SWI_UKSwi-*			; 3F


		dc.w	SWI_OS_ChangeEnvironment-*	; 40
		dc.w	SWI_UKSwi-*			; 41
		dc.w	SWI_UKSwi-*			; 42
		dc.w	SWI_UKSwi-*			; 43
		dc.w	SWI_UKSwi-*			; 44
		dc.w	SWI_UKSwi-*			; 45
		dc.w	SWI_UKSwi-*			; 46
		dc.w	SWI_UKSwi-*			; 47
		dc.w	SWI_UKSwi-*			; 48
		dc.w	SWI_UKSwi-*			; 49
		dc.w	SWI_UKSwi-*			; 4A
		dc.w	SWI_UKSwi-*			; 4B
		dc.w	SWI_UKSwi-*			; 4C
		dc.w	SWI_UKSwi-*			; 4D
		dc.w	SWI_UKSwi-*			; 4E
		dc.w	SWI_UKSwi-*			; 4F

		dc.w	SWI_UKSwi-*			; 50
		dc.w	SWI_UKSwi-*			; 51
		dc.w	SWI_UKSwi-*			; 52
		dc.w	SWI_UKSwi-*			; 53
		dc.w	SWI_UKSwi-*			; 54
		dc.w	SWI_UKSwi-*			; 55
		dc.w	SWI_UKSwi-*			; 56
		dc.w	SWI_UKSwi-*			; 57
		dc.w	SWI_UKSwi-*			; 58
		dc.w	SWI_UKSwi-*			; 59
		dc.w	SWI_UKSwi-*			; 5A
		dc.w	SWI_UKSwi-*			; 5B
		dc.w	SWI_UKSwi-*			; 5C
		dc.w	SWI_UKSwi-*			; 5D
		dc.w	SWI_UKSwi-*			; 5E
		dc.w	SWI_UKSwi-*			; 5F

		dc.w	SWI_UKSwi-*			; 60
		dc.w	SWI_UKSwi-*			; 61
		dc.w	SWI_UKSwi-*			; 62
		dc.w	SWI_UKSwi-*			; 63
		dc.w	SWI_UKSwi-*			; 64
		dc.w	SWI_UKSwi-*			; 65
		dc.w	SWI_UKSwi-*			; 66
		dc.w	SWI_UKSwi-*			; 67
		dc.w	SWI_UKSwi-*			; 68
		dc.w	SWI_UKSwi-*			; 69
		dc.w	SWI_UKSwi-*			; 6A
		dc.w	SWI_UKSwi-*			; 6B
		dc.w	SWI_UKSwi-*			; 6C
		dc.w	SWI_UKSwi-*			; 6D
		dc.w	SWI_UKSwi-*			; 6E
		dc.w	SWI_UKSwi-*			; 6F

		dc.w	SWI_UKSwi-*			; 70
		dc.w	SWI_UKSwi-*			; 71
		dc.w	SWI_UKSwi-*			; 72
		dc.w	SWI_UKSwi-*			; 73
		dc.w	SWI_UKSwi-*			; 74
		dc.w	SWI_UKSwi-*			; 75
		dc.w	SWI_UKSwi-*			; 76
		dc.w	SWI_UKSwi-*			; 77
		dc.w	SWI_UKSwi-*			; 78
		dc.w	SWI_UKSwi-*			; 79
		dc.w	SWI_UKSwi-*			; 7A
		dc.w	SWI_UKSwi-*			; 7B
		dc.w	SWI_OS_LeaveOS-*		; 7C
		dc.w	SWI_OS_ReadLine32-*		; 7D
		dc.w	SWI_UKSwi-*			; 7E
		dc.w	SWI_UKSwi-*			; 7F


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
SWI_OS_EnterOS	ori.w	#$2000,8(SP)
		rts
SWI_OS_LeaveOS	andi.w	#$DFFF,8(SP)
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

kernel_swi_pop_UkSWI:
		lea	4(SP),SP		; ignored popped D0
		bsr	SWI_UKSwi
		bra	swi_exit

SWI_UKSwi
		lea.l	ErrBlk_UKSwi(PC),A0
		move.l	A0,D0	
		SEV
		rts

ErrBlk_UKSwi	dc.l	$1e6
		dc.b    "No Such SWI", 0
		align	2

; TODO: just move to callRDCHV - should that ever return with V set?
SWI_OS_WriteC	bsr	callWRCHV
		CLV
		rts
SWI_OS_ReadC	bsr	callRDCHV
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

;=============================================================================
; SWI OS_ReadLine - deprecated
;=============================================================================
; Read a line from the input stream
; On entry
; D0	R0 = pointer to buffer to hold the line (bits 0-29), and flags (bits 30-31)
; 		bit 31 set => echo only those characters that enter the buffer
; 		bit 30 set => echo characters by echoing the character in R4
; D1	R1 = size of buffer
; D2	R2 = lowest ASCII value to pass
; D3	R3 = highest ASCII value to pass
; D4	R4 = character to echo if bit 30 of R0 is set
; On exit
; D0	R0 corrupted
; D1	R1 = length of buffer read, not including Return.
; D2,D3	R2, R3 corrupted
; 	the C flag is set if input is terminated by an escape condition


SWI_OS_ReadLine
	move.l	D4,-(A7)
	; get flags into top of D4
	move.b	D4,-(A7)
	move.l	D0,D4
	move.b	(A7)+,D4
	bsr	SWI_OS_ReadLine32
	move.l	(A7)+,D4
	rts


;; 6809 ;;mos_OSWORD_0_read_line						; LE902
;; 6809 ;;		ldb	#$04
;; 6809 ;;		ldy	#oswksp_OSWORD0_MAX_CH-4
;; 6809 ;;1		lda	B,X				;transfer bytes 4,3,2 to 2B3-2B5
;; 6809 ;;		sta	B,Y				;
;; 6809 ;;		decb					;decrement Y
;; 6809 ;;		cmpb	#$02				;until Y=1
;; 6809 ;;		bhs	1B				;
;; 6809 ;;		ldy	,X				;get address of input buffer


;=============================================================================
; SWI OS_ReadLine32 
;=============================================================================
; Read a line from the input stream
; On entry
; D0	R0 = pointer to buffer to hold the line (bits 0-29), and flags (bits 30-31)
; 		bit 31 set => echo only those characters that enter the buffer
; 		bit 30 set => echo characters by echoing the character in R4
; D1	R1 = size of buffer
; D2	R2 = lowest ASCII value to pass
; D3	R3 = highest ASCII value to pass
; D4	R4 = character to echo if bit 30 of R0 is set
; On exit
; D0	R0 corrupted
; D1	R1 = length of buffer read, not including Return.
; D2,D3	R2, R3 corrupted
; 	the C flag is set if input is terminated by an escape condition


SWI_OS_ReadLine32
		movem.l	D5/A1,-(SP)
		andi.l  #$0FFFFFFF, D0
		move.l	D0,A1



		clr.b	sysvar_SCREENLINES_SINCE_PAGE	;Y=0 store in print line counter for paged mode
		bsr	SWI_OS_IntOn			;allow interrupts
		clr.l	D5				;zero counter
		bra	OSWORD_0_read_line_loop_read	;Jump to E924

OSWORD_0_read_line_loop_bell				; LE91D
		moveq	#$07,D0				;A=7
OSWORD_0_read_line_loop_inc
		addq.b  #1,D0				;increment Y
		lea.l	1(A1),A1
OSWORD_0_read_line_loop_echo				; LE921
		SWI	XOS_WriteC			;and call OSWRCH 
OSWORD_0_read_line_loop_read				; LE924
		SWI	XOS_ReadC			;else read character  from input stream
		bcs	OSWORD_0_read_line_skip_err	;if carry set then illegal character or other error
		btst.b	#$02, sysvar_OUTSTREAM_DEST
		bne	OSWORD_0_read_line_skip_novdu	;if Carry set E937
		tst.b	sysvar_VDU_Q_LEN		;get number of items in VDU queue
		bne	OSWORD_0_read_line_loop_echo	;if not 0 output character and loop round again

OSWORD_0_read_line_skip_novdu				; LE937	
		cmp.b	#$7F,D0				;if character is not delete
		bne	OSWORD_0_read_line_skip_notdel	;goto E942
		tst.l	D5				;else is Y=0
		beq	OSWORD_0_read_line_loop_read	;and goto E924
		subq.l	#1,D5				;decrement Y and counter
		lea	-1(A1),A1				
		bra	OSWORD_0_read_line_loop_echo	;print backspace
OSWORD_0_read_line_skip_notdel				; LE942
		cmp.b	#$15,D0,				;is it delete line &21
		bne	OSWORD_0_read_line_skip_not_ctrl_u				;if not E953
		tst.l	D5				;if B=0 we are still reading first
							;character
		beq	OSWORD_0_read_line_loop_read	;so E924
		move.b	#$7F,D0				;else output DELETES
							; LE94B
.cllp		SWI	XOS_WriteC			;delete printed chars
		lea	-1(A1),A1			;decrement pointer
		subq.l	#1,D5				;and counter
		bne	.cllp				;loop until pointer ==0
		bra	OSWORD_0_read_line_loop_read	;go back to reading from input stream

OSWORD_0_read_line_skip_not_ctrl_u			; LE953
		move.b	D0,(A1)				;store character in designated buffer
		cmp.b	#$0D,D0				;is it CR?
		beq	OSWORD_0_read_line_skip_return	;if so E96C
		cmp.l	D1,D5				;else check the line length
		bhs	OSWORD_0_read_line_loop_bell	;if = or greater loop to ring bell
		cmp.b	D2,D0	;check minimum character
		blo	OSWORD_0_read_line_loop_echo	;if less than ignore and don't increment
		cmp.b	D3,D0	;check maximum character
		bhi	OSWORD_0_read_line_loop_echo	;if higher then ignore and don't increment
		addq	#1,D5
		lea	1(A1),A1
		bra	OSWORD_0_read_line_loop_echo	;if less than ignore and don't increment
OSWORD_0_read_line_skip_return				; LE96C		
		SWI	XOS_NewLine			;output CR/LF   
		bsr	callNETV			;call Econet vector
OSWORD_0_read_line_skip_err				; LE972
		move.l	D5,D1
		move.b	zp_mos_ESC_flag,D0		;A=ESCAPE FLAG
		rol.b	D0				;put bit 7 into carry 

		movem.l	(SP)+,D5/A1
		rts			

SWI_OS_Word:
		move.l	(WORDV),-(A7)
		rts

SWI_OS_Byte:
		move.l	(BYTEV),-(A7)
		rts

SWI_OS_CLI:	move.l	(CLIV),-(A7)
		rts


ErrBlk_BadBase:
		dc.l	$16A
		dc.b    "Bad base", 0
		align	2
ErrBlk_BadNumber:
		dc.l	$16B
		dc.b    "Bad number", 0
		align	2
ErrBlk_NumberTooBig:
		dc.l	$16C
		dc.b    "Number too big", 0
		align	2

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
; ReadUnsigned.
; ============
;
; Read an unsigned number from a string in decimal (no prefix), hex (&)
; or given base (nn_). Leading spaces are stripped.
; 'Bad base for number' is given if a base is not in 02..10_36
; 'Bad number' is given if
;      (i) No valid number was
;  or (ii) a '<base>_' or '&' has no following valid number
; 'Number too big' is given if the result overflowed a 32-bit word
; In    D1 -> string
;       D0 =  base to read number in (0 means any based number allowed)
;                bit 31 set -> check term chars for ok-ness
;                bit 30 set -> restrict range to 00..FF
;                bit 29 set -> restrict range to 0..D2 (inclusive)
;                               (overrides bit 30)

; Out   VC : D1 -> first unused char, D2 = number
;       VS : D1 unchanged, D2 = ?, D0 = error block

SWI_OS_ReadUnsigned:
		movem.l	D0-D1/D3-D7/A0-A1,-(A7)

		moveq.l	#-1, D7			; limit
		btst	#30, D0
		beq.s	.n30
		moveq.l	#$FF, D7
.n30:		btst	#29, D0
		beq.s	.n29
		move.l	D2, D7
.n29:		move.l	D0, D6			; remember input flags
		andi.l	#$FFFFFFF, D0		; limit base
		cmp.l	#2, D0
		blt.s	.bb
		cmp.l	#36, D0
		ble.s	.bob
.bb:		moveq.l	#10, D0			; default to base 10
.bob:		move.l	D0, D5			; D5 contains base
		move.l	D1, A0
.sklp:		move.b	(A0)+, D0		
		cmp.b	#' ', D0
		beq.s	.sklp
		move.l	A0, A1
		subq.l	#1, A1			; keep ptr to start of string after spaces
		cmp.b	#'&', D0
		bne.s	.notamp
		moveq.l	#16, D4			; force base 16
		bsr.s	ReadNumberInBase
.ckres		bvs.s	.retBadD0
		move.l	A0, 4(A7)		; return updated pointer in D1
		btst	#31, D6
		beq.s	.nockt
		move.b	(A0), D0
		cmp.b	#' ', D0		; check terminating char
		bgt.s	.badNum
.nockt:		cmp.l	D7, D2
		bhi.s	.numBig
.retok:		movem.l (A7)+, D0-D1/D3-D7/A0-A1
		CLV
		rts

.notamp:	move.l	A1, A0			; back to start of string
		moveq.l	#10, D4
		bsr.s	ReadNumberInBase
		bvc.s	.okb
		move.l	D5, D4			; Failed to read a decimal base
		bra.s	.nob
.okb:		move.l	D2, D4			; assume ok
		move.b	(A0)+, D0		; check char after potential base
		cmp.b	#'_', D0
		beq.s	.rb
.nob:		move.l	D5, D4			; nope, move base back as spec'd in call
		move.l	A1, A0			; step back textptr
.rb:		cmp.l	#2, D4
		blt.s	.badBase
		cmp.l	#36, D4
		bhi.s	.badBase
		bsr.s	ReadNumberInBase
		bra.s	.ckres

.badBase:	lea.l   ErrBlk_BadBase, A0
		bra.s	.retBad
.numBig:	lea.l	ErrBlk_NumberTooBig, A0
		bra.s	.retBad
.badNum:	lea.l	ErrBlk_BadNumber, A0
		bra.s	.retBad

.retBad:	move.l	A0, D0
.retBadD0:	move.l	D0,0(A7)	
		movem.l (A7)+, D0-D1/D3-D7/A0-A1
		SEV
		rts


; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
; ReadNumberInBase
; ================

; In    A0 -> string, D4 = base (valid)

; Out   VC : Number read in D2, A0 updated. D3 = number of chars used
;       VS : A0 preserved, D0 -> error block

ReadNumberInBase:
		movem.l	D0/D5-6/A0,-(A7)

        	moveq.l	#0, D2		; Result
        	moveq.l	#0, D3		; Number of valid digits read
		moveq.l #0, D0		; clear high part of D0
.clp		bsr.s	GetCharForReadNumber
        	bne.s	.done		; Finished ?
        	move.l	D4, D5		; loop counter for multiply
        	moveq.l	#0, D6		; Multiply by repeated addition. Base <> 0 !
        	exg.l	D2, D6
        	bra.s	.mlpe
.mlp:		add.l	D6, D2
        	bcs.s	.numBig		; Now checks for overflow !
.mlpe:		dbf	D5, .mlp
		add.l	D0, D2
	        bcc.s  	.clp
        	bra.s	.numBig		; Now checks for overflow here too!

.done:		cmp.l	#0, D3		; Read any chars at all ? VClear
		beq.s	.badNum
		move.l	A0, 12(A7)	; Update string^
		movem.l (A7)+, D0/D5-D6/A0
		CLV
		rts

.badNum:	lea.l	ErrBlk_BadNumber, A0
		bra.s	.retBad
.numBig:	lea.l	ErrBlk_NumberTooBig, A0
		bra.s	.retBad
.retBad		move.l	A0, 0(A7)	
		movem.l (A7)+, D0/D5-D6/A0
		SEV
		rts

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
; GetCharForReadNumber
; ====================
;
; Read a digit and validate for reading in current base. Bases 2..36 are valid

; In    A0 -> string, D4 = base for number input

; Out   EQ -> D0.b = valid number in [0..base-1], r1++
;       NE -> D0 invalid, A0 same

GetCharForReadNumber:

        move.b	(A0),D0
        cmp.b	#"0", D0
        blo.s	.FT95
        cmp.b	#'9', D0
        bls.s	.FT50
        and.b	#$DF, D0
        cmp.b   #'A', D0        ; Always hex it, even if reading in decimal
        blo.s	.FT95
        cmp.b	#'Z', D0
        bhi.s	.FT95
        sub.b	#'A'-('0'+10), D0
.FT50:  sub.b	#'0', D0
        cmp.b	D4, D0		; digit in [0..base-1] ?
        bhs.b   .FT95
        addq.l	#1, A0
        addq.l	#1, D3
        ori	#CC_Z_M, CCR    ; EQ
        rts

.FT95:	andi	#~CC_Z_M, CCR	; NE
        rts
