;; (c) 2019 Dossytronics, Dominic Beesley	

		include "mos.inc"
		include "oslib.inc"
		include "hardware.inc"
;; ported VDU from 6809 mos

		xdef 	mos_VDU_init

mostbl_chardefs := font

		section "code"

		macro	VDU_JMP_REL
		dc.w	\1-mos_vdu_jsr-2
		endm	VDU_JMP_REL

		macro   CLC
		andi	#-2,CCR
		endm	CLC

		macro   SEC
		ori	#$0001,CCR
		endm	CLC

		macro   CLX
		andi	#-17,CCR
		endm	CLC

		macro   SEX
		ori	#$0010,CCR
		endm	CLC



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
mos_vdu_jsr	jsr	(PC,D1)

mostbl_vdu_q_lengths	; 2's complement
		dc.b	$00,$FF,$00,$00,$00,$00,$00,$00	; 0-7
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00 ; 8-15
		dc.b	$00,$FF,$FE,$FB,$00,$00,$FF,$F7 ; 16-23
		dc.b	$F8,$FB,$00,$00,$FC,$FC,$00,$FE ; 24-31
		dc.b	$00

; TEXT WINDOW -BOTTOM ROW LOOK UP TABLE
mostbl_vdu_window_bottom
		dc.b	$C0,$1F,$1F,$1F,$18,$1F,$1F,$18 ;	C3E6
		dc.b	$18				;	C3EE
; TEXT WINDOW -RIGHT HAND COLUMN LOOK UP TABLE
mostbl_vdu_window_right
		dc.b	$4F,$27,$13,$4F,$27,$13,$27,$27 ;	C3EF
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
mostbl_GCOL_options_proc0
		dc.b	$00
; GCOL PLOT OPTIONS PROCESSING LOOK UP TABLE
mostbl_GCOL_options_proc
		dc.b	$FF,$00,$00,$FF,$FF,$FF,$FF,$00 ;	C41C
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
	IF MACH_BEEB
; sent direct to orb of SYSVIA dependent on mode_size
mostbl_VDU_hwscroll_offb1
		dc.b	$0D,$05,$0D,$05			;	C44B
; sent direct to orb of SYSVIA dependent on mode_size
mostbl_VDU_hwscroll_offb2
		dc.b	$04,$04,$0C,$0C,$04		;	C44F
	ENDIF
	IF MACH_CHIPKIT
; new scroll offset table for 6809 hardware offset
mostbl_VDU_hwscroll_offs
		dc.b	$06,$08,$0B,$0C,$F;			TODO: mode 7 doesn't work!
	ENDIF
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
mostbl_VDU_bytes_per_row_w
		dc.w	40,320,640			;	C463 -- note this was just low byte on 6502
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


mos_VDU_WRCH						; LC4C0
		move.b	sysvar_VDU_Q_LEN,D1		; get number of items in VDU queque
		bne	mos_VDU_WRCH_add_to_Q		; if parameters needed then C512
		btst	#VDU_STATUS_B6_CURSORED,zp_vdu_status
		beq	mos_VDU_WRCH_sk_nocurs		;
		bsr	x_start_curs_edit		; if cursor editing enabled two cursors exist
		bsr	x_set_up_write_cursor		; swap values
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
		move.w	D0,D1
		asl.w	D1
		lea	mostbl_vdu_entry_points,A0
		move.w	0(A0,D1),A1
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
		move.l	#vduvar_VDU_Q_END,A0
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
		bsr	x_set_up_write_cursor		;	C529
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
		move.w	SR,-(A7)
		bsr	mos_vdu_callfb
		move.w	(A7)+,CCR			;	C55B
		bcc	LC561				;	C55C

x_main_exit_routine
		move.b	zp_vdu_status,D0		;VDU status byte
		roxr.b	D0				;Carry is set if printer is enabled
LC561		
		btst	#VDU_STATUS_B6_CURSORED,zp_vdu_status
		beq	LC511RTS			;if nmo cursor editing  C511 to exit
