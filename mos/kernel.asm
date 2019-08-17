;; (c) 2019 Dossytronics, Dominic Beesley

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

		xdef		brkBadCommand

		xdef		mos_DEFAULT_BRK_HANDLER
		xdef		mos_WRCH_default_entry

		SECTION "code"



 **************************************************************************
 **************************************************************************
 **                                                                      **
 **                                                                      **
 **      RESET (BREAK) ENTRY POINT                                       **
 **                                                                      **
 **      Power up Enter with nothing set, 6522 System VIA IER bits       **
 **      0 to 6 will be clear                                            **
 **                                                                      **
 **      BREAK IER bits 0 to 6 one or more will be set 6522 IER          **
 **      not reset by BREAK                                              **
 **                                                                      **
 **************************************************************************

handle_res:	
		; copy rom vectors to low memory
		lea	(romv_start,PC),A6
		movea	#0, A0
		moveq	#$63, D0
.lp:		move.l	(A6)+,(A0)+
		dbf	D0,.lp


		; switch maps by temporarily selecting blitter device
		move.b	#JIM_DEVNO_BLITTER,(fred_JIM_DEVNO)
		clr.b	(fred_JIM_DEVNO)

		; initialise DEICE monitor - TODO: move this to utility ROM 
		bsr	deice_init

		; test deice_print
		lea.l	test_d,A0
.lp2		move.b	(A0)+,D0
		beq	.sk
		bsr	deice_print
		bra	.lp2
.sk		moveq	#13,D0
		bsr	deice_print





		; zero page 2 as per cold reset
		lea	oswksp_VDU_VERTADJ,A0
		moveq	#mosvar_SOUND_SEMAPHORE-oswksp_VDU_VERTADJ-1,D1
.cm0		clr.b	(A0)+
		dbf	D1,.cm0
		moveq	#vduvar_GRA_WINDOW-mosvar_SOUND_SEMAPHORE-1,D1
.cm1		st.b	(A0)+
		dbf	D1,.cm1

		; boot bodges for not cleared memory faults
		clr.b	oswksp_VDU_INTERLACE
		clr.b	oswksp_VDU_VERTADJ
		clr.b	sysvar_VDU_Q_LEN		; should be set in buffer flush somewhere early in boot?

		move.b	#$0F,sheila_SYSVIA_ddrb


		; copy os vector default entries
		lea.l	VECTOR_START,A0
		moveq	#((VECTOR_END-VECTOR_START)/4)-1,D0
		lea.l	defaultosvectors(PC),A1

.vlp		move.l	(A1)+,A2
		adda.l	A1,A2
		suba.l	#4,A2
		move.l	A2,(A0)+
		dbf	D0,.vlp

		; clear rest of vectors
		moveq	#((256-(VECTOR_END-VECTOR_START))/4)-1,D0
.vlp2		clr.l	(A0)+
		dbf	D0,.vlp2

		moveq	#2,D0				; init mode 0
		bsr	mos_VDU_init


		lea.l	$FFFF5000,A0
		move.w	#$FF,D0
.lll3		move.b	D0,(A0)+
		dbf	D0,.lll3

		move.w	#255,D1
.lll4		lea.l	test_d,A0
.lll2		move.b	(A0)+,D0
		beq	.sss1
		SWI	OS_WriteC
		bra	.lll2
.sss1		dbf	D1,.lll4


		ori	#$8000,SR	; TRACE

		moveq	#0,D4
.lll5		move.l	D4,D0
		bsr	PrHex_l

		move.b	#13,D0
		SWI	OS_WriteC
		move.b	#10,D0
		SWI	OS_WriteC


		move.b	#17,D0
		SWI	OS_WriteC
		move.b	D4,D0
		andi.b	#$7,D0
		SWI	OS_WriteC

		move.b	#17,D0
		SWI	OS_WriteC
		move.b	D4,D0
		andi.b	#$7,D0
		not.b	D0
		SWI	OS_WriteC

		addq.l	#1,D4
		bra	.lll5




		ori	#$8000,SR	; TRACE



		trap	#0

		
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
		SWI	OS_WriteC
		move.b	(A7)+,D0
		rts




d_PrHex_l:	swap	D0
		jsr	d_PrHex_w
		swap	D0
d_PrHex_w:	move.w	D0,-(A7)
		asr.w	#8,D0
		jsr	d_PrHex_b
		move.w	(A7)+,D0
d_PrHex_b:	move.b,	D0,-(A7)
		asr.b	#4,D0
		jsr	d_PrHex_nyb
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
		moveq	#DEICE_STATE_IRQ_x+7,D0
		bra	deice_enter

handle_trap_0:
		; TODO restore user mode before call OS_GenerateError?
		lea.l	2(SP),SP
		move.l	(SP),A0
		bra	SWI_OS_Generate_Error


********************************************************************************
* SWI dispatch and handling                                                    *
*                                                                              *
* SWIs are emulated using TRAPS#1 and #2, #1 is a shortcut for the longer      *
* #2 form with but uses fewer bytes in the program as the SWI number is        *
* encoded in fewer (16 bits) instead of 24                                     *
*                                                                              *
* TRAP #2                                                                      *
* dc.l 24 bit SWI number (in 32bit field)                                      *
*                                                                              *
* TRAP #1                                                                      *
* dc.w 16 bit SWI number (encoded bit 15=X flag, 14..0 as SWI no)              *
*                                                                              *
* All SWI parameters are passed in D0..D7                                      *
* All Address register should be preserved                                     *
*                                                                              *
*                                                                              *
*                                                                              *
*                                                                              *
********************************************************************************


