

		include "mos.inc"
		include "oslib.inc"
		include "hardware.inc"
		include "kernel_defs.inc"
		include "deice.inc"
		include "macros.inc"
		include "keyboard.inc"

		xdef 	keyb_check_key_code_API
		xdef	x_Turn_on_Keyboard_indicators_API68
		xdef 	mos_enter_keyboard_routines
		xdef	KEYV_default
		xdef 	x_keyb_leds_test_esc
		xdef	mos_RDCHV_default_entry

		xdef	mos_OSBYTE_121
		xdef	mos_OSBYTE_122
		xdef	mos_OSBYTE_129
		xdef	mos_OSBYTE_118


		SECTION "code"

pause_VIA
		move	SR,-(SP)
		move.l	D0,-(SP)
		moveq	#10,D0
.lp		dbf	D0,.lp
		move.l	(SP)+,D0
		rtr



;; Keyboard Input and housekeeping; entered from &F00C 
keyb_input_and_housekeeping			; LEEDA
		movem.l	(SP)+,D3-D4/A0
		moveq	#-1,D1				;
		move.b	zp_mos_keynumlast,D0		;get value of most recently pressed key
		or.b	zp_mos_keynumfirst,D0		;Or it with previous key to check for presses
		bne	LEEE8				;if A=0 no keys pressed so off you go
		move.b	#$81, sheila_SYSVIA_ier		;else enable keybd interupt only by writing bit 7
							;and bit 0 of system VIA interupt register 
		addq.b	#1,D1				;set X=0
LEEE8		move.b	D1,sysvar_KEYB_SEMAPHORE	;reset keyboard semaphore

; : Turn on Keyboard indicators
; 68 no longer mucks about with flags in D0(A)! instead just preserves them
x_Turn_on_Keyboard_indicators_API68			; LEEEB
		move.w	SR,-(SP)
		move.w	D0,-(SP)
		move.b	sysvar_KEYB_STATUS,D0		;read keyboard status;
							;Bit 7  =1 shift enabled
							;Bit 6  =1 control pressed
							;bit 5  =0 shift lock
							;Bit 4  =0 Caps lock
							;Bit 3  =1 shift pressed    
		lsr.b	#1,D0				;shift Caps bit into bit 3
		andi.b	#$18,D0				;mask out all but 4 and 3
		ori.b	#$06,D0				;returns 6 if caps lock OFF &E if on
		move.b	D0,sheila_SYSVIA_orb		;turn on or off caps light if required
		lsr.b	#1,D0				;bring shift bit into bit 3
		ori.b	#$07,D0				;
		move.b	D0,sheila_SYSVIA_orb		;turn on or off shift  lock light
		bsr	keyb_hw_enable_scan		;set keyboard counter
		move.w	(SP)+,D0
		rtr

x_Turn_on_Keyboard_indicators_API68_2
		movem.l	(SP)+,D3-D4/A0
		bra	x_Turn_on_Keyboard_indicators_API68


;; ----------------------------------------------------------------------------
;; Interrogate Keyboard routine;
		; NOTE: API change D1 now contains key code to scan, D0 is preserved
		; NB: needs to preserve carry but return N!
keyb_check_key_code_API
		move.w	SR,-(A7)
		andi.b	#~$08,1(A7)			;clear N
		move.b	#$03,sheila_SYSVIA_orb		;stop Auto scan by writing to system VIA
		move.b	#$7F,sheila_SYSVIA_ddra		;set bits 0 to 6 of port A to input on bit 7
							;output on bits 0 to 6
		move.b	D1,sheila_SYSVIA_ora_nh		;write X to Port A system VIA

		bsr	pause_VIA

		move.b	sheila_SYSVIA_ora_nh,D1		;read back &80 if key pressed (M set)
		bpl	.sk
		ori.b	#$08,1(A7)
.sk		rtr					;and return




 *************************************************************************
 *                                                                       *
 * MAIN KEYBOARD HANDLING ROUTINE   ENTRY FROM KEYV                      *
 * ==========================================================            *
 *                                                                       *
 *                       ENTRY CONDITIONS                                *
 *                       ================                                *
 * C=0, V=0 Test Shift and CTRL keys.. exit with N set if CTRL pressed   *
 *                                 ........with V set if Shift pressed   *
 * C=1, V=0 Scan Keyboard as OSBYTE &79                                  *
 * C=0, V=1 Key pressed interrupt entry                                  *
 * C=1, V=1 Timer interrupt entry                                        *
 *                                                                       *
 *************************************************************************



KEYV_default	
							; LEF02
		movem.l	D3-D4/A0,-(SP)
		move	SR, D4				; 68 - save carry flag
		bvc	.vc1				;if V is clear then leave interrupt routine
							;disable keyboard interrupts
		move.b	#$01,sheila_SYSVIA_ier		;by writing to VIA interrupt vector
		btst	#CC_C_B,D4			; check carry flag
		bne	KEYV_Timer_interrupt_entry	;if timer interrupt then EF13
		bra	KEYV_default_keypress_IRQ	;else to F00F

.vc1		bcc	KEYV_test_shift_ctl		;if test SHFT & CTRL goto EF16
		bra	KEYV_keyboard_scan		;else to F0D1
							;to scan keyboard
; Timer interrupt entry
KEYV_Timer_interrupt_entry
		addq.b	#1,sysvar_KEYB_SEMAPHORE	;increment keyboard semaphore (to 0)