x_cursor_editing_routines
		bsr	x_start_cursor_edit_qry		;	C565

x_start_curs_edit					;LC568
		move.w	SR,-(A7)
		move.w	D0,-(A7)
		move.w	#$318,A0			;	C56A
		move.w	#$364,A1			;	C56C
		bsr	x_exchange_2atY_with_2atX	;	C56E
		bsr	x_set_up_displayaddress		;	C571
		move.w	zp_vdu_top_scanline,A0
		bsr	x_set_cursor_position_X		;	C574
		bchg	#VDU_STATUS_B1_SCROLLOCK,zp_vdu_status	; toggle scrolling disabled
		move.w	(A7)+,D0
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
		move.l	#vduvar_GRA_CUR_INT,A0
		subq.w	#$08,(A0,D1)			;	subtract 8 to move back/up one char
LC636		tst.b	zp_vdu_wksp			;	get back result from x_Check_window_limits
		bne	jmp_cal_ext_coors				;	C638
		bsr	x_Check_window_limits		;	C63A
		beq	jmp_cal_ext_coors				;	C63D
		move.l	#vduvar_GRA_WINDOW_RIGHT,A1
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
		move.l	#vduvar_GRA_CUR_INT,A0
		addq.w	#8,(A0,D1)
LC6CB		tst.b	zp_vdu_wksp			; get back result from window limits above
		bne	jmp_cal_ext_coors		;	C6CD
		bsr	x_Check_window_limits		;	C6CF
		beq	jmp_cal_ext_coors		;	C6D2
		clr.w	D1
		move.b	zp_vdu_wksp+1,D1		;	C6D4
		move.l	#vduvar_GRA_WINDOW_LEFT,A1
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
		move.l  #mostbl_vdu_window_bottom+1,A0
		move.b	vduvar_VDU_Q_END - 3,D0
		cmp.b	vduvar_VDU_Q_END - 1,D0
		blo	LC758rts
		cmp.b	(A0,D1),D0
		bhi	LC758rts
		move.b	vduvar_VDU_Q_END - 2,D0
		move.l	#mostbl_vdu_window_right,A0
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
		jsr	x_check_text_cursor_in_window_setup_display_addr
		bcc	LC732_set_cursor_position
LC7A8		move.l	#vduvar_TXT_CUR_X,A0
		move.l	#vduvar_TEMP_8,A1
		bra	x_exchange_2atY_with_2atX
;; ----------------------------------------------------------------------------
;; VDU  13	  Carriage  Return	  0 parameters
mos_VDU_13
		bsr	x_check_text_cursor_in_use	;	C7AF	
		bne	x_set_graphics_cursor_to_left_hand_column;	C7B4
LC7B7		bsr	x_cursor_to_window_left				;	C7B7
		bra	x_setup_displayaddress_and_cursor_position				;	C7BA
;; ----------------------------------------------------------------------------
x_mos_home_CLG						; LC7BD
		bsr	x_home_graphics_cursor			

;; VDU 16 clear graphics screen		  0 parameters
mos_VDU_16
		tst.b	vduvar_PIXELS_PER_BYTE_MINUS1		; pixels per byte
		beq	LC7F8rts				; if 0 current mode has no graphics so exit
		move.b	vduvar_GRA_BACK,D0			; Background graphics colour
		move.b	vduvar_GRA_PLOT_BACK,D1			; background graphics plot mode (GCOL n)
		bsr	x_set_colour_masks_newAPI		; set graphics byte mask in &D4/5
		move.l	#vduvar_GRA_WINDOW_LEFT,A0		; graphics window
		move.l	#vduvar_TEMP_8,A1			; workspace
		bsr	copy8fromXtoY				; set(300/7+Y) from (300/7+X)
		move.b	vduvar_GRA_WINDOW_TOP + 1,D0		; graphics window top lo.
		sub.b	vduvar_GRA_WINDOW_BOTTOM + 1,D0		; graphics window bottom lo
		addq	#1,D0					; increment
		move.b	D0,vduvar_GRA_WKSP			; and store in workspace (this is line count)
