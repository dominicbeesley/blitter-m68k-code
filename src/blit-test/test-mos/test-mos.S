
#include "hardware.inc"

		xdef kernel_go_todo
		xdef handle_unex
		xdef STACK

		.macro WAIT8US
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
		.endm

		.macro WAITL n
		move.l	#\n, D7
.\@_lp:		subq.l	#1,D7
		bcc	.\@_lp
		.endm

		.macro MAGNIFY
		/* show 8 bytes from 3000-3007 magnified at bottom of screen */
		lea.l	-0xD000,A0	/* src */
		lea.l	-0xA800,A1	/* dest */
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
		.endm


STACK 		= 0x1000

		.text
kernel_go_todo:

		/* Disable and clear all VIA interrupts */
		move.b	#0x7F,D0
		move.b	D0,sheila_SYSVIA_ier
		move.b	D0,sheila_SYSVIA_ifr
		move.b	D0,sheila_USRVIA_ier
		move.b	D0,sheila_USRVIA_ifr

		moveq	#-1,D0
		move.b	D0,sheila_SYSVIA_ddra
		move.b	D0,sheila_SYSVIA_ddrb
		move.b	D0,sheila_SERIAL_ULA

		move.b	#4,sheila_SYSVIA_pcr /* vsync \\ CA1 negative-active-edge CA2 input-positive-active-edge CB1 negative-active-edge CB2 input-nagative-active-edge */
		move.b	#0,sheila_SYSVIA_acr /* none  \\ PA latch-disable PB latch-disable SRC disabled T2 timed-interrupt T1 interrupt-t1-loaded PB7 disabled */

		/* disable all slow bus stuff */
		moveq	#0xF,D1
		move.b	D1,sheila_SYSVIA_ddrb
.lp:		move.b	D1,sheila_SYSVIA_orb
		subq	#1,D1
		cmp.b	#9,D1
		bhs	.lp


	/* SN76489 data byte format */
	/* %1110-wnn latch noise (channel 3) w=white noise (otherwise periodic), nn: 0=hi, 1=med, 2=lo, 3=freq from channel %10 */
	/* %1cc0pppp latch channel (%00-%10) period (low bits) */
	/* %1cc1aaaa latch channel (0-3) atenuation (%0000=loudest..%1111=silent) */
	/* if latched 1110---- %0----nnn noise (channel 3) */
	/* else                %0-pppppp period (high bits) */
	/* See SMS Power! for details http://www.smspower.org/Development/SN76489?sid=ae16503f2fb18070f3f40f2af56807f1 */
	/* int volume_table[16]={32767, 26028, 20675, 16422, 13045, 10362, 8231, 6568, 5193, 4125, 3277, 2603, 2067, 1642, 1304, 0}; */

		move.b	#0xFF,sheila_SYSVIA_ddra

		move.b	#0x9F,D0      		/* silence channel 0 */
.lpa:
		move.b	D0,sheila_SYSVIA_ora_nh  /* sample says SysViaRegH but OS uses no handshake \\ handshake regA */
		clr.b	sheila_SYSVIA_orb	/* enable sound for 8us */

		WAIT8US
		move.b	#8,sheila_SYSVIA_orb
		WAIT8US

		add.b	#0x20,D0
		bcc	.lpa

		/* switch to mode 7 and show a nice screen */

		moveq	#17,D1
		lea.l	mode_7_setup,A0
.lm01:		move.b	D1,sheila_CRTC_reg
		move.b	(A0, D1), sheila_CRTC_rw
		dbf	D1,.lm01
		
		move.b	#0x4B,sheila_VIDULA_ctl

		lea.l	scr_mo7,A0
		lea.l	0xFFFF7C00,A1
		move.w	#scr_mo7_len,D1

.sl:		move.b	(A0)+,(A1)+
		dbf	D1,.sl


		WAITL 6000000

		/* switch to mode 0 and do some reading an writing */

		/* set up palette as B&W */
		moveq	#7,D0
.pl0:		move.b	D0,sheila_VIDULA_pal
		add.b	#0x10,D0
		bpl	.pl0

		move.b	#0x81,D0
.pl1:		move.b	D0,sheila_VIDULA_pal
		add.b	#0x10,D0
		bcc	.pl1



		moveq	#17,D1
		lea.l	mode_0_setup,A0
.lm1:		move.b	D1,sheila_CRTC_reg
		move.b	(A0, D1), sheila_CRTC_rw
		dbf	D1,.lm1
		
		move.b	#0x9D,sheila_VIDULA_ctl

		/* clear screen memory */
		move.b	#0xFF,D0
.cl0lp0:	lea.l	-0xD000,A0		/* FF3000 */
		move.w	#0x5000,D1
.cl0lp:		move.b	D0,(A0)+
		dbf	D1,.cl0lp

		MAGNIFY

		dbf	D0,.cl0lp0

		WAITL 2000000


		/* increment bytes */

		move.w	#0xFF,D2
.ilo:		lea.l	-0xD000,A0		/* FF3000 */
		move.w	#0x5000,D1
.ilo2:		addq.b	#1,(A0)+
		dbf	D1,.ilo2

		MAGNIFY

		dbf	D2,.ilo

		/* increment words */

		WAITL 2000000


		move.w	#0xFFFF,D2
.ilo1:		lea.l	-0xD000,A0		/* FF3000 */
		move.w	#0x5000 / 16 ,D1
.ilo21:		addq.w	#1,(A0)+
		dbf	D1,.ilo21		

		MAGNIFY

		dbf	D2,.ilo1


		WAITL 2000000


		bra	kernel_go_todo




		move.l	#0x12345678,-(A7)
		move.l	(A7)+, D0

lp2:
		movea.l	#-0xD000,A0
		move.l	#0x5000,D1
		addq	#1,D0
lp:		addq	#1,D0
		move.b	D0,(A0)+
		dbf	D1,lp
		bra	lp2




mode_7_setup: 	dc.b 0x3F, 0x28, 0x33, 0x24, 0x1E, 0x02, 0x19, 0x1C, 0x93, 0x12, 0x72, 0x13, 0x28, 0x00, 0x00, 0x00, 0x28, 0x00 /* ; HI(((mode_7_screen) - &74) EOR &20), LO(mode_7_screen) */
mode_0_setup: 	dc.b 0x7F, 0x50, 0x62, 0x28, 0x26, 0x00, 0x20, 0x23, 0x01, 0x07, 0x67, 0x08, 0x06, 0x00, 0x00, 0x00, 0x06, 0x00 /* ; addr / 8 */


handle_unex:
		/* Turn off all interrupts and go busy */
		stop #0x2700

scr_mo7:		.incbin "screen.mo7"
scr_mo7_len	=	. - scr_mo7
