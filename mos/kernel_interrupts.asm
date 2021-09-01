
		include "mos.inc"
		include "oslib.inc"
		include "hardware.inc"
		include "kernel_defs.inc"
		include "deice.inc"
		include "macros.inc"


		xdef 	kernel_handle_IRQ
		xdef	kernel_irq1v_handle
		xdef	kernel_irq2v_handle

		SECTION "code"

kernel_handle_IRQ:
		move.l	(IRQ1V), -(SP)		; call IRQ1V soft vector
		rts

kernel_irq1v_handle:
		movem.l	D0-D3/A0-A1,-(SP)

;; 6809 ;; 		; TODO ACIA
;; 6809 ;; 
;; 6809 ;; 
;; 6809 ;; ;LDCA2:	lda	LFE08				;get value of status register of ACIA
;; 6809 ;; ;	bvs	LDCA9				;if parity error then DCA9
;; 6809 ;; ;	bpl	mos_VIA_INTERUPTS_ROUTINES	;else if no interrupt requested DD06

 		bra	mos_VIA_INTERUPTS_ROUTINES

;; 6809 ;; ;LDCA9:	ldx	zp_mos_rs423timeout		;read RS423 timeout counter
;; 6809 ;; ;	dex					;decrement it
;; 6809 ;; ;	bmi	LDCDE				;and if <0 DCDE
;; 6809 ;; ;	bvs	LDCDD				;else if >&40 DCDD (RTS to DE82)
;; 6809 ;; ;	jmp	LF588				;else read ACIA via F588
;; 6809 ;; ;; ----------------------------------------------------------------------------
;; 6809 ;; ;LDCB3:	ldy	LFE09				;read ACIA data
;; 6809 ;; ;	rol	a				;
;; 6809 ;; ;	asl	a				;
;; 6809 ;; ;LDCB8:	tax					;X=A
;; 6809 ;; ;	tya					;A=Y
;; 6809 ;; ;	ldy	#$07				;Y=07
;; 6809 ;; ;	jmp	x_CAUSE_AN_EVENT		;check and service EVENT 7 RS423 error
;; 6809 ;; ;; ----------------------------------------------------------------------------
;; 6809 ;; ;LDCBF:	ldx	#$02				;read RS423 output buffer
;; 6809 ;; ;	jsr	mos_OSBYTE_145			;
;; 6809 ;; ;	bcc	LDCD6				;if C=0 buffer is not empty goto DCD6
;; 6809 ;; ;	lda	sysvar_PRINT_DEST		;else read printer destination
;; 6809 ;; ;	cmp	#$02				;is it serial printer??
;; 6809 ;; ;	bne	LDC68				;if not DC68
;; 6809 ;; ;	inx					;else X=3
;; 6809 ;; ;	jsr	mos_OSBYTE_145			;read printer buffer
;; 6809 ;; ;	ror	mosbuf_buf_busy+3		;rotate to pass carry into bit 7
;; 6809 ;; ;	bmi	LDC68				;if set then DC68
;; 6809 ;; ;LDCD6:	sta	LFE09				;pass either printer or RS423 data to ACIA 
;; 6809 ;; ;	lda	#$E7				;set timeout counter to stored value
;; 6809 ;; ;	sta	zp_mos_rs423timeout		;
;; 6809 ;; LDCDDrti
;; 6809 ;; 		rti					;and exit (to DE82)
;; 6809 ;; ;; ----------------------------------------------------------------------------
;; 6809 ;; 						;A contains ACIA status
;; 6809 ;; ;LDCDE:	and	sysvar_ACIA_IRQ_MASK_CPY	;AND with ACIA bit mask (normally FF)
;; 6809 ;; ;	lsr	a				;rotate right to put bit 0 in carry 
;; 6809 ;; ;	bcc	LDCEB				;if carry clear receive register not full so DCEB
;; 6809 ;; ;	bvs	LDCEB				;if V is set then DCEB
;; 6809 ;; ;	ldy	sysvar_RS423_CTL_COPY		;else Y=ACIA control setting
;; 6809 ;; ;	bmi	LDC7D				;if bit 7 set receive interrupt is enabled so DC7D
;; 6809 ;; 
;; 6809 ;; ;LDCEB:	lsr	a				;put BIT 2 of ACIA status into
;; 6809 ;; ;	ror	a				;carry if set then Data Carrier Detected applies
;; 6809 ;; ;	bcs	LDCB3				;jump to DCB3
;; 6809 ;; 
;; 6809 ;; ;	bmi	LDCBF				;if original bit 1 is set TDR is empty so DCBF
;; 6809 ;; ;	bvs	LDCDDrti			;if V is set then exit to DE82
;; 6809 ;; 
issue_unknown_interrupt					; LDCF3
;;TODO MODULES ;;		ldb	#SERVICE_5_UKINT		;X=5
;;TODO MODULES ;;		jsr	mos_OSBYTE_143_b_cmd_x_param	;issue rom call 5 'unrecognised interrupt'
;;TODO MODULES ;;		beq	LDCDDrti			;if a rom recognises it then RTI

		movem.l (SP)+,D0-D3/A0-A1
		move.l	(IRQ2V), -(SP)		; call IRQ2V soft vector
		rts