.s1		move.l	#vduvar_TEMP_8 + 4,A0			; right
		move.l	#vduvar_TEMP_8,A1			; left
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
LC7FF		move.b	vduvar_VDU_Q_END - 1,D0
		bpl	LC805
		addq.b	#1,D1
LC805		and.b	vduvar_COL_COUNT_MINUS1,D0
		move.b	D0,zp_vdu_wksp
		move.b	vduvar_COL_COUNT_MINUS1,D0
		beq	LC82B
		and.b	#$07,D0
		add.b	zp_vdu_wksp,D0
		move.l	#mostbl_2_colour_pixmasks-1,A0
		move.b	(A0,D0),D0
		move.l	#vduvar_TXT_FORE,A1
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
		move.l	#vduvar_GRA_PLOT_FORE-2,A1
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
		move.w	#$07,vduvar_VDU_Q_END - 4	;	note word to clear top bits
LC879		bsr	mos_VDU_19			;	C879
		lsr	vduvar_VDU_Q_END - 4		;	C87C
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
		move.w	SR, -(A7)			; save flags
		or.w	#$0700,SR			; and disable interrupts
		move.b	vduvar_VDU_Q_END - 5,D1		; b <= logical colour
		and.b	vduvar_COL_COUNT_MINUS1,D1	; 
		
		move.b	vduvar_VDU_Q_END - 4, D0	; a <= physical colour
LC89E		andi.b	#$0F,D0				; 
		lea	vduvar_PALLETTE, A0
		move.b  D0,0(A0,D1)			; store in saved palette 

		move.b	vduvar_COL_COUNT_MINUS1,D2	; a <= colours - 1
		move.b	D2,D3
							;	2 col		4 col		16 col
LC8AD		roxr.b	#1,D1				; 
		roxr.b	#1,D2			;
		bcs	LC8AD				;
							; b=	$80		$C0		$F0
		asl.b	#1,D1				; wksp2=X0000000	XX000000	XXXX0000
							; a <= phys colour
		or.b	D1,D0				; a <= LLLLPPPP
		

		clr.b	D1
LC8BA		cmp	#3,D3				;	C8BB
		bne	mos_VDU19_sk1			;	C8BC
		move.b	D0,D2
		andi.b	#$60,D2				;	C8BE
		beq	mos_VDU19_sk1			;	C8C0
		cmp.b	#$60,D2				;	C8C2
		beq	mos_VDU19_sk1			;	C8C4
		eori.b	#$60,D0				;	C8C7
		bra	mos_VDU19_sk1			;	C8C9
mos_VDU19_sk1
		bsr	write_pallette_reg				; LC8CC
		add.b	vduvar_COL_COUNT_MINUS1,D1	;	C8D1
		addq.b	#1,D1
		add.b	#$10,D0				;	C8D6
		cmp.b	#$10,D1				;	C8D9
		blo	LC8BA				;	C8DB

		move.w	(A7)+,SR			;	C8DE	ENDIF
		rts

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
		jmp	mos_VDU_WRCH		; TODO - VECTORS!

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
		move.w	D0,-(A7)
		move.b	vduvar_SCREEN_SIZE_HIGH,D0
		asl.w	#8,D0
		add.w	(A7)+,D0
		rts

x68_sub_screen_size_d0
		move.w	D0,-(A7)
		move.b	vduvar_SCREEN_SIZE_HIGH,D0
		asl.w	#8,D0
		add.w	(A7)+,D0
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
		jsr	x68_sub_screen_size_d0		
LC9B3		move.w	D0,vduvar_6845_SCREEN_START
		move.w	D0,A0
		moveq	#$0C,D0
		bra	x_set6845_screenstart_from_X