; Test Shift and Control Keys entry
KEYV_test_shift_ctl
		move.b	sysvar_KEYB_STATUS,D0		;read keyboard status;     
							;Bit 7  =1 shift enabled   
							;Bit 6  =1 control pressed 
							;bit 5  =0 shift lock      
							;Bit 4  =0 Caps lock       
							;Bit 3  =1 shift pressed   
		andi.b	#~(KEYST_M_3_SHIFT|KEYST_M_6_CTRL),D0
							;zero bits 3 and 6
		clr.b	D1				;zero D1 to test for shift key press
		bsr	keyb_check_key_code_API		;interrogate keyboard X=&80 if key determined by
							;X on entry is pressed 
		move.b	D1,zp_mos_OS_wksp2		;save X
		bpl	.notsh				;if no key press (X=0) then EF2A else
		bset	#KEYST_B_3_SHIFT,D0		;set bit 3 to indicate Shift was pressed
.notsh		moveq	#1,D1				;check the control key
		bsr	keyb_check_key_code_API		;via keyboard interrogate
		btst	#CC_C_B, D4
		beq	x_Turn_on_Keyboard_indicators_API68_2	
							;if carry clear (entry via EF16) then off to EEEB
							;to turn on keyboard lights as required
		bpl	.notctl				;if key not pressed goto EF30
		bset	#KEYST_B_6_CTRL,D0		;or set CTRL pressed bit in keyboard status byte in A
.notctl		move.b	D0,sysvar_KEYB_STATUS		;save status byte
		move.b	zp_mos_keynumlast,D1		;if no key previously pressed
		beq	LEFE9				;then EF4D
		bsr	keyb_check_key_code_API		;else check to see if key still pressed
		bmi	x_REPEAT_ACTION			;if so enter repeat routine at EF50
		cmp.b	zp_mos_keynumlast,D1		;else compare B with last key pressed (set flags)
LEF42		beq	.sameas				;DB: slight change as 6809 sets Z on STx
		move.b	D1,zp_mos_keynumlast		;store B in last key pressed
		bra	LEF4A				;if different from previous (Z clear) then EF4D
.sameas							;else zero 
		clr.b	zp_mos_keynumlast		;last key pressed 
LEF4A		bsr	keyb_set_autorepeat_countdown	;and reset repeat system
		bra	LEFE9
;; ----------------------------------------------------------------------------
;; REPEAT ACTION
x_REPEAT_ACTION
		cmp.b	zp_mos_keynumlast,D1		;if B<>last key pressed
		bne	LEF42				;then back to EF42
		tst.b	zp_mos_autorep_countdown	;else get value of AUTO REPEAT COUNTDOWN TIMER
		beq	LEFE9				;if 0 goto EF7B
		subq.b	#1,zp_mos_autorep_countdown	;else decrement
		bne	LEFE9				;and if not 0 goto EF7B
							;this means that either the repeat system is dormant
							;or it is not at the end of its count
		move.b	mosvar_KEYB_AUTOREPEAT_COUNT, zp_mos_autorep_countdown
							;store next value for countdown timer
		move.b	sysvar_KEYB_AUTOREP_PERIOD, mosvar_KEYB_AUTOREPEAT_COUNT	
							;get auto repeat rate from 0255, store it as next value for Countdown timer
		move.b	sysvar_KEYB_STATUS,D0		;get keyboard status
		move.b	zp_mos_keynumlast,D1		;get last key pressed
		cmp.b	#KEYCODE_D0_SHIFTLOCK,D1	;if not SHIFT LOCK key (&D0) goto
		bne	LEF7E				;EF7E
		ori.b	#KEYST_M_7_SHEN|KEYST_M_4_CALK,D0;sets shift enabled, & no caps lock all else preserved
		eor.b	#KEYST_M_7_SHEN|KEYST_M_5_SHLN,D0;reverses shift lock disables Caps lock and Shift enab
LEF74		move.b  D0,sysvar_KEYB_STATUS		;reset keyboard status
							;and set timer
		clr.b	zp_mos_autorep_countdown	;to 0
		bra	LEFE9
		
LEF7E		cmp.b	#KEYCODE_C0_CAPSLOCK,D1		;if not CAPS LOCK
		bne	x_get_ASCII_code		;goto EF91
		ori.b	#KEYST_M_7_SHEN|KEYST_M_5_SHLN,D0;sets shift enabled and disables SHIFT LOCK
		tst.b	zp_mos_OS_wksp2			;if bit 7 not set by (EF20) shift NOT pressed
		bpl	LEF8C				;goto EF8C
		ori.b	#KEYST_M_4_CALK,D0		;else set CAPS LOCK not enabled
		eori.b	#KEYST_M_7_SHEN,D0		;reverse SHIFT enabled

LEF8C		eori.b	#KEYST_M_7_SHEN|KEYST_M_4_CALK,D0;reverse both SHIFT enabled and CAPs Lock
		bra	LEF74				;reset keyboard status and set timer
;; ----------------------------------------------------------------------------
;; get ASCII code; on entry D1=key pressed internal number 
x_get_ASCII_code
		lea	key2ascii_tab-$10(PC),A0
		andi.w	#$007F,D1
		move.b	(A0,D1.w),D0			;get code from look up table
		bne	.skntab				;if not zero goto EF99 else TAB pressed
		move.b	sysvar_KEYB_TAB_CHAR,D0		;get TAB character
