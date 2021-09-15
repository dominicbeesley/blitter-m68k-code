
		macro DEBUG_INFO
		jsr	deice_print_str
		dc.b	\1
		dc.b	13
		dc.b	0
		align	1
		endm

		macro DEBUG_TODO
		jsr	deice_print_str
		dc.b	"TODO: "
		dc.b	\1
		dc.b	13
		dc.b	0
		align	1
.lp\@		stop	#$2000
		bra	.lp\@
		endm


		macro DEBUG_INFO_S
		jsr	deice_print_str
		dc.b	\1
		dc.b	0
		align	1
		endm


		macro TRACE
		trap	#14
		nop
		endm

		macro   CLC
		andi	#-2,CCR
		endm	

		macro   SEC
		ori	#$0001,CCR
		endm	

		macro   CLV
		andi	#-3,CCR
		endm	

		macro   SEV
		ori	#$0002,CCR
		endm	


		macro   CLX
		andi	#-17,CCR
		endm	

		macro   SEX
		ori	#$0010,CCR
		endm	



; TODO: these are bad?!?
		macro	CLI
		andi	#$F8FF,SR
		endm

		macro	SEI
		ori	#$0700,SR
		endm