;; ----------------------------------------------------------------------------
;; VIA INTERUPTS ROUTINES
mos_VIA_INTERUPTS_ROUTINES

		move.b	sheila_SYSVIA_ifr,D0		;read system VIA interrupt flag register
		bpl	mos_PRINTER_INTERRUPT_USER_VIA_1;if bit 7=0 the VIA has not caused interrupt
							;goto DD47
		and.b	sysvar_SYSVIA_IRQ_MASK_CPY,D0	;mask with VIA bit mask
		and.b	sheila_SYSVIA_ier,D0		;and interrupt enable register
		btst	#1,D0				;check for bit 1 (frame sync CA1)
							;
		beq	mos_SYSTEM_INTERRUPT_5_Speech	;if carry clear then no IRQ 1, else
		subq.b	#1,sysvar_CFSTOCTR		;decrement vertical sync counter
		tst.b	zp_mos_rs423timeout		;A=RS423 Timeout counter
		bpl	LDD1E				;if +ve then DD1E
		addq.b	#1,zp_mos_rs423timeout		;else increment it
LDD1E		tst.b	sysvar_FLASH_CTDOWN		;load flash counter
		beq	LDD3D				;if 0 then system is not in use, ignore it
		subq.b	#1,sysvar_FLASH_CTDOWN		;else decrement counter
		bne	LDD3D				;and if not 0 go on past reset routine

		move.b	sysvar_FLASH_SPACE_PERIOD,D0	;else get mark period count in X
		bchg.b	#0,sysvar_VIDPROC_CTL_COPY	;current VIDEO ULA control setting test bit 0 and flip
		beq	LDD34				;is effective if so C=0 jump to DD34

		move.b	sysvar_FLASH_MARK_PERIOD,D0	;else get space period count in X
LDD34		move.b	sysvar_VIDPROC_CTL_COPY, sheila_VIDULA_ctl	;then change colour
		
		move.b	D0,sysvar_FLASH_CTDOWN		;&0251=X resetting the counter

LDD3D		moveq	#$04,D2				;D2=4 and call E494 to check and implement vertical
		bsr	x_CAUSE_AN_EVENT		;sync event (4) if necessary
		moveq	#$02,D0				;A=2
		bra	irq_set_sysvia_ifr_rti		;clear interrupt 1 and exit
;; 6809 ;; ;; ----------------------------------------------------------------------------
;; 6809 ;; ;; PRINTER INTERRUPT USER VIA 1
mos_PRINTER_INTERRUPT_USER_VIA_1
		
		;TODO printer interrupts
		bra	issue_unknown_interrupt


