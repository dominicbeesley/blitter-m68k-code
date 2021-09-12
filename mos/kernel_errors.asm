
	macro ERROR_BLOCK label, num, string
	xdef	\1
\1:
	dc.l	\2
	dc.b	\3
	dc.b	0
	align	1
	endm

	SECTION "code"	        

	ERROR_BLOCK	err_escape, $11, "Escape"
