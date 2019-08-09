		xdef		deice_init
		xdef		deice_enter
		xdef		deice_print

		include		"hardware.inc"
		include		"deice.inc"


		section	"code"

deice_init
		; set up BBC's ACIA for RTS/CTS at 19200 baud - later use OS routines when available
		move.b	#$40, 		sheila_SERIAL_ULA	; 19200,19200
		move.b	#%01010111,	sheila_ACIA_CTL		; master reset
		move.b	#%01010110,	sheila_ACIA_CTL		; RTS high, no interrupts, 8N1, div64
		rts


deice_print
		movem.l	D0/D4/D5,-(A7)
		and.b	#$7F,D0
		jsr	PUTCHAR
		movem.l (A7)+,D0/D4/D5
		rts

*
*===========================================================================
*  Get a character to D0.b
*
*  Return D0.b=char, CY=0 if data received
*	  CY=1 if timeout (0.5 seconds)
*  Corrupts D1,D2
GETCHAR		
		moveq	#-1,D5			; LONG TIMEOUT
.GC10		move.b	sheila_ACIA_CTL,D4
		andi.b	#ACIA_RDRF,D4
		dbne	D5,.GC10
		beq	SEC
		move.b	sheila_ACIA_DATA,D0	; clears Cy		
		rts
SEC		or.b	#$0001,CCR
		rts

PUTCHAR		
		moveq	#-1,D5			; LONG TIMEOUT
.PC10		move.b	sheila_ACIA_CTL,D4
		andi.b	#ACIA_TDRE,D4
		dbne	D5,.PC10
		beq	SEC
		move.b	D0,sheila_ACIA_DATA	; clears Cy		
		rts

*======================================================================
*  Response string for GET TARGET STATUS request
*  Reply describes target:
TSTG	
		dc.b	68			; 2: PROCESSOR TYPE = 68k
		dc.b	COMBUF_SIZE		; 3: SIZE OF COMMUNICATIONS BUFFER
		dc.b	0			; 4: NO TASKING SUPPORT
		dc.w	0,$FFFF			; 5-8: LOW AND HIGH LIMIT OF MAPPED MEM (NONE)		-- note 68008 has 24 bit address space "paging" register is just the high MSB!
		dc.b	B1-B0			; 9:  BREAKPOINT INSTR LENGTH
B0		trap	#0			; 10: BREAKPOINT INSTRUCTION
B1		
		dc.b	"68008"
		dc.b	" monitor V1.1"	; DESCRIPTION, ZERO
		dc.b	"-BBC"
		dc.b	0 
TSTG_SIZE	:=	*-TSTG		; SIZE OF STRING

		align	2

*
*===========================================================================
*  Common handler for default interrupt handlers
*  Enter with D0=interrupt code = processor state
*  All registers stacked, PC=next instruction
*
deice_enter	
INT_ENTRY
		lea.l	deice_reg_top-deice_reg_D0(A7),A0	; calc original stack pointer
		move.l	A0,-(A7)				; and save as supervisor stack
		move.l	USP,A0					; user stack
		move.l	A0,-(A7)				; and save		
		move.b	D0,-(A7)				; status byte (saved as word)
INT_ENTRY_GO
*  Save stacked registers from stack to reg block for return to master
* note we don't bugger about with endianness leave everything big endian
		moveq	#deice_reg_top-deice_regs-1, D1
		movea.l	A7,A0
		lea.l	deice_regs,A1
.lp		move.b	(A0)+,(A1)+
		dbf	D1,.lp

		; reset svc stack to local stack - this will allow us to alter
		; the real stack areas without conflict

		lea.l	deice_stack,A7 			

ENTER_MON	moveq	#FN_RUN_TARG,D0
		bra	RETURN_REGS

MAIN		lea.l	deice_stack,A7 
		lea.l	COMBUF,A0

		bsr	GETCHAR
		bcs	MAIN
		cmp.b	#FN_MIN,D0
		blo	MAIN

		move.b	D0,(A0)+