.skntab		move.b	sysvar_KEYB_STATUS,D3		;get keyboard status
							;store it in &FA
		rol.b	#1,D3				;CTRL pressed into bit 7
		bpl	LEFA9				;if CTRL NOT pressed EFA9
		move.b	zp_mos_keynumfirst,D1		;get no. of previously pressed key
LEFA4		bne	LEF4A				;if not 0 goto EF4A to reset repeat system etc.
		bsr	x_Implement_CTRL_codes		;else perform code changes for CTRL

LEFA9		rol.b	#1,D3				;move shift lock into bit 7
LEFAB		bmi	LEFB5				;if not effective goto EFB5 else
		bsr	x_Modify_code_as_if_SHIFT	;make code changes for SHIFT
		
		rol.b	#1,D3				;caps lock into b7
		bra	LEFC1				;and Jump to EFC1

LEFB5		rol.b	#1,D3				;move CAPS LOCK into bit 7
		bmi	LEFC6				;if not effective goto EFC6
		bsr	mos_CHECK_FOR_ALPHA_CHARACTER	;else make changes for CAPS LOCK on, return with 
							;C clear for Alphabetic codes
		bcs	LEFC6				;if carry set goto EFC6 else make changes for
		bsr	x_Modify_code_as_if_SHIFT	;SHIFT as above

LEFC1		tst.b	sysvar_KEYB_STATUS		;if shift enabled bit is clear
		bpl	LEFD1				;goto EFD1
LEFC6		rol.b	#1,D3				;else get shift bit into z
		bpl	LEFD1				;if not set goto EFD1
		move.b	zp_mos_keynumfirst,D1		;get previous key press
		bne	LEFA4				;if not 0 reset repeat system etc. via EFA4
		bsr	x_Modify_code_as_if_SHIFT	;else make code changes for SHIFT
LEFD1		cmp.b	sysvar_KEYB_ESC_CHAR,D0		;if A<> ESCAPE code 
		bne	LEFDD				;goto EFDD
		move.b	sysvar_KEYB_ESC_ACTION,D1	;get Escape key status
		bne	LEFDD				;if ESCAPE returns ASCII code goto EFDD
		move.b	D1,zp_mos_autorep_countdown	;store in Auto repeat countdown timer
LEFDD		move.b	D0,D2					
		bsr	keyb_enable_scan_IRQonoff	;disable keyboard
		tst.b	sysvar_KEYB_DISABLE		;read Keyboard disable flag used by Econet 
		bne	LEFE9				;if keyboard locked goto EFE9
		bsr	x_INSERT_byte_in_Keyboard_buffer;put character in input buffer
LEFE9		move.b	zp_mos_keynumfirst,D1		;get previous keypress
		beq	LEFF8				;if none  EFF8
		bsr	keyb_check_key_code_API		;examine to see if key still pressed
		move.b	D1,zp_mos_keynumfirst		;store result
		bmi	LEFF8				;if pressed goto EFF8
		clr.b	zp_mos_keynumfirst		;and &ED

LEFF8		move.b	zp_mos_keynumfirst,D1		;get &ED
		bne	LF012				;if not 0 goto F012

		; note pointer/offset to zp_mos_keynumlast!
		move.b	#zp_mos_keynumlast & $FF,D2	;get first keypress into Y (DB: last!)
		bsr	clc_then_mos_OSBYTE_122		;scan keyboard from &10 (osbyte 122)
		bmi	LF00C				;if exit is negative goto F00C
		move.b	zp_mos_keynumlast,zp_mos_keynumfirst
							;else make last key the
							;first key pressed i.e. rollover

LF007		move.b	D1,zp_mos_keynumlast		;save X into &EC
		bsr	keyb_set_autorepeat_countdown	;set keyboard repeat delay
LF00C		bra	keyb_input_and_housekeeping	;go back to EEDA
;; ----------------------------------------------------------------------------
;; Key pressed interrupt entry point; enters with X=key 
KEYV_default_keypress_IRQ				; LF00F
		;;clr.b	D1				; DB ??? not sure what is what here on BeebEm always seems to be X=0 here!
		bsr	keyb_check_key_code_API		;check if key pressed
LF012		tst.b	zp_mos_keynumlast		;get previous key press
		bne	LF00C				;if none back to housekeeping routine
		;TODO: should this be pointer to zp or value from zp?
		move.b	#zp_mos_keynumfirst & $FF,D2	;get last keypress into Y
		bsr	clc_then_mos_OSBYTE_122		;and scan keyboard
		tst.b	D1
		bmi	LF00C				;if negative on exit back to housekeeping
		bra	LF007				;else back to store X and reset keyboard delay etc.
;; Set Autorepeat countdown timer
keyb_set_autorepeat_countdown
							;set timer to 1
		move.b	#$01,zp_mos_autorep_countdown	;
		move.b	sysvar_KEYB_AUTOREP_DELAY,mosvar_KEYB_AUTOREPEAT_COUNT	;get next timer value and store it		
		rts					;

;; Modify code as if SHIFT pressed
x_Modify_code_as_if_SHIFT			; LEA9c
		cmp.b	#'0',D0				;if A='0' skip routine
		beq	LEABErts				;
		cmp.b	#'@',D0				;if A='@' skip routine
		beq	LEABErts				;
		blo	LEAB8				;if A<'@' then EAB8
		cmp.b	#$7F,D0				;else is it DELETE
		beq	LEABErts			;if so skip routine
		bhi	LEABCeor10rts			;if greater than &7F then toggle bit 4
