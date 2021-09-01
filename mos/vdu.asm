;; (c) 2019 Dossytronics, Dominic Beesley	

		include "mos.inc"
		include "oslib.inc"
		include "hardware.inc"
		include "macros.inc"
;; ported VDU from 6809 mos

		xdef 	mos_VDU_init
		xdef	mos_VDU_WRCH
		xdef	x_crtc_set_cursor
		xdef	x_crtc_reset_cursor
		xdef	mos_VDU_9
		xdef	x_setup_read_cursor
		xdef	x_setup_write_cursor

mostbl_chardefs := font

		section "code"

		macro	VDU_JMP_REL
		dc.w	\1-mos_vdu_jmp-2
		endm	VDU_JMP_REL

		macro 	TODO
		trap	#9
		dc.b	\1
		dc.b	0
		align	2
		endm

;;		; get a 16 bit address in SYS space have to do this 
;;		; as move.w *,A0 sign extends
;;		; TODO: shorten this
;;GetAddrSYS16	move.l	D0,-(SP)
;;		moveq	#-1,D0
;;		move.w	(A0),D0
;;		move.l	D0,A0
;;		move.l	(SP)+,D0
;;		rts

		; TODO - make the ZP registers 32 bit where they need to be!
		; the specified address register has its top word set to FFFF
		macro   ADDRSYS16
		exg	D0,\1
		ori.l	#$FFFF0000,D0
		exg	D0,\1
		endm

		; move zp variable in \1 to address \3 via data \2
		macro   LDADDRSYS16
		moveq	#-1,\2
		move.w	\1,\2
		move.l  \2,\3
		endm



mostbl_byte_mask_4col
		dc.b	$00,$11,$22,$33,$44,$55,$66,$77 ;	C31F
		dc.b	$88,$99,$AA,$BB,$CC,$DD,$EE,$FF ;	C327
mostbl_byte_mask_16col
		dc.b	$00,$55,$AA,$FF			;	C32F

mostbl_vdu_entry_points
		VDU_JMP_REL	LC511RTS			; VDU 0
		VDU_JMP_REL	LC511RTS;mos_VDU_1			; VDU 1
		VDU_JMP_REL	mos_VDU_2			; VDU 2
		VDU_JMP_REL	mos_VDU_3			; VDU 3
		VDU_JMP_REL	mos_VDU_4			; VDU 4
		VDU_JMP_REL	mos_VDU_5			; VDU 5
		VDU_JMP_REL	LC511RTS			; VDU 6
		VDU_JMP_REL	LC511RTS;mos_VDU_7			; VDU 7

		VDU_JMP_REL	LC511RTS;mos_VDU_8			; VDU 8
		VDU_JMP_REL	mos_VDU_9			; VDU 9
		VDU_JMP_REL	mos_VDU_10			; VDU 10
		VDU_JMP_REL	mos_VDU_11			; VDU 11
		VDU_JMP_REL	mos_VDU_12			; VDU 12
		VDU_JMP_REL	mos_VDU_13
		VDU_JMP_REL	mos_VDU_14
		VDU_JMP_REL	mos_VDU_15

		VDU_JMP_REL	mos_VDU_16
		VDU_JMP_REL	mos_VDU_17
		VDU_JMP_REL	mos_VDU_18
		VDU_JMP_REL	mos_VDU_19
		VDU_JMP_REL	mos_VDU_20
		VDU_JMP_REL	mos_VDU_21
		VDU_JMP_REL	mos_VDU_22
		VDU_JMP_REL	mos_VDU_23

		VDU_JMP_REL	mos_VDU_24
		VDU_JMP_REL	LC511RTS;mos_VDU_25
		VDU_JMP_REL	mos_VDU_26
		VDU_JMP_REL	LC511RTS
		VDU_JMP_REL	LC511RTS;mos_VDU_28
		VDU_JMP_REL	mos_VDU_29
		VDU_JMP_REL	mos_VDU_30
		VDU_JMP_REL	mos_VDU_31

		VDU_JMP_REL	mos_VDU_127

mos_vdu_callfb	move.w	vduvar_VDU_VEC_JMP,D1
mos_vdu_jmp	jmp	(PC,D1.w)

mostbl_vdu_q_lengths	; 2's complement
		dc.b	$00,$FF,$00,$00,$00,$00,$00,$00	; 0-7
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00 ; 8-15
		dc.b	$00,$FF,$FE,$FB,$00,$00,$FF,$F7 ; 16-23
		dc.b	$F8,$FB,$00,$00,$FC,$FC,$00,$FE ; 24-31
		dc.b	$00

		dc.b	$C0	; TODO: check wat this is for!

mostbl_VDU_VIDPROC_CTL_by_mode
		dc.b	$9C,$D8,$F4,$9C,$88,$C4,$88,$4B ;	C3F7
mostbl_VDU_bytes_per_char
		dc.b	$08,$10,$20,$08,$08,$10,$08,$01 ;	C3FF
mostbl_VDU_pix_mask_16colour				
		dc.b	$AA,$55				;	C407
mostbl_VDU_pix_mask_4colour
		dc.b	$88,$44,$22,$11			;	C409
mostbl_VDU_pix_mask_2colour
		dc.b	$80,$40,$20,$10,$08,$04,$02	;	C40D
mostbl_VDU_mode_colours_m1			; - spills into next table
		dc.b	$01,$03,$0F,$01,$01,$03,$01	 ;	C414
; 2 COLOUR MODES PARAMETER LOOK UP TABLE
mostbl_2_colour_pixmasks
		dc.b	$00,$FF				;	C424
; 4 COLOUR MODES PARAMETER LOOK UP TABLE
mostbl_4_colour_pixmasks
		dc.b	$00,$0F,$F0,$FF			;	C426
; 16 COLOUR MODES PARAMETER LOOK UP TABLE
mostbl_16_colour_pixmasks
		dc.b	$00,$03,$0C,$0F,$30,$33,$3C,$3F ;	C42A
		dc.b	$C0,$C3,$CC,$CF,$F0,$F3,$FC,$FF ;	C432
mostbl_leftmost_pixels
		dc.b	$80,$88,$AA
; modes 3,6,7 are 0 but get set to $7 in vdu_init
mostbl_VDU_pixels_per_byte_m1
		dc.b	$07,$03,$01,$00,$07,$03		;	C43A
; mode size
mostbl_VDU_mode_size				; note first two entries shared by previous tbl
		dc.b	$00,$00,$00,$01,$02,$02,$03,$04 ;	C440
; SOUND PITCH OFFSET BY CHANNEL LOOK UP TABLE ???CHECK
mostbl_SOUND_PITCH_OFFSET_BY_CHANNEL_LOOK_UP_TABLE
		dc.b	$00,$06,$02			;	C448
; sent direct to orb of SYSVIA dependent on mode_size
mostbl_VDU_hwscroll_offb1
		dc.b	$0D,$05,$0D,$05			;	C44B
		align	1
;; 68 - use tbl68_size_bytes_pre_row instead
;;mostbl_VDU_bytes_per_row_w
;;		dc.w	40,320,640			;	C463 -- note this was just low byte on 6502
; sent direct to orb of SYSVIA dependent on mode_size
mostbl_VDU_hwscroll_offb2
		dc.b	$04,$04,$0C,$0C,$04		;	C44F
; where to jump to in CLS unwound
;;;mostbl_VDU_cls_vecjmp
;;;	FDB	cls_Mode_012_entry_point
;;;	FDB	cls_Mode_3_entry_point
;;;	FDB	cls_Mode_45_entry_point
;;;	FDB	cls_Mode_6_entry_point
;;;	FDB	cls_Mode_7_entry_point
mostbl_VDU_screensize_h
		dc.b	$50,$40,$28,$20,$04		;	C459
mostbl_VDU_screebot_h
		dc.b	$30,$40,$58,$60,$7C		;	C45E
mostbl_VDU_6845_mode_012
		dc.b	$7F,$50,$62,$28,$26,$00,$20,$22,$01,$07,$67,$08
mostbl_VDU_6845_mode_3
		dc.b	$7F,$50,$62,$28,$1E,$02,$19,$1B,$01,$09,$67,$09
mostbl_VDU_6845_mode_45
		dc.b	$3F,$28,$31,$24,$26,$00,$20,$22,$01,$07,$67,$08
mostbl_VDU_6845_mode_6
		dc.b	$3F,$28,$31,$24,$1E,$02,$19,$1B,$01,$09,$67,$09
mostbl_VDU_6845_mode_7
		dc.b	$3F,$28,$33,$24,$1E,$02,$19,$1B,$93,$12,$72,$13

;; TELETEXT CHARACTER CONVERSION TABLE
mostbl_TTX_CHAR_CONV
		dc.b	$23,$5F,$60,$23			; #->_->£->#


		align	2

mos_VDU_WRCH						; LC4C0
		move.b	sysvar_VDU_Q_LEN,D1		; get number of items in VDU queque
		bne	mos_VDU_WRCH_add_to_Q		; if parameters needed then C512
		btst	#VDU_STATUS_B6_CURSORED,zp_vdu_status
		beq	mos_VDU_WRCH_sk_nocurs		;
		bsr	x_start_curs_edit		; if cursor editing enabled two cursors exist
		bsr	x_setup_write_cursor		; swap values
		bmi	mos_VDU_WRCH_sk_nocurs		; then set up write cursor
		cmp.b	#$0D,D0				; if display disabled C4D8
		bne	mos_VDU_WRCH_sk_nocurs		; else if character in A=RETURN teminate edit
		bsr	x_cancel_cursor_edit		; else C4D8
mos_VDU_WRCH_sk_nocurs
		cmp.b	#$7F,D0						;is character DELETE ?
		beq	x_read_linkaddresses_and_number_of_parameters1	;if so C4ED
		cmp.b	#$20,D0						;is it less than space? (i.e. VDU control code)
		blo	x_read_linkaddresses_and_number_of_parameters2	;if so C4EF
		tst.b	zp_vdu_status					;else check VDU byte ahain
		bmi	x_main_exit_routine				;if screen disabled exit
		bsr	render_char					;else display a character
		bsr	mos_VDU_9					;and cursor right
		bra	x_main_exit_routine				;				

;; ----------------------------------------------------------------------------
;; read linkFDBesses and number of parameters???
x_read_linkaddresses_and_number_of_parameters1
		moveq	#$20,D0				; to replace delete character
;; read linkFDBesses and number of parameters???
x_read_linkaddresses_and_number_of_parameters2
		andi.w	#$00FF,D0			; clear top of D0
		lea	mostbl_vdu_q_lengths,A0		;	C4EF
		move.b	0(A0,D0),D1
		move.w	D0,D2
		asl.w	#1,D2
		lea	mostbl_vdu_entry_points,A0
		move.w	0(A0,D2),A1
		move.w	A1,vduvar_VDU_VEC_JMP
		move.b	D1,sysvar_VDU_Q_LEN
		beq	x_vdu_no_q
		btst	#VDU_STATUS_B6_CURSORED,zp_vdu_status
		bne	LC52F				; cursor editing in force
LC511RTS	CLC
		rts

;; ----------------------------------------------------------------------------
;; B, sysvar_VDU_Q_LEN are 2's complement of number of parameters. **{NETV=>vduvar_Q+5-$100}
mos_VDU_WRCH_add_to_Q
		ext.w	D1
		lea.l	vduvar_VDU_Q_END,A0
		move.b	D0,(A0,D1)			;	C512
		addq.b	#1,D1				;	C515
		move.b	D1,sysvar_VDU_Q_LEN		;	C516
		bne	LC532				;	C519
		btst	#VDU_STATUS_B7_SCREENDIS,zp_vdu_status
		bne	mos_exec_vdu1
		btst	#VDU_STATUS_B6_CURSORED,zp_vdu_status
		bne	LC526				; bit 6 set - cursor editing in force
		bsr	mos_vdu_callfb
		CLC
		rts					;	C525
; ----------------------------------------------------------------------------
LC526		bsr	x_start_curs_edit		;	C526
		bsr	x_setup_write_cursor		;	C529
		bsr	mos_vdu_callfb
LC52F		bsr	x_cursor_editing_routines	;	C52F
LC532		CLC
		rts					;	C533

;; ----------------------------------------------------------------------------
;; 1 parameter required;	 
mos_exec_vdu1
		;TODOSKIP "Printer character skip"	; printer rediretcted here???
		;;	ldb	vduvar_VDU_VEC_JMP			; get top byte of jump
		;;	cmpb	#$C5					; not used like this any more!
		;;bne	LC532				;	C539
mos_VDU_1
		move.b	zp_vdu_status,D1
		roxr.b	#1,D1
		bcc	LC511RTS			; no printer active return with CLC
		bra	LE11E				; send to printer

;; no parameters found execute
x_vdu_no_q
		;;stx	vduvar_VDU_VEC_JMP		;	C545 - already done

		; set C if char > 8 and < 13
		cmp.b	#$08,D0
		bcc	LC553
		eor.b	#$FF,D0
		cmp.b	#$F2,D0
		eor.b	#$FF,D0
LC553		btst	#VDU_STATUS_B7_SCREENDIS,zp_vdu_status			;	C553
		bne	x_reenable_vdu_if_vdu6		;	vdu disabled
		move.w	SR,-(SP)
		bsr	mos_vdu_callfb
		move.w	(SP)+,CCR			;	C55B
		bcc	LC561				;	C55C

x_main_exit_routine
		move.b	zp_vdu_status,D0		;VDU status byte
		roxr.b	D0				;Carry is set if printer is enabled
LC561		
		btst	#VDU_STATUS_B6_CURSORED,zp_vdu_status
		beq	LC511RTS			;if nmo cursor editing  C511 to exit
x_cursor_editing_routines
		bsr	x_setup_read_cursor		;	C565

x_start_curs_edit					;LC568
		move.w	SR,-(SP)
		move.w	D0,-(SP)
		lea.l	vduvar_TXT_CUR_X,A0		;	C56A
		lea.l	vduvar_TEXT_IN_CUR_X,A1			;	C56C
		bsr	x_exchange_2atY_with_2atX	;	C56E
		bsr	x_set_up_displayaddress		;	C571
		move.w	zp_vdu_top_scanline,A0
		bsr	x_set_cursor_position_X		;	C574
		bchg	#VDU_STATUS_B1_SCROLLOCK,zp_vdu_status	; toggle scrolling disabled
		move.w	(SP)+,D0
		rtr

x_reenable_vdu_if_vdu6	
		eor.b	#$06,D0
		bne	LC58Crts
		bclr	#VDU_STATUS_B0_PRINT,zp_vdu_status
LC58Crts	rts

;x_check_text_cursor_in_use -- removed use btst

;; ----------------------------------------------------------------------------
;; SET PAGED MODE  VDU 14;  
mos_VDU_14
		clr.b	sysvar_SCREENLINES_SINCE_PAGE	;	C58F
		bset	#VDU_STATUS_B2_PAGE,zp_vdu_status;	C592
		rts					;	C594
;; VDU 2 PRINTER ON
mos_VDU_2
		bsr	LE1A2					;	C596
		bset	#VDU_STATUS_B0_PRINT,zp_vdu_status	;	enable printer

mos_VDU_21
		bset	#VDU_STATUS_B7_SCREENDIS,zp_vdu_status  ; display off
;x_ORA_with_vdu_status
		rts
mos_VDU_3	bsr	LE1A2
		bclr	#VDU_STATUS_B0_PRINT,zp_vdu_status	; printer off
		rts
mos_VDU_15	bclr	#VDU_STATUS_B2_PAGE,zp_vdu_status	; page mode off
		rts
;; ----------------------------------------------------------------------------
;; VDU 4 select Text Cursor  No parameters;  
mos_VDU_4
		tst.b	vduvar_PIXELS_PER_BYTE_MINUS1
		beq	LC5ACrts
		bsr	x_crtc_reset_cursor
		bclr	#VDU_STATUS_B5_VDU5,zp_vdu_status
LC5ACrts	rts
;; VDU 5 set graphics cursor
mos_VDU_5
		tst.b	vduvar_PIXELS_PER_BYTE_MINUS1
		beq	LC5ACrts
		move.w	$0A20,sheila_CRTC_reg		; set 6845 R10=$20, =no cursor
		bset	#VDU_STATUS_B5_VDU5, zp_vdu_status
		rts		

;; VDU 8	 CURSOR LEFT	 NO PARAMETERS
mos_VDU_8						; LC5C5
		btst	#VDU_STATUS_B5_VDU5,zp_vdu_status
		bne	x_cursor_left_and_down_with_graphics_cursor_in_use;move cursor left 8 pixels if graphics
		subq.b	#1,vduvar_TXT_CUR_X		; move cursor left
		move.b	vduvar_TXT_CUR_X,D1		;	C5CD
		cmp.b	vduvar_TXT_WINDOW_LEFT,D1	;	C5D0
		bmi	x_execute_wraparound_left_up	;	C5D3
		move.w	vduvar_6845_CURSOR_ADDR,D1	;	C5D5
		move.b	vduvar_BYTES_PER_CHAR,D0	;	C5D9
		asl.w	#8,D0
		sub.w	D0,D1
		move.b	vduvar_SCREEN_BOTTOM_HIGH,D0
		asl.w	#8,D0
		cmp.b	D0,D1		
		bhs	LC5EA				;	C5E5
		move.b	vduvar_SCREEN_SIZE_HIGH,D0	;	C5E7		; TODO swap around and use x68_add_screen_size_d0
		asl.w	#8,D0
		add.w	D0,D1
LC5EA		move.w	D1,A0
		bra	mos_set_cursor_X		;	C5EB
;; ----------------------------------------------------------------------------
;; execute wraparound left-up
x_execute_wraparound_left_up
		move.b	vduvar_TXT_WINDOW_RIGHT,vduvar_TXT_CUR_X;	C5F1
;; cursor up
x_cursor_up
		subq.b	#1,sysvar_SCREENLINES_SINCE_PAGE;	C5F4
		bpl	LC5FC				;	C5F7
		addq.b	#1,sysvar_SCREENLINES_SINCE_PAGE;	C5F9
LC5FC		move.b	vduvar_TXT_CUR_Y,D1		;	C5FC
		cmp.b	vduvar_TXT_WINDOW_TOP,D1	;	C5FF
		beq	x_cursor_at_top_of_window	;	C602
		subq.b	#1,vduvar_TXT_CUR_Y		;	C604
		bra	x_setup_displayaddress_and_cursor_position
;; ----------------------------------------------------------------------------
;; cursor at top of window
x_cursor_at_top_of_window
		CLC
		bsr	x_move_text_cursor_to_next_line ;	C60B
		btst	#VDU_STATUS_B3_WINDOW,zp_vdu_status
		bne	LC619				;	C612
		bsr	x_adjust_screen_RAM_addresses	;	C614
		bra	LC61C				;	C617
LC619		bsr	x_soft_scroll1line		;	C619
LC61C		bra	x_clear_a_line_then_setup_displayaddress_and_cursor_position				;	C61C

;; ----------------------------------------------------------------------------
;; cursor left and down with graphics cursor in use
x_cursor_left_and_down_with_graphics_cursor_in_use
		clr.b	D1				;	C61F
;; cursor down with graphics in use; D1=2 for vertical or 0 for horizontal 
x_cursor_down_with_graphics_in_use
		move.b	D1,zp_vdu_wksp+1		;	C621
		bsr	x_Check_window_limits		;	C623
		clr.w	D1
		move.b	zp_vdu_wksp+1,D1		;	C626
		lea.l	vduvar_GRA_CUR_INT,A0
		subq.w	#$08,(A0,D1)			;	subtract 8 to move back/up one char