*
*  Second byte is data byte count (may be zero)
		bsr	GETCHAR			; GET A LENGTH BYTE
		bcs	MAIN			; JIF TIMEOUT: RESYNC
		cmp.b	#COMBUF_SIZE,D0
		bhi	MAIN			; JIF TOO LONG: ILLEGAL LENGTH
		move.b	D0,(A0)+			; SAVE LENGTH
		beq	MA80			; SKIP DATA LOOP IF LENGTH = 0
*
*  Loop for data
		clr.w	D1
		move.b	D0,D1			; SAVE LENGTH FOR LOOP
		subq.w	#1,D1
MA10		bsr	GETCHAR			; GET A DATA BYTE
		bcs	MAIN			; JIF TIMEOUT: RESYNC
		move.b	D0,(A0)+		; SAVE DATA BYTE
		dbf	D1,MA10
*
*  Get the checksum
MA80		bsr	GETCHAR			; GET THE CHECKSUM
		bcs	MAIN			; JIF TIMEOUT: RESYNC
		move.b	D0,D2			; SAVE CHECKSUM
*
*  Compare received checksum to that calculated on received buffer
*  (Sum should be 0)
		bsr	CHECKSUM
		add.b	D0,D2			; ADD SAVED CHECKSUM TO COMPUTED
		bne	MAIN			; JIF BAD CHECKSUM

*
*  Process the message.
		lea	COMBUF,A0
		move.b	(A0)+,D0		; GET THE FUNCTION CODE
		clr.w	D1
		move.b 	(A0)+,D1		; GET THE LENGTH
		cmp.b	#FN_GET_STAT,D0
		beq	TARGET_STAT
		cmp.b	#FN_READ_MEM,D0
		beq	READ_MEM
		cmp.b	#FN_WRITE_M,D0
		beq	WRITE_MEM
		cmp.b	#FN_READ_RG,D0
		beq	READ_REGS
		cmp.b	#FN_WRITE_RG,D0
		beq	WRITE_REGS
		cmp.b	#FN_RUN_TARG,D0
		beq	RUN_TARGET
		cmp.b	#FN_SET_BYTE,D0
		beq	SET_BYTES
		cmp.b	#FN_IN,D0
		beq	IN_PORT
		cmp.b	#FN_OUT,D0
		beq	OUT_PORT
*
*  Error: unknown function.  Complain
		move.b	#FN_ERROR,D0
		move.b	D0,COMBUF		; SET FUNCTION AS "ERROR"
		moveq	#1,D0
		bra	SEND_STATUS		; VALUE IS "ERROR"

*===========================================================================
*
*  Target Status:  FN, len
*
*  Entry with A=function code, B=data size, X=COMBUF+2
*
TARGET_STAT
		lea	TSTG,A0			; DATA FOR REPLY
		lea	COMBUF+1,A1		; POINTER TO RETURN BUFFER
		moveq	#TSTG_SIZE,D1		; LENGTH OF REPLY
		move.b	D1,(A1)+		; SET SIZE IN REPLY BUFFER
		subq.w	#1,D1
TS10		move.b	(A0)+,D0		; MOVE REPLY DATA TO BUFFER
		move.b	D0,(A1)+
		dbf	D1,TS10
*
*  Compute checksum on buffer, and send to master, then return
		bra	SEND


GetAddrA1
		clr.l	D0
		move.b	0(a0),D0
		swap	D0			; get PAGE into bit 23..16

*
*  Get address - big endian, non aligned
		move.b	1(a0),D0
		rol.w	#8,D0
		move.b	2(a0),D0
		move.l	D0,A1			; ADDRESS IN A1
		rts

*===========================================================================
*
*  Read Memory:	 FN, len, page, Alo, Ahi, Nbytes
*
*  Entry with A=function code, B=data size, X=COMBUF+2
*
READ_MEM

		bsr	GetAddrA1
*
*  Prepare return buffer: FN (unchanged), LEN, DATA
		clr.w	D1
		move.b	3(A0),D1		; NUMBER OF BYTES TO RETURN
		move.b	D1,COMBUF+1		; RETURN LENGTH = REQUESTED DATA	
		beq	GLP90			; JIF NO BYTES TO GET
		subq	#1,D1