LEAACeor30	eori.b	#$30,D0				;reverse bits 4 and 5
		cmp.b	#$6F,D0				;is it &6F (previously '_' (&5F))
		beq	LEAB6				;goto EAB6
		cmp.b	#$50,D0				;is it &50 (previously '`' (&60))
		bne	LEAB8				;if not EAB8
LEAB6		eor.b	#$1F,D0				;else continue to convert ` _
LEAB8		cmp.b	#'!',D0				;compare &21 '!'
		blo	LEABErts			;if less than return
LEABCeor10rts	eor.b	#$10,D0				;else finish conversion by toggling bit 4
LEABErts	rts				;exit
							;
							;ASCII codes &00 &20 no change
							;21-3F have bit 4 reverses (31-3F)
							;41-5E A-Z have bit 5 reversed a-z
							;5F & 60 are reversed
							;61-7E bit 5 reversed a-z becomes A-Z
							;DELETE unchanged
							;&80+ has bit 4 changed

;; ----------------------------------------------------------------------------
;; Implement CTRL codes
x_Implement_CTRL_codes					; LEABF
		cmp.b	#$7F,D0				;is it DEL
		beq	LEAD1rts			;if so ignore routine
		bhs	LEAACeor30				;if greater than &7F go to EAAC
		cmp.b	#$60,D0				;if A<>'`'
		bne	LEACB				;goto EACB
		moveq	#$5F,D0				;if A=&60, A=&5F

LEACB		cmp.b	#'@',D0				;if A<&40
		blo	LEAD1rts			;goto EAD1  and return unchanged
		and.b	#$1F,D0				;else zero bits 5 to 7
LEAD1rts	rts					;return


;; ----------------------------------------------------------------------------
;; OSBYTE 122  KEYBOARD SCAN FROM &10 (16);  
clc_then_mos_OSBYTE_122
		CLC					; clear carry to fall through without doing KEYV
mos_OSBYTE_122						; LF0CD
		move.w	SR,-(SP)
		moveq	#$10,D1				; lowest key to scan (Q)
		move.w	(SP)+,SR
;; OSBYTE 121  KEYBOARD SCAN FROM VALUE IN X
mos_OSBYTE_121
		bcs	jmpKEYV				;if carry set (by osbyte 121) F068
							;JMPs via KEYV and hence return from osbyte
							;however KEYV will return here... 

		movem.l	D3-D4/A0-A1,-(SP)


 *************************************************************************
 *        Scan Keyboard C=1, V=0 entry via KEYV (or from CLC above)      *
 *************************************************************************

KEYV_keyboard_scan					; LF0D1
		lea.l	zp_BASE,A1			; zero page pointer
		move.w	SR,-(SP)			;push flags
		tst.b	D1				;if X is +ve goto F0D9		
		bpl	LF0D9				;		
		bsr	keyb_check_key_code_API		;else interrogate keyboard
		move.w	(SP)+,SR			;push flags - will return -ve for key pressed
		bcs	keyb_hw_enable_scan2		;if carry set F12E to set Auto scan else : TODO68 - this was BCS check!

LF0D9		btst	#CC_C_B,1(SP)
		beq	LF0DE				;if carry clear goto FODE 
							;else (keep Y passed in to clc_then_mos_OSBYTE_122)
		move.b	#$EE,D2				;set Y so next operation saves to 2cd
LF0DE		andi.w	#$00FF,D2
tbloffs := mosvar_KEYB_TWOKEY_ROLLOVER - (zp_mos_keynumlast & $FF)	; $1DF
		lea	tbloffs,A0
		move.b	D1,(A0,D2.w)			;can be: 	2cb (mosvar_KEYB_TWOKEY_ROLLOVER)
							;	,	2cc (+1)
							;	or 	2cd (+2)
		moveq	#$09,D1				;set X to 9
LF0E3		bsr	keyb_enable_scan_IRQonoff	;select auto scan 
		move.b	#$7F,sheila_SYSVIA_ddra		;set port A for input on bit 7 others outputs		
		move.b	#$03,sheila_SYSVIA_orb		;stop auto scan
		move.b	#$0F,sheila_SYSVIA_ora_nh	;select non-existent keyboard column F (0-9 only!)									
		move.b	#$01,sheila_SYSVIA_ifr		;cancel keyboard interrupt
		move.b	D1,sheila_SYSVIA_ora_nh		;select column X (9 max)

		bsr	pause_VIA

		btst.b	#0,sheila_SYSVIA_ifr		;if bit 0 =0 there is no keyboard interrupt so
		beq	LF123				;goto F123
		move.b	D1,D0				;else put column address in A
LF103		;-- TODO68: Check sense of compare!
		cmp.b	(A0,D2.w),D0			;compare with 1DF+Y 
		blo	LF11E				;if less then F11E
		move.b	D0,sheila_SYSVIA_ora_nh		;else select column again 
		tst.b	sheila_SYSVIA_ora_nh		;and if bit 7 is 0
		bpl	LF11E				;then F11E
		; check for pushed carry
		btst.b	#CC_C_B,1(SP)
		bne	LF127				;and if carry set goto F127

		move.b	D0,D4				;else Push A
		move.b	(A1,D2.w),D3
		eor.b	D3,D4				;EOR with EC,ED, or EE depending on Y value
		asl.b	#1,D4				;shift left  
		cmp.b	#$01,D4				;clear? carry if = or greater than number holds EC,ED,EE			
		bcc	LF127				;if carry set F127