;; VDU 26  set default windows		  0 parameters
mos_VDU_26									; LC9BD
		clr.w	D0
		moveq	#$2C,D1
		move.l	#vduvar_GRA_WINDOW_LEFT,A0
LC9C1		move.b	D0,(A0,D1)
		dbf	D1,LC9C1						;	C9C4
		clr.w	D1
		move.b	vduvar_MODE,D1						;	C9C7
		move.l	mostbl_vdu_window_right,A0				;
		move.b	(A0,D1),D0						; text window right hand margin maximum
		move.b	D0,vduvar_TXT_WINDOW_RIGHT				; text window right
		jsr	LCA88_newAPI						; calculate number of bytes in a line
		move.b	1(A0,D1),vduvar_TXT_WINDOW_BOTTOM			; text window bottom margin maximum
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
		move.w	vduvar_6845_CURSOR_ADDR,D0
		moveq	#$0E,D1
x_set_6845_screenstart_from_X			; LCA0E
		move.w	A0,D0
		cmp.b	#$07,vduvar_MODE
		bhs	LCA27
		lsr.w	#3,D0
		bra	mos_set_6845_regD1toD0_16
LCA27		
		sub.w	#$7400,D0			;	CA27
		eor.w	#$20,D0				;	CA29
mos_set_6845_regD1toD0_16
		ror.w	#8,D0
		bsr	mos_set_6845_regD1toD0
		ror.w	#8,D0
		addq.b	#1,D1
		bra	mos_set_6845_regD1toD0		

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
		move.l	#vduvar_VDU_Q_END,A0
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
		move.l	#vduvar_VDU_Q_24_LEFT,A0
		move.l	#vudvar_TMP_XY,A1
		bsr	x_coords_to_width_height	; calculate new width/height at TMP_XY
		or.w	vudvar_TMP_XY,D0		; D0 already contains height, or width
		bmi	x_exchange_310_with_328		; if either negative, quit
		move.l	#vduvar_VDU_Q_24_RIGHT,A0
		bsr	x_set_up_and_adjust_coords_atX
		move.l	#vduvar_VDU_Q_24_LEFT,A0
		bsr	x_set_up_and_adjust_coords_atX
		move.b	vduvar_VDU_Q_24_BOTTOM,D0
		or.b	vduvar_VDU_Q_24_TOP,D0
		bmi	x_exchange_310_with_328		; if top or bottom -ve
		tst.b	vduvar_VDU_Q_24_TOP
		bne	x_exchange_310_with_328		; if top internal coords > 255
		clr.w	D1
		move.b	vduvar_MODE,D1			; screen mode
		move.l	#mostbl_vdu_window_right,A0
		move.w	vduvar_VDU_Q_24_RIGHT,D0	; right margin 
		lsr.w	D0
		lsr.w	D0
		cmpi.w	#$FF,D0
		bhi	x_exchange_310_with_328		; exchange 310/3 with 328/3 - its too big!
		lsr.b	D0				; A=A/2
		cmp.b	(A0,D1),D0			; text window right hand margin maximum
		beq	LCA7A				; if equal CA7A
		bpl	x_exchange_310_with_328		; exchange 310/3 with 328/3
LCA7A		move.l	#vduvar_GRA_WINDOW_LEFT,A1
		move.l	#vduvar_VDU_Q_END - 8,A0
		bsr	copy8fromXtoY			; save updated data

x_exchange_310_with_328
		move.l	#vduvar_GRA_CUR_EXT,A0		; ==$310
		move.l	#vduvar_TEMP_8,A1			; ==$328
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
		move.w	#mostbl_chardefs,A1
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
LCB0E		jsr	mos_OSBYTE_118
		SEC
		bpl	LCB0E
;; zero paged mode  counter
x_zero_paged_mode_counter
		moveq	#-1,D0					;	CB14
		move.b	D0,sysvar_SCREENLINES_SINCE_PAGE	;	CB16