;; 6809 ;; ;	lda	sheila_USRVIA_ifr		;Check USER VIA interrupt flags register
;; 6809 ;; ;	bpl	issue_unknown_interrupt		;if +ve USER VIA did not call interrupt
;; 6809 ;; ;	and	sysvar_USERVIA_IRQ_MASK_CPY	;else check for USER IRQ 1
;; 6809 ;; ;	and	sheila_USRVIA_ier		;
;; 6809 ;; ;	ror	a				;
;; 6809 ;; ;	ror	a				;
;; 6809 ;; ;	bcc	issue_unknown_interrupt		;if bit 1=0 the no interrupt 1 so DCF3
;; 6809 ;; ;	ldy	sysvar_PRINT_DEST		;else get printer type
;; 6809 ;; ;	dey					;decrement
;; 6809 ;; ;	bne	issue_unknown_interrupt		;if not parallel then DCF3
;; 6809 ;; ;	lda	#$02				;reset interrupt 1 flag
;; 6809 ;; ;	sta	sheila_USRVIA_ifr		;
;; 6809 ;; ;	sta	sheila_USRVIA_ier		;disable interrupt 1
;; 6809 ;; ;	ldx	#$03				;and output data to parallel printer
;; 6809 ;; ;	jmp	LE13A				;
;; 6809 ;; ;; ----------------------------------------------------------------------------

;; SYSTEM INTERRUPT 5   Speech
mos_SYSTEM_INTERRUPT_5_Speech

		btst	#5,D0

		;TODO = no speech, do something here with timer 2?
		beq	mos_SYSTEM_INTERRUPT_6_10mS_Clock
		bra	issue_unknown_interrupt

;; 6809 ;; ;		bpl	mos_SYSTEM_INTERRUPT_6_10mS_Clock;if not set the not a speech interrupt so DDCA
;; 6809 ;; ;		lda	#$20				;	DD6F
;; 6809 ;; ;		ldb	#$00				;	DD71
;; 6809 ;; ;		sta	sheila_SYSVIA_ifr		;	DD73
;; 6809 ;; ;		stb	sheila_SYSVIA_t2ch		;	DD76
;; 6809 ;; 
;; 6809 ;; ;LDD79:		ldx	#$08				;	DD79
;; 6809 ;; ;		stx	zp_mos_OS_wksp2+1		;	DD7B
;; 6809 ;; ;LDD7D:		jsr	mos_OSBYTE_152			;	DD7D
;; 6809 ;; ;		ror	mosbuf_buf_busy+8		;	DD80
;; 6809 ;; ;		bmi	LDDC9				;	DD83
;; 6809 ;; ;		tay					;	DD85
;; 6809 ;; ;		beq	LDD8D				;	DD86
;; 6809 ;; ;		jsr	mos_OSBYTE_158			;	DD88
;; 6809 ;; ;		bmi	LDDC9				;	DD8B
;; 6809 ;; ;LDD8D:		jsr	mos_OSBYTE_145			;	DD8D
;; 6809 ;; ;		sta	zp_mos_curPHROM			;	DD90
;; 6809 ;; ;		jsr	mos_OSBYTE_145			;	DD92
;; 6809 ;; ;		sta	zp_mos_genPTR+1			;	DD95
;; 6809 ;; ;		jsr	mos_OSBYTE_145			;	DD97
;; 6809 ;; ;		sta	zp_mos_genPTR			;	DD9A
;; 6809 ;; ;		ldy	zp_mos_curPHROM			;	DD9C
;; 6809 ;; ;		beq	LDDBB				;	DD9E
;; 6809 ;; ;		bpl	LDDB8				;	DDA0
;; 6809 ;; ;		bit	zp_mos_curPHROM			;	DDA2
;; 6809 ;; ;		bvs	LDDAB				;	DDA4
;; 6809 ;; ;		jsr	LEEBB				;	DDA6
;; 6809 ;; ;		bvc	LDDB2				;	DDA9
;; 6809 ;; ;LDDAB:		asl	zp_mos_genPTR			;	DDAB
;; 6809 ;; ;		rol	zp_mos_genPTR+1			;	DDAD
;; 6809 ;; ;		jsr	LEE3B				;	DDAF
;; 6809 ;; ;LDDB2:		ldy	sysvar_SPEECH_SUPPRESS		;	DDB2
;; 6809 ;; ;		jmp	mos_OSBYTE_159			;	DDB5
;; 6809 ;; ;; ----------------------------------------------------------------------------
;; 6809 ;; ;LDDB8:	jsr	mos_OSBYTE_159			;	DDB8
;; 6809 ;; ;LDDBB:	ldy	zp_mos_genPTR			;	DDBB
;; 6809 ;; ;	jsr	mos_OSBYTE_159			;	DDBD
;; 6809 ;; ;	ldy	zp_mos_genPTR+1			;	DDC0
;; 6809 ;; ;	jsr	mos_OSBYTE_159			;	DDC2
;; 6809 ;; ;	lsr	zp_mos_OS_wksp2+1		;	DDC5
;; 6809 ;; ;	bne	LDD7D				;	DDC7
;; 6809 ;; ;LDDC9:	rts					;	DDC9
;; 6809 ;; ;; ----------------------------------------------------------------------------
;; 6809 ;; ;; SYSTEM INTERRUPT 6 10mS Clock
mos_SYSTEM_INTERRUPT_6_10mS_Clock
		btst	#6,D0
		beq	irq_adc_EOC			;bit 6 is in carry so if clear there is no 6 int
							;so go on to DE47
		move.b	#$40,sheila_SYSVIA_ifr		;Clear interrupt 6

 ;UPDATE timers routine, There are 2 timer stores &292-6 and &297-B
 ;these are updated by adding 1 to the current timer and storing the
 ;result in the other, the direction of transfer being changed each
 ;time of update.  This ensures that at least 1 timer is valid at any call
 ;as the current timer is only read.  Other methods would cause inaccuracies
 ;if a timer was read whilst being updated.

 		lea	oswksp_TIME-5,A1 		
 		moveq	#0,D0
		move.b	sysvar_TIMER_SWITCH,D0		;get current system clock store pointer (5,or 10)
		lea	(A1,D0.w), A0
		eor.b	#$0F, D0			;and invert lo nybble (5 becomes 10 and vv)
		move.b	D0,sysvar_TIMER_SWITCH		;and store back in clock pointer (i.e. inverse previous
							;contents)
		lea	(A1,D0.w), A1				

		; we have to do the full add here (as we are copying) and we
		; have to do it byte-wise as it is a) unaligned, b) in little-endian

		moveq	#4,D1
		clr.b	D2
		SEX


