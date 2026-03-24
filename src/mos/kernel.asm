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


		xdef 		handle_res
		xdef		handle_bus_err
		xdef		handle_addr_err
		xdef		handle_illegal
		xdef		handle_div0
		xdef		handle_chk
		xdef		handle_trapv
		xdef		handle_priv
		xdef		handle_trace
		xdef		handle_opA
		xdef		handle_opF
		xdef		handle_int_spur
		xdef		handle_int_IRQ
		xdef		handle_int_NMI
		xdef		handle_int_DEBUG
		xdef		handle_trap_0
		xdef		handle_trap_1
		xdef		handle_trap_2
		xdef		handle_trap_3
		xdef		handle_trap_4
		xdef		handle_trap_5
		xdef		handle_trap_6
		xdef		handle_trap_7
		xdef		handle_trap_8
		xdef		handle_trap_9
		xdef		handle_trap_10
		xdef		handle_trap_11
		xdef		handle_trap_12
		xdef		handle_trap_13
		xdef		handle_trap_14
		xdef		handle_trap_15
		xdef		kernel_reset_all_handlers

		xdef		brkBadCommand

		xdef		mos_DEFAULT_BRK_HANDLER
		xdef		mos_WRCH_default_entry

		xdef		callWRCHV
		xdef		callRDCHV
		xdef		callNETV
		xdef		callBRKV

		xdef		kernel_go_todo
		xdef		intmsg

		xdef		PrHex_l
		xdef		PrHex_w
		xdef		PrHex_b

		xdef		d_PrHex_l
		xdef		d_PrHex_w
		xdef		d_PrHex_b


		xdef		mos_OSBYTE_125
		xdef		mos_OSBYTE_124

		xdef 		SWI_OS_Word_Handle
		xdef 		SWI_OS_Byte_Handle
		xdef		SWI_OS_Control
		xdef		SWI_OS_SetEnv
		xdef		SWI_OS_BreakCtrl
		xdef		SWI_OS_ChangeEnvironment
		xdef		SWI_OS_CallBack
		xdef		SWI_OS_Exit

		xdef		mos_DEFAULT_CLI

		SECTION "code"


DEFAULT_USR_STACK=$8000

kernel_go_todo
		SWI	XOS_NewLine
		;TODO: this is a bit simplistic
		;TODO: need to reset supervisor stack?
		;enter user mode set up a stack and then enable interrupts and change mode
		andi.w	#$80FF, SR
kernel_go_todo_after_error
		move.l	#DEFAULT_USR_STACK, A7

		; do a simple *GOS prompt

kernel_go_loop
		MOVE.B	#'*', D0			; * Prompt
		SWI	OS_WriteC

		MOVE.L	#STR_BUF, D0			; Buffer address
		MOVE.B	#$FF, D1			; Maximum line length is 255
		MOVE.B	#$20, D2			; Minimum acceptable ASCII value
		MOVE.B	#$FF, D3			; Maximum acceptable ASCII value
		CLR.L	D4				; Flags
		SWI	OS_ReadLine32			; SWI OS_ReadLine32: Read line from input
		BCS	escape				; Jump if user pressed ESCAPE

		MOVE.L	#STR_BUF, D0			; D0 points to the line read by the OS_ReadLine32 call
		SWI	OS_CLI				; SWI OS_CLI: Process command
		BRA	kernel_go_loop          	; Loop infinitely

escape
		MOVEQ	#OSBYTE_126_ESCAPE_ACK, D0	; OSBYTE $7E: Acknowledge detection of an ESCAPE condition
		SWI	XOS_Byte
		MOVE.L	#err_escape, D0			; Point D0 to the ESCAPE error message
		SWI	OS_GenerateError
		BRA	kernel_go_loop                  ; This command should never be reached



mos_DEFAULT_BRK_HANDLER:
		; Error block should be at D0 and error PC should be at 2(A7)
		movea.l D0,A1
		; copy to current error handler's buffer
		move.l (handle_R3_Error), A0
		move.l 2(A7), (A0)+
		move.l (A1)+, (A0)+

		;copy up to 251 bytes to block and force terminator
		move.w	#250, D1
.lp		move.b 	(A1)+,(A0)+
		dbeq	D1,.lp
		clr.b	(A0)+				; just in case there's not been a terminator!

		move.l	(handle_R2_Error), A4		; workspace pointer
		
		; force user mode
		andi.w	#$8000,SR

		move.l	(handlev_Error), -(A7)		; jump blind to it - we don't expect a return!
		rts

		
PrHex_l:	swap	D0
		bsr	PrHex_w
		swap	D0
