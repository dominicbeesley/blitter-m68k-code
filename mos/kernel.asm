;; (c) 2019 Dossytronics, Dominic Beesley

		include "mos.inc"
		include "oslib.inc"
		include "hardware.inc"
		include "kernel_defs.inc"


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
		xdef		handle_int_1
		xdef		handle_int_2
		xdef		handle_int_3
		xdef		handle_int_4
		xdef		handle_int_5
		xdef		handle_int_6
		xdef		handle_int_7
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
		xdef		handle_trap_A
		xdef		handle_trap_B
		xdef		handle_trap_C
		xdef		handle_trap_D
		xdef		handle_trap_E
		xdef		handle_trap_F



		SECTION "code"

handle_res:	
		; copy rom vectors to low memory
		lea	(romv_start,PC),A6
		movea	#0, A0
		move.b	#$64, D0
.lp:		move.l	(A6)+,(A0)+
		dbf	D0,.lp



		bsr.b	cls
		lea	(test_d,PC),A0
		bsr.b	PrString
		move.l	#$FACEBEEF,D0
		move.l	#$BEEFDEAD,D1
		move.l	#$DEADBEEF,D2
		move.l	#$D0B0D0B0,D3
		move.w	#$0000,D3

		
here:		trap	#$F

cls:		movea.l	#screen_start,A0
		clr.b	col_ctr
		move.l 	A0,(screen_ptr).w
		movea.l #screen_start+screen_len,A0
		move.w	#(screen_len/16)-1,D0
		moveq	#0,D1
		moveq	#0,D2
		moveq	#0,D3
		moveq	#0,D4
.lp:		movem.l	D1-D4,-(A0)
		dbf	D0,.lp
		rts

PrHex_l:	swap	D0
		jsr	PrHex_w
		swap	D0
PrHex_w:	move.w	D0,-(A7)
		asr.w	#8,D0
		jsr	PrHex_b
		move.w	(A7)+,D0
PrHex_b:	move.b,	D0,-(A7)
		asr.b	#4,D0
		jsr	PrHex_nyb
		move.b	(A7)+,D0	
PrHex_nyb:	move.b	D0,-(A7)
		andi.b	#$F,D0
		cmp.b	#$9,D0
		bls	.dig
		addq.b	#'A'-'9'-1,D0
.dig:		add.b	#'0',D0
		jsr	doOSWRCH
		move.b	(A7)+,D0
		rts


PrString:	move.b	(A0)+,D0
		beq.b	.ex
		bsr.b	doOSWRCH
		bra	PrString
.ex:		rts

doOSWRCH:
		movem.l	D0-D1/A0-A1,-(A7)
		clr.w	D1
		move.b	D0,D1
		sub.b	#32,D1
		bcs.b	.ctl
		asl.w	#3,D1
		movea.l	(screen_ptr).w,A1
		lea.l	(font,PC),A0		
		lea.l	0(A0,D1.W),A0
		move.l	(A0)+,D1
		move.l	D1,(A1)+
		move.l	(A0)+,D1
		move.l	D1,(A1)+
		move.l	A1,(screen_ptr).w
		add.b	#1,(col_ctr)
		cmp.b	#80,(col_ctr)
		bne	.ex
		clr.b	(col_ctr)
.ex:		movem.l	(A7)+,D0-D1/A0-A1
		rts
.ctl:		cmp.b	#13,D0
		bne	.ex
		; next line
		clr.w	D1
		move.b	(col_ctr),D1
		asl.w	#3,D1
		neg.w	D1
		add.w	#640,D1
		move.l  (screen_ptr),A1
		lea.l	0(A1,D1),A1
		move.l	A1,(screen_ptr)
		clr.b	(col_ctr)
		bra	.ex


handle_bus_err:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_bus_err,PC),A0
		bra	intmsg
handle_addr_err:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_addr_err,PC),A0
		bra	intmsg
handle_illegal:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_illegal,PC),A0
		bra	intmsg
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
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_trace,PC),A0
		bra	intmsg
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
handle_int_1:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_int_1,PC),A0
		bra	intmsg
handle_int_2:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_int_2,PC),A0
		bra	intmsg
handle_int_3:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_int_3,PC),A0
		bra	intmsg
handle_int_4:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_int_4,PC),A0
		bra	intmsg
handle_int_5:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_int_5,PC),A0
		bra	intmsg
