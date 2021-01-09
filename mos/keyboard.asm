

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

		SECTION "code"


;; Keyboard Input and housekeeping; entered from &F00C 
keyb_input_and_housekeeping			; LEEDA
		movem.l	(SP)+,D3-D4/A0
		moveq	#-1,D1				;
		move.b	zp_mos_keynumlast,D0		;get value of most recently pressed key
		or.b	zp_mos_keynumfirst,D1		;Or it with previous key to check for presses
		bne	LEEE8				;if A=0 no keys pressed so off you go
		move.b	#$81, sheila_SYSVIA_ier		;else enable keybd interupt only by writing bit 7
							;and bit 0 of system VIA interupt register 
		addq.b	#1,D1				;set X=0
LEEE8		move.b	D1,sysvar_KEYB_SEMAPHORE	;reset keyboard semaphore

; : Turn on Keyboard indicators
; no longer mucks about with flags in D0(A)! instead just preserves them
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
		move.b	sheila_SYSVIA_ora_nh,D1		;read back &80 if key pressed (M set)
		bpl	.sk
		ori.b	#$08,1(A7)
.sk		rtr					;and return



keyb_hw_enable_scan2
		movem.l	(SP)+,D3-D4/A0
keyb_hw_enable_scan
		move.b	#$0B,sheila_SYSVIA_orb
		rts

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
		bra	LEFE9				;if different from previous (Z clear) then EF4D
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
		btst	#KEYST_B_6_CTRL,D3		;CTRL pressed into Z
		beq	LEFA9				;if CTRL NOT pressed EFA9
		move.b	zp_mos_keynumfirst,D1		;get no. of previously pressed key
LEFA4		bne	LEF4A				;if not 0 goto EF4A to reset repeat system etc.
		bsr	x_Implement_CTRL_codes		;else perform code changes for CTRL

LEFA9		btst	#KEYST_B_5_SHLN,D3		;move shift lock into Z
LEFAB		bne	LEFB5				;if not effective goto EFB5 else
		bsr	x_Modify_code_as_if_SHIFT	;make code changes for SHIFT

		btst	#KEYST_M_4_CALK,D3		;move CAPS LOCK into bit 7
		bra	LEFC1				;and Jump to EFC1

LEFB5		btst	#KEYST_M_4_CALK,D3		;move CAPS LOCK into bit 7
		bne	LEFC6				;if not effective goto EFC6
		bsr	mos_CHECK_FOR_ALPHA_CHARACTER	;else make changes for CAPS LOCK on, return with 
							;C clear for Alphabetic codes
		bcs	LEFC6				;if carry set goto EFC6 else make changes for
		bsr	x_Modify_code_as_if_SHIFT	;SHIFT as above

LEFC1		btst	#KEYST_B_7_SHEN,D3		;if shift enabled bit is clear
		bne	LEFD1				;goto EFD1
LEFC6		btst	#KEYST_M_3_SHIFT,D3		;else get shift bit into z
		beq	LEFD1				;if not set goto EFD1
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
		clr.b	D1				; DB ??? not sure what is what here on BeebEm always seems to be X=0 here!
		bsr	keyb_check_key_code_API		;check if key pressed
LF012		tst.b	zp_mos_keynumlast		;get previous key press
		bne	LF00C				;if none back to housekeeping routine
		;TODO: should this be pointer to zp or value from zp?
		move.b	#zp_mos_keynumfirst & $FF,D2	;get last keypress into Y
		bsr	clc_then_mos_OSBYTE_122		;and scan keyboard
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

		movem.l	D3-D4/A0,-(SP)


 *************************************************************************
 *        Scan Keyboard C=1, V=0 entry via KEYV (or from CLC above)      *
 *************************************************************************

KEYV_keyboard_scan
		move.w	SR,-(SP)			;push flags
		tst.b	D1				;if X is +ve goto F0D9		
		bpl	LF0D9				;		
		bsr	keyb_check_key_code_API		;else interrogate keyboard
		move.w	(SP)+,SR
		bra	keyb_hw_enable_scan2		;if carry set F12E to set Auto scan else : TODO68 - this was BCS check!

LF0D9		btst	#CC_C_B,1(SP)
		beq	LF0DE				;if carry clear goto FODE 
							;else (keep Y passed in to clc_then_mos_OSBYTE_122)
		move.b	#$EE,D2				;set Y so next operation saves to 2cd
LF0DE		andi.w	#$00FF,D2
tbloffs := mosvar_KEYB_TWOKEY_ROLLOVER - (zp_mos_keynumlast & $FF)
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
		move.b	(A0,D2.w),D3
		eor.b	D3,D4				;EOR with EC,ED, or EE depending on Y value
		asl.b	#1,D4				;shift left  
		cmp.b	#$01,D4				;clear? carry if = or greater than number holds EC,ED,EE			
		bcc	LF127				;if carry set F127
LF11E		add.b	#$10,D0				;add 16
		bpl	LF103				;and do it again if 0=<result<128

LF123		subq	#1,D1				;decrement X
		bpl	LF0E3				;scan again if greater than 0
		move.b	D1,D0				;
LF127		move.b	D0,D1				;
		move.w	(SP)+,CCR			;pull flags
		movem.l	(SP)+,D3-D4/A0
keyb_enable_scan_IRQonoff				; LF129
		bsr	keyb_hw_enable_scan		;call autoscan		
		; -TODO68: Should we be doing this?
		andi	#$FCFF,SR			;allow interrupts 
		ori	#$0700,SR			;disable interrupts
		rts
		
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
;; : INSERT byte in Keyboard buffer
x_INSERT_byte_in_Keyboard_buffer			; LE4F1		
		;STY_B	zp_mos_OSBW_Y
		;clr	zp_mos_OSBW_X
		clr.b	D1
		rts

