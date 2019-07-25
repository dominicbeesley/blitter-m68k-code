		include "kernel_defs.inc"

		xdef	romv_start

		SECTION "romvectors"
romv_start:	
romv_stack:	dc.l	STACK
romv_reset:	dc.l	handle_res
romv_be:	dc.l	handle_bus_err
romv_addr_err:	dc.l	handle_addr_err
romv_illegal:	dc.l	handle_illegal
romv_div0:	dc.l	handle_div0
romv_chk:	dc.l	handle_chk
romv_trapv:	dc.l	handle_trapv
romv_priv:	dc.l	handle_priv
romv_trace:	dc.l	handle_trace
romv_opA:	dc.l	handle_opA
romv_opF:	dc.l	handle_opF
		blk.l	12,0
romv_int_spur	dc.l	handle_int_spur
romv_int_1	dc.l	handle_int_1
romv_int_2	dc.l	handle_int_2
romv_int_3	dc.l	handle_int_3
romv_int_4	dc.l	handle_int_4
romv_int_5	dc.l	handle_int_5
romv_int_6	dc.l	handle_int_6
romv_int_7	dc.l	handle_int_7
romv_trap_0	dc.l	handle_trap_0
romv_trap_1	dc.l	handle_trap_1
romv_trap_2	dc.l	handle_trap_2
romv_trap_3	dc.l	handle_trap_3
romv_trap_4	dc.l	handle_trap_4
romv_trap_5	dc.l	handle_trap_5
romv_trap_6	dc.l	handle_trap_6
romv_trap_7	dc.l	handle_trap_7
romv_trap_8	dc.l	handle_trap_8
romv_trap_9	dc.l	handle_trap_9
romv_trap_A	dc.l	handle_trap_A
romv_trap_B	dc.l	handle_trap_B
romv_trap_C	dc.l	handle_trap_C
romv_trap_D	dc.l	handle_trap_D
romv_trap_E	dc.l	handle_trap_E
romv_trap_F	dc.l	handle_trap_F
		blk.l	16,0