PrHex_w:	move.w	D0,-(A7)
		asr.w	#8,D0
		bsr	PrHex_b
		move.w	(A7)+,D0
PrHex_b:	move.b,	D0,-(A7)
		asr.b	#4,D0
		bsr	PrHex_nyb
		move.b	(A7)+,D0	
PrHex_nyb:	move.b	D0,-(A7)
		andi.b	#$F,D0
		cmp.b	#$9,D0
		bls	.dig
		addq.b	#'A'-'9'-1,D0
.dig:		add.b	#'0',D0
		SWI	XOS_WriteC
		move.b	(A7)+,D0
		rts
PrSpc:		move.b	#' ',D0
		SWI	XOS_WriteC




d_PrHex_l:	swap	D0
		bsr	d_PrHex_w
		swap	D0
d_PrHex_w:	move.w	D0,-(A7)
		asr.w	#8,D0
		bsr	d_PrHex_b
		move.w	(A7)+,D0
d_PrHex_b:	move.b,	D0,-(A7)
		asr.b	#4,D0
		bsr	d_PrHex_nyb
		move.b	(A7)+,D0	
d_PrHex_nyb:	move.b	D0,-(A7)
		andi.b	#$F,D0
		cmp.b	#$9,D0
		bls	.dig
		addq.b	#'A'-'9'-1,D0
.dig:		add.b	#'0',D0
		bsr	deice_print
		move.b	(A7)+,D0
		rts


d_PrString:	move.b	(A0)+,D0
		beq.b	.ex
		bsr	deice_print
		bra	d_PrString
.ex:		rts




handle_bus_err:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_bus_err,PC),A0
		bra	intmsg_bus
handle_addr_err:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_addr_err,PC),A0
		bra	intmsg_bus
handle_illegal:
		move    #$2700,SR
		movem.l	D0-D7/A0-A6,-(A7)
		moveq	#DEICE_STATE_ILLEGAL,D0
		bra	deice_enter
handle_div0:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_div0,PC),A0
		bra	intmsg
handle_chk:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_chk,PC),A0
		bra	intmsg
handle_trapv:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_trapv,PC),A0
		bra	intmsg
handle_priv:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_priv,PC),A0
		bra	intmsg
handle_trace:
		move    #$2700,SR
		movem.l	D0-D7/A0-A6,-(A7)
		moveq	#DEICE_STATE_TRACE,D0
		bra	deice_enter
handle_opA:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_opA,PC),A0
		bra	intmsg
handle_opF:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_opF,PC),A0
		bra	intmsg
handle_int_spur:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_int_spur,PC),A0
		bra	intmsg


handle_int_NMI:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_int_nmi,PC),A0
		bra	intmsg
handle_int_DEBUG:
		move    #$2700,SR
		movem.l	D0-D7/A0-A6,-(A7)
		moveq	#DEICE_STATE_IRQ_x+7,D0
		bra	deice_enter

;;TODO: Keep this or insist on call SWI_OS_GenerateError?
handle_trap_0:

		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_trap_0,PC),A0
		bsr	intmsg_nostop		
		movem.l	(A7)+,D0-D7/A0-A6

		move.l  2(SP),D0		


		; TODO restore user mode before call OS_GenerateError?
		move.l	#OS_GenerateError, A0
		bra	kernel_swi_handle


handle_trap_1:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_trap_1,PC),A0
		bra	intmsg
handle_trap_2:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_trap_2,PC),A0
		bra	intmsg
handle_trap_3:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_trap_3,PC),A0
		bra	intmsg
handle_trap_4:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_trap_4,PC),A0
		bra	intmsg
handle_trap_5:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_trap_5,PC),A0
		bra	intmsg
handle_trap_6:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_trap_6,PC),A0
		bra	intmsg
handle_trap_7:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_trap_7,PC),A0
		bra	intmsg
handle_trap_8:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_trap_8,PC),A0
		bra	intmsg
handle_trap_9:
		;TODO: handler - display message in DeIce and halt
		move.l	2(SP),A0
t9lp:		move.b	(A0)+,D0
		beq	t9sk
		bsr	deice_print
		bra	t9lp
t9sk:		bra	t9sk

;		movem.l	D0-D7/A0-A6,-(A7)
;		lea	(str_trap_9,PC),A0
;		bra	intmsg
handle_trap_10:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_trap_A,PC),A0
		bra	intmsg
handle_trap_11:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_trap_B,PC),A0
		bra	intmsg
handle_trap_13:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_trap_D,PC),A0
		bra	intmsg
handle_trap_14:
		; start TRACE
		ori.w	#$8000, (A7)
		rte