*
*  Read the requested bytes from local memory
GLP		move.b	(A1)+,(A0)+		; GET BYTE and STORE TO RETURN BUFFER
		dbf	D1,GLP
*
*  Compute checksum on buffer, and send to master, then return
GLP90		JMP	SEND


*===========================================================================
*
*  Write Memory:  FN, len, page, Alo, Ahi, (len-3 bytes of Data)
*
*  Entry with A=function code, B=data size, X=COMBUF+2
*
*  Uses 6 bytes of stack
*
WRITE_MEM

		bsr	GetAddrA1

*
*  Compute number of bytes to write
		clr.w	D1
		move.b	COMBUF+1,D1		; NUMBER OF BYTES TO RETURN
		subq.w	#3,D1			; MINUS PAGE AND ADDRESS and 1 for good luck
		bmi	WLP50			; JIF NO BYTES TO PUT

*
*  Write the specified bytes to local memory
		movem.l	D1/A0/A1,-(A7)
WLP		move.b	(A0)+,(A1)+		; GET BYTE TO WRITE and STORE THE BYTE AT ,Y
		dbf	D1,WLP
*
*  Compare to see if the write worked
		movem.l (A7)+,D1/A0/A1
WLP20		cmp.b	(A0)+,(A1)+		; compare 
		bne	WLP80			; BR IF WRITE FAILED
		dbf	D1,WLP20
*
*  Write succeeded:  return status = 0
WLP50		clr.b	D0			; RETURN STATUS = 0
		BRA	SEND_STATUS
*
*  Write failed:  return status = 1
WLP80		moveq	#1,D0

*  Return OK status
WLP90		bra	SEND_STATUS

*===========================================================================
*
*  Read registers:  FN, len=0
*
*  Entry with A=function code, B=data size, X=COMBUF+2
*
READ_REGS
		; enter with D0 is function code to return either FN_RUN_TARG or FN_READ_REGS
RETURN_REGS	lea.l	deice_regs,A1
		lea.l	COMBUF,A0
		moveq	#deice_reg_top-deice_regs,D1
		move.b	D0,(A0)+			; store fn
		move.b	D1,(A0)+			; store data len
		subq.w	#1,D1				; adjust for dbf
.lp		move.b	(A1)+,(A0)+
		dbf	D1,.lp
		bra	SEND


*===========================================================================
*
*  Write registers:  FN, len, (register image)
*
*  Entry with A=function code, B=data size, X=COMBUF+2
*
WRITE_REGS
*
		subq	#1,D1

						; NUMBER OF BYTES
		bmi	WRR80			; JIF NO REGISTERS
*
*  Copy the registers
		lea.l	deice_regs,A1		; POINTER TO REGISTERS
WRRLP		move.b	(A0)+,D0		; GET BYTE TO A
		move.b	D0,(A1)+		; STORE TO REGISTER RAM

		dbf	D1,WRRLP
*
*  Return OK status
WRR80		clr.b	D0
		bra	SEND_STATUS



*===========================================================================
*
*  Run Target:	FN, len
*
*  Entry with A=function code, B=data size, X=COMBUF+2
*
RUN_TARGET

*
*  Switch to user stack


		move.l	deice_reg_USP,A0	; restore user stack
		move.l	A0,USP			

		lea.l	deice_reg_D0,A7
		movem.l	(A7)+,D0-D7/A0-A6

		move.l	deice_reg_SSP,A7	; restore supervisor stack
		suba.l	#6,A7			; adjust for RTI


		rte


*===========================================================================
*
*  Set target byte(s):	FN, len { (page, ahi, alow, data), (...)... }  - note address sense reversed from noice
*
*  Entry with D0=function code, D1=data size, A0=COMBUF+2
*
*  Return has FN, len, (data from memory locations)
*
*  If error in insert (memory not writable), abort to return short data
*
*  This function is used primarily to set and clear breakpoints
*
*  
*
SET_BYTES

		lea	COMBUF+1,A1		; POINTER TO RETURN BUFFER
		
		clr.b	(A1)+			; SET RETURN COUNT AS ZERO
		lsr.b	D1
		lsr.b	D1			; LEN/4 = NUMBER OF BYTES TO SET
		subq	#1,D1
		bmi	SB99			; JIF NO BYTES (COMBUF+1 = 0)