handle_int_6:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_int_6,PC),A0
		bra	intmsg
handle_int_7:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_int_7,PC),A0
		bra	intmsg
handle_trap_0:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_trap_0,PC),A0
		bra	intmsg
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
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_trap_9,PC),A0
		bra	intmsg
handle_trap_A:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_trap_A,PC),A0
		bra	intmsg
handle_trap_B:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_trap_B,PC),A0
		bra	intmsg
handle_trap_C:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_trap_C,PC),A0
		bra	intmsg
handle_trap_D:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_trap_D,PC),A0
		bra	intmsg
handle_trap_E:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_trap_E,PC),A0
		bra	intmsg
handle_trap_F:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_trap_F,PC),A0
		bra	intmsg



intmsg
		bsr	PrString

		moveq	#13,D0
		jsr	doOSWRCH

		clr.b	D2
		clr.b	D3
intmsg_lp0:	
		moveq	#'D',D0
		bsr	doOSWRCH
		move.b	D2,D0
		add.b	#'0',D0
		bsr	doOSWRCH
		moveq	#'=',D0
		bsr	doOSWRCH
		moveq	#' ',D0
		jsr	doOSWRCH

		move.l	0(A7,D3),D0
		bsr	PrHex_l

		moveq	#' ',D0
		jsr	doOSWRCH
		jsr	doOSWRCH
		jsr	doOSWRCH
		moveq	#'A',D0
		bsr	doOSWRCH
		move.b	D2,D0
		add.b	#'0',D0
		bsr	doOSWRCH
		cmp.b	#7,D2
		beq	.done
		moveq	#'=',D0
		bsr	doOSWRCH
		moveq	#' ',D0
		jsr	doOSWRCH

		move.l	32(A7,D3),D0
		bsr	PrHex_l

		moveq	#13,D0
		jsr	doOSWRCH

		addq.b	#4,D3
		addq.b	#1,D2
		bra	intmsg_lp0

.done
		moveq	#'s',D0
		jsr	doOSWRCH
		moveq	#'=',D0
		bsr	doOSWRCH

		move	A7,D0
		add.l	#66,D0
		bsr	PrHex_l

		moveq	#13,D0
		jsr	doOSWRCH

		moveq	#'A',D0
		jsr	doOSWRCH
		moveq	#'7',D0
		jsr	doOSWRCH
		moveq	#'u',D0
		jsr	doOSWRCH
		moveq	#'=',D0
		jsr	doOSWRCH

		move.l	USP,A0
		move.l	A0,D0
		bsr	PrHex_l

		moveq	#13,D0
		jsr	doOSWRCH

		moveq	#'P',D0
		bsr	doOSWRCH
		moveq	#'C',D0
		bsr	doOSWRCH
		moveq	#'=',D0
		jsr	doOSWRCH
		moveq	#' ',D0
		bsr	doOSWRCH

		move.l	62(A7),D0
		jsr	PrHex_l

		moveq	#13,D0
		jsr	doOSWRCH

		moveq	#'S',D0
		bsr	doOSWRCH
		moveq	#'=',D0
		jsr	doOSWRCH
		moveq	#' ',D0
		bsr	doOSWRCH
		bsr	doOSWRCH

		move.w	60(A7),D0
		jsr	PrHex_w

		moveq	#13,D0
		jsr	doOSWRCH

		stop	#$2700


		movea.l	#STACK,A7			; reset stack

		

test_d:		dc.b	"Blitter Board 68008", 0
str_addr_err:	dc.b	"address error",0
str_bus_err:	dc.b	"bus error",0
str_illegal:	dc.b	"illegal op",0
str_div0:	dc.b	"div0",0
str_chk:	dc.b	"chk",0
str_trapv:	dc.b	"trapv",0
str_priv:	dc.b	"priv",0
str_trace:	dc.b	"trace",0
str_opA:	dc.b	"opA",0
str_opF:	dc.b	"opF",0
str_int_spur:	dc.b	"int_spur",0
str_int_1:	dc.b	"int_1",0
str_int_2:	dc.b	"int_2",0
str_int_3:	dc.b	"int_3",0
str_int_4:	dc.b	"int_4",0
str_int_5:	dc.b	"int_5",0
str_int_6:	dc.b	"int_6",0
str_int_7:	dc.b	"int_7",0
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