handle_trap_1:
		lea.l	-12(SP),SP			; reserve space on stack for SWI number, SWI exit and swi routine address		
		movem.l	D7/A6,-(SP)

		; get swi number in D0 and adjust stacked PC
		clr.l	D7
		move.l	22(SP),A6			; get return address
		move.w	(A6)+,D7			; load word after trap
		ext.l	D7				; sign extend number (not for 16bit swi's X bit is bit 15)
		and.l	#$00027FFF,D7			; mask off unwanted but keep X extended into bit 17
		bra	SWI_Handle_D7

handle_trap_2:
		lea.l	-12(SP),SP			; reserve space on stack for SWI number, SWI exit and swi routine address		
		movem.l	D0/A6,-(SP)
		; get swi number in D0 and adjust stacked PC
		move.l	22(SP),A6
		move.l	(A6)+,D7
SWI_Handle_D7

	;STACK:
	;+-----+---+----------------------------------------+
	;| +16 | l | Original PC (points at SWI number WORD |
	;+-----+---+----------------------------------------+
	;| +14 | w | Original SR                            |
	;+-----+---+----------------------------------------+
	;| +10 | l | reserved for SWI number                |
	;+-----+---+----------------------------------------+
	;| +0C | l | reserved for return to SWI exit        |
	;+-----+---+----------------------------------------+
	;| +08 | l | reserved for SWI routine addr          |
	;+-----+---+----------------------------------------+
	;| +04 | l | old A6                                 |
	;+-----+---+----------------------------------------+
	;| +00 | l | old D7                                 |
	;+-----+---+----------------------------------------+


		move.l	A6,$16(SP)			; adjust return address		
		move.l	D7,$10(SP)			; now save SWI number on the stack

		lea.l	SWI_Exit(PC),A6
		move.l	A6, $0C(SP)			; when we return from SWI go here

		bclr.l	#17,D7				; clear X bit
		cmp.l	#$10,D7
		bhs	FindSwi	
		asl.w	#2,D7
		lea.l	SWI_TABLE_LOW(PC),A6
		lea.l	(A6,D7.w),A6
		move.l	(A6),D7
		lea.l	(A6,D7.l),A6
		move.l	A6,$08(SP)

		movem.l	(SP)+,D7/A6			; restore A6,D7
		rts					; call swi stacked

SWI_NOWT	CLV
		rts

SWI_TABLE_LOW	dc.l	SWI_OS_WriteC-*
		dc.l	SWI_NOWT-*
		dc.l	SWI_NOWT-*
		dc.l	SWI_NOWT-*
		dc.l	SWI_NOWT-*
		dc.l	SWI_NOWT-*
		dc.l	SWI_NOWT-*
		dc.l	SWI_UKSwi-*
		dc.l	SWI_UKSwi-*
		dc.l	SWI_UKSwi-*
		dc.l	SWI_UKSwi-*
		dc.l	SWI_UKSwi-*
		dc.l	SWI_UKSwi-*
		dc.l	SWI_UKSwi-*
		dc.l	SWI_UKSwi-*
		dc.l	SWI_UKSwi-*
		dc.l	SWI_UKSwi-*




SWI_Exit
	;STACK:
	;+-----+---+----------------------------------------+
	;| +06 | l | Original PC (points at SWI number WORD |
	;+-----+---+----------------------------------------+
	;| +04 | w | Original SR                            |
	;+-----+---+----------------------------------------+
	;| +00 | l | reserved for SWI number                |
	;+-----+---+----------------------------------------+

		bvs	SWI_Exit_Error
		bclr	#1,$05(SP)			; reset V flag in stacked SR
		lea.l	4(SP),SP			; skip saved SWI #
		rte					; return


SWI_Exit_Error	; an error occurred work out if original SWI was an error returning one
		; swi number should be TOS
		btst.b	#1,1(SP)			; check error returning bit (bit #17 of SWI number)
		beq	SWI_OS_Generate_Error
		bset	#1,$05(SP)			; set V flag
		lea.l	4(SP),SP
		rte

SWI_OS_Generate_Error
		move.l	(BRKV),-(SP)
		rts
		

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

FindSwi
DoUKSwi		; fix up stack to just contain SWI number/SR/PC
		lea.l	16(SP),SP
SWI_UKSwi
		lea.l	ErrBlk_UKSwi,A0
		SEV
		bra	SWI_Exit	

ErrBlk_UKSwi	dc.l	$1e6
		dc.b    "No Such SWI", 0


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
		moveq	#DEICE_STATE_BP,D0
		bra	deice_enter



intmsg
		bsr	PrString

		moveq	#13,D0
		bsr	deice_print

		clr.b	D2
		clr.w	D3
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

		move.l	0(A7,D3.w),D0
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
		add.l	#66,D0
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

		move.l	62(A7),D0
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

		move.w	60(A7),D0
		bsr	d_PrHex_w

		moveq	#13,D0
		bsr	deice_print

		stop	#$2700


		movea.l	#STACK,A7			; reset stack

mos_WRCH_default_entry
		; TODO all the printer/redirect/spool stuff for now just sends to VDU
		movem.l	D0-D3/A0-A1,-(SP)
		bsr	mos_VDU_WRCH
		movem.l (SP)+,D0-D3/A0-A1
		rts

SWI_OS_WriteC	bsr	callWRCHV
		CLV
		rts
callWRCHV
		move.l	(WRCHV),-(SP)
		rts

brkBadCommand	trap	#0
		dc.l	$FE
		dc.b 	"Bad Command", 0




test_d:		dc.b	"Blitter Board 68008", 13,10,17,2,17,129,"one", 13,10,17,1,17,128,"two",13,10,17,129,17,6,0
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



