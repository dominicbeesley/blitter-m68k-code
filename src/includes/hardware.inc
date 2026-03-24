/* beeb68008 hardware locations and constants */


/* flags register bit masks */
#define CC_C_M	0x0001
#define CC_V_M	0x0002
#define CC_Z_M	0x0004
#define CC_N_M	0x0008
#define CC_X_M	0x0010
#define SR_I0_M	0x0100
#define SR_I1_M	0x0200
#define SR_I2_M	0x0400
#define SR_S_M	0x2000
#define SR_T_M	0x8000


/* flags register bit indices */
#define	CC_C_B	0
#define	CC_V_B	1
#define	CC_Z_B	2
#define	CC_N_B	3
#define	CC_X_B	4
#define	SR_I0_B	8
#define	SR_I1_B	9
#define	SR_I2_B	10
#define	SR_S_B	13
#define	SR_T_B	15



#define	JIM	0xFFFFFD00

* mos ROM memory map location
#define	sheila_ROMCTL_SWR	0xFFFFFE30
#define	sheila_ROMCTL_MOS	0xFFFFFE31
#define	sheila_MEM_DEBUG_SAVE	0xFFFFFE32

#define ROMCTL_BITS_FLEX	0x10

#define	BITS_MEM_CTL_SWMOS		0x01
#define	BITS_MEM_CTL_JIMEN		0x02
#define	BITS_MEM_CTL_SWMOS_DEBUG	0x04
#define	BITS_MEM_CTL_SWMOS_DEBUG_EN	0x08
#define	BITS_MEM_CTL_FLEX		0x10
#define	BITS_MEM_CTL_SWMOS_DEBUG_5C	0x40
#define	BITS_MEM_CTL_SWMOS_DEBUG_ACT	0x80

#define	fred_JIM_DEVNO		0xFFFFFCFF
#define	fred_JIM_PAGE_HI	0xFFFFFCFD
#define	fred_JIM_PAGE_LO	0xFFFFFCFE
	
#define	sheila_NULA_CTLAUX	0xFFFFFE22
#define	sheila_NULA_PALAUX	0xFFFFFE23

#define	sheila_DEBUG		0xFFFFFEFF


#define sheila_MEM_LOMEMTURBO	0xFFFFFE37


#define sheila_BLTCFG0		0xFFFFFE3E
#define sheila_BLTCFG1		0xFFFFFE3F
#define BLTCFG0_T65		0x01
#define BLTCFG0_CPU_6502A_2M	0x00
#define BLTCFG0_CPU_65C02_4M	0x02
#define BLTCFG0_CPU_65C02_8M	0x04
#define BLTCFG0_CPU_6x09_2M	0x08
#define BLTCFG0_CPU_6309_4M	0x0A
#define BLTCFG0_CPU_Z80_8M	0x0C
#define BLTCFG0_CPU_68008	0x0E
#define BLTCFG0_SWROMX		0x10
#define BLTCFG0_BUGBTN		0x80

#define BLTCFG1_MEMI		0x01
#define BLTCFG1_BUGOUT		0x02




/***********************************************************************
* CRTC                                                                *
***********************************************************************/
#define sheila_CRTC_reg		0xFFFFFE00
#define sheila_CRTC_rw		0xFFFFFE01


