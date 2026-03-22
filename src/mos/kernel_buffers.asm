		include "mos.inc"
		include "oslib.inc"
		include "hardware.inc"
		include "kernel_defs.inc"
		include "deice.inc"
		include "macros.inc"

		xdef 	x_INSERT_byte_in_Keyboard_buffer
		xdef	mos_INSV_default_entry_point
		xdef	mos_REMV_default_entry_point
		xdef	mos_CNPV_default_entry_point
		xdef	mos_flush_all_buffers
		
		xdef	mos_OSBYTE_138
		xdef	mos_OSBYTE_145
		xdef	mos_OSBYTE_153

		SECTION	"code"


;TODO68 - refactor how the buffer pointers are done, the 6502 moving towards 0 is
;		fast but we're doing a lot of gymnastics here to make it work
;		consider something simpler i.e. buffer length table, buffer starts
;		?may leave enough room for word pointers?


;; ----------------------------------------------------------------------------
;; : INSERT byte in Keyboard buffer
x_INSERT_byte_in_Keyboard_buffer			; LE4F1		
		;STY_B	zp_mos_OSBW_Y
		;clr	zp_mos_OSBW_X
		clr.b	D1

 *************************************************************************
 *                                                                       *
 *       OSBYTE 153 Put byte in input Buffer checking for ESCAPE         *
 *                                                                       *
 *************************************************************************
;;6809 ;; ;on entry X = buffer number (either 0 or 1)
;;6809 ;; ;X=1 is RS423 input
;;6809 ;; ;X=0 is Keyboard
;;6809 ;; ;Y is character to be written 
; 68k ; on entry 	D1 is buffer number (0, 1, others ignored)
; 68k ;				0 = keyboard
; 68k ;				1 = RS423
; 68k ;           	D2 	Character to write
mos_OSBYTE_153
		cmp.b	#1,D1
		bhi	LE513

		and.b	sysvar_RS423_MODE,D1		;and with RS423 mode (0 treat as keyboard 
							;1 ignore Escapes no events no soft keys)
		bne	mos_OSBYTE_138			;so if RS423 buffer AND RS423 in normal mode (1) E4AF
							;else Y=A character to write			
		cmp.b	sysvar_KEYB_ESC_CHAR,D2		;compare with current escape ASCII code (0=match)
		bne	x_check_event_2_char_into_buf_fromA	;if ASCII or no match E4A8 to enter byte in buffer
		tst.b	sysvar_KEYB_ESC_ACTION		;or with current ESCAPE status (0=ESC, 1=ASCII)
		bne	x_check_event_2_char_into_buf_fromA	;if ASCII or no match E4A8 to enter byte in buffer
				
							
		move.b	D2, D0				;get character back in A
		btst	#0, sysvar_BREAK_EFFECT		;else get ESCAPE/BREAK action byte
		bne	LE513				;and if escape disabled exit with carry clear
		moveq	#$06,D2				;else signal EVENT 6 Escape pressed
		bsr	x_CAUSE_AN_EVENT		;
		bcc	LE513				;if event handles ESCAPE then exit with carry clear
		bsr	mos_OSBYTE_125			;else set ESCAPE flag
LE513		CLC					;clear carry 
		rts					;and exit


BUFFER_PTR_ADDR		MACRO ; 1=START, 2=END
			dc.w (\2+1)-$100
			ENDM

BUFFER_ACC_OFF		MACRO ; 1=START, 2=END
			dc.b (\1-(\2+1)-$100) & $FF	; i.e. $100 - len!
			ENDM


*************************************************************************
*                                                                       *
*       OSBYTE 138 Put byte into Buffer                                 *
*                                                                       *
*************************************************************************
;; 6809 ;; on entry X is buffer number, Y is character to be written 
; D1 = buffer no, D2 = char to write
mos_OSBYTE_138						; LE4AF
		move.b	D2,D0
jmpINSV		move.l	(INSV),-(SP)
		rts

get_buffer_ptr
		and.w	#$00FF,D1
		add.w	D1,D1				; b = 2 * buffer #
		lea	mostbl_BUFFER_ADDRESS_PTR_LUT(PC),A0
		move.w	(A0,D1.w),A0			; get buffer start pointer
		rts



