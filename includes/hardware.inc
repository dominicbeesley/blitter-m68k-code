; beeb6809 hardware locations and constants

rti_opcode		:=	$3B

JIM			:=	$FD00

* mos ROM memory map location
sheila_ROMCTL_SWR	:=	$FE30
sheila_ROMCTL_MOS	:=	$FE31
sheila_MEM_DEBUG_SAVE	:=	$FE32

ROMCTL_BITS_FLEX	:=	$10

	IF MACH_BEEB
BITS_MEM_CTL_SWMOS		:= $01
BITS_MEM_CTL_JIMEN		:= $02
BITS_MEM_CTL_SWMOS_DEBUG	:= $04
BITS_MEM_CTL_SWMOS_DEBUG_EN	:= $08
BITS_MEM_CTL_FLEX		:= $10
BITS_MEM_CTL_SWMOS_DEBUG_5C	:= $40
BITS_MEM_CTL_SWMOS_DEBUG_ACT	:= $80

fred_JIM_DEVNO		:=	$FCFF
fred_JIM_PAGE_HI	:=	$FCFD
fred_JIM_PAGE_LO	:=	$FCFE
	
sheila_NULA_CTLAUX	:=	$FE22
sheila_NULA_PALAUX	:=	$FE23

sheila_DEBUG		:=	$FEFF


sheila_MEM_LOMEMTURBO	:=	$FE37


sheila_BLTCFG0		:=	$FE3E
sheila_BLTCFG1		:=	$FE3F
BLTCFG0_T65		:=	$01
BLTCFG0_CPU_6502A_2M	:=	$00
BLTCFG0_CPU_65C02_4M	:=	$02
BLTCFG0_CPU_65C02_8M	:=	$04
BLTCFG0_CPU_6x09_2M	:=	$08
BLTCFG0_CPU_6309_4M	:=	$0A
BLTCFG0_CPU_Z80_8M	:=	$0C
BLTCFG0_CPU_68008	:=	$0E
BLTCFG0_SWROMX		:=	$10
BLTCFG0_BUGBTN		:=	$80

BLTCFG1_MEMI		:=	$01
BLTCFG1_BUGOUT		:=	$02


	ENDIF

	IF MACH_CHIPKIT
sheila_ROMCTL_RAM	:=	$FE32
sheila_MEMC_SCROFF	:=	$FE33
	ENDIF



* HARDWARELOC - area of RAM used for memory mapped hardware
HARDWARELOC				:= $FC00
HARDWARELOC_END				:= $FEFF

* Where the remapped 6809 vectors live, the hardware remaps
* the 6809 hardware vectors to avoid the OS calls in the original 6502 memory map
REMAPPED_HW_VECTORS			:= $F7F0

OFF_SWI_VEC	:=	$A
OFF_NMI_VEC	:=	$C
OFF_RES_VEC	:=	$E
HW_VECTOR_COUNT	:=	8

***********************************************************************
* CRTC                                                                *
***********************************************************************
sheila_CRTC_reg				:= $FE00
sheila_CRTC_rw				:= $FE01


CRTCR0_HorizontalTotal        		:=  	 0	; 8b WO m0-3:127 m4-7:63
CRTCR1_HorizontalDisplayed    		:=	 1	; 8b WO m0-3:80  m4-7:40
CRTCR2_HorizontalSyncPosition 		:=	 2	; 8b WO m0-3:98  m4-6:49 m7:51
CRTCR3_SyncPulseWidths        		:=	 3	; Horizontal sync pulse width b0-3 WO m0-3:8 m4-7:4, Vertical sync pulse width b4-7 WO Always 2
CRTCR4_VerticalTotal          		:=	 4	; 7b WO m0-2,4-5:38 m3,6-7:30
CRTCR5_VerticalTotalAdjust    		:=	 5	; 5b WO m0-7:0
CRTCR6_VerticalDisplayed      		:=	 6	; 7b WO m0-2,4-5:32 m3,6-7:25
CRTCR7_VerticalSyncPosition   		:=	 7	; 7b WO m0-2,4-5:34 m3,6-7:27
CRTCR8_InterlaceAndControl    		:=	 8	; Interlace modes        b0-1 00,10 non-interlaced, m0-6 01 Interlace sync, m7 11 Interlace sync and video
CRTCR9_CharacterScanLines     		:=	 9	; 5b WO m0-2,4-5:7 m3,6:9 m7:18
CRTCR10_CursorControlStart    		:=	10	; 7b WO b7 unused b6 blink enable b5 blink fast b0-4 crsr start line
CRTCR11_CursorEnd             		:=	11	; 5b WO crsr end line
CRTCR12_Screen1stCharHi       		:=	12	; 6b WO hi byte of (start of screen address)/8
CRTCR13_Screen1stCharLo       		:=	13	; 8b WO lo byte of (start of screen address)/8