#define	CRTCR0_HorizontalTotal        		0	/* 8b WO m0-3:127 m4-7:63 */
#define	CRTCR1_HorizontalDisplayed    		1	/* 8b WO m0-3:80  m4-7:40 */
#define	CRTCR2_HorizontalSyncPosition 		2	/* 8b WO m0-3:98  m4-6:49 m7:51 */
#define	CRTCR3_SyncPulseWidths        		3	/* Horizontal sync pulse width b0-3 WO m0-3:8 m4-7:4, Vertical sync pulse width b4-7 WO Always 2 */
#define	CRTCR4_VerticalTotal          		4	/* 7b WO m0-2,4-5:38 m3,6-7:30 */
#define	CRTCR5_VerticalTotalAdjust    		5	/* 5b WO m0-7:0 */
#define	CRTCR6_VerticalDisplayed      		6	/* 7b WO m0-2,4-5:32 m3,6-7:25 */
#define	CRTCR7_VerticalSyncPosition   		7	/* 7b WO m0-2,4-5:34 m3,6-7:27 */
#define	CRTCR8_InterlaceAndControl    		8	/* Interlace modes        b0-1 00,10 non-interlaced, m0-6 01 Interlace sync, m7 11 Interlace sync and video */
#define	CRTCR9_CharacterScanLines     		9	/* 5b WO m0-2,4-5:7 m3,6:9 m7:18 */
#define	CRTCR10_CursorControlStart    		10	/* 7b WO b7 unused b6 blink enable b5 blink fast b0-4 crsr start line */
#define	CRTCR11_CursorEnd             		11	/* 5b WO crsr end line */
#define	CRTCR12_Screen1stCharHi       		12	/* 6b WO hi byte of (start of screen address)/8 */
#define	CRTCR13_Screen1stCharLo       		13	/* 8b WO lo byte of (start of screen address)/8 */

/***********************************************************************
* Simple Video ULA                                                    *
***********************************************************************/
#define	sheila_VIDULA_ctl			0xFFFFFE20
#define	sheila_VIDULA_pal			0xFFFFFE21

/***********************************************************************
* VIA constants                                                       *
***********************************************************************/

#define VIA_MASK_INT_CA2			0x01
#define VIA_MASK_INT_CA1			0x02
#define VIA_MASK_INT_SR				0x04
#define VIA_MASK_INT_CB2			0x08
#define VIA_MASK_INT_CB1			0x10
#define VIA_MASK_INT_T2				0x20
#define VIA_MASK_INT_T1				0x40
#define VIA_MASK_INT_IRQ			0x80

#define SYSVIA_MASK_INT_VSYNC			VIA_MASK_INT_CA1

/***********************************************************************
* System VIA                                                          *
***********************************************************************/
#define sheila_SYSVIA_orb	0xFFFFFE40
#define sheila_SYSVIA_ora	0xFFFFFE41
#define sheila_SYSVIA_ddrb	0xFFFFFE42
#define sheila_SYSVIA_ddra	0xFFFFFE43
#define sheila_SYSVIA_t1cl	0xFFFFFE44
#define sheila_SYSVIA_t1ch	0xFFFFFE45
#define sheila_SYSVIA_t1ll	0xFFFFFE46
#define sheila_SYSVIA_t1lh	0xFFFFFE47
#define sheila_SYSVIA_t2cl	0xFFFFFE48
#define sheila_SYSVIA_t2ch	0xFFFFFE49
#define sheila_SYSVIA_sr	0xFFFFFE4A
#define sheila_SYSVIA_acr	0xFFFFFE4B
#define sheila_SYSVIA_pcr	0xFFFFFE4C
#define sheila_SYSVIA_ifr	0xFFFFFE4D
#define sheila_SYSVIA_ier	0xFFFFFE4E
#define sheila_SYSVIA_ora_nh	0xFFFFFE4F


/***********************************************************************
* User VIA                                                            *
***********************************************************************/
#define sheila_USRVIA_orb	0xFFFFFE60
#define sheila_USRVIA_ora	0xFFFFFE61
#define sheila_USRVIA_ddrb	0xFFFFFE62
#define sheila_USRVIA_ddra	0xFFFFFE63
#define sheila_USRVIA_t1cl	0xFFFFFE64
#define sheila_USRVIA_t1ch	0xFFFFFE65
#define sheila_USRVIA_t1ll	0xFFFFFE66
#define sheila_USRVIA_t1lh	0xFFFFFE67
#define sheila_USRVIA_t2cl	0xFFFFFE68
#define sheila_USRVIA_t2ch	0xFFFFFE69
#define sheila_USRVIA_sr	0xFFFFFE6A
#define sheila_USRVIA_acr	0xFFFFFE6B
#define sheila_USRVIA_pcr	0xFFFFFE6C
#define sheila_USRVIA_ifr	0xFFFFFE6D
#define sheila_USRVIA_ier	0xFFFFFE6E
#define sheila_USRVIA_ora_nh	0xFFFFFE6F


