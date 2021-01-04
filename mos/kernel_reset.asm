

		include "mos.inc"
		include "oslib.inc"
		include "hardware.inc"
		include "kernel_defs.inc"
		include "deice.inc"
		include "macros.inc"

		xdef kernel_handle_res


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

kernel_handle_res:	
		TRACE
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


		;TODO: check this - clear bottom 32k
		lea.l	$400, A0
		move.w	#$8000-$400,D0
.1		clr.b	(A0)+
		dbf	D0,1

;;TODO: use this as top of 24 bit address RAM? set to 1F?
;;6809;;		sta	sysvar_RAM_AVAIL

		move.b	#$80,D0
		move.b	D0,	sysvar_KEYB_SOFT_CONSISTANCY


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
		bne	x_setup_pg2_lp0				;	DA4E

		move.b	D0,sheila_USRVIA_ddra			;	DA50

		DEBUG_INFO	"Setup zp"

		lea	zp_cfs_w,A0


LDA56		clr.b	(A0)+				;zero zeropage &E2 to &FF
		cmpa	#$200,A0			; remember zero page is in page 1!
		bne	LDA56				;	DA59


		; NOTE: sysvars and vectors have been split - vectors now at 400!
		DEBUG_INFO	"init sysvars"

		; note 200-236 unused and uncleared
		
		lea	mostbl_SYSVAR_DEFAULT_SETTINGS(PC),A0
		lea	sysvar_OSVARADDR,A2		

LDA5B		move.b	(A0)+,(A2)+
		cmpa	A2,A1
		bne	LDA5B

		move.b	#$62,zp_mos_keynumfirst		;	DA66
	

		DEBUG_INFO "init vectors"

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

;;HEREHERHERERERE
;;
;;	IF MACH_BEEB
;;		jsr	ACIA_reset_from_CTL_COPY				; reset ACIA
;;	ENDIF

		DEBUG_INFO "Setup vias"

; clear interrupt and enable registers of Both VIAs
x_clear_IFR_IER_VIAs
		move.b	#$7F, D0
		move.b	D0, sheila_SYSVIA_ifr			; disable and clear interrupts on system
		move.b	D0, sheila_SYSVIA_ier
		move.b  D0, sheila_USRVIA_ifr			; and user vias
		move.b  D0, sheila_USRVIA_ier
	;; DB 20180223 - removed this as *legacy*
;;;		clr	-2,S					; clear the stack
;;;		CLI						; briefly allow interrupts to clear anything pending
;;;		SEI						; disallow again N.B. All VIA IRQs are disabled
;;;;;	lda	#$40
;;;;;	bita	zp_mos_INT_A				; if bit 6=1 then JSR &F055 (normally 0) 
;;;		tst	-2,S					; if this is set then an interrupt occurred
;;;		beq	LDA80					; else DA80
;;;		jsr	[$FDFE]					; if IRQ held low at BREAK then jump to address held in
;;;							; FDFE (JIM) 
;;;LDA80		
								;enable interrupts 1,4,5,6 of system VIA
		move.b  #$F2, sheila_SYSVIA_ier			;
								;0      Keyboard enabled as needed
								;1      Frame sync pulse
								;4      End of A/D conversion
								;5      T2 counter (for speech)
								;6      T1 counter (10 mSec intervals)
								;	
								;set system VIA PCR
		move.b	#$04, sheila_SYSVIA_pcr			;
								;CA1 to interrupt on negative edge (Frame sync)
								;CA2 input pos edge Keyboard
								;CB1 interrupt on negative edge (end of conversion)
								;CB2 Negative edge (Light pen strobe)
								;                       
		move.b	#$60, sheila_SYSVIA_acr			;set system VIA ACR
								;disable latching
								;disable shift register
								;T1 counter continuous interrupts
								;T2 counter timed interrupt
		move.b	#$0E, D0
								;set system VIA T1 counter (Low)
		move.b	D0, sheila_SYSVIA_t1ll			;this becomes effective when T1 hi set

		move.b  D0, sheila_USRVIA_pcr			;set user VIA PCR
								;CA1 interrupt on -ve edge (Printer Acknowledge)
								;CA2 High output (printer strobe)
								;CB1 Interrupt on -ve edge (user port) 
								;CB2 Negative edge (user port)
;TODO ADC
;;	sta	LFEC0						;set up A/D converter
								;Bits 0 & 1 determine channel selected
								;Bit 3=0 8 bit conversion bit 3=1 12 bit

		cmp.b	sheila_USRVIA_pcr, D0			;read user VIA IER if = &0E then DAA2 chip present 
		beq	LDAA2					;so goto DAA2
		addq.b	#1,sysvar_USERVIA_IRQ_MASK_CPY		;else increment user VIA mask to 0 to bar all 
								;user VIA interrupts

LDAA2		move.b	#$27,D0					;set T1 (hi) to &27 this sets T1 to &270E (9998 uS)
		move.b	D0,sheila_SYSVIA_t1lh			;or 10msec, interrupts occur every 10msec therefore
		move.b	D0,sheila_SYSVIA_t1ch			;



;		SWI	XOS_IntOn			; enable interrupts

		moveq	#1,D0				; init mode 0
		bsr	mos_VDU_init


		bra	kernel_go_todo