handle_trap_15:
		; adjust return address/PC to point at the breakpoint instructions - we need to re-execute here
		subi.l	#2,2(A7)

		move    #$2700,SR
		movem.l	D0-D7/A0-A6,-(A7)
		moveq	#DEICE_STATE_BP,D0
		bra	deice_enter



intmsg_bus:
		bsr	d_PrString

		moveq	#13,D0
		bsr	deice_print

		DEBUG_INFO_S "CYC:"
		move.w	60(A7),D0
		bsr	d_PrHex_w	
		moveq	#13, D0
		bsr	deice_print
		DEBUG_INFO_S "ADD:"
		move.l	62(A7),D0
		bsr	d_PrHex_l	
		moveq	#13, D0
		bsr	deice_print
		DEBUG_INFO_S "INS:"
		move.w	66(A7),D0
		bsr	d_PrHex_w	
		moveq	#13, D0
		bsr	deice_print

		moveq.l	#8,D4
		bra	bussk2

intmsg
		bsr	intmsg_nostop

.there		stop	#$2700
		bra	.there

intmsg_nostop	bsr	d_PrString

		moveq	#13,D0
		bsr	deice_print

		clr.l	D4
bussk2:
		clr.l	D3
		clr.b	D2

intmsg_lp0:	
		moveq	#'D',D0
		bsr	deice_print
		move.b	D2,D0
		add.b	#'0',D0
		bsr	deice_print
		moveq	#'=',D0
		bsr	deice_print

		bsr	deice_print_space

		move.l	4(A7,D3.w),D0
		bsr	d_PrHex_l

		bsr	deice_print_space
		bsr	deice_print_space
		bsr	deice_print_space
		moveq	#'A',D0
		bsr	deice_print
		move.b	D2,D0
		add.b	#'0',D0
		bsr	deice_print
		cmp.b	#7,D2
		beq	.done
		moveq	#'=',D0
		bsr	deice_print

		bsr	deice_print_space

		move.l	36(A7,D3.w),D0
		bsr	d_PrHex_l

		moveq	#13,D0
		bsr	deice_print

		addq.b	#4,D3
		addq.b	#1,D2
		bra	intmsg_lp0

.done
		moveq	#'s',D0
		bsr	deice_print
		moveq	#'=',D0
		bsr	deice_print

		move	A7,D0
		add.l	D4,D0
		add.l	#70,D0
		bsr	d_PrHex_l

		moveq	#13,D0
		bsr	deice_print

		moveq	#'A',D0
		bsr	deice_print
		moveq	#'7',D0
		bsr	deice_print
		moveq	#'u',D0
		bsr	deice_print
		moveq	#'=',D0
		bsr	deice_print

		move.l	USP,A0
		move.l	A0,D0
		bsr	d_PrHex_l

		moveq	#13,D0
		bsr	deice_print

		moveq	#'P',D0
		bsr	deice_print
		moveq	#'C',D0
		bsr	deice_print
		moveq	#'=',D0
		bsr	deice_print

		bsr	deice_print_space

		move.l	66(A7,D4.w),D0
		bsr	d_PrHex_l

		moveq	#13,D0
		bsr	deice_print

		moveq	#'S',D0
		bsr	deice_print
		moveq	#'=',D0
		bsr	deice_print

		bsr	deice_print_space
		bsr	deice_print_space

		move.w	64(A7,D4.w),D0
		bsr	d_PrHex_w

		moveq	#13,D0
		bra	deice_print


mos_WRCH_default_entry
		; TODO all the printer/redirect/spool stuff for now just sends to VDU
		movem.l	D0-D3/A0-A1,-(SP)
		bsr	mos_VDU_WRCH
		movem.l (SP)+,D0-D3/A0-A1
		rts


callWRCHV
		move.l	(WRCHV),-(SP)
		rts
callRDCHV
		move.l	(RDCHV),-(SP)
		rts
callNETV
		move.l	(NETV),-(SP)
		rts
callBRKV
		move.l	(BRKV),-(SP)
		rts


brkBadCommand	trap	#0
		dc.l	$FE
		dc.b 	"Bad Command", 0


;; Cribbed from RO 3.71 
mos_OSBYTE_124
		CLC
		bra	Osbyte124_125		
mos_OSBYTE_125
		SEC
Osbyte124_125	movem.l	D1,-(A7)		; preserve flags
		scs	D1
		move.b	D1,zp_mos_ESC_flag
		bsr	callEscapeHV		; call escape vector and possibly set a callback
		movem.l	(A7)+,D1
		rts