;;;mostbl_BUFFER_ADDRESS_LO_LOOK_UP_TABLE
;;;mostbl_BUFFER_ADDRESS_HI_LOOK_UP_TABLE
mostbl_BUFFER_ADDRESS_PTR_LUT
		BUFFER_PTR_ADDR		BUFFER_KEYB_START	,BUFFER_KEYB_END
		BUFFER_PTR_ADDR		BUFFER_SERI_START	,BUFFER_SERI_END
		BUFFER_PTR_ADDR		BUFFER_SERO_START	,BUFFER_SERO_END
		BUFFER_PTR_ADDR		BUFFER_LPT_START	,BUFFER_LPT_END
		BUFFER_PTR_ADDR		BUFFER_SND0_START	,BUFFER_SND0_END
		BUFFER_PTR_ADDR		BUFFER_SND1_START	,BUFFER_SND1_END
		BUFFER_PTR_ADDR		BUFFER_SND2_START	,BUFFER_SND2_END
		BUFFER_PTR_ADDR		BUFFER_SND3_START	,BUFFER_SND3_END
		BUFFER_PTR_ADDR		BUFFER_SPCH_START	,BUFFER_SPCH_END

;;;mostbl_BUFFER_START_ADDRESS_OFFSET
mostbl_BUFFER_ADDRESS_OFFS
		BUFFER_ACC_OFF		BUFFER_KEYB_START	,BUFFER_KEYB_END
		BUFFER_ACC_OFF		BUFFER_SERI_START	,BUFFER_SERI_END
		BUFFER_ACC_OFF		BUFFER_SERO_START	,BUFFER_SERO_END
		BUFFER_ACC_OFF		BUFFER_LPT_START	,BUFFER_LPT_END
		BUFFER_ACC_OFF		BUFFER_SND0_START	,BUFFER_SND0_END
		BUFFER_ACC_OFF		BUFFER_SND1_START	,BUFFER_SND1_END
		BUFFER_ACC_OFF		BUFFER_SND2_START	,BUFFER_SND2_END
		BUFFER_ACC_OFF		BUFFER_SND3_START	,BUFFER_SND3_END
		BUFFER_ACC_OFF		BUFFER_SPCH_START	,BUFFER_SPCH_END


		align 1



*************************************************************************
*                                                                       *
*       INSV insert character in buffer vector default entry point     *
*                                                                       *
*************************************************************************
;6809;on entry X is buffer number, A is character to be written 
;on entry D1 is buffer number, D0 is character to be written 
mos_INSV_default_entry_point					; LE4B3
		CLC					; clear carry for default exit
		move	SR,-(SP)
		movem.l	D2-D3/A0-A2,-(SP)
		andi.w	#$00FF,D1
		SEI					; disable interrupts
		lea	mosbuf_buf_start,A0
		lea	mosbuf_buf_end,A1
		move.b	(A1,D1.w),D2			; get current buffer pointer
		andi.w	#$00FF,D2			; make it a 16 bit offset
		move.w	D2,D3				; stack B for later
		addq.b	#1,D2				; incremenet
		bne	.1F				; if 0 wrap around

		lea	mostbl_BUFFER_ADDRESS_OFFS(PC),A2
		move.b	(A2,D1.w),D2			; wrap around by finding start offs

.1F		cmp.b	(A0,D1.w),D2			; compare to extract pointer
		beq	insv_buf_full			; buffer is full, cause an event and exit
		move.b	D2,(A1,D1.w)			; save updated pointer
		bsr	get_buffer_ptr
		move.b	D0,(A0,D3.w)			; store the byte in the buffer (at the old location!)
		movem.l	(SP)+,D2-D3/A0-A2		; exit with carry clear
		rte

insv_buf_full	cmp.b	#2,D1				; if it's an input buffer raise an event
		bhs	insv_SEC_ret			; its 2 or greater skip
		moveq	#1,D2
		bsr	x_CAUSE_AN_EVENT		; raise the input buffer full event

insv_SEC_ret	movem.l	(SP)+,D2-D3/A0-A2
		ori.b	#CC_C_M,1(SP)			; set carry flag in CC on stack
		rte


; ----------------------------------------------------------------------------
;; check event 2 character entering buffer
x_check_event_2_char_into_buf_fromA				; LE4A8
		moveq	#2,D2
		bsr	x_CAUSE_AN_EVENT
		bra	jmpINSV


;; set input buffer number and flush it
x_set_input_buffer_number_and_flush_it
		move.b	sysvar_CURINSTREAM,D1		;	F095
LF098		bra	x_Buffer_handling		;	F098
;; ----------------------------------------------------------------------------
;	FCB	$1B				;	F09B
;	sta	(zp_lang+130,x)			;	F09C
;	FCB	$83				;	F09E
;	sta	zp_lang+134			;	F09F
;	dey					;	F0A1
;	FCB	$89				;	F0A2
;	FCB	$5C				;	F0A3
;	FCB	$8D				;	F0A4
;; jsr from code!;LF0A5:	jmp	(EVNTV)				;	F0A5

*************************************************************************
*                                                                       *
*       OSBYTE 15  FLUSH SELECTED BUFFER CLASS                          *
*                                                                       *
*                                                                       *
*************************************************************************

                        ;flush selected buffer
                        ;X=0 flush all buffers
                        ;X>1 flush input buffer