LC636		tst.b	zp_vdu_wksp			;	get back result from x_Check_window_limits
		bne	jmp_cal_ext_coors				;	C638
		bsr	x_Check_window_limits		;	C63A
		beq	jmp_cal_ext_coors				;	C63D
		lea.l	vduvar_GRA_WINDOW_RIGHT,A1
		clr.w	D1
		move.b	zp_vdu_wksp+1,D1
		;TODO check this thorougly
		move.w	(A1,D1),(A0,D1)
		cmp.b	#1,D1
		bhs	LC64A
		subq.w	#7,(A0,D1)
		bra	LC660
LC64A		
jmp_cal_ext_coors				; LC658
		bra	x_calculate_external_coordinates_from_internal_coordinates;	C658
;; ----------------------------------------------------------------------------
;; VDU 11 Cursor Up    No Parameters
mos_VDU_11
		btst	#VDU_STATUS_B5_VDU5,zp_vdu_status;	C65B
		beq	x_cursor_up			;	C65E
LC660		moveq	#$02,D1				;	C660
		bra	x_graphic_cursor_up_Beq2	;	C662

;; VDU 9 Cursor right	No parameters
mos_VDU_9						; LC664
		btst	#VDU_STATUS_B5_VDU5,zp_vdu_status
		bne	x_graphic_cursor_right		;	C668
		move.b	vduvar_TXT_CUR_X,D1		;	C66A
		cmp.b	vduvar_TXT_WINDOW_RIGHT,D1	;	C66D
		bhs	x_text_cursor_down_and_right	;	C670
		addq.b	#1,vduvar_TXT_CUR_X		;	C672
		move.w	vduvar_6845_CURSOR_ADDR,A0
		clr.w	D1
		move.b	vduvar_BYTES_PER_CHAR,D1	;	C678
		lea	(A0,D1),A0
		bra	mos_set_cursor_X		;	C681

;; ----------------------------------------------------------------------------
;; : text cursor down and right
x_text_cursor_down_and_right
		move.b	vduvar_TXT_WINDOW_LEFT,vduvar_TXT_CUR_X
;; : text cursor down
x_text_cursor_down
		CLC
		bsr	x_control_scrolling_in_paged_mode_2
		move.b	vduvar_TXT_CUR_Y,D1
		cmp.b	vduvar_TXT_WINDOW_BOTTOM,D1
		bhs	LC69B
		addq.b	#1,vduvar_TXT_CUR_Y
		bra	x_setup_displayaddress_and_cursor_position
LC69B		bsr	x_move_text_cursor_to_next_line
		btst	#VDU_STATUS_B3_WINDOW,zp_vdu_status
		bne	LC6A9
		bsr	x_adjust_screen_RAM_addresses_one_line_scroll
		bra	x_clear_a_line_then_setup_displayaddress_and_cursor_position
LC6A9		bsr	x_execute_upward_scroll

x_clear_a_line_then_setup_displayaddress_and_cursor_position
		bsr	x_clear_a_line
x_setup_displayaddress_and_cursor_position
		bsr	x_set_up_displayaddress
		move.w	zp_vdu_top_scanline,A0
		bra	x_set_cursor_position_X

;; graphic cursor right
x_graphic_cursor_right
		clr.b	D1
;; graphic cursor up  (B=2)
x_graphic_cursor_up_Beq2
		move.b	D1,zp_vdu_wksp+1		;	C6B6
		bsr	x_Check_window_limits		;	C6B8
		clr.w	D1
		move.b	zp_vdu_wksp+1,D1		;	C6BB
		lea.l	vduvar_GRA_CUR_INT,A0
		addq.w	#8,(A0,D1)
LC6CB		tst.b	zp_vdu_wksp			; get back result from window limits above
		bne	jmp_cal_ext_coors		;	C6CD
		bsr	x_Check_window_limits		;	C6CF
		beq	jmp_cal_ext_coors		;	C6D2
		clr.w	D1
		move.b	zp_vdu_wksp+1,D1		;	C6D4
		lea.l	vduvar_GRA_WINDOW_LEFT,A1
		move.w	(A1,D1),(A0,D1)
		cmp.b	#$01,D1				;	C6D9
		blo	LC6F5				;	C6DB
		addq.w	#$06,(A0,D1)			;	C6DD
		bra	x_calculate_external_coordinates_from_internal_coordinates

;; ----------------------------------------------------------------------------
;; VDU 10  Cursor down	  No parameters
mos_VDU_10
		btst	#VDU_STATUS_B5_VDU5,zp_vdu_status;	C6F0
		beq	x_text_cursor_down		;	C6F3
LC6F5		moveq	#$02,D1				;	C6F5
		bra	x_cursor_down_with_graphics_in_use;	C6F7


;; ----------------------------------------------------------------------------
;; VDU 28   define text window	      4 parameters; parameters are set up thus ; 0320  P1 left margin ; 0321  P2 bottom margin ; 0322  P3 right margin ; 0323  P4 top margin ; Note that last parameter is always in 0323 
mos_VDU_28
		clr.w	D1
		move.b	vduvar_MODE,D1
		lea.l  mostbl_vdu_window_bottom+1,A0
		move.b	vduvar_VDU_Q_END - 3,D0
		cmp.b	vduvar_VDU_Q_END - 1,D0
		blo	LC758rts
		cmp.b	(A0,D1),D0
		bhi	LC758rts
		move.b	vduvar_VDU_Q_END - 2,D0
		lea.l	mostbl_vdu_window_right,A0
		cmp.b	(A0,D1),D0
		bhi	LC758rts
		sub.b	vduvar_VDU_Q_END - 4,D0
		bmi	LC758rts
		bsr	LCA88_newAPI
		bset	#VDU_STATUS_B3_WINDOW,zp_vdu_status
		move.l	vduvar_VDU_Q_END - 4,vduvar_TXT_WINDOW_LEFT		;; should be ok on 4 byte boundary
		bsr	x_check_text_cursor_in_window_setup_display_addr
		bcs	mos_VDU_30
LC732_set_cursor_position
		move.w	zp_vdu_top_scanline,A0		; CHECK!
		bra	x_set_cursor_position_X

LC758rts
		rts					; C758


;; ----------------------------------------------------------------------------
;; VDU 12  Clear text Screen		  0 parameters;	 
mos_VDU_12
		btst	#VDU_STATUS_B5_VDU5,zp_vdu_status
		bne	x_mos_home_CLG
		btst	#VDU_STATUS_B3_WINDOW,zp_vdu_status
		beq	LCBC1_clear_whole_screen
LC767		move.b	vduvar_TXT_WINDOW_TOP,D1
LC76A		move.b	D1,vduvar_TXT_CUR_Y
		bsr	x_clear_a_line
		move.b	vduvar_TXT_CUR_Y,D1
		cmp.b	vduvar_TXT_WINDOW_BOTTOM,D1
		addq.b	#1,D1
		bls	LC76A
;; VDU 30  Home cursor			  0  parameters
mos_VDU_30
		btst	#VDU_STATUS_B5_VDU5,zp_vdu_status
		beq	LC781
		bra	x_home_graphics_cursor
;; ----------------------------------------------------------------------------
LC781		clr.b	vduvar_VDU_Q_END - 1
		clr.b	vduvar_VDU_Q_END - 2
;; VDU 31  Position text cursor		  2  parameters; 0322 = X coordinate ; 0323 = Y coordinate 
mos_VDU_31
		btst	#VDU_STATUS_B5_VDU5,zp_vdu_status
		bne	LC758rts
		bsr	LC7A8
		move.b	vduvar_VDU_Q_END - 2,D0
		add.b	vduvar_TXT_WINDOW_LEFT,D0
		move.b	D0,vduvar_TXT_CUR_X
		move.b	vduvar_VDU_Q_END - 1,D0
		add.b	vduvar_TXT_WINDOW_TOP,D0
		move.b	D0,vduvar_TXT_CUR_Y
		bsr	x_check_text_cursor_in_window_setup_display_addr
		bcc	LC732_set_cursor_position
LC7A8		lea.l	vduvar_TXT_CUR_X,A0
		lea.l	vduvar_TEMP_8,A1
		bra	x_exchange_2atY_with_2atX
;; ----------------------------------------------------------------------------
;; VDU  13	  Carriage  Return	  0 parameters
mos_VDU_13
		btst	#VDU_STATUS_B5_VDU5,zp_vdu_status		;	C7AF	
		bne	x_set_graphics_cursor_to_left_hand_column	;	C7B4
LC7B7		bsr	x_cursor_to_window_left				;	C7B7
		bra	x_setup_displayaddress_and_cursor_position	;	C7BA
;; ----------------------------------------------------------------------------
x_mos_home_CLG						; LC7BD
		bsr	x_home_graphics_cursor			

;; VDU 16 clear graphics screen		  0 parameters
mos_VDU_16
		tst.b	vduvar_PIXELS_PER_BYTE_MINUS1		; pixels per byte
		beq	LC7F8rts				; if 0 current mode has no graphics so exit
		move.b	vduvar_GRA_BACK,D0			; Background graphics colour
		move.b	vduvar_GRA_PLOT_BACK,D1			; background graphics plot mode (GCOL n)
		bsr	x_set_gra_masks_newAPI			; set graphics byte mask in &D4/5
		move.l	vduvar_GRA_WINDOW_LEFT,vduvar_TEMP_8	; set(300/7+Y) from (300/7+X)
		move.l	vduvar_GRA_WINDOW_LEFT+4,vduvar_TEMP_8+4; set(300/7+Y) from (300/7+X)
		move.b	vduvar_GRA_WINDOW_TOP + 1,D0		; graphics window top lo.
		sub.b	vduvar_GRA_WINDOW_BOTTOM + 1,D0		; graphics window bottom lo
		addq	#1,D0					; increment
		move.b	D0,vduvar_GRA_WKSP			; and store in workspace (this is line count)
.s1		lea.l	vduvar_TEMP_8 + 4,A0			; right
		lea.l	vduvar_TEMP_8,A1			; left
		bsr	x_vdu_clear_gra_line_newAPI		; clear line
		subq.w	#1,vduvar_TEMP_8 + 6
		subq.b	#1,vduvar_GRA_WKSP			; decrement line count
		bne	.s1					; if <>0 then do it again
LC7F8rts	rts						; exit
	
;; ----------------------------------------------------------------------------
;; COLOUR; parameter in &0323 
mos_VDU_17	; COLOUR
		clr.w	D1				;	C7F9
		bra	LC7FF				;	C7FB
;; GCOL; parameters in 323,322 
mos_VDU_18	; GCOL
		moveq	#$02,D1
LC7FF		clr.w	D0
		move.b	vduvar_VDU_Q_END - 1,D0
		bpl	LC805
		addq.b	#1,D1
LC805		and.b	vduvar_COL_COUNT_MINUS1,D0
		move.b	D0,zp_vdu_wksp
		move.b	vduvar_COL_COUNT_MINUS1,D0
		beq	LC82B
		and.b	#$07,D0
		add.b	zp_vdu_wksp,D0
		lea.l	mostbl_2_colour_pixmasks-1,A0
		move.b	(A0,D0),D0
		lea.l	vduvar_TXT_FORE,A1
		move.b	D0,(A1,D1)
		cmp.b	#$02,D1
		bhs	LC82C
		move.b	vduvar_TXT_FORE,D0
		not.b	D0
		move.b	D0,zp_vdu_txtcolourEOR
		move.b	vduvar_TXT_BACK,D1
		eor.b	D1,D0
		move.b	D0,zp_vdu_txtcolourOR
LC82B		rts
LC82C		
		lea.l	vduvar_GRA_PLOT_FORE-2,A1
		move.b	vduvar_VDU_Q_END - 2,(A1,D1)
		rts
;; ----------------------------------------------------------------------------
vdu20_mo7	move.b	#$20,vduvar_TXT_BACK		;	C833
		rts					;	C838

;; ----------------------------------------------------------------------------
;; VDU 20	  Restore default colours	  0 parameters;	 
mos_VDU_20

		clr.b	vduvar_TXT_FORE			; this is on an odd byte so need byte access
		clr.l	vduvar_TXT_BACK			; clear all colours (6 bytes)
		clr.b	vduvar_GRA_PLOT_BACK	
		move.b	vduvar_COL_COUNT_MINUS1,D1	; number of logical colours less 1
		beq	vdu20_mo7			; if none its MODE 7 so C833
		moveq	#-1,D0				; A=&FF
		cmp.b	#$0F,D1				; if not mode 2 (16 colours)
		bne	LC850				; goto C850
		moveq	#$3F,D0				;else A=&3
LC850		move.b	D0,vduvar_TXT_FORE		;foreground text colour
		move.b	D0,vduvar_GRA_FORE		;foreground graphics colour
		eori.b	#$FF,D0				;invert A 
		move.b	D0,zp_vdu_txtcolourOR		;text colour byte to be orred or EORed into memory
		move.b	D0,zp_vdu_txtcolourEOR		;text colour byte to be orred or EORed into memory
		move.b	D1,vduvar_VDU_Q_END - 5		;set first parameter of 5
		cmp.b	#$03,D1				;if there are 4 colours
		beq	vdu20_4_colour_mode		;goto C874
		blo	vdu20_2_colour_mode		;if less there are 2 colours goto C885
							;else there are 16 colours
		move.b	D1,vduvar_VDU_Q_END - 4		;set second parameter
LC868		bsr	mos_VDU_19			;do VDU 19 etc
		subq.b	#1,vduvar_VDU_Q_END - 4		;decrement first parameter
		subq.b	#1,vduvar_VDU_Q_END - 5		;and last parameter
		bpl	LC868	
		rts					;
;; ----------------------------------------------------------------------------
;; 4 colour mode
vdu20_4_colour_mode
		move.b	#$07,vduvar_VDU_Q_END - 4	;	note word to clear top bits
LC879		bsr	mos_VDU_19			;	C879
		move.b	vduvar_VDU_Q_END - 4,D0		;	C87C
		lsr.b	#1,D0
		move.b	D0,vduvar_VDU_Q_END - 4
		subq.b	#1,vduvar_VDU_Q_END - 5		;	C87F
		bpl	LC879				;	C882
		rts					;	C884
; ----------------------------------------------------------------------------
vdu20_2_colour_mode		
		move.b	#$07, vduvar_VDU_Q_END- 4	;	C885
		bsr	mos_VDU_19			;	C887
		clr.b	vduvar_VDU_Q_END - 4
		clr.b	vduvar_VDU_Q_END - 5		;	C88C
; VDU 19   define logical colours		  5 parameters; &31F=first parameter logical colour ; &320=second physical colour 
mos_VDU_19


		move.w	SR, -(SP)			; save flags
		or.w	#$0700,SR			; and disable interrupts

		moveq	#0,D1
		move.b	vduvar_VDU_Q_END - 5,D1		; b <= logical colour
		and.b	vduvar_COL_COUNT_MINUS1,D1	; 
		
		move.b	vduvar_VDU_Q_END - 4, D0	; a <= physical colour
LC89E		andi.b	#$0F,D0				; 
		lea	vduvar_PALLETTE, A0
		move.b  D0,0(A0,D1.w)			; store in saved palette 

		move.b	vduvar_COL_COUNT_MINUS1,D2	; a <= colours - 1
							;	2 col		4 col		16 col
LC8AD		roxr.b	#1,D1				; 
		roxr.b	#1,D2			;
		bcs	LC8AD				;
							; b=	$80		$C0		$F0
		asl.b	#1,D2				; wksp2=X0000000	XX000000	XXXX0000
							; a <= phys colour
		or.b	D0,D2				; a <= LLLLPPPP
		move.b	D2,D0

		clr.b	D1
LC8BA		cmp.b	#3,vduvar_COL_COUNT_MINUS1	;	C8BB
		bne	mos_VDU19_sk1			;	C8BC
		and.b	#$60,D0				;	C8BE
		beq	LC8CB				;	C8C0
		cmp.b	#$60,D0				;	C8C2
		beq	LC8CB				;	C8C4
		move.b	D2,D0
		eor.b	#$60,D0				;	C8C7
		bne	mos_VDU19_sk1			;	C8C9
LC8CB		move.b	D2,D0		
mos_VDU19_sk1
		bsr	write_pallette_reg				; LC8CC
		add.b	vduvar_COL_COUNT_MINUS1,D1	;	C8D1
		addq.b	#1,D1
		move.b	D2,D0
		add.b	#$10,D0				;	C8D6
		move.b	D0,D2
		cmp.b	#$10,D1				;	C8D9
		blo	LC8BA				;	C8DB

		rte

;; ----------------------------------------------------------------------------
;; OSWORD 12    WRITE PALLETTE; on entry X=&F0:Y=&F1:YX points to parameter block ; byte 0 = logical colour;  byte 1 physical colour; bytes 2-4=0 
;mos_OSWORD_12:
;	php					;	C8E0
;	and	vduvar_COL_COUNT_MINUS1		;	C8E1
;	tax					;	C8E4
;	iny					;	C8E5
;	lda	(zp_mos_OSBW_X),y		;	C8E6
;	jmp	LC89E				;	C8E8
;; ----------------------------------------------------------------------------
;; VDU	  22		  Select Mode	1 parameter; parameter in &323 
mos_VDU_22
		move.b	vduvar_VDU_Q_END - 1,D0		;	C8EB
		bra	mos_VDU_set_mode		;	C8EE
;; ----------------------------------------------------------------------------
;; VDU 23 Define characters		  9 parameters; parameters are:- ; 31B character to define ; 31C to 323 definition 
mos_VDU_23
		;TODO
		rts
;	lda	vduvar_VDU_Q_END - 9;	C8F1
;	cmp	#$20				;	C8F4
;	bcc	x_set_CRT_controller		;	C8F6
;	pha					;	C8F8
;	lsr	a				;	C8F9
;	lsr	a				;	C8FA
;	lsr	a				;	C8FB
;	lsr	a				;	C8FC
;	lsr	a				;	C8FD
;	tax					;	C8FE
;	lda	mostbl_VDU_pix_mask_2colour,x	;	C8FF
;	bit	vduvar_EXPLODE_FLAGS		;	C902
;	bne	LC927				;	C905
;	ora	vduvar_EXPLODE_FLAGS		;	C907
;	sta	vduvar_EXPLODE_FLAGS		;	C90A
;	txa					;	C90D
;	and	#$03				;	C90E
;	clc					;	C910
;	adc	#$BF				;	C911
;	sta	zp_vdu_wksp+5			;	C913
;	lda	vduvar_EXPLODE_FLAGS,x		;	C915
;	sta	zp_vdu_wksp+3			;	C918
;	ldy	#$00				;	C91A
;	sty	zp_vdu_wksp+2			;	C91C
;	sty	zp_vdu_wksp+4			;	C91E
;LC920:	lda	(zp_vdu_wksp+4),y		;	C920
;	sta	(zp_vdu_wksp+2),y		;	C922
;	dey					;	C924
;	bne	LC920				;	C925
;LC927:	pla					;	C927
;	jsr	x_calc_pattern_addr_for_given_char;	C928
;	ldy	#$07				;	C92B
;LC92D:	lda	$031C,y				;	C92D
;	sta	(zp_vdu_wksp+4),y		;	C930
;	dey					;	C932
;	bpl	LC92D				;	C933
;	rts					;	C935
;; ----------------------------------------------------------------------------
;	pla					;	C936
LC937rts	rts					;	C937