.tlp		move.b	(A0)+,D0
		addx.b	D2,D0
		move.b  D0,(A1)+
		dbra	D1,.tlp

		addq.l	#1,oswksp_OSWORD3_CTDOWN
		bne	.s2
		addq.b  #1,oswksp_OSWORD3_CTDOWN+4
		bne	.s2

		moveq	#$05,D2				;process EVENT 5 interval timer
		bsr	x_CAUSE_AN_EVENT		;

.s2
		; TODO68K: oswksp_INKEY_CTDOWN not aligned, worth sorting out as this is executed a lot!?
LDDFA		tst.b	oswksp_INKEY_CTDOWN		;get byte of inkey countdown timer
		bne	.sk1				;if 0 then skip
		tst.b   oswksp_INKEY_CTDOWN+1
		beq	LDE0A
.sk1		subq.b	#1,oswksp_INKEY_CTDOWN		;little-endian 16 bit decrement
		bcc	LDE0A
		subq.b	#1,oswksp_INKEY_CTDOWN+1


LDE0A		bclr.b	#7,mosvar_SOUND_SEMAPHORE	;read bit 7 of envelope processing byte
		beq	LDE1A				;if 0 then DE1A
		move.w	SR,-(SP)			;allow interrupts
		andi.w	#$F0FF,SR
		bsr	irq_sound			;and do routine sound processes
		move.w	(SP)+,SR			;bar interrupts
		bset.b	#7,mosvar_SOUND_SEMAPHORE	;DEC envelope processing byte back to FF


LDE1A		;TODO SPEECH
;; 6809 ;; ;;		tst	mosbuf_buf_busy+8		;read speech buffer busy flag
;; 6809 ;; ;;		bmi	LDE2B				;if set speech buffer is empty, skip routine
;; 6809 ;; ;;		jsr	mos_OSBYTE_158			;update speech system variables
;; 6809 ;; ;;		eora	#$A0				;
;; 6809 ;; ;;		cmpa	#$60				;
;; 6809 ;; ;;		bcc	LDE2B				;if result >=&60 DE2B
;; 6809 ;; ;;		jsr	LDD79				;else more speech work

 		;TODO ACIA