LF11E		add.b	#$10,D0				;add 16
		bpl	LF103				;and do it again if 0=<result<128

LF123		dbf	D1,LF0E3			;decrement X
							;scan again if greater than 0
		move.b	D1,D0				;
LF127		move.b	D0,D1				;
		move.w	(SP)+,CCR			;pull flags
		movem.l	(SP)+,D3-D4/A0-A1
keyb_enable_scan_IRQonoff				; LF129
		bsr	keyb_hw_enable_scan		;call autoscan		
		CLI					;allow interrupts 
		SEI					;disable interrupts		
keyb_hw_enable_scan
		move.w	SR,-(A7)
		move.b	#$0B,sheila_SYSVIA_orb
		rtr

keyb_hw_enable_scan2
		movem.l	(SP)+,D3-D4/A0-A1
		bra	keyb_hw_enable_scan


;; ----------------------------------------------------------------------------
;; CHECK FOR ALPHA CHARACTER; ENTRY  character in A ; exit with carry set if non-Alpha character 
mos_CHECK_FOR_ALPHA_CHARACTER			; LE4E3
		move.l	D0,-(SP)			;Save A
		andi.b	#$DF,D0				;convert lower to upper case
		cmp.b	#'Z',D0				;is it less than eq 'Z'
		bhi	LE4EE				;if so exit with carry clear
		cmp.b	#'A',D0				;is it 'A' or greater ??
		bhs	LE4EF				;if not exit routine with carry set
LE4EE		SEC					;else clear carry
LE4EF		movem.l  (SP)+,D0			;get back original value of A (68: preserve flags!)
		rts					;and Return


;; ----------------------------------------------------------------------------

*************************************************************************
 *                                                                       *
 *       KEY TRANSLATION TABLES                                          *
 *                                                                       *
 *       7 BLOCKS interspersed with unrelated code                       *
 *************************************************************************
                                         
 *key data block 1
key2ascii_tab					; LF03B
		dc.b	$71,$33,$34,$35,$84,$38,$87,$2D,$5E,$8C
		;	 q , 3 , 4 , 5 , f4, 8 , f7, - , ^ , <-

		dcb.b	6	; TODO - spare gap in key2ascii map

*key data block 2
 
LF04B		dc.b	$80,$77,$65,$74,$37,$69,$39,$30,$5F,$8E
		;	 f0, w , e , t , 7 , i , 9 , 0 , _ ,lft

		dcb.b	6	; TODO - spare gap in key2ascii map

 *key data block 3
 
LF05B		dc.b	$31,$32,$64,$72,$36,$75,$6F,$70,$5B,$8F
		;	 1 , 2 , d , r , 6 , u , o , p , [ , dn

		dcb.b	6	; TODO - spare gap in key2ascii map

*key data block 4
 
LF06B		dc.b	$01,$61,$78,$66,$79,$6A,$6B,$40,$3A,$0D
		;	 CL, a , x , f , y , j , k , @ , : ,RET		N.B CL=CAPS LOCK

*speech routine data
LF075		dc.b	$00,$FF,$01,$02,$09,$0A

*key data block 5

F07B	dc.b	$02,$73,$63,$67,$68,$6E,$6C,$3B,$5D,$7F
		;	 SL, s , c , g , h , n , l , ; , ] ,DEL		N.B. SL=SHIFT LOCK

		dcb.b	6	; TODO - spare gap in key2ascii map

 *key data block 6
 
F08B	dc.b	$00,$7A,$20,$76,$62,$6D,$2C,$2E,$2F,$8B
		;	TAB, Z ,SPC, v , b , m , , , . , / ,CPY

		dcb.b	6	; TODO - spare gap in key2ascii map

*key data block 7
F09B	dc.b	$1B,$81,$82,$83,$85,$86,$88,$89,$5C,$8D
		;	ESC, f1, f2, f3, f5, f6, f8, f9, \ , ->


mos_enter_keyboard_routines
		ori.b	#$0A, CCR				;set V and N
jmpKEYV		
		lea.l	-4(A7),A7				; reserve space on stack for vector contents
		move.w	SR,-(SP)				; preserve flags (move.l will reset C/V)
		move.l	(KEYV),2(SP)				; place vector contents above
		rtr						; jump to vector

*************************************************************************
 *                                                                       *
 *        OSBYTE &76 (118) SET LEDs to Keyboard Status                   *
 *                                                                       *
 *************************************************************************
                          ;osbyte entry with carry set
                         ;called from &CB0E, &CAE3, &DB8B

mos_OSBYTE_118					; LE9D9
		move.w	SR,-(SP)			;PUSH P
		SEI					;DISABLE INTERUPTS
		move.b	#$40,D0				;switch on CAPS and SHIFT lock lights
		bsr	x_keyb_leds_test_esc		;via subroutine
		bmi	LE9E7				;if ESCAPE exists (M set) E9E7
		andi	#~(CC_C_M|CC_V_M),CCR		;else clear V and C
							;before calling main keyboard routine to
		bsr	jmpKEYV				;switch on lights as required
LE9E7							;get back flags
		move.b	1(SP),D0			;and rotate carry into bit 0
		rtr					;Return to calling routine