;VDU EXTENSION
x_VDU_EXTENSION
		move.b	vduvar_VDU_Q_END - 5,D0		;	C938
		CLC					;	C93B

jmp_VDUV						; LC93C
		;;jmp	[VDUV]				; C93C
		bra	mos_VDU_WRCH		; TODO - VECTORS!

;; ----------------------------------------------------------------------------
;; set CRT controller
x_set_CRT_controller
		cmp.b	#$01,D0				;	C93F
		blo	LC958				; VDU 23,0,R,X - set (R)eg to (X) in CRTC
		bne	jmp_VDUV			;	C943
		btst	#VDU_STATUS_B5_VDU5,zp_vdu_status;	C945
		bne	LC937rts			;	C948
		move.b	#$20,D0				;	C94A
		tst.b	vduvar_VDU_Q_END - 8		;	C94C
		beq	x_crtc_set_cursor		;	C94F

x_crtc_reset_cursor					; LC951
		move.b	vduvar_CUR_START_PREV,D0	;	C951
x_crtc_set_cursor
		move.b	#$0A,D1				;	C954
		bra	LC985				;	C956
LC958
		move.b	vduvar_VDU_Q_END - 7,D0		;	C958
		move.b	vduvar_VDU_Q_END - 8,D1		;	C95B
mos_set_6845_regD1toD0
		cmp.b	#$07,D1				;	C95E
		blo	LC985				;	C960
		bne	LC967				;	C962
		add.b	oswksp_VDU_VERTADJ,D0		;	C964
LC967		cmp.b	#$08,D1				;	C967
		bne	LC972				;	C969
		tst.b	D0				;	C96B
		bmi	LC972				;	C96D
		move.b	oswksp_VDU_INTERLACE,D1
		eor.b	D1,D0				;	C96F
		moveq	#$08,D1
LC972		cmp.b	#$0A,D1				;	C972
		bne	LC985				;	C974
		move.b	D0,vduvar_CUR_START_PREV	;	C976
							;	C979
							;	C97A
							;	C97C
							;	C97E
							;	C97F
							;	C980
		btst.b	#VDU_STATUS_B5_VDU5,zp_vdu_status		;	C982
		bne	LC98B				;	C983
LC985		move.b	D1,sheila_CRTC_reg		;	C985
		move.b	D0,sheila_CRTC_rw		;	C988
LC98B		rts					;	C98B


x68_add_screen_size_d0
		move.w	D0,-(SP)
		move.b	vduvar_SCREEN_SIZE_HIGH,D0
		asl.w	#8,D0
		add.w	(SP)+,D0
		rts

x68_sub_screen_size_d0
		move.w	D1,-(SP)
		move.b	vduvar_SCREEN_SIZE_HIGH,D1
		asl.w	#8,D1
		sub.w	D1,D0
		move.w	(SP)+,D1
		rts


;; ----------------------------------------------------------------------------
;; adjust screen RAMFDBesses
x_adjust_screen_RAM_addresses
		move.w	vduvar_6845_SCREEN_START,D0
		bsr	x_subtract_bytes_per_line_from_D
		bhs	LC9B3
		bsr	x68_add_screen_size_d0
		bra	LC9B3
x_adjust_screen_RAM_addresses_one_line_scroll	
		move.w	vduvar_BYTES_PER_ROW,D0
		add.w	vduvar_6845_SCREEN_START,D0
		bpl	LC9B3
		bsr	x68_sub_screen_size_d0		
LC9B3		move.w	D0,vduvar_6845_SCREEN_START
		move.w	D0,A0
		moveq	#$0C,D1
		bra	x_set_6845_screenstart_from_X


; TEXT WINDOW -BOTTOM ROW LOOK UP TABLE
mostbl_vdu_window_bottom
		dc.b	$1F,$1F,$1F,$18,$1F,$1F,$18,$18
; TEXT WINDOW -RIGHT HAND COLUMN LOOK UP TABLE
mostbl_vdu_window_right
		dc.b	$4F,$27,$13,$4F,$27,$13,$27,$27 ;	C3EF


;; VDU 26  set default windows		  0 parameters
mos_VDU_26							; LC9BD
		clr.w	D0
		moveq	#$2C,D1							; This seems too high?!
		lea.l	vduvar_GRA_WINDOW_LEFT,A0
LC9C1		move.b	D0,(A0,D1)
		dbf	D1,LC9C1						;	C9C4
		clr.w	D1
		move.b	vduvar_MODE,D1						;	C9C7
						;
		move.b	mostbl_vdu_window_right(PC,D1.w),vduvar_TXT_WINDOW_RIGHT	; text window right hand margin maximum
										; text window right
		bsr	LCA88_newAPI						; calculate number of bytes in a line
		move.b	vduvar_MODE,D1
		move.b	mostbl_vdu_window_bottom(PC,D1.w),vduvar_TXT_WINDOW_BOTTOM; text window bottom margin maximum
										; bottom margin
		move.b	#$03,vduvar_VDU_Q_END - 1				; set as last parameter
		move.b	#$02,vduvar_VDU_Q_END - 3				; increment Y
										; set parameters
		subq.b	#1,vduvar_VDU_Q_END - 2					; set to FF - these were cleared above
		subq.b	#1,vduvar_VDU_Q_END - 4					;
		bsr	mos_VDU_24						; and do VDU 24
		bclr	#VDU_STATUS_B3_WINDOW,zp_vdu_status			; clear bit 3 of &D0
		move.w	vduvar_6845_SCREEN_START,A0				; window area start address lo
mos_set_cursor_X
		move.w	A0,vduvar_6845_CURSOR_ADDR				;	C9F6		
		bpl	x_set_cursor_position_X
		move	A0,D0
		bsr	x68_sub_screen_size_d0
		move	D0,A0
x_set_cursor_position_X
		move.w	A0,zp_vdu_top_scanline
		move.w	vduvar_6845_CURSOR_ADDR,A0
		moveq	#$0E,D1
x_set_6845_screenstart_from_X			; LCA0E
		move.w	A0,D0
		cmp.b	#$07,vduvar_MODE
		bhs	LCA27
		lsr.w	#3,D0
		bra	mos_set_6845_regD1toD0_16
LCA27		
		sub.w	#$7400,D0			;	CA27
		eor.w	#$2000,D0			;	CA29
mos_set_6845_regD1toD0_16
		ror.w	#8,D0
		move.b	D1,sheila_CRTC_reg
		move.b	D0,sheila_CRTC_rw
		ror.w	#8,D0
		addq.b	#1,D1
		move.b	D1,sheila_CRTC_reg
		move.b	D0,sheila_CRTC_rw
		rts

db_endian_vdu_q_swap_68API
		***********************************************
		* BODGE: endianness swap for VDU drivers      *
		* This is subject to change                   *
		*                                             *
		* workspace vars are all in big endian        *
		* Q is in little endian so swap all the bytes *
		* D1 contains number-1 of 16 bit params at end of*
		* Q to swap				      *
		* Carried over from 6x09 port - not sure      *
		* assumes aligned VDU_Q			      *
		***********************************************
		lea.l	vduvar_VDU_Q_END,A0
.s1		move.w	-(A0),D0
		ror.w	#8,D0
		move.w	D0,(A0)
		dbf	D1,.s1
		rts

;; ----------------------------------------------------------------------------
;; VDU 24 Define graphics window		  8 parameters; &31C/D Left margin ; &31E/F Bottom margin ; &320/1 Right margin ; &322/3 Top margin 
mos_VDU_24
		moveq	#4-1,D1
		bsr	db_endian_vdu_q_swap_68API

* temporary equs to make things clearer
vduvar_VDU_Q_24_LEFT	equ	vduvar_VDU_Q_END - 8
vduvar_VDU_Q_24_BOTTOM	equ	vduvar_VDU_Q_END - 6
vduvar_VDU_Q_24_RIGHT	equ	vduvar_VDU_Q_END - 4
vduvar_VDU_Q_24_TOP	equ	vduvar_VDU_Q_END - 2
vduvar_TMP_CURSAVE	equ	vduvar_TEMP_8
vudvar_TMP_XY		equ	vduvar_TEMP_8 + 4


		bsr	x_exchange_310_with_328		; save current cursor value at vduvar_TEMP_8
		lea.l	vduvar_VDU_Q_24_LEFT,A0
		lea.l	vudvar_TMP_XY,A1
		bsr	x_coords_to_width_height	; calculate new width/height at TMP_XY
		or.w	vudvar_TMP_XY,D0		; D0 already contains height, or width
		bmi	x_exchange_310_with_328		; if either negative, quit
		lea.l	vduvar_VDU_Q_24_RIGHT,A0
		bsr	x_set_up_and_adjust_coords_atX
		lea.l	vduvar_VDU_Q_24_LEFT,A0
		bsr	x_set_up_and_adjust_coords_atX
		move.b	vduvar_VDU_Q_24_BOTTOM,D0
		or.b	vduvar_VDU_Q_24_TOP,D0
		bmi	x_exchange_310_with_328		; if top or bottom -ve
		tst.b	vduvar_VDU_Q_24_TOP
		bne	x_exchange_310_with_328		; if top internal coords > 255
		clr.w	D1
		move.b	vduvar_MODE,D1			; screen mode
		lea.l	mostbl_vdu_window_right,A0
		move.w	vduvar_VDU_Q_24_RIGHT,D0	; right margin 
		lsr.w	D0
		lsr.w	D0
		cmpi.w	#$FF,D0
		bhi	x_exchange_310_with_328		; exchange 310/3 with 328/3 - its too big!
		lsr.b	D0				; A=A/2
		cmp.b	(A0,D1),D0			; text window right hand margin maximum
		beq	LCA7A				; if equal CA7A
		bpl	x_exchange_310_with_328		; exchange 310/3 with 328/3
LCA7A		; save updated data
		move.l	vduvar_VDU_Q_END - 8,vduvar_GRA_WINDOW_LEFT
		move.l	vduvar_VDU_Q_END - 4,vduvar_GRA_WINDOW_LEFT+4

x_exchange_310_with_328
		lea.l	vduvar_GRA_CUR_EXT,A0		; ==$310
		lea.l	vduvar_TEMP_8,A1			; ==$328
		bra	x_exchange_4atY_with_4atX

;; ----------------------------------------------------------------------------
LCA88_newAPI
		; old API (y == window width in chars - 1)
		; new API (a == window width in chars - 1)
		addq.b	#1,D0
		and.w	#$00FF,D0
		clr.w	D1
		move.b	vduvar_BYTES_PER_CHAR,D1
		mulu	D1,D0
		move.w	D0,vduvar_TXT_WINDOW_WIDTH_BYTES
LCAA1		rts					;	CAA1

;; ----------------------------------------------------------------------------
;; VDU 29  Set graphics origin			  4 parameters;	 
mos_VDU_29
		move.l	vduvar_VDU_Q_END - 4,vduvar_GRA_ORG_EXT
		bra	x_calculate_external_coordinates_from_internal_coordinates
;; ----------------------------------------------------------------------------
;; VDU 32  (&7F)	  Delete			  0 parameters
mos_VDU_127					; LCAAC
		bsr	mos_VDU_8						;cursor left
		btst	#VDU_STATUS_B5_VDU5,zp_vdu_status			;A=0 if text cursor A=&20 if graphics cursor
		bne	LCAC7							;if graphics then CAC7
		tst.b	vduvar_COL_COUNT_MINUS1					;number of logical colours less 1
		beq	LCAC2							;if mode 7 CAC2
		lea.l	mostbl_chardefs(PC),A1
		;;std	zp_vdu_wksp+4						;store in &DF (&DE) now points to C300 SPACE pattern
		bsr	LCFBF_renderchar2					;display a space
;; ----------------------------------------------------------------------------
LCAC2		moveq	#$20,D0				;A=&20
		bra	x_convert_teletext_characters	;and return to display a space
;; ----------------------------------------------------------------------------
LCAC7		moveq	#$7F,D0				;for graphics cursor
		bsr	x_calc_pattern_addr_for_given_char_API68;set up character definition pointers
		move.b	vduvar_GRA_BACK,D0		;Background graphics colour
		clr.b	D1				;plotmode = 0
		bra	x_plot_char_gra_mode		;invert pattern data (to background colour)



;; ----------------------------------------------------------------------------
;; control scrolling in paged mode
x_control_scrolling_in_paged_mode		; LCAE0
		bsr	x_zero_paged_mode_counter
x_control_scrolling_in_paged_mode_2
		bsr	mos_OSBYTE_118
		bcc	LCAEA
		bmi	x_control_scrolling_in_paged_mode
LCAEA		move.b	zp_vdu_status,D0					;VDU status byte
		eor.b	#$04,D0							;invert bit 2 paged scrolling
		and.b	#$46,D0							;and if 2 cursors, paged mode off, or scrolling 
		bne	LCB1Crts						;barred then CB1C to exit
		tst.b	sysvar_SCREENLINES_SINCE_PAGE
		bmi	LCB19
		move.b	vduvar_TXT_CUR_Y,D0
		cmp.b	vduvar_TXT_WINDOW_BOTTOM,D0
		blo	LCB19
		lsr.b	#2,D0
		addq.b	#1,D0
		add.b	sysvar_SCREENLINES_SINCE_PAGE,D0
		add.b	vduvar_TXT_WINDOW_TOP,D0
		cmp.b	vduvar_TXT_WINDOW_BOTTOM,D0
		blo	LCB19
		CLC
LCB0E		bsr	mos_OSBYTE_118
		SEC
		bpl	LCB0E
;; zero paged mode  counter
x_zero_paged_mode_counter
		moveq	#-1,D0					;	CB14
		move.b	D0,sysvar_SCREENLINES_SINCE_PAGE	;	CB16
LCB19		addq.b	#1,sysvar_SCREENLINES_SINCE_PAGE	;	CB19
LCB1Crts	rts


mos_VDU_init:						; LCB1D
		move.b	D0,-(SP)			; save mode #
		clr.b	zp_vdu_status
		; clear vdu vars at $300-$37E
		moveq	#$7D,D0
		lea.l   vduvars_start,A0
.lp		clr.b	(A0)+
		dbf	D0,.lp
		clr.b	zp_mos_OSBW_X
		bsr	mos_OSBYTE_20			; explode characters
		move.b	#$7F,vduvar_MO7_CUR_CHAR
		move.b	(SP)+,D0			; get back mode #
mos_VDU_set_mode:
		andi.w	#$07,D0				; restrict to modes 0-6 and clear topbits TODO: ???
		move.b	D0,vduvar_MODE
		lea	mostbl_VDU_mode_colours_m1,A0
		move.b  0(A0,D0),vduvar_COL_COUNT_MINUS1
		move.b  mostbl_VDU_bytes_per_char-mostbl_VDU_mode_colours_m1(A0,D0.w),vduvar_BYTES_PER_CHAR
		clr.w	D1
		move.b	mostbl_VDU_pixels_per_byte_m1-mostbl_VDU_mode_colours_m1(A0,D0.w),D1
		move.b  D1,vduvar_PIXELS_PER_BYTE_MINUS1
		bne.b	.bmsk1
		moveq	#$07,D1
.bmsk1		lea	mostbl_VDU_pix_mask_16colour,A1
		move.b	0(A1,D1.w),D1
		move.b	D1,vduvar_RIGHTMOST_PIX_MASK
.ljlp		asl.b	#1,D1
		bpl	.ljlp				; keep shifting left until bit 7 causes N
		move.b	D1,vduvar_LEFTMOST_PIX_MASK
		clr.w	D1
		move.b	mostbl_VDU_mode_size-mostbl_VDU_mode_colours_m1(A0,D0.w),D1
		move.b	D1,vduvar_MODE_SIZE
		move.b	mostbl_VDU_hwscroll_offb2-mostbl_VDU_mode_colours_m1(A0,D1.w),D0
		bsr	mos_poke_SYSVIA_orb
		move.b	mostbl_VDU_hwscroll_offb1-mostbl_VDU_mode_colours_m1(A0,D1.w),D0
		bsr	mos_poke_SYSVIA_orb
		move.b	mostbl_VDU_screensize_h-mostbl_VDU_mode_colours_m1(A0,D1.w),vduvar_SCREEN_SIZE_HIGH
		move.b	mostbl_VDU_screebot_h-mostbl_VDU_mode_colours_m1(A0,D1.w),vduvar_SCREEN_BOTTOM_HIGH
		asl.b	#1,D1
		lea.l	tbl68_size_bytes_pre_row,A1
		move.w	(A1,D1.w),vduvar_BYTES_PER_ROW
		andi.b	#$43,zp_vdu_status
		move.b	vduvar_MODE,D0
		move.b	mostbl_VDU_VIDPROC_CTL_by_mode-mostbl_VDU_mode_colours_m1(A0,D0.w),D0
		bsr	mos_VIDPROC_set_CTL		

		move.w	SR,-(SP)			; save interrupts
		ori	#$0700,SR			; disable interrupts
		clr.w	D2
		move.b	vduvar_MODE_SIZE,D2
		mulu.w	#12,D2
		lea	12+mostbl_VDU_6845_mode_012-mostbl_VDU_mode_colours_m1(A0,D2.w),A0
		moveq	#11,D1
mos_send6845lp					; LCBB0
		move.b	-(A0),D0
		bsr	mos_set_6845_regD1toD0
		dbf	D1,mos_send6845lp

		move.w	(SP)+,SR			; interrupts back

		bsr	mos_VDU_20			; default logical colours
		bsr	mos_VDU_26			; default windows

LCBC1_clear_whole_screen
		move.l	D4,-(SP)
		moveq	#-1,D0				; force bank to FFFF
		move.b	vduvar_SCREEN_BOTTOM_HIGH,D0
		asl.w	#8,D0
		move.w	D0,vduvar_6845_SCREEN_START
		move.l	D0,A0
		move.l	D0,-(SP)
		bsr	mos_set_cursor_X
		moveq	#$0C,D1
		bsr	mos_set_6845_regD1toD0_16	;	CBD1
		clr.w	D0
		move.b	vduvar_MODE_SIZE,D0		;	CBD7
		lea	(mostbl_VDU_screensize_h,PC),A1
		move.b  (A1,D0.w),D0
		asl.w	#8,D0
		move.l	(SP)+,A0
		adda.w	D0,A0				; point at end of screen and clear down
		lsr.w	#4,D0				; SZ*256/16
		subq.w	#1,D0
		clr.b	sysvar_SCREENLINES_SINCE_PAGE	;	CBE7
		clr.b	vduvar_TXT_CUR_X		;	CBEA
		clr.b	vduvar_TXT_CUR_Y		;	CBED
		move.b	vduvar_TXT_BACK,D1		; make regs D1-D4 contain background colour in all bytes
		asl.w	#8,D1
		move.b	vduvar_TXT_BACK,D1
		move.w	D1,D2
		swap	D1
		move.w	D2,D1
		move.l  D1,D2
		move.l  D1,D3
		move.l  D1,D4
.lp		movem.l	D1-D4,-(A0)
		dbf	D0,.lp
		move.l	(SP)+,D4
		rts


;; ----------------------------------------------------------------------------
;; subtract bytes per line from X/A
; note new API, address in D instead of X/A and carry flag is opposite sense
x_subtract_bytes_per_line_from_D
		sub.w	vduvar_BYTES_PER_ROW,D0
		move.w	D1,-(SP)
		move.b	vduvar_SCREEN_BOTTOM_HIGH,D1
		asl.w	#8,D1
		cmp.w	D1,D0
		move.w	(SP)+,D1