mos_OSBYTE_126	btst	#6, zp_mos_ESC_flag
		beq	.noack
		tst.b	sysvar_KEYB_ESC_EFFECT
		bne	.noack

		CLI				; flushing buffers requires interrupts

		move.b	D0,sysvar_SCREENLINES_SINCE_PAGE;	E668
		bsr	mos_STAR_EXEC			;	E66B
		bsr	mos_flush_all_buffers				;	E66E

.noack		bsr	mos_OSBYTE_124
		btst	#6, zp_mos_ESC_flag
		sne	D1
		rts
		


;;;
;;;
;;;
;;;;; ----------------------------------------------------------------------------
;;;;; OSBYTE  126  Acknowledge detection of ESCAPE condition
;;;mos_OSBYTE_126
;;;		clr.b	D1				;	E65C
;;;		tst.b	zp_mos_ESC_flag			;	E65E
;;;		bpl	mos_OSBYTE_124			;	E660
;;;		move.b	sysvar_KEYB_ESC_EFFECT,D0	;	E662
;;;		bne	LE671				;	E665
;;;		CLI					;	E667
;;;		move.b	D0,sysvar_SCREENLINES_SINCE_PAGE;	E668
;;;		bsr	mos_STAR_EXEC			;	E66B
;;;		bsr	mos_flush_all_buffers				;	E66E
;;;LE671		moveq	#-1,D1				;	E671
;;;;; OSBYTE  124  Clear ESCAPE condition
;;;mos_OSBYTE_124
;;;		clr.b	zp_mos_ESC_flag
;;;		rts
;;;;; OSBYTE  125  Set ESCAPE flag
;;;mos_OSBYTE_125
;;;		st.b	zp_mos_ESC_flag
;;;;TODO: TUBE
;;;;;	tst	sysvar_TUBE_PRESENT		;	E676
;;;;;	bmi	LE67C				;	E679
;;;		rts					;	E67B
;;;;; 6809 ;; ; ----------------------------------------------------------------------------
;;;;; 6809 ;; LE67C		TODO	"TUBE ESCAPE"
;;;;; 6809 ;; ;LE67C:	jmp	L0403				;	E67C
;;;;; 6809 ;; ;; ----------------------------------------------------------------------------



mos_STAR_EXEC:
		rts


SWI_OS_Word_Handle:
	move.l	D0,-(A7)

	cmp.w	#8,D0
	bhs	.toobig

	asl.w	#1,D0
	move.w	tblOSWORDS(PC,D0.W),D0
	jsr	tblOSWORDS(PC,D0.w)

.toobig:
	movem.l (A7)+,D0
	rts


tblOSWORDS:
	dc.w	OSWORD_RTS-tblOSWORDS		; 0
	dc.w	OSWORD_1_READ_TIME-tblOSWORDS	; 1
	dc.w	OSWORD_RTS-tblOSWORDS		; 2
	dc.w	OSWORD_RTS-tblOSWORDS		; 3
	dc.w	OSWORD_RTS-tblOSWORDS		; 4
	dc.w	OSWORD_RTS-tblOSWORDS		; 5
	dc.w	OSWORD_RTS-tblOSWORDS		; 6
	dc.w	OSWORD_RTS-tblOSWORDS		; 7

OSWORD_1_READ_TIME:
	movem.l	D1/A1,-(A7)
	moveq	#4,D0
	move.l	D1,A0
	lea	oswksp_TIME,A1
	move.b	sysvar_TIMER_SWITCH,D1
	ext.w	D1
	lea	(A1,D1.w),A1
.lp	move.b	-(A1),(A0)+
	dbf	D0,.lp
	movem.l	(A7)+,D1/A1
OSWORD_RTS:
	rts


SWI_OS_Byte_Handle
		; in the first part of the table?
		cmp.b	#OSBYTE1_END, D0
		blo	x_Process_OSBYTE_SECTION_1
		cmp.b	#OSBYTE2_START, D0
		blo	x_uk_OSBYTE
		cmp.b	#OSBYTE2_END + 1, D0
		blo	x_Process_OSBYTE_SECTION_2
	
		; >= 166, then read/write system variable

		; TODO: sort out which ones are r/w and which ones need special Big-Endian frigs
		DEBUG_INFO_S "OSBYTE R/W SYSVAR "
		bra	mos_OSBYTE_nowt2

x_Process_OSBYTE_SECTION_2
		; save A
		move.w	D0,-(A7)
		sub.w	#OSBYTE2_START - OSBYTE1_END - 1, D0
		bra	x_OSBYTE_trampoline

x_Process_OSBYTE_SECTION_1
		; save A
		move.w	D0,-(A7)

x_OSBYTE_trampoline
		and.w	#$00FF, D0
		asl.w	#1,D0
		lea	tblOSBYTES(PC), A0
		move.w	(A0,D0.w),D0
		lea	(A0,D0.W), A0
		move.w	(A7)+, D0
		jmp	(A0)