LCB19		addq.b	#1,sysvar_SCREENLINES_SINCE_PAGE	;	CB19
LCB1Crts	rts


mos_VDU_init:						; LCB1D
		move.b	D0,-(A7)			; save mode #
		clr.b	zp_vdu_status
		; clear vdu vars at $300-$37E
		moveq	#$7D,D0
		lea.l   vduvars_start,A0
.lp		clr.b	(A0)+
		dbf	D0,.lp
		clr.b	zp_mos_OSBW_X
		bsr	mos_OSBYTE_20			; explode characters
		move.b	#$7F,vduvar_MO7_CUR_CHAR
		move.b	(A7)+,D0			; get back mode #
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
		move.w	mostbl_VDU_bytes_per_row_w-mostbl_VDU_mode_colours_m1(A0,D1.w),vduvar_BYTES_PER_ROW
		andi	#$43,zp_vdu_status
		move.b	vduvar_MODE,D0
		move.b	mostbl_VDU_VIDPROC_CTL_by_mode-mostbl_VDU_mode_colours_m1(A0,D0.w),D0
		bsr	mos_VIDPROC_set_CTL		

		move.w	SR,-(A7)			; save interrupts
		ori	#$0700,SR			; disable interrupts
		clr.w	D2
		move.b	vduvar_MODE_SIZE,D2
		moveq	#12,D1
		mulu.w	D1,D2
		lea	12+mostbl_VDU_6845_mode_012-mostbl_VDU_mode_colours_m1(A0,D2.w),A0
		moveq	#11,D1
mos_send6845lp					; LCBB0
		move.b	-(A0),D0
		bsr	mos_set_6845_regD1toD0
		dbf	D1,mos_send6845lp

		move.w	(A7)+,SR			; interrupts back

		bsr	mos_VDU_20			; default logical colours
		bsr	mos_VDU_26			; default windows

LCBC1_clear_whole_screen
		move.l	#$00FF0000,D0			; force bank to FF
		move.b	vduvar_SCREEN_BOTTOM_HIGH,D0
		asl.w	#8,D0
		move.w	D0,vduvar_6845_SCREEN_START
		move.l	D0,A0
		bsr	mos_set_cursor_X
		moveq	#$0C,D1
		bsr	mos_set_6845_regD1toD0_16	;	CBD1
		clr.w	D0
		move.b	vduvar_MODE_SIZE,D0		;	CBD7
		lea	(mostbl_VDU_screensize_h,PC),A1
		move.b  0(A1,D0.w),D0
		asl.w	#8,D0
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

		rts


;; ----------------------------------------------------------------------------
;; subtract bytes per line from X/A
; note new API, address in D instead of X/A and carry flag is opposite sense
x_subtract_bytes_per_line_from_D
		sub.w	vduvar_BYTES_PER_ROW,D0
		move.w	D1,-(A7)
		move.b	vduvar_SCREEN_BOTTOM_HIGH,D1
		asl.w	#8,D1
		cmp.w	D1,D0
		move.w	(A7)+,D1
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
		lea	4(A7),A7			; skip return and setup address and cursor
		bra	x_setup_displayaddress_and_cursor_position
;; ----------------------------------------------------------------------------
LCD59		move.w	SR,-(A7)			;	CD59
		cmp.b	vduvar_TEXT_IN_CUR_Y,D1		;	CD5A
		bne	.s1				;	CD5D
		rtr
.s1		move.w	(A7)+,CCR			;	CD5F
		bcc	LCD66				;	CD60
		subq.b	#1,vduvar_TEXT_IN_CUR_Y		;	CD62
LCD65rts
		rts
;; ----------------------------------------------------------------------------
LCD66		addq.b	#1,vduvar_TEXT_IN_CUR_Y		;	CD66
		rts					;	CD69

GetTopScanLineAddr
		move.w	#zp_vdu_top_scanline,A0
		; get a 16 bit address in SYS space have to do this 
		; as move.w *,A0 sign extends
		; TODO: shorten this