LCD06		rts					;	CD06


;; ----------------------------------------------------------------------------
;; :move text cursor to next line (direction up/down depends on CC_C)
x_move_text_cursor_to_next_line
		btst	#VDU_STATUS_B1_SCROLLOCK,zp_vdu_status
		bne	LCD47				; scrolling disabled
		btst	#VDU_STATUS_B6_CURSORED,zp_vdu_status
		beq	LCD65rts			; curor editing
LCD47		move.b	vduvar_TXT_WINDOW_BOTTOM,D1	; if carry set on entry get TOP else get BOTTOM
		bcc	LCD4F				
		move.b	vduvar_TXT_WINDOW_TOP,D1		
LCD4F		btst	#VDU_STATUS_B6_CURSORED,zp_vdu_status
		bne	LCD59				; if cursor editing
		move.b	D1,vduvar_TXT_CUR_Y		
		lea	4(SP),SP			; skip return and setup address and cursor
		bra	x_setup_displayaddress_and_cursor_position
;; ----------------------------------------------------------------------------
LCD59		move.w	SR,-(SP)			;	CD59
		cmp.b	vduvar_TEXT_IN_CUR_Y,D1		;	CD5A
		bne	.s1				;	CD5D
		rtr
.s1		move.w	(SP)+,CCR			;	CD5F
		bcc	LCD66				;	CD60
		subq.b	#1,vduvar_TEXT_IN_CUR_Y		;	CD62
LCD65rts
		rts
;; ----------------------------------------------------------------------------
LCD66		addq.b	#1,vduvar_TEXT_IN_CUR_Y		;	CD66
		rts					;	CD69

GetTopScanLineAddr
		lea.l	zp_vdu_top_scanline,A0

;; ----------------------------------------------------------------------------
;; set up write cursor
x_setup_write_cursor
		move.w	SR,-(SP)
		movem.l D0/D1/A0,-(SP)
		bsr	GetTopScanLineAddr
		move.b	vduvar_BYTES_PER_CHAR,D1
		subq	#1,D1
		bne	LCD8F				; it's not MO.7
		move.b	vduvar_GRA_WKSP+8,(A0)		; restore original MO.7 character?
x_cur_exit	movem.l	(SP)+,D0/D1/A0
		rtr
;; ----------------------------------------------------------------------------
x_setup_read_cursor	
		move.w	SR,-(SP)
		movem.l D0/D1/A0,-(SP)
		bsr	GetTopScanLineAddr
		move.b	vduvar_BYTES_PER_CHAR,D1
		subq	#1,D1					;
		bne	LCD8F					;if not mode 7
		move.b	(A0),vduvar_GRA_WKSP+8			;get cursor from top scan line
								;store it
		move.b	vduvar_MO7_CUR_CHAR,(A0)		;mode 7 write cursor character
								;store it at scan line
		bra	x_cur_exit				;and exit

;; ----------------------------------------------------------------------------
LCD8F		moveq	#-1,D0					;A=&FF =cursor
		cmp.b	#$1F,D1					;except in mode 2 (Y=&1F)
		bne	x_produce_white_block_write_cursor	;if not CD97
		moveq	#$3F,D0					;load cursor byte mask
;; produce white block write cursor
x_produce_white_block_write_cursor		
.s1		eor.b	D0,(A0)+			;	CD99
		dbf	D1,.s1				;	CDA0
		bra	x_cur_exit

x_soft_scroll1line	
		bsr	x_exchange_TXTCUR_wksp_doublertsifwindowempty		; also saves height in wksp+4
		move.b	vduvar_TXT_WINDOW_BOTTOM,vduvar_TXT_CUR_Y		;bottom margin
										;current text line
		bsr	x_set_up_displayaddress					;set up display address
LCDB0		bsr	x_subtract_bytes_per_line_from_D			;subtract bytes per character row from this
		bhs	LCDB8							;wraparound if necessary
		bsr	x68_add_screen_size_d0					;screen RAM size hi byte
LCDB8		move.w	D0,zp_vdu_wksp						;store D
		bcs	LCDC6							;if C set there was no wraparound so CDC6
LCDC0		bsr	x_copy_text_line_window_LCE73				;copy line to new position with no address wrap around
		bra	LCDCE							;
;; ----------------------------------------------------------------------------
LCDC6		bsr	x_subtract_bytes_per_line_from_D			; subtract bytes per character row from X/A
		blo	LCDC0							; if a result is outside screen RAM CDC0
		bsr	x_copy_text_line_window_LCE38				; perform a copy
LCDCE		move.w	zp_vdu_wksp,zp_vdu_top_scanline				; store read pointer at write pointer
		dbf	D2,LCDB0

x_exchange_TXT_CUR_with_BITMAP_READ						; LCDDA
		lea.l	vduvar_TEMP_8,A0
		lea.l	vduvar_TXT_CUR_X,A1
x_exchange_2atY_with_2atX							; LCDDE
		moveq	#$02-1,D1						;	CDDE TODO: this is a straigh 16 bit copy do something better?
		bra	x_exchange_B_atY_with_B_atX_68API			;	CDE0
x_exg4atGRACURINTwithGRACURINTOLD						; LCDE2
		lea.l	vduvar_GRA_CUR_INT,A0					;	CDE2
x_exg4atGRACURINTOLDwithX							; LCDE4
		lea.l	vduvar_GRA_CUR_INT_OLD,A1				;	CDE4
x_exchange_4atY_with_4atX
		moveq	#$04-1,D1						;	CDE6
;; exchange (300/300+A)+Y with (300/300+A)+X
; 68k APU change D1 contains n-1
x_exchange_B_atY_with_B_atX_68API						; LCDE8
LCDEA		move.b	(A0),D0
		move.b	(A1),(A0)+
		move.b	D0,(A1)+
		dbf	D1,LCDEA						;	CDFC
		rts								;	CDFE

;; ----------------------------------------------------------------------------
;; execute upward scroll;  
x_execute_upward_scroll								; LCDFF
		bsr	x_exchange_TXTCUR_wksp_doublertsifwindowempty		; exchange line and column cursors with workspace copies
		move.b	vduvar_TXT_WINDOW_TOP,vduvar_TXT_CUR_Y			; top of text window
										; current text line
		bsr	x_set_up_displayaddress					; set up display address							
LCE0B		add.w	vduvar_BYTES_PER_ROW,D0
		bpl	LCE14							;	CE0E
		bsr	x68_sub_screen_size_d0					;	CE11
LCE14		move.w	D0,zp_vdu_wksp						;	CE16
		move	SR,-(SP)
		lsr	#8,D0
		move.b	D0,zp_vdu_wksp+2					;	CE18
		move	(SP)+,CCR
		bhs	LCE22							;	CE1A
LCE1C:		bsr	x_copy_text_line_window_LCE73				;	CE1C
		bra	LCE2A							;	CE1F
;; ----------------------------------------------------------------------------
LCE22		add.w	vduvar_BYTES_PER_ROW,D0					;add bytes per char. row
		bmi	LCE1C							;if outside screen RAM CE1C
		bsr	x_copy_text_line_window_LCE38				;perform a copy
LCE2A:		move.w	zp_vdu_wksp,zp_vdu_top_scanline				;
		subq.b	#1,zp_vdu_wksp+4					;decrement window height
		bne	LCE0B							;CE0B if not 0
		beq	x_exchange_TXT_CUR_with_BITMAP_READ			;exchange text column/linelse CDDA
;; copy routines
x_copy_text_line_window_LCE38
		move.w	D1,-(SP)						; TODO: eliminate?

		LDADDRSYS16 zp_vdu_wksp, D1, A1
		LDADDRSYS16 zp_vdu_top_scanline, D1, A0

		move.w	vduvar_TXT_WINDOW_WIDTH_BYTES,D1
		subq.w	#1,D1

.s1		move.b	(A1)+,(A0)+
		dbf	D1,.s1
		move.w	(SP)+,D1
		rts
							;	CE5A
;; ----------------------------------------------------------------------------
x_exchange_TXTCUR_wksp_doublertsifwindowempty					; LCE5B
		bsr	x_exchange_TXT_CUR_with_BITMAP_READ			;
		move.b	vduvar_TXT_WINDOW_BOTTOM,D0				;	CE5F
		sub.b	vduvar_TXT_WINDOW_TOP,D0				;	CE62
		move.b	D0,zp_vdu_wksp+4					;	CE65
		bne	x_cursor_to_window_left					;	CE67
		lea	4(SP),SP						; - skip return
		bra	x_exchange_TXT_CUR_with_BITMAP_READ	; if no text window pull return address, put back cursor and exit parent subroutine
;; ----------------------------------------------------------------------------
x_cursor_to_window_left	
		move.b	vduvar_TXT_WINDOW_LEFT,D0
		bra	LCEE3_sta_TXT_CUR_X_setC_rts

x_copy_text_line_window_LCE73
;x_copy_text_line_window_LCE73							; LCE73
		move.b	zp_vdu_wksp+1,-(SP)		; save low byte of source pointer

		LDADDRSYS16 zp_vdu_wksp, D1, A1		; set up pointers from 16 bit vars
		LDADDRSYS16 zp_vdu_top_scanline, D1, A0

		clr.w	D1
		move.b	vduvar_TXT_WINDOW_RIGHT,D1	; TODO: check we can corrupt D1 here!
		sub.b	vduvar_TXT_WINDOW_LEFT,D1	; number of chars to copy -1		
LCE7F:		clr.w	D2
		move.b	vduvar_BYTES_PER_CHAR,D2	; TODO: check we can corrupt D2 here!
		subq.b	#1,D2				;	CE82
LCE83:		move.b	(A1)+,(A0)+			;	CE83
		dbf	D2,LCE83			;	CE88

		move.w	A1,D0
		bpl	.s1
		move.b	vduvar_SCREEN_SIZE_HIGH,D0	; gah! sort this out!
		asl	#8,D0
		suba.w	D0,A1
.s1		move.w	A0,D0
		bpl	.s2
		move.b	vduvar_SCREEN_SIZE_HIGH,D0
		asl	#8,D0
		suba.w	D0,A0
.s2
		dbf	D1,LCE7F			; outer loop

		move.w	A0,zp_vdu_wksp
		move.w	A1,zp_vdu_top_scanline

		move.b	zp_vdu_wksp+1,-(SP)		; save low byte of source pointer
		rts					;	CEAB



x_clear_a_line
		move.b	vduvar_TXT_CUR_X,-(SP)		; save text cursor		
		bsr	x_cursor_to_window_left
		bsr	x_set_up_displayaddress
		move.b	vduvar_TXT_WINDOW_RIGHT,D2
		sub.b	vduvar_TXT_WINDOW_LEFT,D2

		LDADDRSYS16 zp_vdu_top_scanline, D3, A0

		move.b	vduvar_TXT_BACK,D3
		asl.w	#8,D3
		move.b	vduvar_TXT_BACK,D3
		move.w	D3,D1
		swap	D3
		move.w	D1,D3
LCEBF		clr.w	D1
		move.b	vduvar_BYTES_PER_CHAR,D1
		subq	#1,D1
		beq	x_clear_a_line_m07
		lsr.w	#3,D1
LCEC5		move.l	D3,(A0)+
		move.l	D3,(A0)+
		dbf	D1,LCEC5
x_clear_a_line_m07_2
		move.w	A0,D0
		bpl	LCEDA
		move.b	vduvar_SCREEN_SIZE_HIGH,D0
		asl	#8,D0
		suba	D0,A0
LCEDA		dbf	D2,LCEBF
		move.w	A0,zp_vdu_top_scanline
		move.b	(SP)+,D0
LCEE3_sta_TXT_CUR_X_setC_rts	
		move.b	D0,vduvar_TXT_CUR_X
LCEE6_setC_rts
		SEC
		rts
x_clear_a_line_m07
		move.b	D3,(A0)+
		bra	x_clear_a_line_m07_2

;; ----------------------------------------------------------------------------
x_check_text_cursor_in_window_setup_display_addr
		move.b	vduvar_TXT_CUR_X,D1
		cmp.b	vduvar_TXT_WINDOW_LEFT,D1
		bmi	LCEE6_setC_rts
		cmp.b	vduvar_TXT_WINDOW_RIGHT,D1
		bhi	LCEE6_setC_rts
LCEF7		move.b	vduvar_TXT_CUR_Y,D1
		cmp.b	vduvar_TXT_WINDOW_TOP,D1
		bmi	LCEE6_setC_rts
		cmp.b	vduvar_TXT_WINDOW_BOTTOM,D1
		bhi	LCEE6_setC_rts

; NOTE drops through!

;; set up displayaddressess
; 
; Mode 0: (0319)*640+(0318)* 8 		0
; Mode 1: (0319)*640+(0318)*16 		0
; Mode 2: (0319)*640+(0318)*32 		0
; Mode 3: (0319)*640+(0318)* 8 		1
; Mode 4: (0319)*320+(0318)* 8 		2
; Mode 5: (0319)*320+(0318)*16 		2
; Mode 6: (0319)*320+(0318)* 8 		3
; Mode 7: (0319)* 40+(0318)  		4
 ;this gives a displacement relative to the screen RAM start address
 ;which is added to the calculated number and stored in in 34A/B
 ;if the result is less than &8000, the top of screen RAM it is copied into X/A
 ;and D8/9.  
 ;if the result is greater than &7FFF the hi byte of screen RAM size is
 ;subtracted to wraparound the screen. X/A, D8/9 are then set from this

tbl68_size_bytes_pre_row
		dc.w	640,640,320,320,40

x_set_up_displayaddress
		clr.w	D0
		move.b	vduvar_TXT_CUR_Y,D0
		clr.w	D1
		move.b	vduvar_MODE_SIZE,D1
		asl.b	#1,D1
		move.w	tbl68_size_bytes_pre_row(PC,D1),D1
		mulu	D0,D1
		add.w	vduvar_6845_SCREEN_START,D1
		move.w	D1,zp_vdu_top_scanline
		move.b	vduvar_BYTES_PER_CHAR,D0
		clr.w	D1
		move.b	vduvar_TXT_CUR_X,D1
		mulu	D1,D0
		add.w	zp_vdu_top_scanline,D0
		move.w	D0,vduvar_6845_CURSOR_ADDR
		bpl	.s1
		bsr	x68_sub_screen_size_d0
.s1		move.w	D0,zp_vdu_top_scanline
		rts

; 68API - changed to expect A1 register to contain pointer to character bitmap?
x_vdu5_render_char			; foreground graphics colour
		move.l	vduvar_GRA_FORE,D0		; foreground graphics plot mode (GCOL n)
		move.l	vduvar_GRA_PLOT_FORE,D1		; 
x_plot_char_gra_mode					; 
		bsr	x_set_gra_masks_newAPI		; set graphics byte mask in &D4/5
		move.l	vduvar_GRA_CUR_INT,vduvar_TEMP_8; copy (324/7) graphics cursor to workspace (328/B)
		moveq	#7,D0				; row counter
LCF6B:		move.b	(A1)+,D0			; get pattern byte
		beq	LCF86				; if A=0 CF86 to skip plotting row		
LCF75:		bpl	LCF7A				; and if top bit set CF7A
		bsr	LD0E3_API68			; else display a pixel -- new API, preserve D0,A0
LCF7A:		addq.w	#1,vduvar_GRA_CUR_INT		; current horizontal graphics cursor	CF7D
LCF82:		asl	#1,D0				; shift bit map left
		bne	LCF75				; keep plotting if anything left
LCF86:		move.w  vduvar_TEMP_8,vduvar_GRA_CUR_INT; restore coords to start of current row
		subq.w	#1,vduvar_GRA_CUR_INT+2		; move down a line
		dbf	D0,LCF6B			; loop lines
		move.l  vduvar_TEMP_8,vduvar_GRA_CUR_INT; restore graphics cursor
		rts

;; ----------------------------------------------------------------------------
;; home graphics cursor
x_home_graphics_cursor
		move.w	vduvar_GRA_WINDOW_TOP,vduvar_GRA_CUR_INT + 2
;; set graphics cursor to left hand column
x_set_graphics_cursor_to_left_hand_column
		move.w	vduvar_GRA_WINDOW_LEFT,vduvar_GRA_CUR_INT
		bra	x_calculate_external_coordinates_from_internal_coordinates

;; ----------------------------------------------------------------------------
render_char
		tst.b	vduvar_COL_COUNT_MINUS1
		beq	x_convert_teletext_characters
		bsr	x_calc_pattern_addr_for_given_char_API68
;; API68 enter with character pointer in A1 register
LCFBF_renderchar2
		btst	#VDU_STATUS_B5_VDU5,zp_vdu_status			
		bne	x_vdu5_render_char
render_logo2

		LDADDRSYS16 zp_vdu_top_scanline,D0, A0

		moveq	#7,D3
		move.b	zp_vdu_txtcolourOR,D0
		move.b	zp_vdu_txtcolourEOR,D1

		cmp.b	#3,vduvar_COL_COUNT_MINUS1		;	CFBF
		beq	render_char_4colour		;	CFCC
		bhi	render_char_16colour		;	CFCE

		; get colour eor/or masks into D0, D1 replicated to 32 bit width
		asl.w	#8,D0
		move.b	zp_vdu_txtcolourOR,D0
		move.w	D0,D2
		swap	D0
		move.w	D2,D0

		asl.w	#8,D1
		move.b	zp_vdu_txtcolourEOR,D1
		move.w	D1,D2
		swap	D1
		move.w	D2,D1

		move.l	(A1)+,D2
		or.l	D0,D2
		eor.l	D1,D2
		move.l	D2,(A0)+

		move.l	(A1)+,D2
		or.l	D0,D2
		eor.l	D1,D2
		move.l	D2,(A0)+
		rts					;	CFDB
render_logox4
		bsr	render_logox2
render_logox2
		bsr	render_logo
render_logo
		move.l	A1,-(SP)
		bsr	render_logo2
		bsr	mos_VDU_9
		move.l	(SP)+,A1
		lea.l	8(A1),A1
		rts
;; ----------------------------------------------------------------------------
;; convert teletext characters; mode 7 
x_convert_teletext_characters
		moveq	#$02,D1
		lea.l	mostbl_TTX_CHAR_CONV,A0
LCFDE		cmp.b	(A0,D1),D0
		beq	LCFE9				;	CFE1
		dbf	D1,LCFDE			;	CFE4		
LCFE6		LDADDRSYS16 zp_vdu_top_scanline,D1,A0
		move.b	D0,(A0)
		rts					;	CFE8
LCFE9		move.b	1(A0,D1),D0
		bra	LCFE6

;; four colour modes
render_char_4colour
		move.l	A2,-(SP)
		; TODO check to see if table look up or calculate for masks is quickest
		lea.l	mostbl_byte_mask_4col,A2
		clr.w	D2
.l1		move.b	(A1,D3),D2
		lsr.b	#4,D2				; get bottom half of font bitmap row
		move.b	(A2,D2),D2			; convert to mo.1 bitmask		
		or.b	D0,D2				
		eor.b	D1,D2				; apply colour
		move.b	D2,(A0,D3)			; store in screen

		move.b	(A1,D3),D2
		and.b	#$0F,D2				; get next 4 pixels
		move.b	(A2,D2),D2			; convert to mo.1 bitmask
		or.b	D0,D2				
		eor.b	D1,D2				; apply colour
		move.b	D2,8(A0,D3)			; store in screen
		dbf	D3,.l1
		move.l	(SP)+,A2
LD017rts	rts