;; ----------------------------------------------------------------------------
;; Turn on keyboard lights and Test Escape flag; called from &E1FE, &E9DD  ;  
x_keyb_leds_test_esc
		bcc	LE9F5
		move.b	#$07,sheila_SYSVIA_orb
		move.b	#$06,sheila_SYSVIA_orb
LE9F5		tst.b	zp_mos_ESC_flag
		rts
;

;; ----------------------------------------------------------------------------
;; get a byte from keyboard buffer and interpret as necessary; on entry A=cursor editing status 1=return &87-&8B,  ; 2= use cursor keys as soft keys 11-15 ; this area not reached if cursor editing is normal 
mos_interpret_keyb_byte					; LE515
		ror	#1,D0				;get bit 1 into carry
		bcc	mos_interpret_keyb_byte2
		move.b	(A7)+,D0			;get back A
		bra	x_exit_with_carry_clear		;if carry is set return
						;else cursor keys are 'soft'

mos_interpret_keyb_byte2
		clr.w	D2
		move.b	1(A7),D2			;leave A on stack
		lsr.b	#4,D2					;get high nybble into lo
		eor.b	#$04,D2				;and invert bit 2
;; 6809 ;; 							;&8 becomes &C
;; 6809 ;; 							;&9 becomes &D
;; 6809 ;; 							;&A becomes &E
;; 6809 ;; 							;&B becomes &F
;; 6809 ;; 							;&C becomes &8
;; 6809 ;; 							;&D becomes &9
;; 6809 ;; 							;&E becomes &A
;; 6809 ;; 							;&F becomes &B
		lea	sysvar_KEYB_C0CF_INSERT_INT-8,A0
	 	move.b	(A0,D2.w),D0			;read 026D to 0274 code interpretation status
;; 6809 ;; 							;0=ignore key, 1=expand as 'soft' key
;; 6809 ;; 							;2-&FF add this to base for ASCII code
;; 6809 ;; 							;note that provision is made for keypad operation
;; 6809 ;; 							;as codes &C0-&FF cannot be generated from keyboard
;; 6809 ;; 							;but are recognised by OS
;; 6809 ;; 							;
;; 6809 ;; 
 		cmp.b	#$01,D0				;is it 01
 		beq	x_expand_soft_key_strings	;if so expand as 'soft' key via E594
 		blo	x_get_byte_from_buffer68	;if above CMP generated Carry then code 0 must have
 							;been returned so E539 to ignore
 		move.b	(A7)+,D0			;else get back original byte
 		and	#$0F,D0				;else add ASCII to BASE key number so clear hi nybble
 		add.b	(A0,D2.w),D0			;add ASCII base
 		CLC					;clear carry
 		rts					;and exit

x_get_byte_from_buffer68
		move.b	(A7)+,D0
		bra	x_get_byte_from_buffer

;; ----------------------------------------------------------------------------
;; ERROR MADE IN USING EDIT FACILITY
x_ERROR_EDITING
		bsr	mos_VDU_7		;	E534
		move.w	(A7)+,D1

;; get byte from buffer
x_get_byte_from_buffer					; LE539
		bsr	mos_OSBYTE_145			;get byte from buffer X
		bcs	LE593rts			;if buffer empty E593 to exit

;; TODO68K: printer/rs423
;;		move.b	D0,-(A7)			;else Push byte
;;		cmp.b	#$01,D1				;and if RS423 input buffer is not the one
;;		bne	LE549				;then E549
;;		jsr	LE173				;else oswrch
;;		ldx	#$01				;X=1 (RS423 input buffer)
;; 		CLC					;clear (was set) carry
;;LE549							; LE549
;; 		move.b  (A7)+,D0			;get back original byte
;; ;; 6809 ;; 		bcs	LE551				;if carry clear (I.E not RS423 input) E551
;; ;; 6809 ;; 		LDY_B	sysvar_RS423_MODE		;else Y=RS423 mode (0 treat as keyboard )
;; ;; 6809 ;; 		bne	x_exit_with_carry_clear		;if not 0 ignore escapes etc. goto E592
;; ;; 6809 ;; LE551						; LE551

 		tst.b	D0				;test A (was tay)
 		bpl	x_exit_with_carry_clear		;if code is less than &80 its simple so E592
 		move.b	D0,-(A7)
 		andi.b	#$0F,D0				;else clear high nybble
 		cmpi.b	#$0B,D0				;if less than 11 then treat as special code
 		blo	mos_interpret_keyb_byte2	;or function key and goto E519 		
 		addi.b	#$7C,D0				;else add &7C (&7B +C) to convert codes B-F to 7-B
 		move.b	D0,1(A7)			;replace stacked A
		move.b	sysvar_KEY_CURSORSTAT,D0	;get cursor editing status
		bne	mos_interpret_keyb_byte		; if not 0 (normal) E515
		
		move.b	(A7)+,D0
		btst	#1,sysvar_OUTSTREAM_DEST
		bne	x_get_byte_from_buffer		; screen disabled
 		cmp.b	#$87,D0				;else is it COPY key
 		beq	x_deal_with_COPY_key		;if so E5A6
 							; LE575
 		move.w	D1,-(A7)
 		bsr	x_cursor_start			;execute edit action

 		move.w	(A7)+,D1
