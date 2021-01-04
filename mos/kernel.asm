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

		SECTION "code"


		macro DEBUG_INFO

		jsr	deice_print_str
		dc.b	\1
		dc.b	0
		align	1

		endm


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

		move.w	#$4E73,vec_nmi						; set rte in nmi space start
		ori.w	#$0700,SR						; disable interrupts

		; initialise DEICE monitor - TODO: move this to utility ROM 
		bsr	deice_init

		; test deice_print
		lea.l	test_d,A0
.lp2		move.b	(A0)+,D0
		beq	.sk
		bsr	deice_print
		bcc	.nomsg
		bra	.lp2
.sk		moveq	#13,D0
		bsr	deice_print
.nomsg	
		move.b	sheila_SYSVIA_ier,D0
		asl.b	#1,D0
		move.b	D0,D4				; save this for later
		beq	mos_handle_res_skip_clear_mem1	; it's a power boot do a full clear

		move.b	sysvar_BREAK_EFFECT,D0		;else if BREAK pressed read BREAK Action flags (set by
							;*FX200,n) 
		lsr	#1,D0				;divide by 2
		cmp.b	#$01,D0				;if (bit 1 not set by *FX200)
		bne	mos_handle_res_skip_clear_mem2	;then &DA03

mos_handle_res_skip_clear_mem1
		; do full memory clear here?
mos_handle_res_skip_clear_mem2
		move.b	#$0F,sheila_SYSVIA_ddrb

 *************************************************************************
 *                                                                       *
 *        set addressable latch IC 32 for peripherals via PORT B         *
 *                                                                       *
 *       ;bit 3 set sets addressed latch high adds 8 to VIA address      *
 *       ;bit 3 reset sets addressed latch low                           *
 *                                                                       *
 *       Peripheral              VIA bit 3=0             VIA bit 3=1     *
 *                                                                       *
 *       Sound chip              Enabled                 Disabled        *
 *       speech chip (RS)        Low                     High            *
 *       speech chip (WS)        Low                     High            *
 *       Keyboard Auto Scan      Disabled                Enabled         *
 *       C0 address modifier     Low                     High            * NOTE: Not used on 6809
 *       C1 address modifier     Low                     High            * NOTE: Not used on 6809
 *       Caps lock  LED          ON                      OFF             *
 *       Shift lock LED          ON                      OFF             *
 *                                                                       *
 *       C0 & C1 are involved with hardware scroll screen address        * NOTE: Not used on 6809
 *************************************************************************
		moveq	#$F,D1				;B=&F on entry
.l1		subq.w	#1,D1				;loop start
		move.b	D1,sheila_SYSVIA_orb		;Write latch IC32
		cmp.b	#$09,D1				;Is it 9?
		bhs	.l1				;If not go back and do it again
							;B=8 at this point
							;Caps Lock On, SHIFT Lock undetermined
							;Keyboard Autoscan on
							;Sound disabled (may still sound)
		clr.b	sysvar_BREAK_LAST_TYPE		;Clear last BREAK flag
		moveq	#9,D0				;B=9
LDA11		move.b	D0,D1				;
		bsr	keyb_check_key_code_API		;Interrogate keyboard
		roxl.b	#1,D1
		roxr.w	#1,D2				;rotate MSB into bit 7 of &FC
							;Get back value of X for loop
		subq	#1,D0				;Decrement it
		bne	LDA11				;and if >0 do loop again
							;On exit if Carry set link 3 is made
							;link 2 = bit 0 of &FC and so on
							;If CTRL pressed bit 7 of &FC=1 X=0
		lsr.w	#7,D2				;CTRL is now in bit 8 7..0 is keyboard links	
		move.b	D2,zp_mos_INT_A			;Save keyboard links for later
		bsr	x_Turn_on_Keyboard_indicators_API	;Set LEDs
							;Carry set on entry is in bit 0 of A on exit
							;Get carry back into carry flag