; TODO: Make these tables smaller with word sized pointers	
tblOSBYTES:
mostbl_OSBYTE_LOOK_UP
		dc.w	mos_OSBYTE_0 - tblOSBYTES			
		dc.w	mos_OSBYTE_1AND6 - tblOSBYTES		
		dc.w	mos_OSBYTE_2 - tblOSBYTES			
		dc.w	mos_OSBYTE_3AND4 - tblOSBYTES		
		dc.w	mos_OSBYTE_3AND4 - tblOSBYTES		
		dc.w	mos_OSBYTE_5 - tblOSBYTES			
		dc.w	mos_OSBYTE_1AND6 - tblOSBYTES		
		dc.w	mos_OSBYTE_07 - tblOSBYTES			
		dc.w	mos_OSBYTE_08 - tblOSBYTES			
		dc.w	mos_OSBYTE_09 - tblOSBYTES			
		dc.w	mos_OSBYTE_10 - tblOSBYTES			
		dc.w	mos_OSBYTE_11 - tblOSBYTES			
		dc.w	mos_OSBYTE_12 - tblOSBYTES			
		dc.w	mos_OSBYTE_13 - tblOSBYTES			
		dc.w	mos_OSBYTE_14 - tblOSBYTES			
		dc.w	mos_OSBYTE_15 - tblOSBYTES			
		dc.w	mos_OSBYTE_16 - tblOSBYTES			
		dc.w	mos_OSBYTE_17 - tblOSBYTES			
		dc.w	mos_OSBYTE_18 - tblOSBYTES			
		dc.w	mos_OSBYTE_19 - tblOSBYTES			
		dc.w	mos_OSBYTE_20 - tblOSBYTES			
		dc.w	mos_OSBYTE_21 - tblOSBYTES			
OSBYTE1_END	equ	21

OSBYTE2_START	equ	117
mostbl_OSBYTE_LOOK_UP2
		dc.w	mos_OSBYTE_117 - tblOSBYTES			
		dc.w	mos_OSBYTE_118 - tblOSBYTES			
		dc.w	mos_OSBYTE_119 - tblOSBYTES			
		dc.w	mos_OSBYTE_nowt - tblOSBYTES			
		dc.w	mos_OSBYTE_121 - tblOSBYTES			
		dc.w	mos_OSBYTE_122 - tblOSBYTES			
		dc.w	mos_OSBYTE_123 - tblOSBYTES			
		dc.w	mos_OSBYTE_124 - tblOSBYTES			
		dc.w	mos_OSBYTE_125 - tblOSBYTES			
		dc.w	mos_OSBYTE_126 - tblOSBYTES			
		dc.w	mos_OSBYTE_nowt - tblOSBYTES			
		dc.w	mos_OSBYTE_nowt - tblOSBYTES			
		dc.w	mos_OSBYTE_129 - tblOSBYTES			
		dc.w	mos_OSBYTE_130 - tblOSBYTES			
		dc.w	mos_OSBYTE_131 - tblOSBYTES			
		dc.w	mos_OSBYTE_132 - tblOSBYTES			
		dc.w	mos_OSBYTE_133 - tblOSBYTES			
		dc.w	mos_OSBYTE_134 - tblOSBYTES			
		dc.w	mos_OSBYTE_135 - tblOSBYTES			
		dc.w	mos_OSBYTE_136 - tblOSBYTES			
		dc.w	mos_OSBYTE_nowt - tblOSBYTES			
		dc.w	mos_OSBYTE_138 - tblOSBYTES			
		dc.w	mos_OSBYTE_nowt - tblOSBYTES			
		dc.w	mos_OSBYTE_nowt - tblOSBYTES			
		dc.w	mos_OSBYTE_nowt - tblOSBYTES			
		dc.w	mos_OSBYTE_nowt - tblOSBYTES			
		dc.w	mos_OSBYTE_143 - tblOSBYTES			
		dc.w	mos_OSBYTE_144 - tblOSBYTES			
		dc.w	mos_OSBYTE_nowt - tblOSBYTES			
		dc.w	mos_OSBYTE_146 - tblOSBYTES			
		dc.w	mos_OSBYTE_nowt - tblOSBYTES			
		dc.w	mos_OSBYTE_148 - tblOSBYTES			
		dc.w	mos_OSBYTE_nowt - tblOSBYTES			
		dc.w	mos_OSBYTE_150 - tblOSBYTES			
		dc.w	mos_OSBYTE_nowt - tblOSBYTES			
		dc.w	mos_OSBYTE_nowt - tblOSBYTES			
		dc.w	mos_OSBYTE_153 - tblOSBYTES			
		dc.w	mos_OSBYTE_nowt - tblOSBYTES			
		dc.w	mos_OSBYTE_nowt - tblOSBYTES			
		dc.w	mos_OSBYTE_156 - tblOSBYTES					
		dc.w	mos_OSBYTE_157 - tblOSBYTES			
		dc.w	mos_OSBYTE_nowt - tblOSBYTES			
		dc.w	mos_OSBYTE_nowt - tblOSBYTES			
		dc.w	mos_OSBYTE_160 - tblOSBYTES			
		dc.w	mos_OSBYTE_161 - tblOSBYTES			
		dc.w	mos_OSBYTE_162 - tblOSBYTES			
		dc.w	mos_OSBYTE_163 - tblOSBYTES			
		dc.w	mos_OSBYTE_164 - tblOSBYTES			
		dc.w	mos_OSBYTE_165 - tblOSBYTES			