;; ----------------------------------------------------------------------------
render_char_16colour
		move.w	D4,-(SP)
		move.w	D5,-(SP)
		clr.w	D5
		lea.l	mostbl_byte_mask_16col,A2
rc16csk1	move.w	#3,D4				; set bit above bitmask for loop counter
		move.b	(A1,D3),D2			; get bitmask	
LD023		rol.b	#2,D2
		move.b	D2,D5				; save
		and.b	#$03,D5
		move.b	(A2,D5),D5
		or.b	D0,D5
		eor.b	D1,D5
		move.b	D5,(A0,D3)
		addq.b	#$08,D3
		dbf	D4,LD023
LD018		sub.b	#$21,D3
		bpl	rc16csk1			;	D01B
		move.w	(SP)+,D5
		move.w  (SP)+,D4
		rts

;API68 - returns address in A1
x_calc_pattern_addr_for_given_char_API68 
		movem.l	D0,-(SP)
		andi.w	#$00FF,D0
		asl	#3,D0
		move.b	D0,zp_vdu_wksp + 5			;a contains "char defs page offset"
		lsr.w	#8,D0					; get "page"
		btst	D0,vduvar_EXPLODE_FLAGS			;check if that bit is set in explosion bitmask
		bne	.x_cpa_sk_exploded			;if it is use that address
		asl	#8,D0
		lea.l	(mostbl_chardefs - $100)(PC),A1		;space is at 32 remember!
		lea.l	(A1,D0.w),A1
.s1		clr.w	D0					;clear top bits
		move.b	zp_vdu_wksp + 5,D0			;store whole address
		lea.l	(A1,D0.w),A1
		movem.l	(SP)+,D0
		rts
.x_cpa_sk_exploded
		lea.l	vduvar_EXPLODE_FLAGS,A1
		clr.l	D0				; TODO - exploded chars only in first 64k?
		move.b	(A1,D0),D0			;	get explode address from table
		asl.w	#8,D0
		move.l	D0,A0
		bra	.s1

;;;; ----------------------------------------------------------------------------
;;;; PLOT ROUTINES ENTER HERE; 
;;**************************************************************************
;;* on entry	
;;*	ADDRESS		PARAMETER	DESCRIPTION 
;;*	031F		1		plot type 	vduvar_VDU_Q_END - 5
;;*	0320/1		2,3		X coordinate	vduvar_VDU_Q_END - 4
;;*	0322/3		4,5		Y coordinate	vduvar_VDU_Q_END - 2
;;**************************************************************************
;;
;;
vduvar_VDU_Q_PLT_CODE	:= vduvar_VDU_Q_END - 5
vduvar_VDU_Q_PLT_X	:= vduvar_VDU_Q_END - 4
vduvar_VDU_Q_PLT_Y	:= vduvar_VDU_Q_END - 2
;;
;;x_PLOT_ROUTINES_ENTER_HERE
;;
;;		; swap coordinates endiannes
;;		ldy	#2
;;		jsr	db_endian_vdu_q_swap			; - if removed reinstate LDX below!
;;
;;;;	ldx	#vduvar_VDU_Q_PLT_X			; X=&20 - DB: already set up by endiannes swap
;;		jsr	x_set_up_and_adjust_coords_atX_2	; translate xoordinates
;;		lda	vduvar_VDU_Q_PLT_CODE			; get plot type
;;		cmpa	#$04					; if its 4
;;		lbeq	mos_PLOT_MOVE_absolute			; D0D9 move absolute
;;		ldb	#$05					; Y=5
;;		anda	#$03					; mask only bits 0 and 1
;;		beq	LD080					; if result is 0 then its a move (multiple of 8)
;;		lsra						; else move bit 0 int C
;;		bcs	x_graphics_colour_wanted		; if set then D078 graphics colour required
;;		decb						; Y=4
;;		bra	LD080					; logic inverse colour must be wanted
;;;; graphics colour wanted
;;x_graphics_colour_wanted
;;		jsr	mos_tax					; X=A if A=0 its a foreground colour 1 its background
;;		ldb	vduvar_GRA_PLOT_FORE,x			; get fore or background graphics PLOT mode
;;		lda	vduvar_GRA_FORE,x			; get fore or background graphics colour
;;;;;	tax						; X=A
;;LD080		jsr	x_set_gra_masks_newAPI		; set up colour masks in D4/5
;;		lda	vduvar_VDU_Q_PLT_CODE			; get plot type
;;		lbmi	x_VDU_EXTENSION				; if &80-&FF then D0AB type not implemented
;;		asla						; bit 7=bit 6
;;		bpl	x_analyse_first_parameter_in_0to63_range; if bit 6 is 0 then plot type is 0-63 so D0C6
;;		anda	#$F0					; else mask out lower nybble
;;		asla						; shift old bit 6 into C bit old 5 into bit 7
;;		beq	mos_PLOT_A_SINGLE_POINT			; if 0 then type 64-71 was called single point plot
;;							; goto D0D6
;;		eora	#$40					; if bit 6 NOT set type &80-&87 fill triangle
;;		lbeq	mos_PLOT_Fill_triangle_routine		; so D0A8
;;		pshs	A					; else push A
;;		jsr	x_copyplotcoordsexttoGRACURINT					; copy 0320/3 to 0324/7 setting XY in current graphics
;;							; coordinates
;;		puls	A					; get back A
;;		eora	#$60					; if BITS 6 and 5 NOT SET type 72-79 lateral fill 
;;		beq	LD0AE					; so D0AE
;;		cmpa	#$40					; if type 88-95 horizontal line blanking
;;		lbne	x_VDU_EXTENSION				; so D0AB
;;
;;		lda	#$02					; else A=2
;;		sta	zp_vdu_wksp+2				; store it
;;		jmp	plot_filhorz_back_qry			; and jump to D506 type not implemented ??? DB: I think is fill line in background colour!
;;;; ----------------------------------------------------------------------------
;;LD0AE		sta	zp_vdu_wksp+2				;	D0AE
;;		jmp	mos_LATERAL_FILL_ROUTINE		;	D0B0
;;;; ----------------------------------------------------------------------------


mostbl_GCOL_options_proc0
		dc.b	$00
; GCOL PLOT OPTIONS PROCESSING LOOK UP TABLE
mostbl_GCOL_options_proc
		dc.b	$FF,$00,$00,$FF,$FF,$FF,$FF,$00 ;	C41C

		align 	2

;; :set colour masks; graphics plot mode in B ; colour in A
* was plot mode in Y, colour in X
x_set_gra_masks_newAPI
		and.w	#$00FF,D1
		move.w	D2,-(SP)
		move.w	D0,-(SP)
		or.b	mostbl_GCOL_options_proc(PC,D1),D0
		move.b	mostbl_GCOL_options_proc+1(PC,D1),D2
		eor.b	D2,D0
		move.b	D0,zp_vdu_gracolourOR
		move.w	(SP)+,D0
		or.b	mostbl_GCOL_options_proc0(PC,D1),D0
		move.b	mostbl_GCOL_options_proc+4(PC,D1),D2
		eor.b	D2,D0
		move.b	D0,zp_vdu_gracolourEOR
		move.w	(SP)+,D2
		rts


;; ----------------------------------------------------------------------------
;; analyse first parameter in 0-63 range;  
x_analyse_first_parameter_in_0to63_range
		asl.b	D0				;shift left again
		bmi	x_VDU_EXTENSION			;if -ve options are in range 32-63 not implemented
		asl.b	#2,D0				;shift left twice more
		bpl	.s1				;if still +ve type is 0-7 or 16-23 so D0D0
		bsr	x_PLOT_grpixmask_ckbounds	;else display a point
.s1		bsr	x_mos_draw_line			;perform calculations
		bra	mos_PLOT_MOVE_absolute		;
;; ----------------------------------------------------------------------------
;; PLOT A SINGLE POINT
mos_PLOT_A_SINGLE_POINT							; LD0D6
		bsr	x_PLOT_grpixmask_ckbounds			; plot the point
mos_PLOT_MOVE_absolute							; LD0D9
		bsr	x_exg4atGRACURINTwithGRACURINTOLD		; save the old cursor
x_copyplotcoordsexttoGRACURINT						; LD0DC
		move.l	vduvar_VDU_Q_PLT_X,vduvar_GRA_CUR_INT		;	D0DC
		rts
;;x_copyplotcoordsexttoY							; LD0DE
;;		ldx	#						;	D0DE
;;		jmp	copy4fromXtoY					;	D0E0
;; ----------------------------------------------------------------------------
LD0E3_API68
		movem.l	D0/A0,-(SP)
		lea.l	vduvar_GRA_CUR_INT,A0				;	D0E3
		bsr	x__check_in_window_bounds_setup_screen_addr_atX	;	D0E5
		beq	x_mos_vdu_gra_drawpixels_in_grpixmask		;	D0E8
		rts							;	D0EA
;; ----------------------------------------------------------------------------
x_PLOT_grpixmask_ckbounds
		bsr	x__check_in_window_bounds_setup_screen_addr	;	D0EB
		bne	LD103rts					;	D0EE
x_mos_vdu_gra_drawpixels_in_grpixmask					; LD0F0
		move.b	vduvar_GRA_CUR_CELL_LINE,D1			;	D0F0
		;; new API check LD0F3 
x_mos_vdu_gra_drawpixels_in_grpixmask_cell_line_in_B 			; LD0F3 
		LDADDRSYS16 zp_vdu_gra_char_cell,D0,A0
		move.b	zp_vdu_grpixmask,D0				;	D0F3
		and.b	zp_vdu_gracolourOR,D0				;	D0F5
		or.b	(A0,D1),D0					;	D0F7
		move.b	zp_vdu_gracolourEOR,D2				;	D0FB
		and.b	zp_vdu_grpixmask,D2				;	D0FD
		eor.b	D2,D0						;	D0FF
		move.b	D0,(A0,D1)					;	D101
LD103rts
		rts							;	D103
;; ----------------------------------------------------------------------------

x_mos_vdu_gra_drawpixel_whole_byte
		move.w	D2,-(SP)					; check if needed
		move.w	D0,-(SP)					; check if needed
		LDADDRSYS16 zp_vdu_gra_char_cell,D0,A0
		move.b	(A0,D1),D0					; LD104
		or.b	zp_vdu_gracolourOR,D0
		move.b	zp_vdu_gracolourEOR,D2
		eor.b	D2,D0
		move.b	D0,(A0,D1)
		move.w	(SP)+,D0
		move.w	(SP)+,D2
		rts

;; ----------------------------------------------------------------------------
;; Check window limits;	
		; returns A = %0000TBRL where any bit means (T)op(B)ottom(R)ight(L)eft bounds
x_Check_window_limits
		lea.l	vduvar_GRA_CUR_INT,A0		;	D10D
x_Check_window_limits_atX
		clr.b	D0				;	D111
		lea.l	vduvar_GRA_WINDOW + 2,A1		;	D113 - bottom
		bsr	x_cursor_and_margins_check	;	D115	; check Y against BOTTOM/TOP
		asl.b	#2,D0				;	D118
		lea.l	-2(A0),A0
		lea.l	-2(A1),A1
		bsr	x_cursor_and_margins_check	;	D120
		lea.l	2(A0),A0
		rts					;	D127

;; ----------------------------------------------------------------------------
;; cursor and margins check;  
		; API: X is coords to check
		; return 1 if (2,X) < (0,Y)
		; return 2 if (2,X) >=(4,Y)
		; return is in zp_vdu_wksp which is 0 on entry
x_cursor_and_margins_check 			
		move.w	2(A0),D1				;	D128
		cmp.w	(A1),D1				;	D12B
		bmi	LD146				;	D134
		move.w	4(A1),D1			;	D136
		cmp.w	2(A0),D1			;	D139
		bpl	LD148				;	D142
		addq.b	#1,D0				;	D144
LD146		addq.b	#1,D0				;	D146
LD148		rts					;	D148

;; ----------------------------------------------------------------------------
;; set up and adjust positional data
x_set_up_and_adjust_coords_atX					; LD149
		moveq	#-1,D0					;A=&FF
		bne	x_sadjs1				;then &D150
x_set_up_and_adjust_coords_atX_2				; LD14D
		move.b	vduvar_VDU_Q_END - 5,D0			;get first parameter in plot;	D14D
x_sadjs1	move.b	D0,zp_vdu_wksp				;store in &DA
		lea.l	vduvar_GRA_WINDOW_BOTTOM,A1		;Y=302
		bsr	x_gra_coord_ext2int			;set up vertical coordinates/2
		asr.w	2(A0)					;/2 again to convert 1023 to 0-255 for internal use
								;this is why minimum vertical plot separation is 4
		lea.l	vduvar_GRA_WINDOW_LEFT,A1		;Y=0
		lea.l	-2(A0),A0				;X=X-2
		bsr	x_gra_coord_ext2int			;set up horiz. coordinates/2 this is OK for mode0,4
		cmp.b	#3,vduvar_PIXELS_PER_BYTE_MINUS1	;get number of pixels/byte (-1)
								;if Y=3 (modes 1 and 5)
		beq	.s1					;D16D
		bhs	.s2					;for modes 0 & 4 this is 7 so D170
		asr.w	2(A0)					;for other modes divide by 2 twice
.s1		asr.w	2(A0)					;divide by 2
.s2		tst.b	vduvar_MODE_SIZE			;get screen display type
		beq	.s3					;if not 0 (modes 3-7) divide by 2 again
		asr.w	2(A0)
.s3		rts						;and exit

;; ----------------------------------------------------------------------------
;; calculate external coordinates in internal format; 
; on entry 	X is usually &31E or &320  
;		Y is vduvar_GRA_WINDOW_BOTTOM or vduvar_GRA_WINDOW_LEFT for vert/horz calc  
x_gra_coord_ext2int					; LD176
		btst	#2,zp_vdu_wksp			;get &DA			; TODO eliminate this? use reg?
							;if bit 2=0
		beq	.s1				;then D186 to calculate relative coordinates
		move.w	2(A0),D0			;else get coordinate 
		bra	.s2				;	D184
.s1		move.w	2(A0),D0			;get coordinate 
		add.w	$10(A1),D0			;add cursor position
.s2		move.w	D0,$10(A1)			;save new cursor 
		add.w	$C(A1),D0			;add graphics origin
		move.w	D0,2(A0)
		asr.w	2(A0)				; DB: change to ASR - TODO: check
		rts

;; ----------------------------------------------------------------------------
;; calculate external coordinates from internal coordinates
x_calculate_external_coordinates_from_internal_coordinates ; TODO: speed up by loading X with address of coords instead of offset?
		move.l	vduvar_GRA_CUR_INT,vduvar_GRA_CUR_EXT

		move.w	vduvar_GRA_CUR_EXT+2,D0
		asl.w	#2,D0
		sub.w	vduvar_GRA_ORG_EXT+2,D0
		move.w	D0,vduvar_GRA_CUR_EXT+2

		moveq	#4,D1
		move.b	vduvar_PIXELS_PER_BYTE_MINUS1,D0
.l1		subq	#1,D1
		lsr.b	D0
		bne	.l1
		tst.b	vduvar_MODE_SIZE
		beq	LD1D5
		addq	#1,D1
LD1D5		move.w	vduvar_GRA_CUR_EXT,D0
		asl.w	D1,D0
		sub.w	vduvar_GRA_ORG_EXT,D0
		move.w	D0,vduvar_GRA_CUR_EXT
		rts

;; ----------------------------------------------------------------------------
;; compare X and Y PLOT spans

vduvar_TEMP_draw_W		equ	vduvar_TEMP_8 + 0
vduvar_TEMP_draw_H		equ	vduvar_TEMP_8 + 2
vduvar_TEMP_draw_XY		equ	vduvar_TEMP_8 + 4
vduvar_TEMP_draw_Y		equ	vduvar_TEMP_8 + 6

zp_vdu_wksp_draw_flags		equ	zp_vdu_wksp + 1		; contains $80 if dotted line to be drawn, $40 if current point is out of bounds
zp_vdu_wksp_draw_loop_ctr	equ	zp_vdu_wksp + 2		; save X (counter?)
zp_vdu_wksp_draw_stop		equ	zp_vdu_wksp + 3		; pointer to end of line to be drawn (contains $20 or $24)
zp_vdu_wksp_draw_slope		equ	zp_vdu_wksp + 4		; either 0 or 2 depending on slop of line
zp_vdu_wksp_draw_start		equ	zp_vdu_wksp + 5		; pointer to start of line to be drawn (contains either $20 or $24)
zp_vdu_wksp_draw_sav		equ	zp_vdu_wksp + 6		; DB: new used to save single byte register. TODO: check for clash!
	; bits	purpose
	; 7	dotted line
	; 6	start point out of bounds
DRAWFLAGS_START_OOB	equ	$80			; note these are opposite way round to 6502
DRAWFLAGS_START_DOT	equ	$40


vduvar_GRA_WKSP_0_ENDMAJ	equ	vduvar_GRA_WKSP + 0
vduvar_GRA_WKSP_2_JMP		equ	vduvar_GRA_WKSP + 2	; code to draw pixels?
vduvar_GRA_WKSP_4_DOTORNOT	equ	vduvar_GRA_WKSP + 4	; when to draw a dot for dotted lines
vduvar_GRA_WKSP_5_ERRACC	equ	vduvar_GRA_WKSP + 5	; the error accumulator, starts with 1/2 the major
vduvar_GRA_WKSP_7_DELTA_MINOR	equ	vduvar_GRA_WKSP + 7	; the minor delta (mag of W or H which ever is less)
vduvar_GRA_WKSP_9_DELTA_MAJOR	equ	vduvar_GRA_WKSP + 9	; the minor delta (mag of W or H which ever is greater)

x_mos_draw_line						; LD1ED
		TODO "x_mos_draw_line"