x_set_up_page_2
		lea	oswksp_OSWORD3_CTDOWN,A0
		lea	sysvar_BREAK_LAST_TYPE,A1
;;	puls	A					;get back A from &D9DB
		tst.b	D4				;if A=0 power up reset so DA36 with X=&9C Y=&8D
		beq	.s1

		lea	sysvar_FX238,A1				;else Y=&7E
		bcc	x_set_up_page_2_2			;and if not CTRL-BREAK DA42 WARM RESET
		lea	sysvar_BREAK_VECTOR_JMP,A1		;else Y=&87 COLD RESET
		addq.b	#1,sysvar_BREAK_LAST_TYPE		;&28D=1
.s1		addq.b	#1,sysvar_BREAK_LAST_TYPE		;&28D=&28D+1
								;get keyboard links set
		not.b	D4					;invert
		move.b	D4,sysvar_STARTUP_OPT			;and store at &28F
		lea	oswksp_VDU_VERTADJ,A0			;X=&90

		DEBUG_INFO	"Setup page 2"

;; : set up page 2; on entry	   &28D=0 Warm reset, X=&9C, Y=&7E ; &28D=1 Power up  , X=&90, Y=&8D ; &28D=2 Cold reset, X=&9C, Y=&87 
x_set_up_page_2_2
		clr.b	D0
x_setup_pg2_lp0	
		cmpa	#mosvar_SOUND_SEMAPHORE,A0		;zero &200+X to &2CD
		blo	x_setup_pg2_sk1				;	DA46
		st.b	D0					;then set &2CE to &2FF to &FF
x_setup_pg2_sk1
		move.b	D0,(A0)+				;LDA4A
		cmpa	#vduvars_start,A0
		bne	x_setup_pg2_lp0			;	DA4E

		move.b	D0,sheila_USRVIA_ddra		;	DA50

		DEBUG_INFO	"Setup zp"

		lea	zp_cfs_w,A0


LDA56		clr.b	(A0)+				;zero zeropage &E2 to &FF
		cmpa	#$200,A0			; remember zero page is in page 1!
		bne	LDA56				;	DA59


		DEBUG_INFO	"Setup vectors"

		; note 200-236 unused and uncleared
		
		lea	mostbl_SYSVAR_DEFAULT_SETTINGS(PC),A0
		lea	sysvar_OSVARADDR,A2		

LDA5B		move.b	(A0)+,(A2)+
		cmpa	A2,A1
		bne	LDA5B

		move.b	$62,zp_mos_keynumfirst		;	DA66
	

;;HEREHERHERERERE
;;
;;	IF MACH_BEEB
;;		jsr	ACIA_reset_from_CTL_COPY				; reset ACIA
;;	ENDIF





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



;		SWI	XOS_IntOn			; enable interrupts

		moveq	#1,D0				; init mode 0
		bsr	mos_VDU_init


		XWRITES	"HELLO ISHBEL"


		lea.l	$FFFF5000,A0
		move.w	#$FF,D0
.lll3		move.b	D0,(A0)+
		dbf	D0,.lll3


		move.w	#100,D1
		
		lea.l	test_d,A1
.lll4		move.l	A1,D0
		SWI	OS_Write0
		dbf	D1,.lll4



		moveq	#0,D4
.lll5		move.l	D4,D0
		bsr	PrHex_l

		SWI	OS_NewLine

		SWI	OS_WriteI+17
		move.b	D4,D0
		andi.b	#$7,D0
		SWI	OS_WriteC

		SWI	OS_WriteI+17
		move.b	D4,D0
		andi.b	#$7,D0
		not.b	D0
		SWI	OS_WriteC

		addq.l	#1,D4
		bra	.lll5


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


handle_int_IRQ:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_int_1,PC),A0
		bra	intmsg
handle_int_NMI:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_int_2,PC),A0
		bra	intmsg
handle_int_DEBUG:
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
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_trap_E,PC),A0
		bra	intmsg
handle_trap_15:
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