OSBYTE2_END	equ	165

mos_OSBYTE_0
mos_OSBYTE_1AND6
mos_OSBYTE_2
mos_OSBYTE_3AND4
mos_OSBYTE_5
mos_OSBYTE_07
mos_OSBYTE_08
mos_OSBYTE_09
mos_OSBYTE_10
mos_OSBYTE_11
mos_OSBYTE_12
mos_OSBYTE_13
mos_OSBYTE_14
mos_OSBYTE_15
mos_OSBYTE_16
mos_OSBYTE_17
mos_OSBYTE_18
mos_OSBYTE_19
mos_OSBYTE_20
mos_OSBYTE_21

mos_OSBYTE_117
mos_OSBYTE_119
mos_OSBYTE_123
mos_OSBYTE_130
mos_OSBYTE_131
mos_OSBYTE_132
mos_OSBYTE_133
mos_OSBYTE_134
mos_OSBYTE_135
mos_OSBYTE_136
mos_OSBYTE_143
mos_OSBYTE_144
mos_OSBYTE_146
mos_OSBYTE_148
mos_OSBYTE_150
mos_OSBYTE_156
mos_OSBYTE_157
mos_OSBYTE_160
mos_OSBYTE_161
mos_OSBYTE_162
mos_OSBYTE_163
mos_OSBYTE_164
mos_OSBYTE_165





mos_OSBYTE_nowt
		; not implemented - print hex registers to DEBUG and exit

		move.l	D0,-(A7)

		DEBUG_INFO_S "TODO: OSBYTE: "

mos_OSBYTE_nowt2
		bsr	d_PrHex_b
		bsr	deice_print_space
		move.b	D1,D0
		bsr	d_PrHex_b
		bsr	deice_print_space
		move.b	D2,D0
		bsr	d_PrHex_b
		bsr	deice_print_space
		move.b	#13, 0
		bsr	deice_print

		move.l	(A7)+,D0
		rts


x_uk_OSBYTE	;
		; TODO: check this is right		
		move.l	D2,D4
		move.l	D1,D3
		move.l	D0,D2
		move.b	#SERVICE_7_UKOSBYTE, D1
		SWI	XOS_ServiceCall
		rts

test_d:		dc.b	"Blitter Board 68000", 13,10,17,2,17,129,"one", 13,10,17,1,17,128,"two",13,10,17,129,17,6,0
str_addr_err:	dc.b	"address error",0
str_bus_err:	dc.b	"bus error",0
str_div0:	dc.b	"div0",0
str_chk:	dc.b	"chk",0
str_trapv:	dc.b	"trapv",0
str_priv:	dc.b	"priv",0
str_trace:	dc.b	"trace",0
str_opA:	dc.b	"opA",0
str_opF:	dc.b	"opF",0
str_int_spur:	dc.b	"int_spur",0
str_int_nmi:	dc.b	"int_nmi",0
str_trap_0:	dc.b	"trap_0",0
str_trap_1:	dc.b	"trap_1",0
str_trap_2:	dc.b	"trap_2",0
str_trap_3:	dc.b	"trap_3",0
str_trap_4:	dc.b	"trap_4",0
str_trap_5:	dc.b	"trap_5",0
str_trap_6:	dc.b	"trap_6",0
str_trap_7:	dc.b	"trap_7",0
str_trap_8:	dc.b	"trap_8",0
str_trap_9:	dc.b	"trap_9",0
str_trap_A:	dc.b	"trap_A",0
str_trap_B:	dc.b	"trap_B",0
str_trap_C:	dc.b	"trap_C",0
str_trap_D:	dc.b	"trap_D",0
str_trap_E:	dc.b	"trap_E",0
str_trap_F:	dc.b	"trap_F",0



		align	1
		xdef NETV_dummy