/***********************************************************************
*  VIA constants                                                      *
***********************************************************************/

#define VIA_IFR_BIT_ANY	0x80
#define VIA_IFR_BIT_T1	0x40
#define VIA_IFR_BIT_T2	0x20
#define VIA_IFR_BIT_CB1	0x10
#define VIA_IFR_BIT_CB2	0x08
#define VIA_IFR_BIT_SR	0x04
#define VIA_IFR_BIT_CA1	0x02
#define VIA_IFR_BIT_CA2	0x01


/***********************************************************************
* BBC B/B+ WD177x                                                     *
***********************************************************************/

#define sheila_1770_dcontrol	0xFFFFFE80
#define sheila_1770_wdc_cmd	0xFFFFFE84
#define sheila_1770_wdc_trk	0xFFFFFE85
#define sheila_1770_wdc_sec	0xFFFFFE86
#define sheila_1770_wdc_dat	0xFFFFFE87

/***********************************************************************
* TUBE                                                                *
***********************************************************************/

#define sheila_TUBE_R1_STATUS	0xFFFFFEE0
#define sheila_TUBE_R1_DATA	0xFFFFFEE1
#define sheila_TUBE_R2_STATUS	0xFFFFFEE2
#define sheila_TUBE_R2_DATA	0xFFFFFEE3
#define sheila_TUBE_R3_STATUS	0xFFFFFEE4
#define sheila_TUBE_R3_DATA	0xFFFFFEE5
#define sheila_TUBE_R4_STATUS	0xFFFFFEE6
#define sheila_TUBE_R4_DATA	0xFFFFFEE7



#define sheila_ACIA_CTL	0xFFFFFE08
#define sheila_ACIA_DATA	0xFFFFFE09
#define sheila_SERIAL_ULA	0xFFFFFE10
#define ACIA_RDRF	0x01
#define ACIA_TDRE	0x02


/* BLTCON is written in two passes with top bit clear i.e. not BLTCON_ACT_ACT */
/* the exec flags are first set */
/* then with top bit set the active flag, bit mode and cell flags are set */
/* BLTCON/ACT byte flags */

#define BLITCON_ACT_ACT	0x80		/* always set when setting act constants/execing */
#define BLITCON_ACT_CELL	0x40		/* cell addressing used i.e. move one byte left adds 8 to address */
							/* moving one line down either adds 1 byte or STRIDE depending on whether  */
							/* line crosses an 8 line boundary */
#define BLITCON_ACT_MODE_1BBP	0x00		/* 1 bit per pixel mapping 2 colours */
#define BLITCON_ACT_MODE_2BBP	0x10		/* 2 bit per pixel mapping 4 colours */
#define BLITCON_ACT_MODE_4BBP	0x20		/* 4 bit per pixel mapping 16 colours */
#define BLITCON_ACT_MODE_8BBP	0x30		/* 8 bit per pixel mapping 256 colours */
#define BLITCON_ACT_LINE	0x08		/* draw a line */
#define BLITCON_ACT_COLLISION	0x04		/* gets reset for any non-zero D data (even in EXEC_D is clear)  */


#define BLITCON_LINE_MAJOR_UPnRIGHT	0x10		/* line draw major axis is up */
#define BLITCON_LINE_MINOR_CCW	0x20		/* minor axis is CCW to MAJOR i.e. left when maj up, up when maj right */
							/* otherwise 			  right when maj up, down when maj right */


#define BLITCON_EXEC_A	0x01
#define BLITCON_EXEC_B	0x02
#define BLITCON_EXEC_C	0x04
#define BLITCON_EXEC_D	0x08
#define BLITCON_EXEC_E	0x10

