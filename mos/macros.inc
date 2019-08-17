
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

