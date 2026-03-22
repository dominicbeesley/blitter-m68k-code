
		xdef	romv_start
		xdef	romv_size
		xdef	romv_size_words

		SECTION "romvectors"
romv_start:	
romv_stack:	dc.l	STACK
romv_reset:	dc.l	kernel_handle_res
romv_be:		dc.l	handle_unex
romv_addr_err:	dc.l	handle_unex
romv_illegal:	dc.l	handle_unex
romv_div0:	dc.l	handle_unex
romv_chk:	dc.l	handle_unex
romv_trapv:	dc.l	handle_unex
romv_priv:	dc.l	handle_unex
romv_trace:	dc.l	handle_unex
romv_opA:	dc.l	handle_unex
romv_opF:	dc.l	handle_unex
		blk.l	12,0
romv_int_spur	dc.l	handle_unex
romv_int_1	dc.l	handle_unex
romv_int_2	dc.l	handle_unex
romv_int_3	dc.l	handle_unex
romv_int_4	dc.l	handle_unex
romv_int_5	dc.l	handle_unex
romv_int_6	dc.l	handle_unex
romv_int_7	dc.l	handle_unex
romv_trap_0	dc.l	handle_unex
romv_trap_1	dc.l	handle_unex
romv_trap_2	dc.l	handle_unex
romv_trap_3	dc.l	handle_unex
romv_trap_4	dc.l	handle_unex
romv_trap_5	dc.l	handle_unex
romv_trap_6	dc.l	handle_unex
romv_trap_7	dc.l	handle_unex
romv_trap_8	dc.l	handle_unex
romv_trap_9	dc.l	handle_unex
romv_trap_A	dc.l	handle_unex
romv_trap_B	dc.l	handle_unex
romv_trap_C	dc.l	handle_unex
romv_trap_D	dc.l	handle_unex
romv_trap_E	dc.l	handle_unex
romv_trap_F	dc.l	handle_unex
		blk.l	16,0
romv_end:
romv_size	:= 256
romv_size_words := romv_size/4