NETV_dummy	rts







;=================================== Environment / Handler ============================================

tblHandlerLocations
	dc.l		handlev_MemoryLimit,		0,				0
	dc.l		handlev_UndefinedInstruction,	0,				0
	dc.l		handlev_PrefetchAbort,		0,				0
	dc.l		handlev_DataAbort,		0,				0
	dc.l		handlev_AddressException,	0,				0
	dc.l		handlev_OtherException,		0,				0
	dc.l		handlev_Error,			handle_R2_Error,		handle_R3_Error
	dc.l		handlev_CallBack,		handle_R2_CallBack,		handle_R3_CallBack
	dc.l		handlev_BreakPoint,		handle_R2_BreakPoint,		handle_R3_BreakPoint
	dc.l		handlev_Escape,			handle_R2_Escape,		0
	dc.l		handlev_Event,			handle_R2_Event,		0
	dc.l		handlev_Exit,			handle_R2_Exit,			0
	dc.l		handlev_UnusedSWI,		handle_R2_UnusedSWI,		0
	dc.l		handlev_ExceptionRegisters,	0,				0
	dc.l		handlev_ApplicationSpace,	0,				0
	dc.l		handlev_CurrentlyActiveObject,	0,				0
	dc.l		handlev_UpCall,			handle_R2_UpCall,		handle_R3_UpCall

NUM_HANDLERS=17


tblDefaultHandlers
	dc.l		0,				0,				0
	dc.l		defhandle_UndefinedInstruction,	0,				0
	dc.l		defhandle_PrefetchAbort,	0,				0
	dc.l		defhandle_DataAbort,		0,				0
	dc.l		defhandle_AddressException,	0,				0
	dc.l		defhandle_OtherException,	0,				0
	dc.l		defhandle_Error,		0,				GEN_BUF
	dc.l		defhandle_CallBack,		0,				DUMP_BUF
	dc.l		defhandle_BreakPoint,		0,				DUMP_BUF
	dc.l		defhandle_Escape,		0,				0
	dc.l		defhandle_Event,		0,				0
	dc.l		defhandle_Exit,			0,				0
	dc.l		defhandle_UnusedSWI,		0,				0
	dc.l		defhandle_ExceptionRegisters,	0,				0
	dc.l		defhandle_ApplicationSpace,	0,				0
	dc.l		defhandle_CurrentlyActiveObject,0,				0
	dc.l		defhandle_UpCall,		0,				GEN_BUF


SWI_OS_ChangeEnvironment
	cmp.w	#NUM_HANDLERS,D0
	bhi	.silly

	move.w	SR,-(A7)
	movem.l	A2-A4,-(A7)
	SEI				; disable interrupts while we do this

	mulu	#12,D0
	lea	tblHandlerLocations,A0
	lea	(A0,D0.w), A0

	movem.l	(A0)+,A2-A4

	; handler address
	move.l	D1,D0
	move.l	(A2),D1
	tst.l	D0
	beq	.s0
	move.l	D0,(A2)
.s0
	;workspace
	cmpa.l	#0,A3
	beq	.s1
	move.l	D2,D0
	move.l	(A3),D2
	tst.l	D0
	beq	.s1
	move.l	D0,(A3)
.s1
	;buffer
	cmpa.l	#0,A4
	beq	.s2
	move.l	D3,D0
	move.l	(A4),D3
	tst.l	D0
	beq	.s2
	move.l	D0,(A4)
.s2
	movem.l	(A7)+, A2-A4
	rte




.silly
	move.l	#err_BadEnvNumber,D0
	SEV
	rts


kernel_reset_all_handlers:
	; set default values in each handler
	; TODO: probably need a more nuanced approach

	lea	tblHandlerLocations(PC), A0
	lea	tblDefaultHandlers(PC), A1
	move.w	#NUM_HANDLERS-1, D3
.lp	movem.l	(A0)+,A2-A4
	movem.l (A1)+,D0-D2
	move.l	D0,(A2)
	cmpa.l	#0,A3
	beq	.sk1
	move.l	D1,(A3)
.sk1	cmpa.l	#0,A4
	beq	.sk2
	move.l	D2,(A4)
.sk2	dbf	D3,.lp
	rts





callEscapeHV
	move.l	A4,-(A7)
	pea	anExit(PC)
	move.l	(handle_R2_Escape), A4
	move.l	(handlev_Escape),-(A7)
	rts
anExit	cmpa.l	#1,A4
	bne	.sk
	SWI	XOS_SetCallBack
.sk	move.l	(A7)+,A4	
	rts