GetAddrSYS16	move.l	D0,-(A7)
		moveq	#-1,D0
		move.w	(A0),D0
		move.l	D0,A0
		move.l	(A7)+,D0
		rts

;; ----------------------------------------------------------------------------
;; set up write cursor
x_set_up_write_cursor
		move.w	SR,-(A7)
		movem.l D0/D1/A0,-(A7)
		bsr	GetTopScanLineAddr
		move.b	vduvar_BYTES_PER_CHAR,D1
		subq	#1,D1
		bne	LCD8F				; it's not MO.7
		move.b	vduvar_GRA_WKSP+8,(A0)		; restore original MO.7 character?
x_cur_exit	movem.l	(A7)+,D0/D1/A0
		rtr
;; ----------------------------------------------------------------------------
x_start_cursor_edit_qry	
		move.w	SR,-(A7)
		movem.l D0/D1/A0,-(A7)
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
		move.l	#vduvar_TEMP_8,A0
		move.l	#vduvar_TXT_CUR_X,A1
x_exchange_2atY_with_2atX							; LCDDE
		moveq	#$02-1,D1						;	CDDE TODO: this is a straigh 16 bit copy do something better?
		bra	x_exchange_B_atY_with_B_atX_68API			;	CDE0
x_exg4atGRACURINTwithGRACURINTOLD						; LCDE2
		move.l	#vduvar_GRA_CUR_INT,A0					;	CDE2
x_exg4atGRACURINTOLDwithX							; LCDE4
		move.l	#vduvar_GRA_CUR_INT_OLD,A1				;	CDE4
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
		move	SR,-(A7)
		lsr	#8,D0
		move.b	D0,zp_vdu_wksp+2					;	CE18
		move	(A7)+,CCR
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
		move.w	D1,-(A7)						; TODO: eliminate?
		move.w	vduvar_TXT_WINDOW_WIDTH_BYTES,D1
		subq.w	#1,D1
		lea	zp_vdu_wksp,A0
		bsr	GetAddrSYS16
		move.l	A0,A1
		lea	zp_vdu_top_scanline,A0
		bsr	GetAddrSYS16
.s1		move.b	(A1)+,(A0)+
		dbf	D1,.s1
		move.w	(A7)+,D1
		rts
							;	CE5A
;; ----------------------------------------------------------------------------
x_exchange_TXTCUR_wksp_doublertsifwindowempty					; LCE5B
		bsr	x_exchange_TXT_CUR_with_BITMAP_READ			;
		move.b	vduvar_TXT_WINDOW_BOTTOM,D0				;	CE5F
		sub.b	vduvar_TXT_WINDOW_TOP,D0				;	CE62
		move.b	D0,zp_vdu_wksp+4					;	CE65
		bne	x_cursor_to_window_left					;	CE67
		lea	4(A7),A7						; - skip return
		bra	x_exchange_TXT_CUR_with_BITMAP_READ	; if no text window pull return address, put back cursor and exit parent subroutine
;; ----------------------------------------------------------------------------
x_cursor_to_window_left	
		move.b	vduvar_TXT_WINDOW_LEFT,D0
		bra	LCEE3_sta_TXT_CUR_X_setC_rts

x_copy_text_line_window_LCE73
;x_copy_text_line_window_LCE73							; LCE73
		move.b	zp_vdu_wksp+1,-(A7)		; save low byte of source pointer

		lea.l	zp_vdu_wksp,A0			; set up pointers from 16 bit vars
		jsr	GetAddrSYS16
		move.l	A0,A1
		lea.l	zp_vdu_top_scanline,A0
		jsr	GetAddrSYS16

		clr.w	D1
		move.b	vduvar_TXT_WINDOW_RIGHT,D1	; TODO: check we can corrupt D1 here!
		sub.b	vduvar_TXT_WINDOW_LEFT,D1	; number of chars to copy -1		
