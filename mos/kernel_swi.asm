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


SWI_TABLE_LOW_COUNT	EQU	$80
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
		dc.w	SWI_OS_ReadLine-*		; 0E
		dc.w	SWI_UKSwi-*			; 0F
		dc.w	SWI_UKSwi-*			; 10
		dc.w	SWI_UKSwi-*			; 11
		dc.w	SWI_UKSwi-*			; 12
		dc.w	SWI_OS_IntOn-*			; 13
		dc.w	SWI_OS_IntOff-*			; 14
		dc.w	SWI_UKSwi-*			; 15
		dc.w	SWI_OS_EnterOS-*		; 16
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


		dc.w	SWI_UKSwi-*			; 30
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


		dc.w	SWI_UKSwi-*			; 40
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
		dc.w	SWI_UKSwi-*			; 7D
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

;=============================================================================
; SWI OS_ReadLine
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
		move.l 	D4,-(SP)
		; move flag bits to top of D4
		andi.l	#$00FFFFFF, D4
		eor.l	D0,D4

		andi.l	#$3FFFFFFF,D0
		eor.l	D0,D4

		moveq.l	#0,D1
		move.l	(SP)+,D4
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
;; 6809 ;;		clr	sysvar_SCREENLINES_SINCE_PAGE	;Y=0 store in print line counter for paged mode
;; 6809 ;;		CLI					;allow interrupts
;; 6809 ;;		clrb					;zero counter
;; 6809 ;;		bra	OSWORD_0_read_line_loop_read				;Jump to E924
;; 6809 ;;
;; 6809 ;;OSWORD_0_read_line_loop_bell				; LE91D
;; 6809 ;;		lda	#$07				;A=7
;; 6809 ;;OSWORD_0_read_line_loop_inc
;; 6809 ;;		incb					;increment Y
;; 6809 ;;		leay	1,Y
;; 6809 ;;OSWORD_0_read_line_loop_echo				; LE921
;; 6809 ;;		jsr	OSWRCH				;and call OSWRCH 
;; 6809 ;;OSWORD_0_read_line_loop_read				; LE924
;; 6809 ;;		jsr	OSRDCH				;else read character  from input stream
;; 6809 ;;		bcs	OSWORD_0_read_line_skip_err	;if carry set then illegal character or other error
;; 6809 ;;							;exit via E972
;; 6809 ;;	IF CPU_6809
;; 6809 ;;		pshs	A
;; 6809 ;;		lda	sysvar_OUTSTREAM_DEST		;A=&27C get output stream *FX3 
;; 6809 ;;		bita	#2
;; 6809 ;;		puls	A
;; 6809 ;;	ELSE
;; 6809 ;;		tim	#$02, sysvar_OUTSTREAM_DEST
;; 6809 ;;	ENDIF
;; 6809 ;;		bne	OSWORD_0_read_line_skip_novdu	;if Carry set E937
;; 6809 ;;		tst	sysvar_VDU_Q_LEN		;get number of items in VDU queue
;; 6809 ;;		bne	OSWORD_0_read_line_loop_echo	;if not 0 output character and loop round again
;; 6809 ;;OSWORD_0_read_line_skip_novdu				; LE937	
;; 6809 ;;		cmpa	#$7F				;if character is not delete
;; 6809 ;;		bne	OSWORD_0_read_line_skip_notdel				;goto E942
;; 6809 ;;		cmpb	#$00				;else is Y=0
;; 6809 ;;		beq	OSWORD_0_read_line_loop_read	;and goto E924
;; 6809 ;;		decb					;decrement Y and counter
;; 6809 ;;		leay	-1,Y				
;; 6809 ;;		bra	OSWORD_0_read_line_loop_echo	;print backspace
;; 6809 ;;OSWORD_0_read_line_skip_notdel				; LE942
;; 6809 ;;		cmpa	#$15				;is it delete line &21
;; 6809 ;;		bne	OSWORD_0_read_line_skip_not_ctrl_u				;if not E953
;; 6809 ;;		tstb					;if B=0 we are still reading first
;; 6809 ;;							;character
;; 6809 ;;		beq	OSWORD_0_read_line_loop_read	;so E924
;; 6809 ;;		lda	#$7F				;else output DELETES
;; 6809 ;;							; LE94B
;; 6809 ;;1		jsr	OSWRCH				;delete printed chars
;; 6809 ;;		leay	-1,Y				;decrement pointer
;; 6809 ;;		decb					;and counter
;; 6809 ;;		bne	1B				;loop until pointer ==0
;; 6809 ;;		bra	OSWORD_0_read_line_loop_read	;go back to reading from input stream
;; 6809 ;;
;; 6809 ;;OSWORD_0_read_line_skip_not_ctrl_u			; LE953
;; 6809 ;;		sta	,y				;store character in designated buffer
;; 6809 ;;		cmpa	#$0D				;is it CR?
;; 6809 ;;		beq	OSWORD_0_read_line_skip_return	;if so E96C
;; 6809 ;;		cmpb	oswksp_OSWORD0_LINE_LEN		;else check the line length
;; 6809 ;;		bhs	OSWORD_0_read_line_loop_bell	;if = or greater loop to ring bell
;; 6809 ;;		cmpa	oswksp_OSWORD0_MIN_CH		;check minimum character
;; 6809 ;;		blo	OSWORD_0_read_line_loop_echo	;if less than ignore and don't increment
;; 6809 ;;		cmpa	oswksp_OSWORD0_MAX_CH		;check maximum character
;; 6809 ;;		bhi	OSWORD_0_read_line_loop_echo	;if higher then ignore and don't increment
;; 6809 ;;		incb
;; 6809 ;;		leay	1,Y
;; 6809 ;;		bra	OSWORD_0_read_line_loop_echo	;if less than ignore and don't increment
;; 6809 ;;OSWORD_0_read_line_skip_return				; LE96C		
;; 6809 ;;		jsr	OSNEWL				;output CR/LF   
;; 6809 ;;		jsr	[NETV]				;call Econet vector
;; 6809 ;;OSWORD_0_read_line_skip_err				; LE972
;; 6809 ;;		m_tby
;; 6809 ;;		lda	zp_mos_ESC_flag			;A=ESCAPE FLAG
;; 6809 ;;		rola					;put bit 7 into carry 
;; 6809 ;;		rts					;and exit routine
;; 6809 ;;



		move.l	(SP)+,D4
		rts			