***********************************************************************
* Simple Video ULA                                                    *
***********************************************************************
sheila_VIDULA_ctl			:= $FE20
sheila_VIDULA_pal			:= $FE21
	IF MACH_CHIPKIT
sheila_VIDULA_pixand			:= $FE22
sheila_VIDULA_pixeor			:= $FE23
sheila_VIDULA_ttx			:= $FE24

sheila_RAMDAC_ADDR_WR			:= $FE28
sheila_RAMDAC_VAL			:= $FE29
sheila_RAMDAC_PIXMASK			:= $FE2A
sheila_RAMDAC_ADDR_RD			:= $FE2B
	ENDIF

***********************************************************************
* VIA constants                                                       *
***********************************************************************

VIA_MASK_INT_CA2			:=	$01
VIA_MASK_INT_CA1			:=	$02
VIA_MASK_INT_SR				:=	$04
VIA_MASK_INT_CB2			:=	$08
VIA_MASK_INT_CB1			:=	$10
VIA_MASK_INT_T2				:=	$20
VIA_MASK_INT_T1				:=	$40
VIA_MASK_INT_IRQ			:=	$80

SYSVIA_MASK_INT_VSYNC			:=	VIA_MASK_INT_CA1

***********************************************************************
* System VIA                                                          *
***********************************************************************
sheila_SYSVIA_orb			:= $FE40
sheila_SYSVIA_ora			:= $FE41
sheila_SYSVIA_ddrb			:= $FE42
sheila_SYSVIA_ddra			:= $FE43
sheila_SYSVIA_t1cl			:= $FE44
sheila_SYSVIA_t1ch			:= $FE45
sheila_SYSVIA_t1ll			:= $FE46
sheila_SYSVIA_t1lh			:= $FE47
sheila_SYSVIA_t2cl			:= $FE48
sheila_SYSVIA_t2ch			:= $FE49
sheila_SYSVIA_sr			:= $FE4A
sheila_SYSVIA_acr			:= $FE4B
sheila_SYSVIA_pcr			:= $FE4C
sheila_SYSVIA_ifr			:= $FE4D
sheila_SYSVIA_ier			:= $FE4E
sheila_SYSVIA_ora_nh			:= $FE4F

***********************************************************************
* SYS VIA - slow data bus RTC                                         *
***********************************************************************

	IF MACH_CHIPKIT
BITS_RTC_AS_ON	:=		$88			; PB7
BITS_RTC_AS_OFF :=		$08			;
BITS_RTC_CS	:=		$04			; latch
BITS_RTC_DS	:=		$02			; latch
BITS_RTC_RnW	:=		$01			; latch
BITS_LAT_ON	:=		$08			; latch

RTC_REG_SECONDS	:=		$0
RTC_REG_MINUTES	:=		$2
RTC_REG_HOURS	:=		$4
RTC_REG_DOW	:=		$6
RTC_REG_DAY	:=		$7
RTC_REG_MONTH	:=		$8
RTC_REG_YEAR	:=		$9
	ENDIF


***********************************************************************
* User VIA                                                            *
***********************************************************************
sheila_USRVIA_orb			:= $FE60
sheila_USRVIA_ora			:= $FE61
sheila_USRVIA_ddrb			:= $FE62
sheila_USRVIA_ddra			:= $FE63
sheila_USRVIA_t1cl			:= $FE64
sheila_USRVIA_t1ch			:= $FE65
sheila_USRVIA_t1ll			:= $FE66
sheila_USRVIA_t1lh			:= $FE67
sheila_USRVIA_t2cl			:= $FE68
sheila_USRVIA_t2ch			:= $FE69
sheila_USRVIA_sr			:= $FE6A
sheila_USRVIA_acr			:= $FE6B
sheila_USRVIA_pcr			:= $FE6C
sheila_USRVIA_ifr			:= $FE6D
sheila_USRVIA_ier			:= $FE6E
sheila_USRVIA_ora_nh			:= $FE6F


