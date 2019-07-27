;; (c) 2019 Dossytronics, Dominic Beesley	

		include "mos.inc"
		include "oslib.inc"
		include "hardware.inc"
;; ported VDU from 6809 mos

		xdef 	mos_VDU_init

		section "code"

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

				
				
mos_VDU_init:						; LCB1D
		move.b	D0,-(A7)			; save mode #
		clr.b	dp_vdu_status
		; clear vdu vars at $300-$37E
		moveq	#$7D,D0
		lea.l   vduvars_start,A0
.lp		clr.b	(A0)+
		dbf	D0,.lp
		clr.b	dp_mos_OSBW_X
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
		andi	#$43,dp_vdu_status
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
		bsr	mos_set_cursor_D0
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

HERE

		trap	#1

		rts





; ----------------------------------------------------------------------------
; OSBYTE 20		  Explode characters;  
mos_OSBYTE_20
		; TODO - not sure where to store expoded chars and whether to pre-reserve memory
		rts

mos_VDU_20	move.b	#$A5,vduvar_TXT_BACK
		rts
mos_VDU_26	rts
mos_set_cursor_D0
		move.w	D0,vduvar_6845_CURSOR_ADDR		;	C9F6
		cmp.w	#$8000,D0
		blo	x_set_cursor_position_D0
		sub.w	vduvar_SCREEN_SIZE_HIGH,D0
x_set_cursor_position_D0
		move.w	D0,dp_vdu_top_scanline
		move.w	vduvar_6845_CURSOR_ADDR,D0
		moveq	#$0E,D1
x_set_6845_screenstart_from_X			; LCA0E
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

*************************************************************************
*                                                                       *
*       OSBYTE 154 (&9A) SET VIDEO ULA                                  *       
*                                                                       *
*************************************************************************
mos_OSBYTE_154
		move.b	dp_mos_OSBW_X,D0
mos_VIDPROC_set_CTL
		move.w	SR,-(A7)
		ori.w	#$0700,SR			;disable interrupts
		move.b	D0,sysvar_VIDPROC_CTL_COPY	;save RAM copy of new parameter
		move.b	D0,sheila_VIDULA_ctl		;write to control register
		move.b	sysvar_FLASH_MARK_PERIOD,sysvar_FLASH_CTDOWN	;read  space count
							;set flash counter to this value
		move.w	(A7)+,SR			;get back status
		rts					;and return


mos_poke_SYSVIA_orb
		move.w	SR,-(A7)
		ori.w	#$0700,SR
		move.b	D0,sheila_SYSVIA_orb
		move.w	(A7)+,SR
		rts


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
		btst.b	#VDU_STATUS_B5_VDU5,dp_vdu_status		;	C982
		bne	LC98B				;	C983
LC985		move.b	D1,sheila_CRTC_reg		;	C985
		move.b	D0,sheila_CRTC_rw		;	C988
LC98B		rts					;	C98B