;;9;;		
;;9;;		jsr	x_PLOTXYsubGRACURStoTEMP8	; get line width/height
;;9;;		lda	vduvar_TEMP_draw_H		; eor top bytes of height
;;9;;		eora	vduvar_TEMP_draw_W		; and width
;;9;;		bmi	1F				; if differing signs
;;9;;		ldd	vduvar_TEMP_draw_W		; compare width to height
;;9;;		subd	vduvar_TEMP_draw_H		; NOTE: swapped sense here for differing C flag behaviour TODO: check!
;;9;;		bra	2F				;
;;9;;; ---------------------------------------------------------------------------
;;9;;1		ldd	vduvar_TEMP_draw_W		; signs are different add width to
;;9;;		addd	vduvar_TEMP_draw_H		; height
;;9;;2		
;;9;;		; 	W	H	C
;;9;;		;	-	-	|W|>|H|
;;9;;		;	+	+	|W|<|H|
;;9;;		;	-	+	|W|<|H|
;;9;;		;	+	-	|W|>|H|
;;9;;
;;9;;		rora						
;;9;;		ldb	#$00					
;;9;;		eora	vduvar_TEMP_draw_H			
;;9;;
;;9;;		; 	W	H	C
;;9;;		;	-	-	|W|<|H|
;;9;;		;	+	+	|W|<|H|
;;9;;		;	-	+	|W|<|H|
;;9;;		;	+	-	|W|<|H|
;;9;;
;;9;;		bpl	1F		; branch if |W| > |H|			
;;9;;		ldb	#$02					
;;9;;
;;9;;		; at this point B = 0 if |W| < |H|
;;9;;
;;9;;
;;9;;1		stb	zp_vdu_wksp_draw_slope			;	D21E
;;9;;		ldx	#mostbl_drawline_major_routine
;;9;;		ldx	B,X
;;9;;		stx	vduvar_VDU_VEC_JMP			;	D229
;;9;;
;;9;;		; at this point the choice has been made whether to:
;;9;;		; move up every pixel (|H|>|W|) or 
;;9;;		; move right every pixel (|H|<|W|)
;;9;;
;;9;;		ldx	#vduvar_TEMP_8			; get sign of either X or Y
;;9;;		tst	B,X				; depending on B (Y if moving up, X if moving right)
;;9;;		bpl	1F				; test direction
;;9;;		ldx	#vduvar_GRA_CUR_INT		; start drawing from current cursor
;;9;;		bra	2F
;;9;;1		ldx	#vduvar_VDU_Q_PLT_X		; start from plot point and work back
;;9;;2		STX_B	zp_vdu_wksp_draw_start		; store the low byte of the start coords pointer
;;9;;		ldy	#vduvar_TEMP_draw_XY		; 
;;9;;		jsr	copy4fromXtoY			; copy starting coord to XY accumulator
;;9;;		ldb	zp_vdu_wksp_draw_start		; get the ending coordinate
;;9;;		eorb	#$04				; by eor'ing with 4
;;9;;		stb	zp_vdu_wksp_draw_stop		; and store the low byte of this
;;9;;		orb	zp_vdu_wksp_draw_slope		; select X or Y depending on slope 
;;9;;		ldx	#vduvars_start			; point at page 3
;;9;;		abx					; X points at ending X or Y depending on slope
;;9;;		jsr	copy2fromXto330			; store in vduvar_GRA_WKSP_0_ENDMAJ
;;9;;
;;9;;		lda	vduvar_VDU_Q_PLT_CODE			
;;9;;		anda	#$10				; dotted line
;;9;;		asla					; 
;;9;;		asla					; 
;;9;;		sta	zp_vdu_wksp_draw_flags		; store in flags as bit 7
;;9;;
;;9;;		ldx	#vduvar_TEMP_draw_XY		; get starting coordinate
;;9;;		jsr	x_Check_window_limits_atX	; check bounds
;;9;;		sta	zp_vdu_wksp_draw_loop_ctr	; store for later check of ending coords
;;9;;		beq	1F				; if eq then in bounds don't set flag
;;9;;
;;9;;	IF CPU_6309
;;9;;		oim	#DRAWFLAGS_START_OOB, zp_vdu_wksp_draw_flags	; flag start point is out of bounds
;;9;;	ELSE
;;9;;		rol	zp_vdu_wksp_draw_flags
;;9;;		SEC
;;9;;		ror	zp_vdu_wksp_draw_flags		
;;9;;	ENDIF
;;9;;
;;9;;1		ldb	zp_vdu_wksp_draw_stop		; LD263
;;9;;		ldx	#vduvars_start
;;9;;		abx
;;9;;		jsr	x_Check_window_limits_atX	; check to see if endpoint is OOB
;;9;;		bita	zp_vdu_wksp_draw_loop_ctr	; and with saved OOB flags from above
;;9;;		beq	1F				; not the same
;;9;;		rts					; if both start and stop out of bounds 
;;9;;							; _in the same extreme_ POH
;; ----------------------------------------------------------------------------
;;9;;1
;;9;;	IF BLITTER
;;9;;		ora	zp_vdu_wksp_draw_flags
;;9;;		sta	zp_vdu_wksp_draw_flags		; used int blitter test
;;9;;	ENDIF
;;9;;		ldb	zp_vdu_wksp_draw_slope		; LD26D
;;9;;		beq	1F				; depending on slope
;;9;;		lsra					; shift top bound flag into right bound flag
;;9;;		lsra					;
;;9;;1		anda	#$02				; check right bound (or top) flag
;;9;;		beq	x_drawline_majorend_notoob	; skip following if not oob
;;9;;		orb	#$04				; == 6 or 4 depending on slope
;;9;;		ldx	#vduvars_start
;;9;;		abx
;;9;;		jsr	copy2fromXto330			; copy right (or top) graphics window value into
;;9;;							; vduvar_GRA_WKSP_0_ENDMAJ, replacing requested coord
;;9;;x_drawline_majorend_notoob
;;9;;		jsr	x_drawline_init_bresenham	;	D27E
;;9;;
;;9;;	IF BLITTER
;;9;;
;;9;;		lda	sysvar_USERFLAG
;;9;;		coma
;;9;;		ora	zp_vdu_wksp_draw_flags
;;9;;		lbeq	x_drawline_blit
;;9;;	ENDIF
;;9;;
;;9;;
;;9;;
;;9;;		ldb	zp_vdu_wksp_draw_slope		;	D281
;;9;;		eorb	#$02				;	D283
;;9;;		stb	zp_vdu_wksp_draw_sav
;;9;;;;;	tax						;	D285
;;9;;;;;	tay						;	D286
;;9;;		lda	vduvar_TEMP_draw_W		; check for with width / height -ve
;;9;;		eora	vduvar_TEMP_draw_H		;	D28A
;;9;;		bpl	LD290				;	D28D
;;9;;		incb					;	D28F
;;9;;LD290		ldx	#mostbl_drawline_minor_routine
;;9;;		aslb
;;9;;		ldx	B,X
;;9;;		rorb
;;9;;		stx	vduvar_GRA_WKSP_2_JMP		;	D293
;;9;;		lda	#$7F				;	D29C
;;9;;		sta	vduvar_GRA_WKSP_4_DOTORNOT	;	D29E
;;9;;	IF BLITTER
;;9;;		lda	zp_vdu_wksp_draw_flags		; test and remove end OOB flags
;;9;;		anda	#$C0
;;9;;		sta	zp_vdu_wksp_draw_flags
;;9;;	ELSE
;;9;;		tsta
;;9;;	ENDIF
;;9;;		tfr	B,A
;;9;;		bmi	LD2CE				;	D2A3
;;9;;		ldx	#mostbl_VDU_mode_size+7
;;9;;		ldb	B,X				; 4, 0, 6 or 2 depending on B
;;9;;;	tax						;	D2A8
;;9;;		ldx	#vduvar_GRA_WINDOW_LEFT
;;9;;		ldd	B,X				; 	D2AA
;;9;;		LDY_B	zp_vdu_wksp_draw_sav
;;9;;		subd	vduvar_TEMP_draw_XY,Y
;;9;;;;;	sbc	vduvar_TEMP_8+4,y			;	D2AD
;;9;;;;;	sta	zp_vdu_wksp				;	D2B0
;;9;;;;;	lda	vduvar_GRA_WINDOW_LEFT+1,x		;	D2B2
;;9;;;;;	sbc	vduvar_TEMP_8+5,y			;	D2B5
;;9;;;;;	ldy	zp_vdu_wksp				;	D2B8
;;9;;;;;	tax						;	D2BA
;;9;;		bpl	LD2C0				;	D2BB
;;9;;		m_NEGD	;	D2BD
;;9;;LD2C0
;;9;;;;;	tax						;	D2C0
;;9;;;;;	iny						;	D2C1
;;9;;;;;	bne	LD2C5					;	D2C2
;;9;;;;;	inx						;	D2C4
;;9;;;LD2C5:	txa						;	D2C5
;;9;;;;;		addd	#1
;;9;;;;;
;;9;;;;;		tsta
;;9;;		incb
;;9;;		bne	LD2C5
;;9;;		inca
;;9;;LD2C5		tsta	; TODO REMOVE?
;;9;;	
;;9;;		beq	1F					;	D2C6
;;9;;		ldb	#$00					;	D2C8
;;9;;1		stb	zp_vdu_wksp_draw_start			;	D2CA
;;9;;		beq	LD2D7					;	D2CC

;;9;;LD2CE		
;;9;;;;;	txa						;	D2CE
;;9;;		lsra						;	D2CF
;;9;;		rora						;	D2D0
;;9;;		ora	#$02					;	D2D1
;;9;;		eora	zp_vdu_wksp_draw_slope			;	D2D3
;;9;;		sta	zp_vdu_wksp_draw_slope			;	D2D5
;;9;;LD2D7		ldx	#vduvar_TEMP_draw_XY			;	D2D7
;;9;;		jsr	x_setup_screen_addr_from_intcoords_atX	;	D2D9
;;9;;		ldx	zp_vdu_wksp_draw_loop_ctr
;;9;;		leax	-1,X
;;9;;		stx	zp_vdu_wksp_draw_loop_ctr
;;9;;x_drawline_loop						; LD2E3
;;9;;		lda	zp_vdu_wksp_draw_flags		; check flags
;;9;;		beq	x_drawline_plot_point		; no flags - plot this point
;;9;;		asla
;;9;;		bpl	x_drawline_notdotted		; if not $80 set then not dotted line
;;9;;		tst	vduvar_GRA_WKSP_4_DOTORNOT	;	D2E9
;;9;;		bpl	LD2F3				;	D2EC
;;9;;		dec	vduvar_GRA_WKSP_4_DOTORNOT	;	D2EE
;;9;;		bne	LD316				;	D2F1
;;9;;LD2F3		inc	vduvar_GRA_WKSP_4_DOTORNOT	;	D2F3
;;9;;		bcc	x_drawline_plot_point		; not expecting to go oob
;;9;;x_drawline_notdotted					; LD2F9	
;;9;;		ldx	#vduvar_TEMP_draw_XY			;	D2FB
;;9;;		jsr	x__check_in_window_bounds_setup_screen_addr_atX				;	D2FD
;;9;;;;;	ldx	zp_vdu_wksp_draw_loop_ctr			;	D300
;;9;;		tsta						;	D302
;;9;;		bne	LD316					;	D304
;;9;;
;;9;;x_drawline_plot_point					; LD306	
;;9;;
;;9;;		lda	zp_vdu_grpixmask			;	D306
;;9;;		anda	zp_vdu_gracolourOR			;	D308
;;9;;		ldb	vduvar_GRA_CUR_CELL_LINE
;;9;;		ldx	zp_vdu_gra_char_cell
;;9;;		abx
;;9;;		ora	,X
;;9;;		sta	zp_vdu_wksp			;	D30C
;;9;;		lda	zp_vdu_gracolourEOR		;	D30E
;;9;;		anda	zp_vdu_grpixmask		;	D310
;;9;;		eora	zp_vdu_wksp			;	D312
;;9;;		sta	,X
;;9;;		;;;	sta	(zp_vdu_gra_char_cell),y	;	D314
;;9;;LD316
;;9;;;;;	sec					;	D316
;;9;;		ldd	vduvar_GRA_WKSP_5_ERRACC		;	D317
;;9;;		subd	vduvar_GRA_WKSP_7_DELTA_MINOR		;	D31A
;;9;;		bcc	LD339				;	D326
;;9;;		addd	vduvar_GRA_WKSP_9_DELTA_MAJOR		;	D32D
;;9;;		SEC					;	D338
;;9;;LD339		std	vduvar_GRA_WKSP_5_ERRACC		;	D339
;;9;;		pshs	CC				;	D33C
;;9;;		bcc	LD348				;	D33D
;;9;;		jmp	[vduvar_GRA_WKSP_2_JMP]		;	D33F
;;9;;;; ----------------------------------------------------------------------------
;;9;;;; vertical scan module 1
;;9;;x_drawline_minor_up			; LD342
;;9;;		dec	vduvar_GRA_CUR_CELL_LINE	;	D342
;;9;;		bpl	LD348				;	D343
;;9;;		jsr	x_move_display_point_up_a_line	;	D345
;;9;;LD348		jmp	[vduvar_VDU_VEC_JMP]		; call major increment routine
;;9;;;; ----------------------------------------------------------------------------
;;9;;;; vertical scan module 2
;;9;;x_drawline_minor_down			; LD34B
;;9;;		inc	vduvar_GRA_CUR_CELL_LINE
;;9;;		ldb	vduvar_GRA_CUR_CELL_LINE	; increment cell line counter
;;9;;		cmpb	#$08				; if overflowed
;;9;;		bne	LD348				; add a line's worth to pointer
;;9;;		ldd	zp_vdu_gra_char_cell		;
;;9;;		addd	vduvar_BYTES_PER_ROW		;
;;9;;		bpl	LD363				;
;;9;;		suba	vduvar_SCREEN_SIZE_HIGH		; if we got here wrap screen
;;9;;LD363		clr	vduvar_GRA_CUR_CELL_LINE
;;9;;		std	zp_vdu_gra_char_cell		;
;;9;;		jmp	[vduvar_VDU_VEC_JMP]
;;9;;;; ----------------------------------------------------------------------------
;;9;;;; horizontal scan module 1
;;9;;x_drawline_minor_right			; LD36A
;;9;;		lsr	zp_vdu_grpixmask		;	D36A
;;9;;		bcc	LD348				;	D36C
;;9;;		jsr	x_move_display_move_right_to_next_cell				;	D36E
;;9;;		jmp	[vduvar_VDU_VEC_JMP]		;	D371
;;9;;;; ----------------------------------------------------------------------------
;;9;;;; horizontal scan module 2
;;9;;x_drawline_minor_left				; LD374
;;9;;		asl	zp_vdu_grpixmask		;	D374
;;9;;		bcc	LD348				;	D376
;;9;;		jsr	x_move_display_move_left_to_next_cell				;	D378
;;9;;		jmp	[vduvar_VDU_VEC_JMP]		;	D37B
;;9;;
;;9;;
;;9;;;; ----------------------------------------------------------------------------
;;9;;x_drawline_major_up				; LD37D
;;9;;		dec	vduvar_GRA_CUR_CELL_LINE	;	D37E
;;9;;		bpl	1F				;	D37F
;;9;;		jsr	x_move_display_point_up_a_line	;	D381
;;9;;		bra	1F				;	D384
;;9;;x_drawline_major_right				; LD386
;;9;;		lsr	zp_vdu_grpixmask		;	D386
;;9;;		bcc	1F				;	D388
;;9;;		jsr	x_move_display_move_right_to_next_cell				;	D38A
;;9;;1		puls	CC				;	D38D
;;9;;;;		ldx	zp_vdu_wksp_draw_loop_ctr
;;9;;;;		leax	1,X
;;9;;;;		stx	zp_vdu_wksp_draw_loop_ctr
;;9;;		inc	zp_vdu_wksp_draw_loop_ctr+1
;;9;;		bne	1F
;;9;;		inc	zp_vdu_wksp_draw_loop_ctr+0
;;9;;		beq	LD39Frts				;	D393
;;9;;1		tst	zp_vdu_wksp_draw_flags		;	D395
;;9;;		bmi	x_drawline_move_coords_for_check				;	D397
;;9;;		lbcc	x_drawline_loop				;	D399
;;9;;		dec	zp_vdu_wksp_draw_start			;	D39B
;;9;;		lbne	x_drawline_loop				;	D39D
;;9;;LD39Frts
;;9;;		rts					;	D39F
;;9;;
;;9;;;; ----------------------------------------------------------------------------
;;9;;; Still doing starting bounds check update the X/Y coords 
;;9;;x_drawline_move_coords_for_check			; LD3A0
;;9;;		lda	zp_vdu_wksp_draw_slope			;	D3A0
;;9;;		ldy	#vduvar_TEMP_draw_XY
;;9;;		anda	#$02				;	D3A4
;;9;;		bcc	LD3C2				; DB: swapped sense here
;;9;;
;;9;;		tst	zp_vdu_wksp_draw_slope		;	D3A9
;;9;;		bmi	LD3B7				;	D3AB
;;9;;		ldx	A,Y
;;9;;		leax	1,X
;;9;;		stx	A,Y
;;9;;;	inc	vduvar_TEMP_8+4,x		;	D3AD
;;9;;;	bne	LD3C2				;	D3B0
;;9;;;	inc	vduvar_TEMP_8+5,x		;	D3B2
;;9;;;	bcc	LD3C2				;	D3B5
;;9;;		bra	LD3C2
;;9;;LD3B7		
;;9;;		ldx	A,Y
;;9;;		leax	-1,X
;;9;;		stx	A,Y
;;9;;
;;9;;;;;	lda	vduvar_TEMP_8+4,x		;	D3B7
;;9;;;;;	bne	LD3BF				;	D3BA
;;9;;;;;	dec	vduvar_TEMP_8+5,x		;	D3BC
;;9;;;;;LD3BF:	dec	vduvar_TEMP_8+4,x	;	D3BF
;;9;;
;;9;;LD3C2		eora	#$02				;	D3C3
;;9;;		ldx	A,Y
;;9;;		leax	1,X
;;9;;		stx	A,Y
;;9;;;;;	inc	vduvar_TEMP_8+4,x		;	D3C6
;;9;;;;;	bne	LD3CE				;	D3C9
;;9;;;;;	inc	vduvar_TEMP_8+5,x		;	D3CB
;;9;;;;;LD3CE:	ldx	zp_vdu_wksp+2		;	D3CE
;;9;;		jmp	x_drawline_loop				;	D3D0
;;9;;;; ----------------------------------------------------------------------------
;;9;;;; move display point up a line
;;9;;x_move_display_point_up_a_line
;;9;;		ldd	zp_vdu_gra_char_cell
;;9;;		subd	vduvar_BYTES_PER_ROW
;;9;;		cmpa	vduvar_SCREEN_BOTTOM_HIGH
;;9;;		bhs	1F
;;9;;		adda	vduvar_SCREEN_SIZE_HIGH		; wrap!
;;9;;1		std	zp_vdu_gra_char_cell
;;9;;		ldb	#7
;;9;;		stb	vduvar_GRA_CUR_CELL_LINE
;;9;;		rts
;;9;;;; ----------------------------------------------------------------------------
;;9;;		;TODO: use index register instead?
;;9;;		; keep 8 bit ops, slightly quicker
;;9;;x_move_display_move_right_to_next_cell			; LD3ED
;;9;;		lda	vduvar_LEFTMOST_PIX_MASK	;	D3ED
;;9;;		sta	zp_vdu_grpixmask		;	D3F0
;;9;;		ldb	zp_vdu_gra_char_cell+1
;;9;;		addb	#8
;;9;;		stb	zp_vdu_gra_char_cell+1
;;9;;		bcc	1F
;;9;;		inc	zp_vdu_gra_char_cell
;;9;;1		rts					;	D3FC
;;9;;;; ----------------------------------------------------------------------------
;;9;;		; keep 8 bit ops, slightly quicker
;;9;;x_move_display_move_left_to_next_cell
;;9;;		lda	vduvar_RIGHTMOST_PIX_MASK	;	D3FD
;;9;;		sta	zp_vdu_grpixmask		;	D400
;;9;;		ldb	zp_vdu_gra_char_cell+1
;;9;;		subb	#8
;;9;;		stb	zp_vdu_gra_char_cell+1
;;9;;		bcc	1F
;;9;;		dec	zp_vdu_gra_char_cell+0
;;9;;1		rts
;;9;;;; ----------------------------------------------------------------------------
;;9;;;; :: coordinate subtraction
;;9;;x_PLOTXYsubGRACURStoTEMP8
;;9;;		ldy	#vduvar_TEMP_8
;;9;;		ldx	#vduvar_VDU_Q_PLT_X
x_coords_to_width_height			; LD411
		bsr	.s1
.s1		move.w	4(A0),D0
		sub.w	(A0)+,D0
		move.w	D0,(A1)+
		rts					;	D42B