***********************************************************************
*  VIA constants                                                      *
***********************************************************************

VIA_IFR_BIT_ANY				:= $80
VIA_IFR_BIT_T1				:= $40
VIA_IFR_BIT_T2				:= $20
VIA_IFR_BIT_CB1				:= $10
VIA_IFR_BIT_CB2				:= $08
VIA_IFR_BIT_SR				:= $04
VIA_IFR_BIT_CA1				:= $02
VIA_IFR_BIT_CA2				:= $01


	IF MACH_BEEB
***********************************************************************
* BBC B/B+ WD177x                                                     *
***********************************************************************

sheila_1770_dcontrol	:=	$FE80
sheila_1770_wdc_cmd	:=	$FE84
sheila_1770_wdc_trk	:=	$FE85
sheila_1770_wdc_sec	:=	$FE86
sheila_1770_wdc_dat	:=	$FE87
	ENDIF

***********************************************************************
* TUBE                                                                *
***********************************************************************

sheila_TUBE_R1_STATUS			:= $FEE0
sheila_TUBE_R1_DATA			:= $FEE1
sheila_TUBE_R2_STATUS			:= $FEE2
sheila_TUBE_R2_DATA			:= $FEE3
sheila_TUBE_R3_STATUS			:= $FEE4
sheila_TUBE_R3_DATA			:= $FEE5
sheila_TUBE_R4_STATUS			:= $FEE6
sheila_TUBE_R4_DATA			:= $FEE7


	IF MACH_CHIPKIT
*============================================================================
*  :=ates for memory mapped 16450 serial port 
*============================================================================
S16550			:=	$FE78			; base of 16450 UART
S16550_RXR		:=	S16550+0		; Receiver buffer register
S16550_TXR		:=	S16550+0		; Transmitter buffer register
S16550_IER		:=	S16550+1		; Interrupt enable register
S16550_FCR		:=	S16550+2		; 16550 FIFO control register
S16550_LCR		:=	S16550+3		; Line control register
S16550_MCR		:=	S16550+4		; Modem control register
S16550_DTR		:=	S16550+1		; Bit :=ate used to control status LED
S16550_LSR		:=	S16550+5		; Line status register

SER_BIT_RXRDY		:=	$01            ; BIT MASK FOR RX BUFFER FULL
SER_BIT_TXRDY		:=	$20            ; BIT MASK FOR TX BUFFER EMPTY

SER_BAUD_CLOCK_IN	:=	7372800			; fr:=ency of on board serial crystal


sheila_VINC_data	:=	$FE50
sheila_VINC_status	:=	$FE52
VINC_status_TXE		:=	$01
VINC_status_RXF		:=	$02
	ENDIF

	IF MACH_BEEB

* note: this are for Retroclinic DC
sheila_VINC_data	:=	$FCF8
sheila_VINC_status	:=	$FCF9
VINC_status_TXE		:=	$40
VINC_status_RXF		:=	$80

sheila_ACIA_CTL		:=	$FE08
sheila_ACIA_DATA	:=	$FE09
sheila_SERIAL_ULA	:=	$FE10
ACIA_RDRF		:=	$01
ACIA_TDRE		:=	$02


; BLTCON is written in two passes with top bit clear i.e. not BLTCON_ACT_ACT
; the exec flags are first set
; then with top bit set the active flag, bit mode and cell flags are set
; BLTCON/ACT byte flags

BLITCON_ACT_ACT			:=	$80		; always set when setting act constants/execing
BLITCON_ACT_CELL		:=	$40		; cell addressing used i.e. move one byte left adds 8 to address
							; moving one line down either adds 1 byte or STRIDE depending on whether 
							; line crosses an 8 line boundary
