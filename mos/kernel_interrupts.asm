
		xdef 	kernel_handle_IRQ

		SECTION "code"


kernel_handle_IRQ:
		movem.l	D0-D7/A0-A6,-(A7)
		lea	(str_int_1,PC),A0
		bra	intmsg


str_int_1:	dc.b	"int_1",0