/* DMA controller control flags */
#define DMACTL_ACT	0x80		/* always set to initiate a transfer */
#define DMACTL_EXTEND	0x20		/* use extended functions from control2 */
#define DMACTL_HALT	0x10		/* halt cpu during transfer */
#define DMACTL_STEP_DEST_NONE	0x00		/* do not step destination address */
#define DMACTL_STEP_DEST_UP	0x04		/* step destination up after transfer */
#define DMACTL_STEP_DEST_DOWN	0x08		/* step destination down after transfer */
#define DMACTL_STEP_DEST_RESV	0x0C		/* reserved do not use */
#define DMACTL_STEP_SRC_NONE	0x00		/* do not step destination address */
#define DMACTL_STEP_SRC_UP	0x01		/* step destination up after transfer */
#define DMACTL_STEP_SRC_DOWN	0x02		/* step destination down after transfer */
#define DMACTL_STEP_SRC_RESV	0x03		/* reserved do not use */

#define DMACTL2_IF	0x80		/* interrupt occurred */
#define DMACTL2_IE	0x02		/* interrupt enable, interrupt after transfer */
#define DMACTL2_SZ_BYTE	0x00
#define DMACTL2_SZ_WORD	0x04
#define DMACTL2_SZ_WORDSWAPDEST	0x08
#define DMACTL2_SZ_WORDSWAPSRC	0x0C
#define DMACTL2_PAUSE	0x01

/* Sound Status / control bits */
#define SND_CTL_ACT	0x80
#define SND_CTL_REPEAT	0x01


#define DMAC_BLITCON_offs	0
#define DMAC_FUNCGEN_offs	0x1
#define DMAC_WIDTH_offs	0x2
#define DMAC_HEIGHT_offs	0x3
#define DMAC_SHIFT_offs	0x4
#define DMAC_MASK_FIRST_offs	0x5
#define DMAC_MASK_LAST_offs	0x6
#define DMAC_DATA_A_offs	0x7
#define DMAC_ADDR_A_offs	0x8
#define DMAC_DATA_B_offs	0xB
#define DMAC_ADDR_B_offs	0xC
#define DMAC_ADDR_C_offs	0xF
#define DMAC_ADDR_D_offs	0x12
#define DMAC_ADDR_E_offs	0x15
#define DMAC_STRIDE_A_offs	0x18
#define DMAC_STRIDE_B_offs	0x1A
#define DMAC_STRIDE_C_offs	0x1C
#define DMAC_STRIDE_D_offs	0x1E

#define DMAC_SND_DATA_offs	0x20
#define DMAC_SND_ADDR_offs	0x21
#define DMAC_SND_PERIOD_offs	0x24
#define DMAC_SND_LEN_offs	0x26
#define DMAC_SND_STATUS_offs	0x28
#define DMAC_SND_VOL_offs	0x29
#define DMAC_SND_REPOFF_offs	0x2A
#define DMAC_SND_PEAK_offs	0x2C

#define DMAC_SND_MA_VOL_offs	0x2E
#define DMAC_SND_SEL_offs	0x2F

#define DMAC_DMA_CTL_offs	0x30
#define DMAC_DMA_SRC_ADDR_offs	0x31
#define DMAC_DMA_DEST_ADDR_offs	0x34
#define DMAC_DMA_COUNT_offs	0x37
#define DMAC_DMA_DATA_offs	0x39
#define DMAC_DMA_CTL2_offs	0x3A
#define DMAC_DMA_PAUSE_offs	0x3B
#define DMAC_DMA_SEL_offs	0x3F

/* ; these addresses when accessing through page wide ram / JIM */
#define jim_page_DMAC	0xFEFC		/* hardware jim page */
#define jim_DMAC	0xFFFFFD60	/* jim location in SYS map */