mos_OSBYTE_15						; LF0A8
		bne	x_set_input_buffer_number_and_flush_it;if X<>1 flush input buffer only
mos_flush_all_buffers					; LF0AA
		moveq	#$08,D1				;else load highest buffer number (8)
.l1		CLI					;allow interrupts 
		SEI					;briefly!
		bsr	mos_OSBYTE_21			;flush buffer
		dbra	D1,.l1				;decrement X to point at next buffer
;; OSBYTE 21  FLUSH SPECIFIC BUFFER; on entry X=buffer number 
mos_OSBYTE_21
		cmp.b	#$09,D1				;	F0B4
		blo	LF098				;	F0B6
		rts					;	F0B8




 *************** Buffer handling *****************************************
		;X=buffer number
		;Buffer number	Address		Flag	Out pointer	In pointer
		;0=Keyboard	3E0-3FF		2CF	2D8		2E1
		;1=RS423 Input	A00-AFF		2D0	2D9		2E2
		;2=RS423 output	900-9BF		2D1	2DA		2E3
		;3=printer	880-8BF		2D2	2DB		2E4
		;4=sound0	840-84F		2D3	2DC		2E5
		;5=sound1	850-85F		2D4	2DD		2E6
		;6=sound2	860-86F		2D5	2DE		2E7
		;7=sound3	870-87F		2D6	2DF		2E8
		;8=speech	8C0-8FF		2D7	2E0		2E9

x_Buffer_handling					; LE1AD
		CLC					;clear carry
x_Buffer_handling2					; LE1AE
		move	SR,-(SP)			;save A, flags
		move.l	D0,-(SP)			; PRESERVE FLAGS!
		SEI					;set interrupts
		bcs	LE1BB				;if carry set on entry then E1BB
;6809;		lda	mostbl_SERIAL_BAUD_LOOK_UP,x	;else get byte from baud rate/sound data table
;6809;		bpl	LE1BB				;if +ve the E1BB
		move.w	#$00F0,D0			; decide which buffers are sound!
		btst	D1,D0
		beq	LE1BB

		bsr	snd_clear_chan_API		;else clear sound data

LE1BB		

;;6809;;		SEC					;set carry
;;6809;;		ror	mosbuf_buf_busy,x		;rotate buffer flag to show buffer empty
		; TODO change mosbuf_buf_busy to a bitmask?
		andi.w	#$00FF,D1
		lea	mosbuf_buf_busy,A0
		st.b	(A0,D1.w)

		cmp.b	#$02,D1				;if X>1 then its not an input buffer
		bhs	LE1CB				;so E1CB

		clr.b	D0				;else Input buffer so A=0
		move.b	D0,sysvar_KEYB_SOFTKEY_LENGTH	;store as length of key string
		move.b	D0,sysvar_VDU_Q_LEN		;and length of VDU queque
LE1CB		bsr	x_mos_SEV_and_CNPV				;then enter via count purge vector any 
							;user routines
		move.l	(SP)+,D0			;restore flags, A and exit
		rtr

 *************************************************************************
 *                                                                       *
 *       COUNT PURGE VECTOR      DEFAULT ENTRY                           *
 *                                                                       *
 *                                                                       *
 *************************************************************************
 ;on entry if V set clear buffer
 ;         if C set get space left
 ;         else get bytes used 
mos_CNPV_default_entry_point				; LE1D1
		move.w	SR,-(SP)
		movem.l	A0-A2,-(SP)
		andi.w	#$00FF,D1
		lea	mosbuf_buf_start,A0
		lea	mosbuf_buf_end,A1
		SEI
		btst	#CC_V_B,13(SP)
		beq	LE1DA				;if bit 6 is set then E1DA
		move.b	(A0,D1.w),(A1,D1.w)		;else start of buffer=end of buffer
		movem.l	(SP)+,A0-A2
		rte					;and exit
;; ----------------------------------------------------------------------------
LE1DA		lea	mostbl_BUFFER_ADDRESS_OFFS,A2
		move.b	(A1,D1.w),D0			;get end of buffer
		sub.b	(A0,D1.w),D0			;subtract start of buffer
		bcc	LE1EA				;if carry caused E1EA
		sub.b	(A2,D1.w),D0			;subtract buffer start offset (i.e. add buffer length)
LE1EA		
		btst	#CC_C_B,13(SP)
		beq	LE1F3				;if carry clear E1F3 to exit
		add.b	(A2,D1.w),D0			;add to get bytes used
		eor.b	#$FF,D0				;and invert to get space left
LE1F3
		move.b	D0,D1				;X=A
		movem.l	(SP)+,A0-A2
		rte