BLITCON_ACT_MODE_1BBP		:=	$00		; 1 bit per pixel mapping 2 colours
BLITCON_ACT_MODE_2BBP		:=	$10		; 2 bit per pixel mapping 4 colours
BLITCON_ACT_MODE_4BBP		:=	$20		; 4 bit per pixel mapping 16 colours
BLITCON_ACT_MODE_8BBP		:=	$30		; 8 bit per pixel mapping 256 colours
BLITCON_ACT_LINE		:=	$08		; draw a line
BLITCON_ACT_COLLISION		:=	$04		; gets reset for any non-zero D data (even in EXEC_D is clear) 


BLITCON_LINE_MAJOR_UPnRIGHT	:=	$10		; line draw major axis is up
BLITCON_LINE_MINOR_CCW		:=	$20		; minor axis is CCW to MAJOR i.e. left when maj up, up when maj right
							; otherwise 			  right when maj up, down when maj right


BLITCON_EXEC_A			:=	$01
BLITCON_EXEC_B			:=	$02
BLITCON_EXEC_C			:=	$04
BLITCON_EXEC_D			:=	$08
BLITCON_EXEC_E			:=	$10

; DMA controller control flags
DMACTL_ACT			:=	$80		; always set to initiate a transfer
DMACTL_EXTEND			:=	$20		; use extended functions from control2
DMACTL_HALT			:=	$10		; halt cpu during transfer
DMACTL_STEP_DEST_NONE		:=	$00		; do not step destination address
DMACTL_STEP_DEST_UP		:=	$04		; step destination up after transfer
DMACTL_STEP_DEST_DOWN		:=	$08		; step destination down after transfer
DMACTL_STEP_DEST_RESV		:=	$0C		; reserved do not use
DMACTL_STEP_SRC_NONE		:=	$00		; do not step destination address
DMACTL_STEP_SRC_UP		:=	$01		; step destination up after transfer
DMACTL_STEP_SRC_DOWN		:=	$02		; step destination down after transfer
DMACTL_STEP_SRC_RESV		:=	$03		; reserved do not use

DMACTL2_IF			:=	$80		; interrupt occurred
DMACTL2_IE			:=	$02		; interrupt enable, interrupt after transfer
DMACTL2_SZ_BYTE			:=	$00
DMACTL2_SZ_WORD			:=	$04
DMACTL2_SZ_WORDSWAPDEST		:=	$08
DMACTL2_SZ_WORDSWAPSRC		:=	$0C
DMACTL2_PAUSE			:=	$01

; Sound Status / control bits
SND_CTL_ACT			:=	$80
SND_CTL_REPEAT			:=	$01


DMAC_BLITCON_offs		:=	0
DMAC_FUNCGEN_offs		:=	$1
DMAC_WIDTH_offs			:=	$2
DMAC_HEIGHT_offs		:=	$3
DMAC_SHIFT_offs			:=	$4
DMAC_MASK_FIRST_offs		:=	$5
DMAC_MASK_LAST_offs		:=	$6
DMAC_DATA_A_offs		:=	$7
DMAC_ADDR_A_offs		:=	$8
DMAC_DATA_B_offs		:=	$B
DMAC_ADDR_B_offs		:=	$C
DMAC_ADDR_C_offs		:=	$F
DMAC_ADDR_D_offs		:=	$12
DMAC_ADDR_E_offs		:=	$15
DMAC_STRIDE_A_offs		:=	$18
DMAC_STRIDE_B_offs		:=	$1A
DMAC_STRIDE_C_offs		:=	$1C
DMAC_STRIDE_D_offs		:=	$1E

DMAC_SND_DATA_offs		:=	$20
DMAC_SND_ADDR_offs		:=	$21
DMAC_SND_PERIOD_offs		:=	$24
DMAC_SND_LEN_offs		:=	$26
DMAC_SND_STATUS_offs		:=	$28
DMAC_SND_VOL_offs		:=	$29
DMAC_SND_REPOFF_offs		:=	$2A
DMAC_SND_PEAK_offs		:=	$2C

DMAC_SND_MA_VOL_offs		:=	$2E
DMAC_SND_SEL_offs		:=	$2F

DMAC_DMA_CTL_offs		:=	$30
DMAC_DMA_SRC_ADDR_offs		:=	$31
DMAC_DMA_DEST_ADDR_offs		:=	$34
DMAC_DMA_COUNT_offs		:=	$37
DMAC_DMA_DATA_offs		:=	$39
DMAC_DMA_CTL2_offs		:=	$3A
DMAC_DMA_PAUSE_offs		:=	$3B
DMAC_DMA_SEL_offs		:=	$3F

