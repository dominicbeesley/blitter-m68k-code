
		include "hardware.inc"

		xdef kernel_go_todo
		xdef handle_unex
		xdef STACK

		macro WAIT8US
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		endm

		macro WAITL n
		move.l	#\1, D7
.\@_lp:		subq.l	#1,D7
		bcc	.\@_lp
		endm

		macro MAGNIFY
		; show 8 bytes from 3000-3007 magnified at bottom of screen
		lea.l	-$D000,A0	; src
		lea.l	-$A800,A1	; dest
		moveq	#7,D4
.\@_lp0:	move.b	(A0)+,D3
		moveq	#7,D5
.\@_lp1:	rol.b	#1,D3
		scs.b	(A1)+
		scs.b	(A1)+
		scs.b	(A1)+
		scs.b	(A1)+
		scs.b	(A1)+
		scs.b	(A1)+
		scs.b	(A1)+
		scs.b	(A1)+
		scs.b	(A1)+
		scs.b	(A1)+
		scs.b	(A1)+
		scs.b	(A1)+
		scs.b	(A1)+
		scs.b	(A1)+
		scs.b	(A1)+
		scs.b	(A1)+
		dbf	D5,.\@_lp1
		adda	#640-128,A1
		dbf	D4,.\@_lp0
		endm


STACK := $1000

		section "code"
kernel_go_todo:

		; Disable and clear all VIA interrupts
		move.b	#$7F,D0
		move.b	D0,sheila_SYSVIA_ier
		move.b	D0,sheila_SYSVIA_ifr
		move.b	D0,sheila_USRVIA_ier
		move.b	D0,sheila_USRVIA_ifr

		moveq	#-1,D0
		move.b	D0,sheila_SYSVIA_ddra
		move.b	D0,sheila_SYSVIA_ddrb
		move.b	D0,sheila_SERIAL_ULA

		move.b	#4,sheila_SYSVIA_pcr ; vsync \\ CA1 negative-active-edge CA2 input-positive-active-edge CB1 negative-active-edge CB2 input-nagative-active-edge
		move.b	#0,sheila_SYSVIA_acr ; none  \\ PA latch-disable PB latch-disable SRC disabled T2 timed-interrupt T1 interrupt-t1-loaded PB7 disabled

		; disable all slow bus stuff
		moveq	#$F,D1
		move.b	D1,sheila_SYSVIA_ddrb
.lp:		move.b	D1,sheila_SYSVIA_orb
		subq	#1,D1
		cmp.b	#9,D1
		bhs	.lp


	; SN76489 data byte format
	; %1110-wnn latch noise (channel 3) w=white noise (otherwise periodic), nn: 0=hi, 1=med, 2=lo, 3=freq from channel %10
	; %1cc0pppp latch channel (%00-%10) period (low bits)
	; %1cc1aaaa latch channel (0-3) atenuation (%0000=loudest..%1111=silent)
	; if latched 1110---- %0----nnn noise (channel 3)
	; else                %0-pppppp period (high bits)
	; See SMS Power! for details http://www.smspower.org/Development/SN76489?sid=ae16503f2fb18070f3f40f2af56807f1
	; int volume_table[16]={32767, 26028, 20675, 16422, 13045, 10362, 8231, 6568, 5193, 4125, 3277, 2603, 2067, 1642, 1304, 0};

		move.b	#$FF,sheila_SYSVIA_ddra

		move.b	#$9F,D0      		; silence channel 0
.lpa:
		move.b	D0,sheila_SYSVIA_ora_nh  ; sample says SysViaRegH but OS uses no handshake \\ handshake regA
		clr.b	sheila_SYSVIA_orb	; enable sound for 8us

		WAIT8US
		move.b	#8,sheila_SYSVIA_orb
		WAIT8US

		add.b	#$20,D0
		bcc	.lpa

		; switch to mode 7 and show a nice screen

		moveq	#17,D1
		lea.l	mode_7_setup,A0
.lm01:		move.b	D1,sheila_CRTC_reg
		move.b	(A0, D1), sheila_CRTC_rw
		dbf	D1,.lm01
		
		move.b	#$4B,sheila_VIDULA_ctl

		lea.l	scr_mo7,A0
		lea.l	$FFFF7C00,A1
		move.w	#scr_mo7_len,D1

.sl:		move.b	(A0)+,(A1)+
		dbf	D1,.sl


		WAITL 6000000

		; switch to mode 0 and do some reading an writing

		; set up palette as B&W
		moveq	#7,D0
.pl0:		move.b	D0,sheila_VIDULA_pal
		add.b	#$10,D0
		bpl	.pl0

		move.b	#$81,D0
.pl1:		move.b	D0,sheila_VIDULA_pal
		add.b	#$10,D0
		bcc	.pl1



		moveq	#17,D1
		lea.l	mode_0_setup,A0
.lm1:		move.b	D1,sheila_CRTC_reg
		move.b	(A0, D1), sheila_CRTC_rw
		dbf	D1,.lm1
		
		move.b	#$9D,sheila_VIDULA_ctl

		; clear screen memory
		move.b	#$FF,D0
.cl0lp0:	lea.l	-$D000,A0		; FF3000
		move.w	#$5000,D1
.cl0lp:		move.b	D0,(A0)+
		dbf	D1,.cl0lp

		MAGNIFY

		dbf	D0,.cl0lp0

		WAITL 2000000


		; increment bytes

		move.w	#$FF,D2
.ilo:		lea.l	-$D000,A0		; FF3000
		move.w	#$5000,D1
.ilo2:		addq.b	#1,(A0)+
		dbf	D1,.ilo2

		MAGNIFY

		dbf	D2,.ilo

		; increment words

		WAITL 2000000


		move.w	#$FFFF,D2
.ilo1:		lea.l	-$D000,A0		; FF3000
		move.w	#$5000/16,D1
.ilo21:		addq.w	#1,(A0)+
		dbf	D1,.ilo21		

		MAGNIFY

		dbf	D2,.ilo1


		WAITL 2000000


		bra	kernel_go_todo




		move.l	#$12345678,-(A7)
		move.l	(A7)+, D0

lp2:
		movea.l #-$D000,A0
		move.l	#$5000,D1
		addq	#1,D0
lp:		addq	#1,D0
		move.b	D0,(A0)+
		dbf	D1,lp
		bra	lp2




mode_7_setup: 	dc.b $3F, $28, $33, $24, $1E, $02, $19, $1C, $93, $12, $72, $13, $28, $00, $00, $00, $28, $00 ;; HI(((mode_7_screen) - &74) EOR &20), LO(mode_7_screen)
mode_0_setup: 	dc.b $7F, $50, $62, $28, $26, $00, $20, $23, $01, $07, $67, $08, $06, $00, $00, $00, $06, $00 ;; addr / 8


handle_unex:
		; Turn off all interrupts and go busy
		stop #$2700

scr_mo7:	incbin "screen.mo7"
scr_mo7_len:=	*-scr_mo7