#define jim_DMAC_BLITCON	(jim_DMAC + DMAC_BLITCON_offs)
#define jim_DMAC_FUNCGEN	(jim_DMAC + DMAC_FUNCGEN_offs)
#define jim_DMAC_WIDTH		(jim_DMAC + DMAC_WIDTH_offs)
#define jim_DMAC_HEIGHT		(jim_DMAC + DMAC_HEIGHT_offs)
#define jim_DMAC_SHIFT		(jim_DMAC + DMAC_SHIFT_offs)
#define jim_DMAC_MASK_FIRST	(jim_DMAC + DMAC_MASK_FIRST_offs)
#define jim_DMAC_MASK_LAST	(jim_DMAC + DMAC_MASK_LAST_offs)
#define jim_DMAC_DATA_A		(jim_DMAC + DMAC_DATA_A_offs)
#define jim_DMAC_ADDR_A		(jim_DMAC + DMAC_ADDR_A_offs)
#define jim_DMAC_DATA_B		(jim_DMAC + DMAC_DATA_B_offs)
#define jim_DMAC_ADDR_B		(jim_DMAC + DMAC_ADDR_B_offs)
#define jim_DMAC_ADDR_C		(jim_DMAC + DMAC_ADDR_C_offs)
#define jim_DMAC_ADDR_D		(jim_DMAC + DMAC_ADDR_D_offs)
#define jim_DMAC_ADDR_E		(jim_DMAC + DMAC_ADDR_E_offs)
#define jim_DMAC_STRIDE_A	(jim_DMAC + DMAC_STRIDE_A_offs)
#define jim_DMAC_STRIDE_B	(jim_DMAC + DMAC_STRIDE_B_offs)
#define jim_DMAC_STRIDE_C	(jim_DMAC + DMAC_STRIDE_C_offs)
#define jim_DMAC_STRIDE_D	(jim_DMAC + DMAC_STRIDE_D_offs)

#define jim_DMAC_SND_DATA	(jim_DMAC + DMAC_SND_DATA_offs)
#define jim_DMAC_SND_ADDR	(jim_DMAC + DMAC_SND_ADDR_offs)
#define jim_DMAC_SND_PERIOD	(jim_DMAC + DMAC_SND_PERIOD_offs)
#define jim_DMAC_SND_LEN	(jim_DMAC + DMAC_SND_LEN_offs)
#define jim_DMAC_SND_STATUS	(jim_DMAC + DMAC_SND_STATUS_offs)
#define jim_DMAC_SND_VOL	(jim_DMAC + DMAC_SND_VOL_offs)
#define jim_DMAC_SND_REPOFF	(jim_DMAC + DMAC_SND_REPOFF_offs)
#define jim_DMAC_SND_PEAK	(jim_DMAC + DMAC_SND_PEAK_offs)
#define jim_DMAC_SND_SEL	(jim_DMAC + DMAC_SND_SEL_offs)
#define jim_DMAC_SND_MA_VOL	(jim_DMAC + DMAC_SND_MA_VOL_offs)


#define jim_DMAC_DMA_CTL	(jim_DMAC + DMAC_DMA_CTL_offs)
#define jim_DMAC_DMA_SRC_ADDR	(jim_DMAC + DMAC_DMA_SRC_ADDR_offs)
#define jim_DMAC_DMA_DEST_ADDR	(jim_DMAC + DMAC_DMA_DEST_ADDR_offs)
#define jim_DMAC_DMA_COUNT	(jim_DMAC + DMAC_DMA_COUNT_offs)
#define jim_DMAC_DMA_DATA	(jim_DMAC + DMAC_DMA_DATA_offs)
#define jim_DMAC_DMA_CTL2	(jim_DMAC + DMAC_DMA_CTL2_offs)
#define jim_DMAC_DMA_PAUSE	(jim_DMAC + DMAC_DMA_PAUSE_offs)
#define jim_DMAC_DMA_SEL	(jim_DMAC + DMAC_DMA_SEL_offs)


/* ; these addresses when accessing direct - preferred on 68008 */
#define blit_DMAC		0xFFFEFC60