;;9;;;; ----------------------------------------------------------------------------
;;9;;
;;9;;; caculate the initial error accumulator and deltas
;;9;;; on entry 	X = 306 or 304 depending on slope
;;9;;; 		Y = zp_vdu_wksp+2 (332)
;;9;;
;;9;;x_drawline_init_bresenham				; LD42C
;;9;;		lda	zp_vdu_wksp_draw_slope		; depending on slope
;;9;;		bne	LD437				;
;;9;;		ldx	#vduvar_TEMP_draw_W		;
;;9;;		ldy	#vduvar_TEMP_draw_H		;
;;9;;		jsr	x_exchange_2atY_with_2atX	; swap width / height if going up
;;9;;LD437		ldx	#vduvar_TEMP_draw_W		;
;;9;;		ldy	#vduvar_GRA_WKSP_7_DELTA_MINOR	;
;;9;;		jsr	copy4fromXtoY			; 
;;9;;		LDX_B	zp_vdu_wksp_draw_slope		;	D43F
;;9;;		ldd	vduvar_GRA_WKSP_0_ENDMAJ	; get major end point
;;9;;		subd	vduvar_TEMP_draw_XY,X		; subtract major start point
;;9;;		bmi	LD453				; get absolute value
;;9;;		m_NEGD					;	D450
;;9;;
;;9;;LD453		std	zp_vdu_wksp_draw_loop_ctr	
;;9;;		ldx	#vduvar_GRA_WKSP_5_ERRACC	;	D457
;;9;;LD459		jsr	x_drawline_init_get_delta	;	D459
;;9;;		lsra					;	D45C
;;9;;		rorb					;	D461
;;9;;		std	0,X				; store half the major delta as the initial error (middle of point)
;;9;;		leax	-2,X
;;9;;
;;9;;x_drawline_init_get_delta
;;9;;		ldd	4,X				; get the delta
;;9;;		bpl	1F				; if +ve skip
;;9;;		m_NEGD					; negate
;;9;;		std	4,X				; store the delta
;;9;;1		rts					; LD47B
;; ----------------------------------------------------------------------------
;;9;;copy8fromXtoY
;;9;;		ldb	#$08				; LD47C
;;9;;		bra	x_copy_B_bytes_from_XtoY
;;9;;copy2fromXto330					; LD480
;;9;;		ldy	#vduvar_GRA_WKSP
;;9;;copy2fromXtoY					; LD482
;;9;;		ldb	#$02				
;;9;;		bra	x_copy_B_bytes_from_XtoY
;;9;;copy4from324to328
;;9;;		ldy	#vduvar_TEMP_8		; LD486
;;9;;copy4fromGRA_CUR_INTtoY
;;9;;		ldx	#vduvar_GRA_CUR_INT		; LD488
;;9;;copy4fromXtoY
;;9;;		ldb	#$04				; LD48A
;;9;;x_copy_B_bytes_from_XtoY			; LDF8C
;;9;;		lda	,x+
;;9;;		sta	,y+
;;9;;		decb
;;9;;		bne	x_copy_B_bytes_from_XtoY
;;9;;		rts
;;9;;
;;9;;	IF CPU_6809
;;9;;
;; ----------------------------------------------------------------------------
;; negation routine
;;9;;x_negation_routine_newAPI
;;9;;		coma					; TODO CHECK!
;;9;;		comb
;;9;;		addd	#1
;;9;;		rts
;;9;;	ENDIF
;;9;;
;;9;;	IF BLITTER
;;9;;x_drawline_blit
;;9;;		ldx	#vduvar_TEMP_draw_XY
;;9;;		jsr 	x_setup_screen_addr_from_intcoords_atX
;;9;;
;;9;;
;;9;;		lda	zp_mos_jimdevsave
;;9;;		pshs	A
;;9;;		lda	#JIM_DEVNO_BLITTER
;;9;;		sta	zp_mos_jimdevsave
;;9;;		sta	fred_JIM_DEVNO
;;9;;		ldx	#jim_page_DMAC
;;9;;		stx	fred_JIM_PAGE_HI
;;9;;
;;9;;		; line drawing test
;;9;;		;============================
;;9;;		; set start point address
;;9;;		lda	#$FF
;;9;;		sta	jim_DMAC_ADDR_C
;;9;;		sta	jim_DMAC_ADDR_D
;;9;;		ldx	zp_vdu_gra_char_cell
;;9;;		ldb	vduvar_GRA_CUR_CELL_LINE
;;9;;		abx
;;9;;		stx	jim_DMAC_ADDR_C+1
;;9;;		stx	jim_DMAC_ADDR_D+1
;;9;;		ldx	vduvar_BYTES_PER_ROW
;;9;;		stx	jim_DMAC_STRIDE_C
;;9;;		stx	jim_DMAC_STRIDE_D
;;9;;
;;9;;		; set start point pixel mask and colour
;;9;;		lda	zp_vdu_gracolourOR
;;9;;		eora	zp_vdu_gracolourEOR
;;9;;		sta	jim_DMAC_DATA_B		
;;9;;		lda	zp_vdu_grpixmask				
;;9;;		sta	jim_DMAC_DATA_A
;;9;;		; set major length
;;9;;		ldd	zp_vdu_wksp_draw_loop_ctr
;;9;;		m_NEGD
;;9;;		std	jim_DMAC_WIDTH		; 16 bits!
;;9;;		; set slope
;;9;;		ldd	vduvar_GRA_WKSP_9_DELTA_MAJOR
;;9;;		std	jim_DMAC_ADDR_B+1		
;;9;;		ldd	vduvar_GRA_WKSP_5_ERRACC
;;9;;		std	jim_DMAC_ADDR_A+1		; initial error accumulator value
;;9;;		ldd	vduvar_GRA_WKSP_7_DELTA_MINOR
;;9;;		std	jim_DMAC_STRIDE_A
;;9;;
;;9;;		;set func gen to be plot B masked by A
;;9;;		lda	#$CA				; B masked by A
;;9;;		sta	jim_DMAC_FUNCGEN
;;9;;
;;9;;		; set bltcon 0
;;9;;		lda	#BLITCON_EXEC_C + BLITCON_EXEC_D
;;9;;		sta	jim_DMAC_BLITCON
;;9;;		; set bltcon 1 - right/down
;;9;;		ldb	zp_vdu_wksp_draw_slope
;;9;;		lda	vduvar_TEMP_draw_W		; check for with width / height -ve
;;9;;		eora	vduvar_TEMP_draw_H		;	D28A
;;9;;		bpl	1F				;	D28D
;;9;;		incb					;	D28F
;;9;;1		ldx	#mostbl_slope2bltcon		
;;9;;		lda	B,X
;;9;;		ora	#BLITCON_ACT_ACT + BLITCON_ACT_CELL + BLITCON_ACT_LINE
;;9;;		
;;9;;		sta	jim_DMAC_BLITCON
;;9;;
;;9;;		puls	A
;;9;;		sta	zp_mos_jimdevsave
;;9;;		sta	fred_JIM_DEVNO
;;9;;
;;9;;		rts
;;9;;
;;9;;mostbl_slope2bltcon
;;9;;		FCB	$20,$00,$10,$30
;;9;;
;;9;;	ENDIF


;	pha					;	D49B
;	tya					;	D49C
;	eor	#$FF				;	D49D
;	tay					;	D49F
;	pla					;	D4A0
;	eor	#$FF				;	D4A1
;	iny					;	D4A3
;	bne	LD4A9				;	D4A4
;	clc					;	D4A6
;	adc	#$01				;	D4A7
;LD4A9:	rts					;	D4A9
;; ----------------------------------------------------------------------------
;LD4AA:	jsr	x__check_in_window_bounds_setup_screen_addr;	D4AA
;	bne	LD4B7				;	D4AD
;	lda	(zp_vdu_gra_char_cell),y	;	D4AF
;	eor	vduvar_GRA_BACK			;	D4B1
;	sta	zp_vdu_wksp			;	D4B4
;	rts					;	D4B6
;; ----------------------------------------------------------------------------
;LD4B7:	pla					;	D4B7
;	pla					;	D4B8
;LD4B9:	inc	vduvar_GRA_CUR_INT+2		;	D4B9
;	jmp	LD545				;	D4BC
;; ----------------------------------------------------------------------------
;; LATERAL FILL ROUTINE
mos_LATERAL_FILL_ROUTINE
		TODO "mos_LATERAL_FILL_ROUTINE"
;	jsr	LD4AA				;	D4BF
;	and	zp_vdu_grpixmask		;	D4C2
;	bne	LD4B9				;	D4C4
;	ldx	#$00				;	D4C6
;	jsr	LD592				;	D4C8
;	beq	LD4FA				;	D4CB
;	ldy	vduvar_GRA_CUR_CELL_LINE	;	D4CD
;	asl	zp_vdu_grpixmask		;	D4D0
;	bcs	LD4D9				;	D4D2
;	jsr	LD574				;	D4D4
;	bcc	LD4FA				;	D4D7
;LD4D9:	jsr	x_move_display_move_left_to_next_cell				;	D4D9
;	lda	(zp_vdu_gra_char_cell),y	;	D4DC
;	eor	vduvar_GRA_BACK			;	D4DE
;	sta	zp_vdu_wksp			;	D4E1
;	bne	LD4F7				;	D4E3
;	sec					;	D4E5
;	txa					;	D4E6
;	adc	vduvar_PIXELS_PER_BYTE_MINUS1	;	D4E7
;	bcc	LD4F0				;	D4EA
;	inc	zp_vdu_wksp_draw_flags			;	D4EC
;	bpl	LD4F7				;	D4EE
;LD4F0:	tax					;	D4F0
;	jsr	x_mos_vdu_gra_drawpixel_whole_byte				;	D4F1
;	sec					;	D4F4
;	bcs	LD4D9				;	D4F5
;LD4F7:	jsr	LD574				;	D4F7
;LD4FA:	ldy	#$00				;	D4FA
;	jsr	LD5AC				;	D4FC
;	ldy	#$20				;	D4FF
;	ldx	#$24				;	D501
;	jsr	x_exchange_300_3Y_with_300_3X	;	D503
plot_filhorz_back_qry				; LD506
		TODO	"plot_filhorz_back_qry - plot fill back?"
;	jsr	LD4AA				;	D506
;	ldx	#$04				;	D509
;	jsr	LD592				;	D50B
;	txa					;	D50E
;	bne	LD513				;	D50F
;	dec	zp_vdu_wksp_draw_flags			;	D511
;LD513:	dex					;	D513
;LD514:	jsr	LD54B				;	D514
;	bcc	LD540				;	D517
;LD519:	jsr	x_move_display_move_right_to_next_cell				;	D519
;	lda	(zp_vdu_gra_char_cell),y	;	D51C
;	eor	vduvar_GRA_BACK			;	D51E
;	sta	zp_vdu_wksp			;	D521
;	lda	zp_vdu_wksp+2			;	D523
;	bne	LD514				;	D525
;	lda	zp_vdu_wksp			;	D527
;	bne	LD53D				;	D529
;	sec					;	D52B
;	txa					;	D52C
;	adc	vduvar_PIXELS_PER_BYTE_MINUS1	;	D52D
;	bcc	LD536				;	D530
;	inc	zp_vdu_wksp_draw_flags			;	D532
;	bpl	LD53D				;	D534
;LD536:	tax					;	D536
;	jsr	x_mos_vdu_gra_drawpixel_whole_byte				;	D537
;	sec					;	D53A
;	bcs	LD519				;	D53B
;LD53D:	jsr	LD54B				;	D53D
;LD540:	ldy	#$04				;	D540
;	jsr	LD5AC				;	D542
;LD545:	jsr	mos_PLOT_MOVE_absolute				;	D545
;	jmp	x_calculate_external_coordinates_from_internal_coordinates;	D548
;; ----------------------------------------------------------------------------
;LD54B:	lda	zp_vdu_grpixmask		;	D54B
;	pha					;	D54D
;	clc					;	D54E
;	bcc	LD560				;	D54F
;LD551:	pla					;	D551
;	inx					;	D552
;	bne	LD559				;	D553
;	inc	zp_vdu_wksp_draw_flags			;	D555
;	bpl	LD56F				;	D557
;LD559:	lsr	zp_vdu_grpixmask		;	D559
;	bcs	LD56F				;	D55B
;	ora	zp_vdu_grpixmask		;	D55D
;	pha					;	D55F
;LD560:	lda	zp_vdu_grpixmask		;	D560
;	bit	zp_vdu_wksp			;	D562
;	php					;	D564
;	pla					;	D565
;	eor	zp_vdu_wksp+2			;	D566
;	pha					;	D568
;	plp					;	D569
;	beq	LD551				;	D56A
;	pla					;	D56C
;	eor	zp_vdu_grpixmask		;	D56D
;LD56F:	sta	zp_vdu_grpixmask		;	D56F
;	jmp	x_mos_vdu_gra_drawpixels_in_grpixmask				;	D571
;; ----------------------------------------------------------------------------
;LD574:	lda	#$00				;	D574
;	clc					;	D576
;	bcc	LD583				;	D577
;LD579:	inx					;	D579
;	bne	LD580				;	D57A
;	inc	zp_vdu_wksp_draw_flags			;	D57C
;	bpl	LD56F				;	D57E
;LD580:	asl	a				;	D580
;	bcs	LD58E				;	D581
;LD583:	ora	zp_vdu_grpixmask		;	D583
;	bit	zp_vdu_wksp			;	D585
;	beq	LD579				;	D587
;	eor	zp_vdu_grpixmask		;	D589
;	lsr	a				;	D58B
;	bcc	LD56F				;	D58C
;LD58E:	ror	a				;	D58E
;	sec					;	D58F
;	bcs	LD56F				;	D590
;LD592:	lda	vduvar_GRA_WINDOW_LEFT,x	;	D592
;	sec					;	D595
;	sbc	vduvar_VDU_Q_END - 4			;	D596
;	tay					;	D599
;	lda	vduvar_GRA_WINDOW_LEFT+1,x	;	D59A
;	sbc	vduvar_VDU_Q_END - 3			;	D59D
;	bmi	LD5A5				;	D5A0
;	jsr	x_negation_routine		;	D5A2
;LD5A5:	sta	zp_vdu_wksp_draw_flags			;	D5A5
;	tya					;	D5A7
;	tax					;	D5A8
;	ora	zp_vdu_wksp_draw_flags			;	D5A9
;	rts					;	D5AB
;; ----------------------------------------------------------------------------
;LD5AC:	sty	zp_vdu_wksp			;	D5AC
;	txa					;	D5AE
;	tay					;	D5AF
;	lda	zp_vdu_wksp_draw_flags			;	D5B0
;	bmi	LD5B6				;	D5B2
;	lda	#$00				;	D5B4
;LD5B6:	ldx	zp_vdu_wksp			;	D5B6
;	bne	LD5BD				;	D5B8
;	jsr	x_negation_routine		;	D5BA
;LD5BD:	pha					;	D5BD
;	clc					;	D5BE
;	tya					;	D5BF
;	adc	vduvar_GRA_WINDOW_LEFT,x	;	D5C0
;	sta	vduvar_VDU_Q_END - 4			;	D5C3
;	pla					;	D5C6
;	adc	vduvar_GRA_WINDOW_LEFT+1,x	;	D5C7
;	sta	vduvar_VDU_Q_END - 3			;	D5CA
;	rts					;	D5CD
;; ----------------------------------------------------------------------------
;; OSWORD 13 read last two graphic cursor positions;  
;mos_OSWORD_13:
;	lda	#$03				;	D5CE
;	jsr	LD5D5				;	D5D0
;	lda	#$07				;	D5D3
;LD5D5:	pha					;	D5D5
;	jsr	x_exg4atGRACURINTwithGRACURINTOLD				;	D5D6
;	jsr	x_calculate_external_coordinates_from_internal_coordinates;	D5D9
;	ldx	#$03				;	D5DC
;	pla					;	D5DE
;	tay					;	D5DF
;LD5E0:	lda	vduvar_GRA_CUR_EXT,x		;	D5E0
;	sta	(zp_mos_OSBW_X),y		;	D5E3
;	dey					;	D5E5
;	dex					;	D5E6
;	bpl	LD5E0				;	D5E7
;	rts					;	D5E9
;; ----------------------------------------------------------------------------
;; PLOT Fill triangle routine
mos_PLOT_Fill_triangle_routine
		TODO "mos_PLOT_Fill_triangle_routine"
;	ldx	#$20				;	D5EA
;	ldy	#$3E				;	D5EC
;	jsr	copy8fromXtoY				;	D5EE
;	jsr	LD632				;	D5F1
;	ldx	#$14				;	D5F4
;	ldy	#$24				;	D5F6
;	jsr	LD636				;	D5F8
;	jsr	LD632				;	D5FB
;	ldx	#$20				;	D5FE
;	ldy	#$2A				;	D600
;	jsr	x_coords_to_width_height				;	D602
;	lda	vduvar_TEMP_8+3		;	D605
;	sta	vduvar_GRA_WKSP+2		;	D608
;	ldx	#$28				;	D60B
;	jsr	LD459				;	D60D
;	ldy	#$2E				;	D610
;	jsr	x_copyplotcoordsexttoY				;	D612
;	jsr	x_exg4atGRACURINTwithGRACURINTOLD				;	D615
;	clc					;	D618
;	jsr	LD658				;	D619
;	jsr	x_exg4atGRACURINTwithGRACURINTOLD				;	D61C
;	ldx	#$20				;	D61F
;	jsr	x_exchange_4atGRACUREXTOLDwithX				;	D621
;	sec					;	D624
;	jsr	LD658				;	D625
;	ldx	#$3E				;	D628
;	ldy	#$20				;	D62A
;	jsr	copy8fromXtoY				;	D62C
;	jmp	mos_PLOT_MOVE_absolute				;	D62F
;; ----------------------------------------------------------------------------
;LD632:	ldx	#$20				;	D632
;	ldy	#$14				;	D634
;LD636:	lda	vduvar_GRA_WINDOW_BOTTOM,x	;	D636
;	cmp	vduvar_GRA_WINDOW_BOTTOM,y	;	D639
;	lda	vduvar_GRA_WINDOW_BOTTOM+1,x	;	D63C
;	sbc	vduvar_GRA_WINDOW_BOTTOM+1,y	;	D63F
;	bmi	LD657				;	D642
;	jmp	x_exchange_300_3Y_with_300_3X	;	D644
;; ----------------------------------------------------------------------------
;; OSBYTE 134  Read cursor position
mos_OSBYTE_134
		clr.l	D1
		move.b	vduvar_TXT_CUR_X,D1		;	D647
		sub.b	vduvar_TXT_WINDOW_LEFT,D1	;	D64B
		clr.l	D2
		move.b	vduvar_TXT_CUR_Y,D2		;	D64F
		sub.b	vduvar_TXT_WINDOW_TOP,D2	;	D653
LD657		rts					;	D657

;; ----------------------------------------------------------------------------
;LD658:	php					;	D658
;	ldx	#$20				;	D659
;	ldy	#$35				;	D65B
;	jsr	x_coords_to_width_height				;	D65D
;	lda	vduvar_GRA_WKSP+6		;	D660
;	sta	$033D				;	D663
;	ldx	#$33				;	D666
;	jsr	LD459				;	D668
;	ldy	#$39				;	D66B
;	jsr	x_copyplotcoordsexttoY				;	D66D
;	sec					;	D670
;	lda	vduvar_VDU_Q_END - 2			;	D671
;	sbc	vduvar_GRA_CUR_INT+2		;	D674
;	sta	vduvar_VDU_Q_END - 9;	D677
;	lda	vduvar_VDU_Q_END - 1			;	D67A
;	sbc	vduvar_GRA_CUR_INT+3		;	D67D
;	sta	$031C				;	D680
;	ora	vduvar_VDU_Q_END - 9;	D683
;	beq	LD69F				;	D686
;LD688:	jsr	LD6A2				;	D688
;	ldx	#$33				;	D68B
;	jsr	LD774				;	D68D
;	ldx	#$28				;	D690
;	jsr	LD774				;	D692
;	inc	vduvar_VDU_Q_END - 9;	D695
;	bne	LD688				;	D698
;	inc	$031C				;	D69A
;	bne	LD688				;	D69D
;LD69F:	plp					;	D69F
;	bcc	LD657				;	D6A0