mos_check_eco_get_byte_from_kbd			; LE577
		;	TODO econet
		tst.b	sysvar_ECO_OSRDCH_INTERCEPT	;check econet RDCH flag
		bpl	x_get_byte_from_key_string	;if not set goto E581
		moveq	#$06,D0				;else Econet function 6 
		bra	callNETV

********* get byte from key string **************************************
;on entry 0268 contains key length
;and 02C9 key string pointer to next byte

x_get_byte_from_key_string
		tst.b	sysvar_KEYB_SOFTKEY_LENGTH	;get length of keystring
		beq	x_get_byte_from_buffer		;if 0 E539 get a character from the buffer
		clr.w	D0
		move.b	mosvar_SOFTKEY_PTR,D0		;get soft key expansion pointer
		lea	soft_keys_start+1,A0
		move.b	(A0,D0.w),D0			;get character from string
		addq.b	#1,mosvar_SOFTKEY_PTR		;increment pointer
		subq.b	#1,sysvar_KEYB_SOFTKEY_LENGTH	;decrement length
;; exit with carry clear
x_exit_with_carry_clear
		CLC					;	E592
LE593rts	
		rts					;	E593
;; ----------------------------------------------------------------------------
;; expand soft key strings
x_expand_soft_key_strings				; LE594
		move.b	(A7)+,D1			;restore original code
		andi.w	#$0F,D1				;blank hi nybble to get key string number
		lea	soft_keys_ptrs,A0
		move.b	(A0,D1.w),D0			;get start point
		move.b	D0,mosvar_SOFTKEY_PTR		;and store it
		bsr	x_get_keydef_length		;get string length in A
		move.b	D0,sysvar_KEYB_SOFTKEY_LENGTH	;and store it
		bra	mos_check_eco_get_byte_from_kbd	;if not 0 then get byte via E577 and exit

;; deal with COPY key
x_deal_with_COPY_key
		move.w	D1,-(A7)
		bsr	x_cursor_COPY				;	E5A8
		tst.b	D0
		beq	x_ERROR_EDITING				;	E5AC
		move.w	(A7)+,D1
		CLC						;	E5B1
		rts


; OSBYTE 129   Read key within time limit; X and Y contains either time limit in centi seconds Y=&7F max ; or Y=&FF and X=-ve INKEY value 
mos_OSBYTE_129					; LE713
		tst.b	D2				; check Y negative
		bmi	LE721				; if Y=&FF the E721
		CLI					; else allow interrupts
		bsr	OSBYTE_129_timed			; and go to timed routine
		bcs	LE71F_tay_c_rts			; if carry set then E71F
		move.b	D0,D1				; then X=A
		clr.b	D0				; A=0
LE71F_tay_c_rts	move.b	D0,D2				; Y=A
		rts					; and return
;; ----------------------------------------------------------------------------
LE721		tst.b	D1				; A=X
		beq	mos_OSBYTE_129_machtype
		eor.b	#$7F,D1				; convert to keyboard input
		SEC
		bsr	jmpKEYV				; then scan keyboard
		rol.b	#1,D0				; put bit 7 into carry
LE729		moveq	#-1,D1				; X=&FF
		bcs	LE731				; if bit 7 of A was set goto E731 (RTS)
		moveq   #0,D1				; else X=0
		move.l	D1,D2				; and Y=0
LE731		rts					; and exit
mos_OSBYTE_129_machtype
		move.b	#mos_MACHINE_TYPE_BYTE,D1
		moveq	#-1,D2
		rts


;; ----------------------------------------------------------------------------
;; OSBYTE 129 TIMED ROUTINE; ON ENTRY TIME IS IN X,Y 
OSBYTE_129_timed
			move.b	D0,oswksp_INKEY_CTDOWN		; store time in INKEY countdown timer
			move.b	D1,oswksp_INKEY_CTDOWN+1	; which is decremented every 10ms

			; store flag in top bit of D0
			move.b	#$FF, zp_mos_OS_wksp		; A=&FF
			bra	LDEC7				; goto DEC7
;; RDCHV entry point	  read a character
mos_RDCHV_default_entry
	 		clr.b	zp_mos_OS_wksp			; signal we entered through RDCHV not OSBYTE 129
LDEC7								
			movem.l	D1-D2/A0,-(SP)
		;TODO: EXEC
;; 6809 ;; 		pshs	B,X,Y				; store X and Y
;; 6809 ;; 		LDY_B	sysvar_EXEC_FILE		; get *EXEC file handle
;; 6809 ;; 		beq	LDEE6				; if 0 (not allocated) then DEE6
;; 6809 ;; 		SEC					; set carry
;; 6809 ;; 		ror	zp_mos_cfs_critical		; set bit 7 of CFS active flag to prevent  clashes
;; 6809 ;; 		jsr	OSBGET				; get a byte from the file
;; 6809 ;; 		pshs	CC				; push processor flags to preserve carry
;; 6809 ;; 		lsr	zp_mos_cfs_critical		; restore &EB 
;; 6809 ;; 		puls	CC				; get back flags
;; 6809 ;; 		bcc	mos_RDCHV_char_found		; and if carry clear, character found so exit via DF03
;; 6809 ;; 		lda	#$00				; else A=00 as EXEC file empty
;; 6809 ;; 		sta	sysvar_EXEC_FILE		; store it in exec fil;e handle
;; 6809 ;; 		jsr	OSFIND				; and close file via OSFIND
;; 6809 ;; 


