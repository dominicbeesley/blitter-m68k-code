
; NOTE: all address fields in the functions are 24 bit big endian rather than 8 bit page followed by 16 bit LE

DEICE_RAM		:=	$A00
COMBUF_SIZE		:=	$80
DEICE_STACK_SIZE	:=	$A0

deice_regs		:= DEICE_RAM
deice_reg_STATUS	:= deice_regs + $00
deice_reg_USP		:= deice_regs + $02
deice_reg_SSP		:= deice_regs + $06
deice_reg_D0		:= deice_regs + $0A
deice_reg_D1		:= deice_regs + $0E
deice_reg_D2		:= deice_regs + $12
deice_reg_D3		:= deice_regs + $16
deice_reg_D4		:= deice_regs + $1A
deice_reg_D5		:= deice_regs + $1E
deice_reg_D6		:= deice_regs + $22
deice_reg_D7		:= deice_regs + $26
deice_reg_A0		:= deice_regs + $2A
deice_reg_A1		:= deice_regs + $2E
deice_reg_A2		:= deice_regs + $32
deice_reg_A3		:= deice_regs + $36
deice_reg_A4		:= deice_regs + $3A
deice_reg_A5		:= deice_regs + $3E
deice_reg_A6		:= deice_regs + $42
deice_reg_SR		:= deice_regs + $46
deice_reg_PC		:= deice_regs + $48
deice_reg_top		:= deice_regs + $4C

deice_run_flag		:= deice_reg_top
deice_ram_top		:= deice_run_flag + 2		; has to be aligned!


COMBUF			:= deice_ram_top
deice_stack		:= COMBUF+COMBUF_SIZE+DEICE_STACK_SIZE


DEICE_STATE_BP		:=	1			; breakpoint
DEICE_STATE_TRACE	:= 	2			; trace
DEICE_STATE_ILLEGAL	:=      3
DEICE_STATE_IRQ_x	:=	$10			; add the irq number to this


*
*======================================================================
*  HARDWARE PLATFORM INDEPENDENT EQUATES AND CODE
*
*  Communications function codes.
FN_GET_STAT	:=	$FF    ; reply with device info
FN_READ_MEM	:=	$FE    ; reply with data
FN_WRITE_M	:=	$FD    ; reply with status (+/-)
FN_READ_RG	:=	$FC    ; reply with registers
FN_WRITE_RG	:=	$FB    ; reply with status
FN_RUN_TARG	:=	$FA    ; reply (delayed) with registers
FN_SET_BYTES	:=	$F9    ; reply with data (truncate if error)
FN_IN		:=	$F8    ; input from port
FN_OUT		:=	$F7    ; output to port
*
FN_MIN		:=	$F7    ; MINIMUM RECOGNIZED FUNCTION CODE
FN_ERROR	:=	$F0    ; error reply to unknown op-code