;; 6809 ;;  *************************************************************************
;; 6809 ;;  *                                                                       *
;; 6809 ;;  *       OSBYTE 153 Put byte in input Buffer checking for ESCAPE         *
;; 6809 ;;  *                                                                       *
;; 6809 ;;  *************************************************************************
;; 6809 ;;  ;on entry X = buffer number (either 0 or 1)
;; 6809 ;;  ;X=1 is RS423 input
;; 6809 ;;  ;X=0 is Keyboard
;; 6809 ;;  ;Y is character to be written 
;; 6809 ;; mos_OSBYTE_153
;; 6809 ;; 		ldd	zp_mos_OSBW_Y			; A=Y, B=X (on entry to OSBYTE)
;; 6809 ;; 							;A=buffer number
;; 6809 ;; 		andb	sysvar_RS423_MODE		;and with RS423 mode (0 treat as keyboard 
;; 6809 ;; 							;1 ignore Escapes no events no soft keys)
;; 6809 ;; 		bne	mos_OSBYTE_138			;so if RS423 buffer AND RS423 in normal mode (1) E4AF
;; 6809 ;; 							;else Y=A character to write
;; 6809 ;; 		ldx	#0				;force keyboard buffer -- TODO: is this right?
;; 6809 ;; 		cmpa	sysvar_KEYB_ESC_CHAR		;compare with current escape ASCII code (0=match)
;; 6809 ;; 		bne	x_check_event_2_char_into_buf_fromA	;if ASCII or no match E4A8 to enter byte in buffer
;; 6809 ;; 		tst	sysvar_KEYB_ESC_ACTION		;or with current ESCAPE status (0=ESC, 1=ASCII)
;; 6809 ;; 		bne	x_check_event_2_char_into_buf_fromA	;if ASCII or no match E4A8 to enter byte in buffer
;; 6809 ;; 		lda	sysvar_BREAK_EFFECT		;else get ESCAPE/BREAK action byte
;; 6809 ;; 		rora					;Rotate to get ESCAPE bit into carry
;; 6809 ;; 		lda	zp_mos_OSBW_Y			;get character back in A
;; 6809 ;; 		bcs	LE513				;and if escape disabled exit with carry clear
;; 6809 ;; 		ldy	#$06				;else signal EVENT 6 Escape pressed
;; 6809 ;; 		jsr	x_CAUSE_AN_EVENT		;
;; 6809 ;; 		bcc	LE513				;if event handles ESCAPE then exit with carry clear
;; 6809 ;; 		jsr	mos_OSBYTE_125			;else set ESCAPE flag
;; 6809 ;; LE513		CLC					;clear carry 
;; 6809 ;; 		rts					;and exit
;; 6809 ;; ;; ----------------------------------------------------------------------------
;; 6809 ;; ;; get a byte from keyboard buffer and interpret as necessary; on entry A=cursor editing status 1=return &87-&8B,  ; 2= use cursor keys as soft keys 11-15 ; this area not reached if cursor editing is normal 
;; 6809 ;; mos_interpret_keyb_byte					; LE515
;; 6809 ;; 		rora					;get bit 1 into carry
;; 6809 ;; 		bcc	mos_interpret_keyb_byte2
;; 6809 ;; 		puls	A				;get back A
;; 6809 ;; 		lbra	x_exit_with_carry_clear		;if carry is set return
;; 6809 ;; 						;else cursor keys are 'soft'
;; 6809 ;; 
;; 6809 ;; mos_interpret_keyb_byte2
;; 6809 ;; 		lda	,S				;leave A on stack
;; 6809 ;; 		lsra					;get high nybble into lo
;; 6809 ;; 		lsra					;
;; 6809 ;; 		lsra					;
;; 6809 ;; 		lsra					;A=8-&F
;; 6809 ;; 		eora	#$04				;and invert bit 2
;; 6809 ;; 							;&8 becomes &C
;; 6809 ;; 							;&9 becomes &D
;; 6809 ;; 							;&A becomes &E
;; 6809 ;; 							;&B becomes &F
;; 6809 ;; 							;&C becomes &8
;; 6809 ;; 							;&D becomes &9
;; 6809 ;; 							;&E becomes &A
;; 6809 ;; 							;&F becomes &B
;; 6809 ;; 		m_tay					;Y=A = 8-F
;; 6809 ;; 		lda	sysvar_KEYB_C0CF_INSERT_INT-8,y	;read 026D to 0274 code interpretation status
;; 6809 ;; 							;0=ignore key, 1=expand as 'soft' key
;; 6809 ;; 							;2-&FF add this to base for ASCII code
;; 6809 ;; 							;note that provision is made for keypad operation
;; 6809 ;; 							;as codes &C0-&FF cannot be generated from keyboard
;; 6809 ;; 							;but are recognised by OS
;; 6809 ;; 							;
;; 6809 ;; 
;; 6809 ;; 		cmpa	#$01				;is it 01
;; 6809 ;; 		lbeq	x_expand_soft_key_strings	;if so expand as 'soft' key via E594
;; 6809 ;; 		puls	A				;else get back original byte
;; 6809 ;; 		blo	x_get_byte_from_buffer		;then code 0 must have
;; 6809 ;; 							;been returned so E539 to ignore
;; 6809 ;; 		anda	#$0F				;else add ASCII to BASE key number so clear hi nybble
;; 6809 ;; 		adda	sysvar_KEYB_C0CF_INSERT_INT-8,y	;add ASCII base
;; 6809 ;; 		CLC					;clear carry
;; 6809 ;; 		rts					;and exit


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