LDEE6			tst.b	zp_mos_ESC_flag			; check ESCAPE flag if bit 7 set Escape pressed
 			bmi	mos_RDCHV_return_SEC_ESC	; so off to DF00
			move.b	sysvar_CURINSTREAM,D1		; else get current input buffer number
	 		bsr	mos_check_eco_get_byte_from_kbd	; get a byte from keyboard buffer
	 		bcc	mos_RDCHV_char_found		; and exit if valid character found
	 		tst.b	zp_mos_OS_wksp			; check flags
	 
	 		bpl	LDEE6				; if entered through RDCHV keep trying
	 		tst.w	oswksp_INKEY_CTDOWN		; else check if countdown has expired
	 		bne	LDEE6				; if it hasn't carry on
	 		bra	mos_RDCHV_return_SEC		; else restore A and exit
mos_RDCHV_return_SEC_ESC					; LDF00
 			move.b	#$1B,D0				; return ESCAPE 			
mos_RDCHV_return_SEC 			
 			SEC					; set carry
mos_RDCHV_char_found	movem.l	(SP)+,D1-D2/A0
			rts				;	LDF03
 			


;; ----------------------------------------------------------------------------
;; : set string lengths
; on entry: 	B is key number (16 bit!)
; on exit:	A, zp_mos_OS_wksp2+1 - length of current keydef
x_get_keydef_length
		move.w	D1,-(A7)
		lea	soft_keys_start,A0
		SEI					;bar interrupts
		move.b	(A0,D1.w),D0			; get start of string
		move.b	D0,-(A7)			; push start pointer
		move.b	(soft_keys_end_ptr),D1		; get max pointer
		sub.b	1(A7),D1			; subtract start from that
		move.b 	D1, zp_mos_OS_wksp2+1		; max length
		move.w	#$10,D1
.lp1		move.b	(A0,D1.w),D0			; get ptr B
		sub.b	1(A7),D0			; is this pointer after "current"
		bls	.sk2
		cmp.b	zp_mos_OS_wksp2+1,D0		; is this shorter?
		bhs	.sk2				; no
		move.b	D0,zp_mos_OS_wksp2+1		; yes
.sk2		dbf	D1,.lp1
		lea	2(A7),A7			; discard temp val
		move.b	zp_mos_OS_wksp2+1,D0		;get back latest value of A     
		move.w	(A7)+,D1			;pull flags, restore X and return						
		rts					;and return


;; ----------------------------------------------------------------------------
x_cursor_start					; LD8CE
		move.b	D0,-(A7)			; Push A
		tst.b	sysvar_VDU_Q_LEN		; X=number of items in VDU queque
		bne	LD916pulsArts			; if not 0 D916
		move.b	#$A0,D0				; A=&A0
		and.b	zp_vdu_status,D0			; else check VDU status byte
		bne	LD916pulsArts			; if either VDU is disabled or plot to graphics
						; cursor enabled then D916
		btst.b	#6,(zp_vdu_status)
		bne	.sk1				; if cursor editing enabled D8F5
		move.b	vduvar_CUR_START_PREV,D0	; else get 6845 register start setting
		andi.b	#$9F,D0				; clear bits 5 and 6
		ori.b	#$40,D0				; set bit 6 to modify last cursor size setting
		bsr	x_crtc_set_cursor		; change write cursor format
		move.w	(vduvar_TXT_CUR_X),(vduvar_TEXT_IN_CUR_X)
							; set text input cursor from text output cursor
		bsr	x_setup_read_cursor		; modify character at cursor poistion
		bset.b	#1,(zp_vdu_status)		; bit 1 of VDU status is set to bar scrolling
.sk1		bclr.b	#6,(zp_vdu_status)		;bit 6 of VDU status =0 
		move.b	(A7)+,D0			;Pull A
		bclr	#7,D0				;clear hi bit (7)
		; TODO: I suspect this will trash registers - check!
		bsr	mos_VDU_WRCH			; exec up down left or right?
		ori.b	#$40,(zp_vdu_status)		; set vdu status
		rts					;exit 
;; ----------------------------------------------------------------------------
x_cursor_COPY					; LD905
;;	lda	#$20				;A=&20
;;	bita	zp_vdu_status			
;;	bvc	LD8CBclrArts			;if bit 6 cursor editing is set
;;	bne	LD8CBclrArts			;or bit 5 is set exit &D8CB
		move.b	zp_vdu_status,D0
		btst	#6,D0
		beq	LD8CBclrArts			; not cursor editing
		btst	#5,D0
		bne	LD8CBclrArts			; VDU5
		movem	D1/D2,-(A7)
		move.b	#135, D0
		SWI	OS_Byte				;read a character from the screen - note changed this to use
		move	D1,D0				;OSBYTE instead of direct jump to allow 135 to be intercepted
							;in VNULA utils ROM
		movem	(A7)+,D1/D2
		
		beq	LD917rts			;if A=0 on return exit via D917
							;else store A
		move.b	D0,-(A7)
		bsr	mos_VDU_9			;perform cursor right
LD916pulsArts	
		move.b	(A7)+,D0			;	D916
LD917rts	
		rts					;	D917

LD8CBclrArts	clr.b	D0
		rts

;; ----------------------------------------------------------------------------


x_cancel_cursor_edit					; LD918
		andi.b	#$BD,(zp_vdu_status)		;	D918		
		bsr	x_crtc_reset_cursor		;	D91D
		move.b	#$0D,D0				;	D920
		rts					;	D922