*
*  Loop on inserting bytes
SB10		
		; get address (big endian)
		clr.l	D2
		move.b	(A0)+,D2
		swap	D2
		move.b	(A0)+,D2
		rol.w	#8,D2
		move.b	(A0)+,D2
		move.l	D2,A2

*
*  Read current data at byte location
		move.b	(A2),D2
*
*  Insert new data at byte location
		move.b	(A0),D0			; GET BYTE TO STORE	
		move.b	D0,(A2)			; WRITE TARGET MEMORY
*
*  Verify write
		cmp.b	(A2),D0			; READ TARGET MEMORY

		bne	SB90			; BR IF INSERT FAILED: ABORT
*
*  Save target byte in return buffer
		move.b	D2,(A1)+
		addi.b	#1,COMBUF+1		; COUNT ONE RETURN BYTE
*
*  Loop for next byte
		dbf	D1,SB10			; *LOOP FOR ALL BYTES
*
*  Return buffer with data from byte locations
SB90
*
*  Compute checksum on buffer, and send to master, then return
SB99		bra	SEND


*===========================================================================
*
*  Input from port:  FN, len, PortAddressHi, PAlo (=0)	- note BigEndian
*
*  While the 68008 has no input or output instructions, we retain these
*  to allow write-without-verify, this always reads from address $FFFFxxxx
*
*  Entry with A=function code, B=data size, X=COMBUF+2
*
IN_PORT
*
*  Get port address
		moveq	#-1,D2
		move.b	(A0)+,D2
		rol.w	#8,D2
		move.b	(A0)+,D2
		move.l	D2,A1

*
*  Read the requested byte from local memory
		move.b	(A1),D0
*
*  Return byte read as "status"
		bra	SEND_STATUS

*===========================================================================
*
*  Output to port  FN, len, PortAddressHi, PAlo (=0)	- note BigEndian
*
*  While the 68008 has no input or output instructions, we retain these
*  to allow write-without-verify, this writes from address $FFFFxxxx
*
*  Entry with A=function code, B=data size, X=COMBUF+2
*
OUT_PORT
*
*  Get port address
		moveq	#-1,D2
		move.b	(A0)+,D2
		rol.w	#8,D2
		move.b	(A0)+,D2
		move.l	D2,A1
*
*  Get data
		move.b	(A0)+,D0
*
*  Write value to port
		move.b	D0,(A1)
*
*  Do not read port to verify (some I/O devices don't like it)
*
*  Return status of OK
		clr.b	D0
		bra	SEND_STATUS

*===========================================================================
*  Build status return with value from D0
*
SEND_STATUS
		move.b	D0,COMBUF+2		; SET STATUS
		move.b	#1,COMBUF+1		; SET LENGTH
		bra	SEND

*===========================================================================
*  Append checksum to COMBUF and send to master
*
SEND		bsr	CHECKSUM		; GET A=CHECKSUM, X->checksum location
		neg	D0
		move.b	D0,(A0)			; STORE NEGATIVE OF CHECKSUM
*
*  Send buffer to master
		lea.l	COMBUF,A0		; POINTER TO DATA
		clr.w	D1
		move.b	1(A0),D1		; LENGTH OF DATA
		addq.w	#3-1,D1			; PLUS FUNCTION, LENGTH, CHECKSUM
.lp		move.b	(A0)+,D0
		bsr	PUTCHAR			; SEND A BYTE
		dbf	D1,.lp
		bra	MAIN			; BACK TO MAIN LOOP

*===========================================================================
*  Compute checksum on COMBUF.	COMBUF+1 has length of data,
*  Also include function byte and length byte
*
*  Returns:
*	A = checksum
*	X = pointer to next byte in buffer (checksum location)
*	B is scratched
*
CHECKSUM
		lea.l	COMBUF,A0		; pointer to buffer
		clr.w	D1
		move.b	1(A0),D1		; length of message
		addq.w	#2-1,D1			; plus function, length
		clr.b	D0			; init checksum to 0
.lp		add.b	(A0)+,D0
		dbf	D1,.lp
		rts				; return with checksum in A



