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

		xdef		brkBadCommand

		xdef		mos_DEFAULT_BRK_HANDLER
		xdef		mos_WRCH_default_entry

		xdef		callWRCHV

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

		SECTION "code"


kernel_go_todo

		lea.l	0, A0
		lea.l	0, A1
		move.l	#$FFFF0100,(A0)

		moveq	#4,D1
		clr.b	D2
		SEX
		bra	.tsk	


.tlp		move.b  D0,(A1)+
.tsk		move.b	(A0)+,D0
		addx.b	D2,D0
		dbcc	D1,.tlp
		move.b  D0,(A1)


		move.l	#$C0000700, D0
		move.l	#$100, D1
		moveq.l #' ', D2
		moveq.l #$7F, D3
		moveq.l #'#', D4
		SWI	XOS_ReadLine

		lea.l	$700, A0
		clr.b	(A0,D1)
		move.l	A0,D0
		SWI	XOS_Write0



		XWRITES	"HELLO ISHBEL"


		lea.l	$FFFF5000,A0
		move.w	#$FF,D0
.lll3		move.b	D0,(A0)+
		dbf	D0,.lll3


		move.w	#99,D1
		
		lea.l	test_d,A1
.lll4		move.l	A1,D0
		SWI	OS_Write0
		dbf	D1,.lll4




		moveq	#0,D4
.lll5		move.l	D4,D0
		bsr	PrHex_l

		SWI	OS_WriteI+' '

		; time is little-endian, rearrange
		moveq	#3,D1
		lea.l	oswksp_TIME,A0
.llt		rol.l	#8,D0
		move.b	(A0,D1.W),D0		
		dbra	D1,.llt
		bsr	PrHex_l


		SWI	OS_NewLine

		SWI	OS_WriteI+17
		move.b	D4,D0
		andi.b	#$F,D0
		SWI	OS_WriteC

		SWI	OS_WriteI+17
		move.b	D4,D0
		lsr.b	#4,D0
		not.b	D0
		andi.b	#$F,D0
		ori.b	#$80,D0
		SWI	OS_WriteC

		addq.l	#1,D4

		move.w	#$0FFF, D7
		and.w	D4,D7
		bne	.lll5

		; change mode
		SWI	OS_WriteI+22
		move.w	D4, D0
		lsr.w	#8, D0
		lsr.w	#4, D0
		andi.b	#7, D0
		SWI	OS_WriteC

		bra	.lll5


		trap	#0

		
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
		SWI	OS_WriteC
		move.b	(A7)+,D0
		rts




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


PrString:	move.b	(A0)+,D0
		beq.b	.ex
		bsr	deice_print
		bra	PrString
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
		; TODO restore user mode before call OS_GenerateError?
		lea.l	2(SP),SP
		move.l	(SP),D0
		SWI	OS_GenerateError

		

mos_DEFAULT_BRK_HANDLER:

		; TODO reset stack?

		move.l	(A0)+,D0
		bsr	d_PrHex_l
		move.b	#' ',D0
		bsr	deice_print
.lp		move.b	(A0)+,D0
		beq	.s1
		bsr	deice_print
		bra	.lp
.s1		stop	#$0


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
		move    #$2700,SR
		movem.l	D0-D7/A0-A6,-(A7)
		moveq	#DEICE_STATE_BP,D0
		bra	deice_enter



intmsg_bus:
		bsr	PrString

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
		bsr	PrString

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
		moveq	#' ',D0
		bsr	deice_print

		move.l	0(A7),D0
		bsr	d_PrHex_l

		moveq	#' ',D0
		bsr	deice_print
		bsr	deice_print
		bsr	deice_print
		moveq	#'A',D0
		bsr	deice_print
		move.b	D2,D0
		add.b	#'0',D0
		bsr	deice_print
		cmp.b	#7,D2
		beq	.done
		moveq	#'=',D0
		bsr	deice_print
		moveq	#' ',D0
		bsr	deice_print

		move.l	32(A7,D3.w),D0
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
		add.l	#64,D0
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
		moveq	#' ',D0
		bsr	deice_print

		move.l	62(A7,D4.w),D0
		bsr	d_PrHex_l

		moveq	#13,D0
		bsr	deice_print

		moveq	#'S',D0
		bsr	deice_print
		moveq	#'=',D0
		bsr	deice_print
		moveq	#' ',D0
		bsr	deice_print
		bsr	deice_print

		move.w	60(A7,D4.w),D0
		bsr	d_PrHex_w

		moveq	#13,D0
		bsr	deice_print

.there		stop	#$2700
		bra	.there



mos_WRCH_default_entry
		; TODO all the printer/redirect/spool stuff for now just sends to VDU
		movem.l	D0-D3/A0-A1,-(SP)
		bsr	mos_VDU_WRCH
		movem.l (SP)+,D0-D3/A0-A1
		rts


callWRCHV
		move.l	(WRCHV),-(SP)
		rts

brkBadCommand	trap	#0
		dc.l	$FE
		dc.b 	"Bad Command", 0


;; ----------------------------------------------------------------------------
;; OSBYTE  126  Acknowledge detection of ESCAPE condition
mos_OSBYTE_126
		clr.b	D1				;	E65C
		tst.b	zp_mos_ESC_flag			;	E65E
		bpl	mos_OSBYTE_124			;	E660
		move.b	sysvar_KEYB_ESC_EFFECT,D0	;	E662
		bne	LE671				;	E665
		CLI					;	E667
		move.b	D0,sysvar_SCREENLINES_SINCE_PAGE;	E668
		bsr	mos_STAR_EXEC			;	E66B
		bsr	mos_flush_all_buffers				;	E66E
LE671		moveq	#-1,D1				;	E671
;; OSBYTE  124  Clear ESCAPE condition
mos_OSBYTE_124
		CLX
		bra	mos_OSBYTE_125_2		;	E673
;; OSBYTE  125  Set ESCAPE flag
mos_OSBYTE_125
		SEX
mos_OSBYTE_125_2
		move.b	zp_mos_ESC_flag,D0
		roxr.b	#1,D0				;	E674
		move.b	D0,zp_mos_ESC_flag
;TODO: TUBE
;;	tst	sysvar_TUBE_PRESENT		;	E676
;;	bmi	LE67C				;	E679
		rts					;	E67B
;; 6809 ;; ; ----------------------------------------------------------------------------
;; 6809 ;; LE67C		TODO	"TUBE ESCAPE"
;; 6809 ;; ;LE67C:	jmp	L0403				;	E67C
;; 6809 ;; ;; ----------------------------------------------------------------------------



mos_STAR_EXEC:
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