;LD6A2:	ldx	#$39				;	D6A2
;	ldy	#$2E				;	D6A4

*****************************************************
* OLD API X,Y contained PAGE 3 relative pointers to *
* start end of line to plot			    *
* now X,Y contain full pointers			    *
*****************************************************

x_vdu_clear_gra_line_newAPI				; 	LD6A6
		TODO	"x_vdu_clear_gra_line_newAPI"
;;9;;		stx	zp_vdu_wksp+4				;	check left < right, if not swap em
;;9;;		ldd	,X
;;9;;		cmpd	,Y
;;9;;		blo	1F
;;9;;		exg	X,Y
;;9;;		stx	zp_vdu_wksp+4				; note: now using 4,6 instead of 4,5
;;9;;1		sty	zp_vdu_wksp+6				; 
;;9;;		ldd	0,y					; right on stack, we're going to use it to count down...
;;9;;		pshs	D
;;9;;		ldx	zp_vdu_wksp+6				; check right bound
;;9;;		jsr	x_Check_window_limits_atX		;
;;9;;		beq	1F					;
;;9;;
;;9;;		cmpa	#$02					; check for bounds broken == right
;;9;;		bne	3F					; if it's any other bound we're off the screen, skip this line
;;9;;		ldd	vduvar_GRA_WINDOW_RIGHT			;
;;9;;		std	0,X					; reset right bound to right edge of window/screen 
;;9;;1		jsr	x_setup_screen_addr_from_intcoords_atX	; setup the screen address pointer
;;9;;		ldx	zp_vdu_wksp+4				; check left pointer bounds
;;9;;		jsr	x_Check_window_limits_atX		;
;;9;;		lsra						; shift right, Left broken into carry rest in A
;;9;;		bne	3F					; if anything other than left we're off the screen, skip line
;;9;;		bcc	1F					; if not C then left bound ok
;;9;;		ldx	#vduvar_GRA_WINDOW_LEFT			;
;;9;;1		ldd	[zp_vdu_wksp+6]				; subtract left coord (or window left if bounds broken) from right 
;;9;;		subd	,x					; to get width
;;9;;		std	zp_vdu_wksp+2				; store here
;;9;;		clra
;;9;;LD6FE		asla						; shift left one
;;9;;		ora	zp_vdu_grpixmask			; copy in another right most pixel to A
;;9;;		ldb	zp_vdu_wksp+3				; decrement width counter
;;9;;		bne	LD719					;
;;9;;		dec	zp_vdu_wksp+2				;
;;9;;		bpl	LD719					;
;;9;;		sta	zp_vdu_grpixmask			; we're at the left of the line, plot pixels in current pixel mask
;;9;;		jsr	x_mos_vdu_gra_drawpixels_in_grpixmask
;;9;;3		puls	D		
;;9;;		std	[zp_vdu_wksp+6]				; restore right bound
;;9;;		rts						; done
;; ----------------------------------------------------------------------------
;;9;;LD719		dec	zp_vdu_wksp+3				; decrement width counter
;;9;;		tsta						; see if we've filled up A with pixel mask bits
;;9;;		bpl	LD6FE					; if not try another pixel
;;9;;		sta	zp_vdu_grpixmask			; store the pixel mask
;;9;;		jsr	x_mos_vdu_gra_drawpixels_in_grpixmask 	; and plot
;;9;;		lda	zp_vdu_wksp+3				; get low byte of width counter
;;9;;		inca						; increment it
;;9;;		bne	LD72A					;
;;9;;		inc	zp_vdu_wksp+2				; and high byte if needed
;;9;;LD72A		pshs	A					; store updated low byte on stack
;;9;;		lsr	zp_vdu_wksp+2				; divide by width low by two
;;9;;		rora						; divide A by two
;;9;;		ldb	vduvar_PIXELS_PER_BYTE_MINUS1		; get pixels per byte
;;9;;		cmpb	#$03					; 
;;9;;		beq	LD73B					;
;;9;;		bcs	LD73E					;
;;9;;		lsr	zp_vdu_wksp+2				;
;;9;;		rora						;
;;9;;LD73B		lsr	zp_vdu_wksp+2				;
;;9;;		lsra						; 
;;9;;LD73E		ldb	vduvar_GRA_CUR_CELL_LINE		;
;;9;;		tsta						;
;;9;;		beq	LD753					;	D742
;;9;;LD744		subb	#$08					;	D746
;;9;;		bcc	LD74D					;	D749
;;9;;		dec	zp_vdu_gra_char_cell + 0		;	D74B
;;9;;LD74D		jsr	x_mos_vdu_gra_drawpixel_whole_byte
;;9;;		deca						;	D750
;;9;;		bne	LD744					;	D751
;;9;;
;;9;;
;;9;;LD753
;;9;;		puls	A				;	D753
;;9;;		anda	vduvar_PIXELS_PER_BYTE_MINUS1	;	D754
;;9;;		beq	3B				;	D757
;;9;;		pshs	B
;;9;;		clrb					;	D75A
;;9;;LD75C		aslb					;	D75C
;;9;;		orb	vduvar_RIGHTMOST_PIX_MASK	;	D75D
;;9;;		deca					;	D760
;;9;;		bne	LD75C				;	D761
;;9;;		stb	zp_vdu_grpixmask		;	D763
;;9;;		puls	B
;;9;;		subb	#$08				;	D767
;;9;;		bcc	LD76E				;	D76A
;;9;;		dec	zp_vdu_gra_char_cell		;	D76C
;;9;;LD76E		jsr	x_mos_vdu_gra_drawpixels_in_grpixmask_cell_line_in_B				;	D76E
;;9;;		jmp	3B				;	D771


;; ----------------------------------------------------------------------------
;; OSBYTE 135  Read character at text cursor position
mos_OSBYTE_135
;;9;;		TODO	"OSBYTE 135"
;;9;;		tst	vduvar_COL_COUNT_MINUS1			;	D7C2
;;9;;		bne	LD7DC					;	D7C5
;;9;;		lda	[zp_vdu_top_scanline]			;	D7C7
;;9;;		ldy	#$02					;	D7C9
;;9;;LD7CB		cmpa	mostbl_TTX_CHAR_CONV+1,y		;	D7CB
;;9;;		bne	LD7D4					;	D7CE
;;9;;		lda	mostbl_TTX_CHAR_CONV,y			;	D7D0
;;9;;		leay	-1,y					;	D7D3
;;9;;LD7D4		leay	-1,y					;	D7D4
;;9;;		bpl	LD7CB					;	D7D5
;;9;;mos_OSBYTE_135_YeqMODE_XeqArts
;;9;;		LDY_B	vduvar_MODE				;	D7D7
;;9;;mos_tax		m_tax
;;9;;		rts						;	D7DB
;;9;;;; ----------------------------------------------------------------------------
;;9;;LD7DC		jsr	x_set_up_pattern_copy		;set up copy of the pattern bytes at text cursor
;;9;;		lda	#$20				;X=&20
;;9;;		ldx	#vduvar_TEMP_8
;;9;;		sta	zp_vdu_wksp			;store current char
;;9;;		bra	1F
;;9;;mos_OSBYTE_135_lp1					; LD7E1
;;9;;;;;	txa						;A=&20
;;9;;;;;	pha						;Save it
;;9;;		lda	zp_vdu_wksp
;;9;;1		jsr	x_calc_pattern_addr_for_given_char	;get pattern address for code in A
;;9;;		ldy	zp_vdu_wksp + 4
;;9;;;;;	pla						;get back A
;;9;;;;;	tax						;and X
;;9;;LD7E8		ldb	#$07				;Y=7
;;9;;LD7EA		lda	B,X				;get byte in pattern copy
;;9;;		cmpa	B,Y				;check against pattern source
;;9;;		bne	LD7F9				;if not the same D7F9
;;9;;		decb					;else Y=Y-1
;;9;;		bpl	LD7EA				;and if +ve D7EA
;;9;;		lda	zp_vdu_wksp
;;9;;		cmpa	#$7F				;is X=&7F (delete)
;;9;;		bne	mos_OSBYTE_135_YeqMODE_XeqArts	;if not D7D7
;;9;;LD7F9		clra
;;9;;		inc	zp_vdu_wksp			;else X=X+1
;;9;;		beq	mos_OSBYTE_135_YeqMODE_XeqArts	; past 255 give up return A = 0
;;9;;		leay	8,Y
;;9;;		tfr	Y,D
;;9;;		tstb
;;9;;;	lda	zp_vdu_wksp+4				;get byte lo address
;;9;;;	clc						;clear carry
;;9;;;	adc	#$08					;add 8
;;9;;;	sta	zp_vdu_wksp+4				;store it
;;9;;		bne	LD7E8					;and go back to check next character if <>0
;;9;;		bra	mos_OSBYTE_135_lp1			; recalc char pointer (may be into redeffed chars)
;;9;;;; set up pattern copy
;;9;;x_set_up_pattern_copy
;;9;;		ldb	#$07				; Y=7
;;9;;		ldx	zp_vdu_top_scanline
;;9;;		ldy	#vduvar_TEMP_8
;;9;;LD80A		stb	zp_vdu_wksp			; &DA=Y
;;9;;		lda	#$01				; A=1 - this will rol out and signal end of loop
;;9;;		sta	zp_vdu_wksp_draw_flags		; &DB=A
;;9;;LD810		lda	vduvar_LEFTMOST_PIX_MASK	; A=left colour mask
;;9;;		sta	zp_vdu_wksp+2			; store an &DC
;;9;;		lda	B,X				; get a byte from current text character
;;9;;		eora	vduvar_TXT_BACK			; EOR with text background colour
;;9;;		CLC					; clear carry
;;9;;LD81B		bita	zp_vdu_wksp+2			; and check bits of colour mask
;;9;;		beq	LD820				; if result =0 then D820
;;9;;		SEC					; else set carry
;;9;;LD820		rol	zp_vdu_wksp_draw_flags		; &DB=&DB+Carry
;;9;;		bcs	LD82E				; if carry now set (bit 7 DB originally set) D82E
;;9;;		lsr	zp_vdu_wksp+2			; else  &DC=&DC/2 - roll screen bits right
;;9;;		bcc	LD81B				; if carry clear D81B - keep going for this mask
;;9;;;;;	tya					; A=Y
;;9;;;;;	adc	#$07				; ADD ( (7+carry)
;;9;;;;;	tay					; Y=A
;;9;;		addb	#8
;;9;;		bra	LD810				; 
;;9;;
;;9;;LD82E		ldb	zp_vdu_wksp			; read modified values into Y and A
;;9;;		lda	zp_vdu_wksp_draw_flags		; 
;;9;;		sta	B,y				; store copy
;;9;;		decb					; and do it again
;;9;;		bpl	LD80A				; until 8 bytes copied
;;9;;		rts					; exit
;; ----------------------------------------------------------------------------
;; pixel reading
;x_pixel_reading:
;	pha					;	D839
;	tax					;	D83A
;	jsr	x_set_up_and_adjust_positional_data;	D83B
;	pla					;	D83E
;	tax					;	D83F
;	jsr	x__check_in_window_bounds_setup_screen_addr_atX				;	D840
;	bne	LD85A				;	D843
;	lda	(zp_vdu_gra_char_cell),y	;	D845
;LD847:	asl	a				;	D847
;	rol	zp_vdu_wksp			;	D848
;	asl	zp_vdu_grpixmask		;	D84A
;	php					;	D84C
;	bcs	LD851				;	D84D
;	lsr	zp_vdu_wksp			;	D84F
;LD851:	plp					;	D851
;	bne	LD847				;	D852
;	lda	zp_vdu_wksp			;	D854
;	and	vduvar_COL_COUNT_MINUS1		;	D856
;	rts					;	D859
;; ----------------------------------------------------------------------------
;LD85A:	lda	#$FF				;	D85A
LD85Crts
		rts					;	D85C

;; ----------------------------------------------------------------------------
;; : check for window violations and set up screen address
x__check_in_window_bounds_setup_screen_addr		; LD85D
		lea.l	vduvar_VDU_Q_END - 4,A0		
x__check_in_window_bounds_setup_screen_addr_atX		; LD85F
		bsr	x_Check_window_limits_atX	
		bne	LD85Crts			;	D862
x_setup_screen_addr_from_intcoords_atX	
		clr.w	D0
		move.b	3(A0),D0			; get y coord
		not.b	D0				;	D867
		move.w	D0,D1				; todo speed this up by using D and MUL?
		and.b	#$07,D0				;	D86A
		move.b	D0,vduvar_GRA_CUR_CELL_LINE	;	D86C
		and.b	#$F8,D1
		mulu	#640/8,D1
		tst.b	vduvar_MODE_SIZE		;	D87C
		beq	LD884				;	D87F
		lsr.w	#1,D1
LD884		add.w	vduvar_6845_SCREEN_START,D1	;	D884
		move.w	D1,zp_vdu_gra_char_cell		;	D887
		move.w	(A0),D0
		move.w	D0,-(SP)
		and.b	vduvar_PIXELS_PER_BYTE_MINUS1,D0
		add.b	vduvar_PIXELS_PER_BYTE_MINUS1,D0
		and.w	#$00FF,D0
		lea.l	mostbl_VDU_pix_mask_16colour,A0
		move.b	-1(A0,D0),zp_vdu_grpixmask
		cmp.b	#3,vduvar_PIXELS_PER_BYTE_MINUS1;	D8A6		
		move.w	(SP)+,D0
		beq	LD8B2				;	4 pixels per byte
		bhs	LD8B5				;	8 pixels per byte
						;	2 pixels per byte
		asl.w	#1,D0
LD8B2		asl.w	#1,D0		
LD8B5		and.w	#$FFF8,D0			;	D8B5
		add.w	zp_vdu_gra_char_cell,D0
		bpl	LD8C6				;	D8C0
		sub.w	vduvar_SCREEN_SIZE_HIGH,D0	;	D8C3		
LD8C6		move.w	D0,zp_vdu_gra_char_cell
		move.b	vduvar_GRA_CUR_CELL_LINE,D1	;	D8C8
LD8CBclrArts	clr.w	D0
		rts					;	D8CD

;; ----------------------------------------------------------------------------
x_cursor_start					; LD8CE
		move.b	D0,-(SP)			; Push A
		clr.w	D1
		tst.b	sysvar_VDU_Q_LEN		; X=number of items in VDU queque
		bne	LD916pulsArts			; if not 0 D916
		btst	#VDU_STATUS_B7_SCREENDIS,zp_vdu_status
		bne	LD916pulsArts
		btst	#VDU_STATUS_B5_VDU5,zp_vdu_status
		bne	LD916pulsArts			; if either VDU is disabled or plot to graphics
							; cursor enabled then D916
		btst	#VDU_STATUS_B6_CURSORED,zp_vdu_status
		bne	.s1				; if cursor editing enabled D8F5
		move.b	vduvar_CUR_START_PREV,D0	; else get 6845 register start setting
		and.b	#$9F,D0				; clear bits 5 and 6
		or.b	#$40,D0				; set bit 6 to modify last cursor size setting
		bsr	x_crtc_set_cursor		; change write cursor format
		move.w	vduvar_TXT_CUR_X,vduvar_TEXT_IN_CUR_X	; set text input cursor from text output cursor
		bsr	x_setup_read_cursor		; modify character at cursor poistion
		bset	#VDU_STATUS_B1_SCROLLOCK,zp_vdu_status; bit 1 of VDU status is set to bar scrolling
.s1		bclr	#VDU_STATUS_B6_CURSORED,zp_vdu_status;bit 6 of VDU status =0 
		move.b	(SP)+,D0			;Pull A
		and.b	#$7F,D0				;clear hi bit (7)
		bsr	mos_VDU_WRCH			; exec up down left or right?
		bset	#VDU_STATUS_B6_CURSORED,zp_vdu_status; enable cursor editing
		rts

;; ----------------------------------------------------------------------------
x_cursor_COPY					; LD905
		btst	#VDU_STATUS_B6_CURSORED,zp_vdu_status
		beq	LD8CBclrArts				;exit not cursor editing
		btst	#VDU_STATUS_B5_VDU5,zp_vdu_status
		bne	LD8CBclrArts				;exit vdu5

		
		move.b	#135,D0
		SWI	XOS_Byte				;read a character from the screen - note changed this to use
		tst.b	D1
		move.b	D1,-(SP)			;else store char
		beq	LD916pulsArts
		bsr	mos_VDU_9			;perform cursor right
LD916pulsArts	move.b	(SP)+,D0
LD917rts	rts

x_cancel_cursor_edit							; LD918
		bclr	#VDU_STATUS_B1_SCROLLOCK,zp_vdu_status		; reset scroll lock
		bclr	#VDU_STATUS_B6_CURSORED,zp_vdu_status   	; reset cursor edit
		bsr	x_crtc_reset_cursor				;	D91D
		moveq	#$0D,D0						;	D920
		rts							;	D922



*************************************************************************
*                                                                       *
*       OSBYTE 154 (&9A) SET VIDEO ULA                                  *       
*                                                                       *
*************************************************************************
mos_OSBYTE_154
		move.b	zp_mos_OSBW_X,D0
mos_VIDPROC_set_CTL
		move.w	SR,-(SP)
		ori.w	#$0700,SR			;disable interrupts
		move.b	D0,sysvar_VIDPROC_CTL_COPY	;save RAM copy of new parameter
		move.b	D0,sheila_VIDULA_ctl		;write to control register
		move.b	sysvar_FLASH_MARK_PERIOD,sysvar_FLASH_CTDOWN	;read  space count
							;set flash counter to this value
		move.w	(SP)+,SR			;get back status
		rts					;and return

*************************************************************************
*                                                                       *
*        OSBYTE &9B (155) write to pallette register                    *       
*                                                                       *
*************************************************************************
                ;entry X contains value to write

mos_OSBYTE_155
		move.b	zp_mos_OSBW_X,D0		;	EA10
write_pallette_reg
		move	SR,-(SP)			;	EA13
		or.w	#$0700,SR			;	EA14
		move.b	D0,-(SP)
		eori.b	#$07,D0				;	EA11
		move.b	D0,sysvar_VIDPROC_PAL_COPY	;	EA15
		move.b	D0,sheila_VIDULA_pal		;	EA18
		move.b	(SP)+,D0
		rte

mos_poke_SYSVIA_orb
		move.w	SR,-(SP)
		ori.w	#$0700,SR
		move.b	D0,sheila_SYSVIA_orb
		move.w	(SP)+,SR
		rts



;; printer driver - move to another module / osbyte / trap
LE11E		rts
LE1A2		rts

mos_OSBYTE_118	
		CLC
		rts

; ----------------------------------------------------------------------------
; OSBYTE 20		  Explode characters;  
mos_OSBYTE_20
		; TODO - not sure where to store expoded chars and whether to pre-reserve memory
		rts
