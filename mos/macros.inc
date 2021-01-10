
		macro DEBUG_INFO
		jsr	deice_print_str
		dc.b	\1
		dc.b	13
		dc.b	0
		align	1
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
		endm	CLC

		macro   SEC
		ori	#$0001,CCR
		endm	CLC

		macro   CLV
		andi	#-3,CCR
		endm	CLV

		macro   SEV
		ori	#$0002,CCR
		endm	SEV


		macro   CLX
		andi	#-17,CCR
		endm	CLC

		macro   SEX
		ori	#$0010,CCR
		endm	CLC



; TODO: these are bad?!?
		macro	CLI
		andi	#$F8FF,SR
		endm

		macro	SEI
		ori	#$0700,SR
		endm