LCE7F:		clr.w	D2
		move.b	vduvar_BYTES_PER_CHAR,D2	; TODO: check we can corrupt D2 here!
		subq.b	#1,D2				;	CE82
CE83:		move.b	(A1)+,(A0)+			;	CE83
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

		move.b	zp_vdu_wksp+1,-(A7)		; save low byte of source pointer
		rts					;	CEAB

x_clear_a_line
		move.b	vduvar_TXT_CUR_X,-(A7)		; save text cursor		
		jsr	x_cursor_to_window_left
		jsr	x_set_up_displayaddress
		move.b	vduvar_TXT_WINDOW_RIGHT,D2
		sub.b	vduvar_TXT_WINDOW_LEFT,D2
		move.l	#zp_vdu_top_scanline,A0
		bsr	GetAddrSYS16
		move.b	vduvar_TXT_BACK,D0
LCEBF		clr.w	D1
		move.b	vduvar_BYTES_PER_CHAR,D1
		subq	#1,D1
LCEC5		move.b	D0,(A0)+
		dbf	D1,LCEC5
		move.w	A0,D0
		bpl	LCEDA
		move.b	vduvar_SCREEN_SIZE_HIGH,D0
		asl	#8,D0
		suba	D0,A0
LCEDA		dbf	D2,LCEBF
		move.w	A0,zp_vdu_top_scanline
		move.b	(A7)+,D0
LCEE3_sta_TXT_CUR_X_setC_rts	
		move.b	D0,vduvar_TXT_CUR_X
LCEE6_setC_rts
		SEC
		rts

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
		dc.w	640,320,320,40

x_set_up_displayaddress
		clr.w	D0
		move.b	vduvar_TXT_CUR_Y,D0
		clr.w	D1
		move.b	vduvar_MODE_SIZE,D1
		asl.b	#1,D1
		move.w	tbl68_size_bytes_pre_row(PC,D1),D1
		mulu	D0,D1
		move.w	D1,zp_vdu_top_scanline
		move.b	vduvar_BYTES_PER_CHAR,D0
		clr.w	D1
		move.b	vduvar_TXT_CUR_X,D1
		mulu	D1,D0
		add.w	zp_vdu_top_scanline,D0
		bpl	.s1
		bsr	x68_sub_screen_size_d0
.s1		rts

; 68API - changed to expect A1 register to contain pointer to character bitmap?
x_vdu5_render_char			; foreground graphics colour
		move.l	vduvar_GRA_FORE,D0		; foreground graphics plot mode (GCOL n)
		move.l	vduvar_GRA_PLOT_FORE,D1		; 
x_plot_char_gra_mode					; 
		jsr	x_set_colour_masks_newAPI	; set graphics byte mask in &D4/5
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
;; API68 enter with character pointer in A1 register
render_char
		tst.b	vduvar_COL_COUNT_MINUS1
		beq	x_convert_teletext_characters
		bsr	x_calc_pattern_addr_for_given_char_API68
LCFBF_renderchar2
		btst	#VDU_STATUS_B5_VDU5,zp_vdu_status			
		bne	x_vdu5_render_char
render_logo2

		moveq	#7,D3
		move.b	zp_vdu_txtcolourOR,D0
		move.b	zp_vdu_txtcolourEOR,D1

		move.l	#zp_vdu_top_scanline,A0
		bsr	GetAddrSYS16
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
		jsr	render_logox2
render_logox2
		jsr	render_logo
render_logo
		move.l	A1,-(A7)
		jsr	render_logo2
		jsr	mos_VDU_9
		move.l	(A7)+,A1
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
LCFE6		move.l	#zp_vdu_top_scanline,A0
		bsr	GetAddrSYS16
		move.b	D0,(A0)
		rts					;	CFE8
LCFE9		move.b	1(A0,D1),D0
		bra	LCFE6

;; four colour modes
render_char_4colour
		; TODO check to see if table look up or calculate for masks is quickest
		lea.l	mostbl_byte_mask_4col,A2
		clr.w	D2