;; 6809 ;; ;LDE2B:		orcc	#CC_C+CC_V			;set V and C
;; 6809 ;; ;		jsr	LDCA2				;check if ACIA needs attention

 		move.b	zp_mos_keynumlast,D0		;check if key has been pressed
 		or.b	zp_mos_keynumfirst,D0		;
 		and.b	sysvar_KEYB_SEMAPHORE,D0	;(this is 0 if keyboard is to be ignored, else &FF)
 		beq	LDE3E				;if 0 ignore keyboard
 		SEC					;else set carry
 		bsr	mos_enter_keyboard_routines	;and call keyboard
 
LDE3E		;TODO PRINTER
;; 6809 ;; ;		jsr	LE19B				;check for data in user defined printer channel
 		;TODO ADC
;; 6809 ;; ;		bit	LFEC0				;if ADC bit 6 is set ADC is not busy
;; 6809 ;; ;		bvs	LDE4A				;so DE4A

		movem.l (SP)+,D0-D3/A0-A1
		rte					; finished interrupts

;; ----------------------------------------------------------------------------
;; SYSTEM INTERRUPT 4 ADC end of conversion
irq_adc_EOC
		btst	#4,D0						;put original bit 4 from FE4D into bit 7 of A
		beq	irq_keyboard ;if not set DE72
		;TODO ADC / CB1

;; 6809 ;; ;LDE4A:	ldx	sysvar_ADC_CUR			;else get current ADC channel
;; 6809 ;; ;	beq	LDE6C				;if 0 DE6C
;; 6809 ;; ;	lda	LFEC2				;read low data byte
;; 6809 ;; ;	sta	oswksp_OSWORD0_MAX_CH,x		;store it in &2B6,7,8 or 9
;; 6809 ;; ;	lda	LFEC1				;get high data byte 
;; 6809 ;; ;	sta	adc_CH4_LOW,x			;and store it in hi byte
;; 6809 ;; ;	stx	adc_CH_LAST			;store in Analogue system flag marking last channel
;; 6809 ;; ;	ldy	#$03				;handle event 3 conversion complete
;; 6809 ;; ;	jsr	x_CAUSE_AN_EVENT		;
;; 6809 ;; 
;; 6809 ;; ;	dex					;decrement X
;; 6809 ;; ;	bne	LDE69				;if X=0
;; 6809 ;; ;	ldx	sysvar_ADC_MAX			;get highest ADC channel preseny
;; 6809 ;; ;LDE69:	jsr	LDE8F				;and start new conversion
LDE6C		moveq	#$10,D0				;rest interrupt 4
irq_set_sysvia_ifr_rti					; LDE6E
		move.b	D0, sheila_SYSVIA_ifr		; reset SYS VIA IFR
		movem.l (SP)+,D0-D3/A0-A1
		rte					; finished interrupts
;; 6809 ;; ;; ----------------------------------------------------------------------------
;; 6809 ;; ;; SYSTEM INTERRUPT 0 Keyboard;	
irq_keyboard					; LDE72
		btst	#0,D0
		beq	issue_unknown_interrupt		;if bit 7 clear not a keyboard interrupt
		bsr	mos_enter_keyboard_routines	;else scan keyboard
		moveq	#$01,D0				;A=1
		bra	irq_set_sysvia_ifr_rti		;and off to reset interrupt and exit



kernel_irq2v_handle:
		DEBUG_INFO "Unhandled interrupt"

		DEBUG_INFO_S "SYSVIA IFR="
		move.b	sheila_SYSVIA_ifr, D0
		bsr	d_PrHex_b

		moveq	#13, D0
		bsr	deice_print

		DEBUG_INFO_S "SYSVIA IER="
		move.b	sheila_SYSVIA_ier, D0
		bsr	d_PrHex_b

		moveq	#13, D0
		bsr	deice_print

		DEBUG_INFO_S "SYSVIA MASK="
		move.b	sysvar_SYSVIA_IRQ_MASK_CPY, D0
		bsr	d_PrHex_b

		moveq	#13, D0
		bsr	deice_print


		DEBUG_INFO_S "USRVIA IFR="
		move.b	sheila_USRVIA_ifr, D0
		bsr	d_PrHex_b

		moveq	#13, D0
		bsr	deice_print

there:		stop	#$FFFF
		bra	there