;; ----------------------------------------------------------------------------
;; enter byte in buffer, wait and flash lights if full
x_INSV_flashiffull
		SEI					; prevent interrupts
		bsr	jmpINSV				; enter a byte in buffer X
		bcc	LE20D				; if successful exit
		bsr	x_keyb_leds_test_esc		; else switch on both keyboard lights
		jsr	x_Turn_on_Keyboard_indicators_API68	; switch off unselected LEDs
		bmi	LE20D				; if return is -ve Escape pressed so exit
		CLI					; else allow interrupts
		bra	x_INSV_flashiffull		; if byte didn't enter buffer go and try it again
LE20D		rts					; then return

*************************************************************************
*                                                                       *
*       OSBYTE 152 Examine Buffer status                                *
*                                                                       *
*************************************************************************
;on entry X = buffer number
;on exit Y next character or preserved if buffer empty
;if buffer is empty C=1, Y is preserved else C=0
mos_OSBYTE_152					; LE45B
		SEV
		bra	jmpREMV				;	E45E
*************************************************************************
*                                                                       *
*       OSBYTE 145 Get byte from Buffer                                 *
*                                                                       *
*************************************************************************
;on entry X = buffer number
; ON EXIT Y is character extracted 
;if buffer is empty C=1, else C=0
mos_OSBYTE_145
		CLV
jmpREMV
		lea.l	-4(A7),A7				; reserve space on stack for vector contents
		move.w	SR,-(SP)				; preserve flags (move.l will reset C/V)
		move.l	(REMV),2(SP)				; place vector contents above
		rtr						; jump to vector
*************************************************************************
*                                                                       *
*       REMV buffer remove vector default entry point                   *
*                                                                       *
*************************************************************************
;on entry X = buffer number
;on exit if buffer is empty C=1, Y is preserved 
;else C=0, Y = char (and A)

mos_REMV_default_entry_point					; LE464
		CLC						;clear carry (assume success)
		move.w	SR,-(SP)
		movem.l	A0-A2,-(SP)				;push flags and A regs
		exg	D0,D2
		lea	mosbuf_buf_start,A2
		lea	mosbuf_buf_end,A1
		SEI						;bar interrupts
		andi.w	#$00FF,D1
		clr.w	D2
		move.b	(A2,D1.w),D2				;get output pointer for buffer X
		cmp.b	(A1,D1.w),D2				;compare to input pointer
		beq	remv_SEC_ret				;if equal buffer is empty so E4E0 to exit
		bsr	get_buffer_ptr				;find buffer start pointer	
		move.b	(A0,D2.w),D0				;get char from buffer
		btst	#CC_V_B,13(SP)
		beq	.1F					;V not set branch
		exg	D0,D2					;stick char found Y
		movem.l	(SP)+,A0-A2				;return with C=0, this is the osbyte 152 return
.1F		addq.b	#1,D2					;increment start pointer
		bne	.2F					;if it is 0
		
		lea	mostbl_BUFFER_ADDRESS_OFFS,A0
		move.b	(A0,D1.w),D2				;wrap around by finding start offs

.2F		move.b	D2,(A2,D1.w)				;store updated pointer
		cmp.b	(A2,D1.w),D2				;check if buffer empty
		bne	.3F					;if not the same buffer is not empty so exit
		cmp.b	#2,D1					;if buffer is input (0 or 1)
		blo	.3F					;then E48F

		clr.b	D2					;buffer is empty so Y=0
		bsr	x_CAUSE_AN_EVENT			;and enter EVENT routine to signal EVENT 0 buffer
								;becoming empty
.3F		move.b	D0,D2					;return char in Y and A
		movem.l	(SP)+,A0-A2				;return with carry clear
		rte

remv_SEC_ret
		exg	D0,D2					; TODO68 - check this!
		movem.l	(SP)+,A0-A2
		ori.b	#CC_C_M,1(SP)				; set carry flag in CC on stack
		rte

;; ----------------------------------------------------------------------------
;; check occupancy of input or free space of output buffer; X=buffer number ; Buffer number  Address	    Flag    Out pointer	    In pointer ; 0=Keyboard	3E0-3FF		2CF	2D8		2E1 ; 1=RS423 Input  A00-AFF	     2D0     2D9	 
;x_check_buffer_space:
;	txa					;	E732
;	eor	#$FF				;	E733
;	tax					;	E735
;	cpx	#$02				;	E736
LE738		CLV				;	E738
		bra	x_mos_CNPV			;	E739
x_mos_SEV_and_CNPV					; LE73B
		ori.w	#CC_V_M+CC_C_M+CC_N_M,SR
x_mos_CNPV						; LE73E
		lea.l	-4(SP),A7				; reserve space on stack for vector contents
		move.w	SR,-(SP)				; preserve flags (move.l will reset C/V)
		move.l	(CNPV),2(SP)				; place vector contents above
		rtr						; jump to vector