defhandle_UndefinedInstruction
	DEBUG_TODO	"defhandle_UndefinedInstruction"
defhandle_PrefetchAbort
	DEBUG_TODO	"defhandle_PrefetchAbort"
defhandle_DataAbort
	DEBUG_TODO	"defhandle_DataAbort"
defhandle_AddressException
	DEBUG_TODO	"defhandle_AddressException"
defhandle_OtherException
	DEBUG_TODO	"defhandle_OtherException"
defhandle_CallBack
	DEBUG_TODO	"defhandle_CallBack"
defhandle_BreakPoint
	DEBUG_TODO	"defhandle_BreakPoint"
defhandle_Event
	DEBUG_TODO	"defhandle_Event"
defhandle_Exit
	DEBUG_TODO	"defhandle_Exit"
defhandle_UnusedSWI
	DEBUG_TODO	"defhandle_UnusedSWI"
defhandle_ExceptionRegisters
	DEBUG_TODO	"defhandle_ExceptionRegisters"
defhandle_ApplicationSpace
	DEBUG_TODO	"defhandle_ApplicationSpace"
defhandle_CurrentlyActiveObject
	DEBUG_TODO	"defhandle_CurrentlyActiveObject"
defhandle_UpCall
	DEBUG_TODO	"defhandle_UpCall"




defhandle_Escape:
	rts


defhandle_Error
		move.l	#DEFAULT_USR_STACK, A7
		lea.l	GEN_BUF, A1

		move.l  (A1)+,D0
		bsr	PrHex_l
		bsr	PrSpc

		move.l	(A1)+,D0
		bsr	PrHex_l
		bsr	PrSpc

		move.l	A1, D0
		SWI	XOS_Write0
		SWI	XOS_NewLine
		SWI	XOS_NewLine
.s1		bra	kernel_go_todo_after_error


SWI_OS_CallBack
		movem.l	D2-D4,-(A7)
		move.b	#HANDLER_7_CallBack,D4
		bra	handlecomm
handlecomm
		move.l	D0,D3
		move.l	D4,D0
		jsr	CallCESWI
		bvs	.s1
		move.l	D3,D0
.s1		movem.l	(A7)+,D2-D4
		rts

SWI_OS_BreakCtrl
		movem.l	D2-D4,-(A7)
		move.b	#HANDLER_8_BreakPoint,D4
		bra	handlecomm
	
CallCESWI
		clr.l	D2
		SWI	XOS_ChangeEnvironment
		rts

		; assumes no errors!
SWI_OS_Control	
		move.w	SR,-(A7)
		movem.l	D0-D3,-(A7)

		SEI

		move.b	#HANDLER_10_Event,D0
		move.l	D3,D1
		jsr	CallCESWI
		move.l	D1,4(A7)

		move.b	#HANDLER_9_Escape,D0
		move.l	8(A7),D1
		jsr	CallCESWI
		move.l	D1,8(A7)

		move.b	#HANDLER_6_Error,D0
		movem.l	(A7)+,D1/D3
		jsr	CallCESWI
		move.l	D1,D0
		move.l	D3,D0

		movem.l	(A7)+,D2-D3
		rte

SWI_OS_SetEnv
		move.w	SR,-(A7)
		movem.l	D0-D1,-(A7)
		SEI

		move.b	#HANDLER_4_AddressException,D0
		move.l	D7,D1
		SWI	XOS_ChangeEnvironment
		move.l	D1,D7

		move.b	#HANDLER_3_DataAbort,D0
		move.l	D6,D1
		SWI	XOS_ChangeEnvironment
		move.l	D1,D6

		move.b	#HANDLER_2_PrefetchAbort,D0
		move.l	D5,D1
		SWI	XOS_ChangeEnvironment
		move.l	D1,D5

		move.b	#HANDLER_1_UndefinedInstruction,D0
		move.l	D4,D1
		SWI	XOS_ChangeEnvironment
		move.l	D1,D4

		move.b	#HANDLER_1_UndefinedInstruction,D0
		move.l	4(A7),D1
		SWI	XOS_ChangeEnvironment
		move.l	D1,4(A7)

		move.b	#HANDLER_11_Exit,D0
		move.l	0(A7),D1
		SWI	XOS_ChangeEnvironment
		move.l	D1,0(A7)

		;TODO: missed out RAMLIMIT in R2
		;TODO: didn't clear R3


		movem.l	(A7)+,D0-D1
		rte

SWI_OS_Exit	bra	kernel_go_todo



mos_DEFAULT_CLI:
		movem.l D0-D2/A0-A2,-(A7)


; TODO: command table, pass to FS, modules etc */		



		bra	brkBadCommand