jim_page_DMAC			:=	$FEFC		; hardware jim page
jim_DMAC			:=	$FD60		; jim location in SYS map

jim_DMAC_BLITCON		:=	jim_DMAC + DMAC_BLITCON_offs
jim_DMAC_FUNCGEN		:=	jim_DMAC + DMAC_FUNCGEN_offs
jim_DMAC_WIDTH			:=	jim_DMAC + DMAC_WIDTH_offs
jim_DMAC_HEIGHT			:=	jim_DMAC + DMAC_HEIGHT_offs
jim_DMAC_SHIFT			:=	jim_DMAC + DMAC_SHIFT_offs
jim_DMAC_MASK_FIRST		:=	jim_DMAC + DMAC_MASK_FIRST_offs
jim_DMAC_MASK_LAST		:=	jim_DMAC + DMAC_MASK_LAST_offs
jim_DMAC_DATA_A			:=	jim_DMAC + DMAC_DATA_A_offs
jim_DMAC_ADDR_A			:=	jim_DMAC + DMAC_ADDR_A_offs
jim_DMAC_DATA_B			:=	jim_DMAC + DMAC_DATA_B_offs
jim_DMAC_ADDR_B			:=	jim_DMAC + DMAC_ADDR_B_offs
jim_DMAC_ADDR_C			:=	jim_DMAC + DMAC_ADDR_C_offs
jim_DMAC_ADDR_D			:=	jim_DMAC + DMAC_ADDR_D_offs
jim_DMAC_ADDR_E			:=	jim_DMAC + DMAC_ADDR_E_offs
jim_DMAC_STRIDE_A		:=	jim_DMAC + DMAC_STRIDE_A_offs
jim_DMAC_STRIDE_B		:=	jim_DMAC + DMAC_STRIDE_B_offs
jim_DMAC_STRIDE_C		:=	jim_DMAC + DMAC_STRIDE_C_offs
jim_DMAC_STRIDE_D		:=	jim_DMAC + DMAC_STRIDE_D_offs

jim_DMAC_SND_DATA		:=	jim_DMAC + DMAC_SND_DATA_offs
jim_DMAC_SND_ADDR		:=	jim_DMAC + DMAC_SND_ADDR_offs
jim_DMAC_SND_PERIOD		:=	jim_DMAC + DMAC_SND_PERIOD_offs
jim_DMAC_SND_LEN		:=	jim_DMAC + DMAC_SND_LEN_offs
jim_DMAC_SND_STATUS		:=	jim_DMAC + DMAC_SND_STATUS_offs
jim_DMAC_SND_VOL		:=	jim_DMAC + DMAC_SND_VOL_offs
jim_DMAC_SND_REPOFF		:=	jim_DMAC + DMAC_SND_REPOFF_offs
jim_DMAC_SND_PEAK		:= 	jim_DMAC + DMAC_SND_PEAK_offs


jim_DMAC_SND_SEL		:=	jim_DMAC + DMAC_SND_SEL_offs
jim_DMAC_SND_MA_VOL		:=	jim_DMAC + DMAC_SND_MA_VOL_offs

jim_DMAC_DMA_CTL		:=	jim_DMAC + DMAC_DMA_CTL_offs
jim_DMAC_DMA_SRC_ADDR		:=	jim_DMAC + DMAC_DMA_SRC_ADDR_offs
jim_DMAC_DMA_DEST_ADDR		:=	jim_DMAC + DMAC_DMA_DEST_ADDR_offs
jim_DMAC_DMA_COUNT		:=	jim_DMAC + DMAC_DMA_COUNT_offs
jim_DMAC_DMA_DATA		:=	jim_DMAC + DMAC_DMA_DATA_offs
jim_DMAC_DMA_CTL2		:=	jim_DMAC + DMAC_DMA_CTL2_offs
jim_DMAC_DMA_PAUSE		:=	jim_DMAC + DMAC_DMA_PAUSE_offs
jim_DMAC_DMA_SEL		:=	jim_DMAC + DMAC_DMA_SEL_offs

JIM_DEVNO_HOG1MPAULA		:=	$D0
JIM_DEVNO_BLITTER		:=	$D1


	ENDIF