#define blit_DMAC_BLITCON	(blit_DMAC + DMAC_BLITCON_offs)
#define blit_DMAC_FUNCGEN	(blit_DMAC + DMAC_FUNCGEN_offs)
#define blit_DMAC_WIDTH		(blit_DMAC + DMAC_WIDTH_offs)
#define blit_DMAC_HEIGHT	(blit_DMAC + DMAC_HEIGHT_offs)
#define blit_DMAC_SHIFT		(blit_DMAC + DMAC_SHIFT_offs)
#define blit_DMAC_MASK_FIRST	(blit_DMAC + DMAC_MASK_FIRST_offs)
#define blit_DMAC_MASK_LAST	(blit_DMAC + DMAC_MASK_LAST_offs)
#define blit_DMAC_DATA_A	(blit_DMAC + DMAC_DATA_A_offs)
#define blit_DMAC_ADDR_A	(blit_DMAC + DMAC_ADDR_A_offs)
#define blit_DMAC_DATA_B	(blit_DMAC + DMAC_DATA_B_offs)
#define blit_DMAC_ADDR_B	(blit_DMAC + DMAC_ADDR_B_offs)
#define blit_DMAC_ADDR_C	(blit_DMAC + DMAC_ADDR_C_offs)
#define blit_DMAC_ADDR_D	(blit_DMAC + DMAC_ADDR_D_offs)
#define blit_DMAC_ADDR_E	(blit_DMAC + DMAC_ADDR_E_offs)
#define blit_DMAC_STRIDE_A	(blit_DMAC + DMAC_STRIDE_A_offs)
#define blit_DMAC_STRIDE_B	(blit_DMAC + DMAC_STRIDE_B_offs)
#define blit_DMAC_STRIDE_C	(blit_DMAC + DMAC_STRIDE_C_offs)
#define blit_DMAC_STRIDE_D	(blit_DMAC + DMAC_STRIDE_D_offs)

#define blit_DMAC_SND_DATA	(blit_DMAC + DMAC_SND_DATA_offs)
#define blit_DMAC_SND_ADDR	(blit_DMAC + DMAC_SND_ADDR_offs)
#define blit_DMAC_SND_PERIOD	(blit_DMAC + DMAC_SND_PERIOD_offs)
#define blit_DMAC_SND_LEN	(blit_DMAC + DMAC_SND_LEN_offs)
#define blit_DMAC_SND_STATUS	(blit_DMAC + DMAC_SND_STATUS_offs)
#define blit_DMAC_SND_VOL	(blit_DMAC + DMAC_SND_VOL_offs)
#define blit_DMAC_SND_REPOFF	(blit_DMAC + DMAC_SND_REPOFF_offs)
#define blit_DMAC_SND_PEAK	(blit_DMAC + DMAC_SND_PEAK_offs)
#define blit_DMAC_SND_SEL	(blit_DMAC + DMAC_SND_SEL_offs)
#define blit_DMAC_SND_MA_VOL	(blit_DMAC + DMAC_SND_MA_VOL_offs)

#define blit_DMAC_DMA_CTL	(blit_DMAC + DMAC_DMA_CTL_offs)
#define blit_DMAC_DMA_SRC_ADDR	(blit_DMAC + DMAC_DMA_SRC_ADDR_offs)
#define blit_DMAC_DMA_DEST_ADDR	(blit_DMAC + DMAC_DMA_DEST_ADDR_offs)
#define blit_DMAC_DMA_COUNT	(blit_DMAC + DMAC_DMA_COUNT_offs)
#define blit_DMAC_DMA_DATA	(blit_DMAC + DMAC_DMA_DATA_offs)
#define blit_DMAC_DMA_CTL2	(blit_DMAC + DMAC_DMA_CTL2_offs)
#define blit_DMAC_DMA_PAUSE	(blit_DMAC + DMAC_DMA_PAUSE_offs)
#define blit_DMAC_DMA_SEL	(blit_DMAC + DMAC_DMA_SEL_offs)



#define JIM_DEVNO_HOG1MPAULA	0xD0
#define JIM_DEVNO_BLITTER	0xD1