.l1		move.b	(A1,D3),D2
		lsr.b	#4,D2				; get bottom half of font bitmap row
		move.b	(A2,D0),D2			; convert to mo.1 bitmask		
		or.b	D0,D2				
		eor.b	D1,D2				; apply colour
		move.b	D2,(A0,D3)			; store in screen

		move.b	(A1,D3),D2
		and.b	#$0F,D2				; get next 4 pixels
		move.b	(A2,D0),D2			; convert to mo.1 bitmask
		or.b	D0,D2				
		eor.b	D1,D2				; apply colour
		move.b	D2,8(A0,D3)			; store in screen
		dbf	D3,.l1
LD017rts	rts

;; ----------------------------------------------------------------------------
LD018		sub.b	#$21,D3
		bmi	LD017rts			;	D01B
		bra	rc16csk1
render_char_16colour
		lea.l	mostbl_byte_mask_16col,A2
rc16csk1	move.w	#$100,D2			; set bit above bitmask for loop counter
		move.b	(A1,D3),D2			; get bitmask		
LD023		asl.w	#2,D2	
		beq	LD018			
		move.b	D2,zp_vdu_wksp+2			; save
		and.b	#$03,D2
		move.b	(A2,D2),D2
		or.b	D0,D2
		eor.b	D1,D2
		move.b	D2,(A0,D3)
		move.b	zp_vdu_wksp+2,D2
		addq.b	#$08,D3
		bra	LD023

;API68 - returns address in A2
x_calc_pattern_addr_for_given_char_API68 
		movem.l	D0,-(A7)
		andi	#$00FF,D0
		asl	#3,D0
		move.b	D0,zp_vdu_wksp + 5			;a contains "char defs page offset"
		lsr.w	#8,D0					; get "page"
		btst	D0,vduvar_EXPLODE_FLAGS			;check if that bit is set in explosion bitmask
		bne	.x_cpa_sk_exploded			;if it is use that address
		move.l	#mostbl_chardefs - $100,D0		;space is at 32 remember!
.s1		move.b	zp_vdu_wksp + 5,D0			;store whole address
		move.l	D0,A0
		movem.l	(A7)+,D0
		rts
.x_cpa_sk_exploded
		lea.l	vduvar_EXPLODE_FLAGS,A1
		clr.l	D0				; TODO - exploded chars only in first 64k?
		move.b	(A1,D0),D0			;	get explode address from table
		asl.w	#8,D0
		bra	.s1



*************************************************************************
*                                                                       *
*       OSBYTE 154 (&9A) SET VIDEO ULA                                  *       
*                                                                       *
*************************************************************************
mos_OSBYTE_154
		move.b	zp_mos_OSBW_X,D0
mos_VIDPROC_set_CTL
		move.w	SR,-(A7)
		ori.w	#$0700,SR			;disable interrupts
		move.b	D0,sysvar_VIDPROC_CTL_COPY	;save RAM copy of new parameter
		move.b	D0,sheila_VIDULA_ctl		;write to control register
		move.b	sysvar_FLASH_MARK_PERIOD,sysvar_FLASH_CTDOWN	;read  space count
							;set flash counter to this value
		move.w	(A7)+,SR			;get back status
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
		move	SR,-(A7)			;	EA13
		or.w	#$0700,SR			;	EA14
		move.b	D0,-(A7)
		eori.b	#$07,D0				;	EA11
		move.b	D0,sysvar_VIDPROC_PAL_COPY	;	EA15
		move.b	D0,sheila_VIDULA_pal		;	EA18
		move.b	(A7)+,D0
		move	(A7)+,SR			;	EA1B
		rts

mos_poke_SYSVIA_orb
		move.w	SR,-(A7)
		ori.w	#$0700,SR
		move.b	D0,sheila_SYSVIA_orb
		move.w	(A7)+,SR
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
