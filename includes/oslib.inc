;	OS Entry points

		macro SWI
	if (\1 & $00FDFFFF) > $8000
		trap #2
		dc.l \1
	else
		trap #1
		dc.w ((\1 & $00020000) >> 2) | (\1 & $7FFF)
	endif
		endm


; GSINIT					:=	$FFC2
; GSREAD					:=	$FFC5
; OSRDCH_NV				:=	$FFC8
; OSWRCH_NV				:=	$FFCB
; OSFIND					:=	$FFCE
; OSGBPB					:=	$FFD1
; OSBPUT					:=	$FFD4
; OSBGET					:=	$FFD7
; OSARGS					:=	$FFDA
; OSFILE					:=	$FFDD
; OSRDCH					:=	$FFE0
; OSASCI					:=	$FFE3
; OSNEWL					:=	$FFE7
; OSWRCR					:=	$FFEC
; OSWRCH					:=	$FFEE
; OSWORD					:=	$FFF1
; OSBYTE					:=	$FFF4
; OSCLI					:=	$FFF7
; 
; PRSTRING				:=	$FF9B
; CLICOM					:=	$FFB9
; ERRJMP					:=	$FFBC
; OSINIT					:=	$FFBF
; SCANHEX					:=	$FFA1
; OSQUIT					:=	$FFA7
; PRHEX					:=	$FFAA
; PR2HEX					:=	$FFAD
; USERINT					:=	$FFB0
; PRTEXT					:=	$FFB3
; 
; OSRDRM					:=	$FF98	; !!! Different to Beeb !!!
; OSEVEN					:=	$FF9E	; !!! Different to Beeb !!!
; RAWVDU					:=	$FFA3	; !!! Different to Beeb !!!
; 
; DEBUGPRINTNEWL				:=	$FF8C
; DEBUGPRINTHEX				:=	$FF8F
; DEBUGPRINTA				:=	$FF92
; DEBUGPRINTX				:=	$FF95

;	OS Constants
OSFILE_LOAD				:= $FF
OSFILE_SAVE				:= $00
OSFILE_CAT				:= $05
OSFILE_OFS_FILENAME			:= $00
OSFILE_OFS_LOAD				:= $02
OSFILE_OFS_EXEC				:= $06
OSFILE_OFS_LEN				:= $0A
OSFILE_OFS_START			:= $0A
OSFILE_OFS_ATTR				:= $0E
OSFILE_OFS_END				:= $0E

OSFIND_CLOSE				:= $00
OSFIND_OPENIN				:= $40
OSFIND_OPENOUT				:= $80
OSFIND_OPENUP				:= $C0

OSWORD_SOUND				:= $07
OSWORD_ENVELOPE				:= $08

OSARGS_cmdtail				:= $01
OSARGS_EXT				:= $02


OSGBPB_WRITE_PTR			:=	$00
OSGBPB_WRITE_NOPTR			:=	$02
OSGBPB_READ_PTR				:=	$03
OSGBPB_READ_NOPTR			:=	$04
OSGBPB_READ_TITLE			:=	$05
OSGBPB_READ_DIR				:=	$06
OSGBPB_READ_LIB				:=	$07
OSGBPB_GET_DIRENT			:=	$08


SERVICE_0_NOP				:=	$0
SERVICE_1_ABSWKSP_REQ			:=	$1
SERVICE_2_RELWKSP_REQ			:=	$2
SERVICE_3_AUTOBOOT			:=	$3
SERVICE_4_UKCMD				:=	$4
SERVICE_5_UKINT				:=	$5
SERVICE_6_BRK				:=	$6
SERVICE_7_UKOSBYTE			:=	$7
SERVICE_7_UKOSWORD			:=	$8
SERVICE_9_HELP				:=	$9
SERVICE_A_ABSWKSP_CLAIM			:=	$A
SERVICE_B_NMI_RELEASE			:=	$B
SERVICE_C_NMI_CLAIM			:=	$C
SERVICE_D_ROMFS_INIT			:=	$D
SERVICE_E_ROMFS_GETB			:=	$E
SERVICE_F_FSVEC_CLAIMED			:=	$F
SERVICE_10_SPOOL_CLOSE			:=	$10
SERVICE_11_FONT_BANG			:=	$11
SERVICE_12_INITFS			:=	$12
SERVICE_13_SERIAL_CHAR			:=	$13
SERVICE_14_PRINT_CHAR			:=	$14
SERVICE_15_100Hz			:=	$15
SERVICE_25_FSINFO			:=	$25

FSCV_6_NewFS				:=	$06

; OS Vectors

VECTOR_START				:=	$0400
VECTOR_END				:=	$0460
USERV					:=	$0400	; User vector, called by *LINE, *CODE, OSWORD >=&E0
BRKV					:=	$0404	; The BRK vector
IRQ1V					:=	$0408	; Main interrupt vector
IRQ2V					:=	$040C	; Secondary interrupt vector
CLIV					:=	$0410	; Command Line Interpreter vector
BYTEV					:=	$0414	; OSBYTE (*FX) calls
WORDV					:=	$0418	; OSWORD calls
WRCHV					:=	$041C	; Send character to current output stream
RDCHV					:=	$0420	; Wait for a character from current input stream
FILEV					:=	$0424	; Operate on a whole file, eg loading/saving/delete/etc
ARGSV					:=	$0428	; Read/Write arguments on an open file
BGETV					:=	$042C	; Read a byte from an open file
BPUTV					:=	$0430	; Write a byte to an open file
GBPBV					:=	$0434	; Read/Write block of data from/to open file or device
FINDV					:=	$0438	; Open or close a file
FSCV					:=	$043C	; Various filing system control calls
EVNTV					:=	$0440	; Event handler
UPTV					:=	$0444	; User Print vector
NETV					:=	$0448	; Network Print vector
VDUV					:=	$044C	; Unrecognised VDU commands
KEYV					:=	$0450	; Read the keyboard
INSV					:=	$0454	; Insert characters into a buffer
REMV					:=	$0458	; Remove characters from a buffer
CNPV					:=	$045C	; Count or Purge a buffer


OSBYTE_13_ENABLE_EVENT			:=	13
OSBYTE_14_ENABLE_EVENT			:=	14
OSBYTE_108_WRITE_SHADOW_STATE		:=	108
OSBYTE_119_CLOSE_SPOOL_AND_EXEC		:=	119
OSBYTE_126_ESCAPE_ACK			:=	126
OSBYTE_129_INKEY			:=	129
OSBYTE_142_SERVICE_CALL			:=	143
OSBYTE_156_SERIAL_STATE			:=	156
OSBYTE_160_READ_VDU_VARIABLE		:=	160
OSBYTE_168_READ_ROM_POINTER_TABLE	:=	168
OSBYTE_171_ROMTAB			:=	170
OSBYTE_232_VAR_IRQ_MASK_SERIAL		:=	232
OSBYTE_234_VAR_TUBE			:=	234
OSBYTE_253_VAR_LAST_RESET		:=	253

vduvar_ix_GRA_WINDOW			:= $00				
vduvar_ix_GRA_WINDOW_LEFT		:= $00	; Current graphics window left column in pixels
vduvar_ix_GRA_WINDOW_BOTTOM		:= $02	; Current graphics window bottom row in pixels
vduvar_ix_GRA_WINDOW_RIGHT		:= $04	; Current graphics window right column in pixels
vduvar_ix_GRA_WINDOW_TOP		:= $06	; Current graphics window top row in pixels
vduvar_ix_TXT_WINDOW_LEFT		:= $08	; Current text window left hand column
vduvar_ix_TXT_WINDOW_BOTTOM		:= $09	; Current text window bottom row
vduvar_ix_TXT_WINDOW_RIGHT		:= $0A	; Current text window right hand column
vduvar_ix_TXT_WINDOW_TOP		:= $0B	; Current text window top column
vduvar_ix_GRA_ORG_EXT			:= $0C	; Current graphics origin in external coordinates
vduvar_ix_GRA_CUR_EXT			:= $10	; Current graphics cursor in external coordinates
vduvar_ix_GRA_CUR_INT_OLD		:= $14	; Old graphics cursor in external coordinates
vduvar_ix_TXT_CUR_X			:= $18	; Current text cursor X
vduvar_ix_TXT_CUR_Y			:= $19	; Current text cursor Y
vduvar_ix_GRA_CUR_CELL_LINE		:= $1A	; Line within current graphics cell of graphics cursor
vduvar_ix_VDU_Q_START			:= $1B
vduvar_ix_VDU_Q_END			:= $24	; end of VDU Q (well 1 after!)
vduvar_ix_GRA_CUR_INT			:= $24	; Current graphics cursor in internal coordinates
vduvar_ix_TEMP_8			:= $28	; Bitmap read from screen by OSBYTE 135, various coordinate routines
vduvar_ix_GRA_WKSP			:= $30	; Graphics workspace
vduvar_ix_6845_CURSOR_ADDR		:= $4A	; Text cursor address for 6845
vduvar_ix_TXT_WINDOW_WIDTH_BYTES	:= $4C	; Text window width in bytes
vduvar_ix_SCREEN_BOTTOM_HIGH		:= $4E	; High byte of bottom of screen memory
vduvar_ix_BYTES_PER_CHAR		:= $4F	; Bytes per character for current mode
vduvar_ix_6845_SCREEN_START		:= $50	; Screen display start address for 6845
vduvar_ix_BYTES_PER_ROW			:= $52	; Bytes per screen row
vduvar_ix_SCREEN_SIZE_HIGH		:= $54	; Screen memory size high byte
vduvar_ix_MODE				:= $55	; Current screen mode
vduvar_ix_MODE_SIZE			:= $56	; Memory map type: 0 - 20K, 1 - 16K, 2 - 10K, 3 - 8K, 4 - 1K
vduvar_ix_TXT_FORE			:= $57	; Foreground text colour
vduvar_ix_TXT_BACK			:= $58	; Background text colour
vduvar_ix_GRA_FORE			:= $59	; Foreground graphics colour
vduvar_ix_GRA_BACK			:= $5A	; Background graphics colour
vduvar_ix_GRA_PLOT_FORE			:= $5B	; Foreground plot mode
vduvar_ix_GRA_PLOT_BACK			:= $5C	; Background plot mode
vduvar_ix_VDU_VEC_JMP			:= $5D	; General VDU jump vector
vduvar_ix_CUR_START_PREV		:= $5F	; Cursor start register previous setting
vduvar_ix_COL_COUNT_MINUS1		:= $60	; Number logical colours -1
vduvar_ix_PIXELS_PER_BYTE_MINUS1	:= $61	; Pixels per byte -1 (zero if text only mode)
vduvar_ix_LEFTMOST_PIX_MASK		:= $62	; Leftmost pixel colour mask
vduvar_ix_RIGHTMOST_PIX_MASK		:= $63	; Rightmost pixel colour mask
vduvar_ix_TEXT_IN_CUR_X			:= $64	; Text input cursor X
vduvar_ix_TEXT_IN_CUR_Y			:= $65	; Text input cursor Y
vduvar_ix_MO7_CUR_CHAR			:= $66	; Teletext output cursor character
vduvar_ix_EXPLODE_FLAGS			:= $67	; Font explosion flags, b1=224-255 in RAM, b7=32-63 in RAM
vduvar_ix_FONT_LOC32_63			:= $68	; Font location, characters 32-63
vduvar_ix_FONT_LOC64_95			:= $69	; Font location, characters 64-95 
vduvar_ix_FONT_LOC96_127		:= $6A	; Font location, characters 96-127
vduvar_ix_FONT_LOC128_159		:= $6B	; Font location, characters 128-159
vduvar_ix_FONT_LOC160_191		:= $6C	; Font location, characters 160-191
vduvar_ix_FONT_LOC192_223		:= $6D	; Font location, characters 192-223
vduvar_ix_FONT_LOC224_255		:= $6E	; Font location, characters 224-255
vduvar_ix_PALLETTE			:= $6F	; Palette for colours 0 to 15


OS_WriteC                                         EQU $00000000 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
OS_WriteS                                         EQU $00000001 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
OS_Write0                                         EQU $00000002 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
OS_NewLine                                        EQU $00000003 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
OS_ReadC                                          EQU $00000004
OS_CLI                                            EQU $00000005 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Oscli
OS_Byte                                           EQU $00000006 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/PMF/osbyte
OS_Word                                           EQU $00000007 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/PMF/osword?annotate=4.4.2.8
OS_File                                           EQU $00000008
OS_Args                                           EQU $00000009
OS_BGet                                           EQU $0000000A ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
OS_BPut                                           EQU $0000000B ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
OS_GBPB                                           EQU $0000000C
OS_Find                                           EQU $0000000D
OS_ReadLine                                       EQU $0000000E ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
OS_Control                                        EQU $0000000F ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
OS_GetEnv                                         EQU $00000010 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
OS_Exit                                           EQU $00000011 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
OS_SetEnv                                         EQU $00000012 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
OS_IntOn                                          EQU $00000013
OS_IntOff                                         EQU $00000014
OS_CallBack                                       EQU $00000015 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
OS_EnterOS                                        EQU $00000016
OS_BreakPt                                        EQU $00000017 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38 Middle?annotate=4.15.2.30
OS_BreakCtrl                                      EQU $00000018
OS_UnusedSWI                                      EQU $00000019 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38 Middle?annotate=4.15.2.30
OS_UpdateMEMC                                     EQU $0000001A ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5 MEMC1?annotate=4.1.7.1 MEMC2?annotate=4.1.7.1
OS_SetCallBack                                    EQU $0000001B ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
OS_Mouse                                          EQU $0000001C ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
OS_Heap                                           EQU $0000001D ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/HeapMan?annotate=4.5.2.4.2.1
OS_Module                                         EQU $0000001E ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ModHand?annotate=4.11.2.13
OS_Claim                                          EQU $0000001F ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
OS_Release                                        EQU $00000020 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
OS_ReadUnsigned                                   EQU $00000021 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
OS_GenerateEvent                                  EQU $00000022 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/NewIRQs?annotate=4.10.2.26
OS_ReadVarVal                                     EQU $00000023 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Arthur2?annotate=4.6.2.10
OS_SetVarVal                                      EQU $00000024 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Arthur2?annotate=4.6.2.10
OS_GSInit                                         EQU $00000025 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Arthur2?annotate=4.6.2.10
OS_GSRead                                         EQU $00000026 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Arthur2?annotate=4.6.2.10
OS_GSTrans                                        EQU $00000027 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Arthur2?annotate=4.6.2.10
OS_BinaryToDecimal                                EQU $00000028 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
OS_FSControl                                      EQU $00000029 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
OS_ChangeDynamicArea                              EQU $0000002A ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26 Utility?annotate=4.6.2.8
OS_GenerateError                                  EQU $0000002B ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
OS_ReadEscapeState                                EQU $0000002C ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
OS_EvaluateExpression                             EQU $0000002D ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Arthur3?annotate=4.3.2.11
OS_SpriteOp                                       EQU $0000002E
OS_ReadPalette                                    EQU $0000002F
OS_ServiceCall                                    EQU $00000030 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
OS_ReadVduVariables                               EQU $00000031 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
OS_ReadPoint                                      EQU $00000032
OS_UpCall                                         EQU $00000033 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
OS_CallAVector                                    EQU $00000034 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
OS_ReadModeVariable                               EQU $00000035 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
OS_RemoveCursors                                  EQU $00000036 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
OS_RestoreCursors                                 EQU $00000037 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
OS_SWINumberToString                              EQU $00000038 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/SWINaming?annotate=4.5.2.8
OS_SWINumberFromString                            EQU $00000039 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/SWINaming?annotate=4.5.2.8
OS_ValidateAddress                                EQU $0000003A ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
OS_CallAfter                                      EQU $0000003B ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/TickEvents?annotate=4.4.2.4
OS_CallEvery                                      EQU $0000003C ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/TickEvents?annotate=4.4.2.4
OS_RemoveTickerEvent                              EQU $0000003D ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/TickEvents?annotate=4.4.2.4
OS_InstallKeyHandler                              EQU $0000003E
OS_CheckModeValid                                 EQU $0000003F ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
OS_ChangeEnvironment                              EQU $00000040 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
OS_ClaimScreenMemory                              EQU $00000041
OS_ReadMonotonicTime                              EQU $00000042
OS_SubstituteArgs                                 EQU $00000043 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
OS_PrettyPrint                                    EQU $00000044 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
OS_Plot                                           EQU $00000045 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduplot?annotate=4.2.2.5 vduswis?annotate=4.6.2.21
OS_WriteN                                         EQU $00000046 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
OS_AddToVector                                    EQU $00000047 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
OS_WriteEnv                                       EQU $00000048 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
OS_ReadArgs                                       EQU $00000049 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
OS_ReadRAMFsLimits                                EQU $0000004A ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
OS_ClaimDeviceVector                              EQU $0000004B
OS_ReleaseDeviceVector                            EQU $0000004C
OS_DelinkApplication                              EQU $0000004D ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
OS_RelinkApplication                              EQU $0000004E ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
OS_HeapSort                                       EQU $0000004F ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/HeapSort?annotate=4.2.2.5
OS_ExitAndDie                                     EQU $00000050 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
OS_ReadMemMapInfo                                 EQU $00000051 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26
OS_ReadMemMapEntries                              EQU $00000052 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26
OS_SetMemMapEntries                               EQU $00000053 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26
OS_AddCallBack                                    EQU $00000054 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
OS_ReadDefaultHandler                             EQU $00000055 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
OS_SetECFOrigin                                   EQU $00000056
OS_SerialOp                                       EQU $00000057 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
OS_ReadSysInfo                                    EQU $00000058 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
OS_Confirm                                        EQU $00000059 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
OS_ChangedBox                                     EQU $0000005A ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
OS_CRC                                            EQU $0000005B ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
OS_ReadDynamicArea                                EQU $0000005C ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26
OS_PrintChar                                      EQU $0000005D ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/PMF/oseven?annotate=4.2.2.3
OS_ChangeRedirection                              EQU $0000005E
OS_RemoveCallBack                                 EQU $0000005F ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
OS_FindMemMapEntries                              EQU $00000060 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26
OS_SetColour                                      EQU $00000061
OS_ClaimSWI                                       EQU $00000062
OS_ReleaseSWI                                     EQU $00000063
OS_Pointer                                        EQU $00000064 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/PMF/mouse?annotate=4.3.2.4
OS_ScreenMode                                     EQU $00000065 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
OS_DynamicArea                                    EQU $00000066 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26
OS_AbortTrap                                      EQU $00000067
OS_Memory                                         EQU $00000068 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MemInfo?annotate=4.4.2.26
OS_ClaimProcessorVector                           EQU $00000069 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ExtraSWIs?annotate=4.1.8.2
OS_Reset                                          EQU $0000006A
OS_MMUControl                                     EQU $0000006B ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
OS_ResyncTime                                     EQU $0000006C ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/PMF/realtime?annotate=4.3.2.4
OS_PlatformFeatures                               EQU $0000006D ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
OS_SynchroniseCodeAreas                           EQU $0000006E ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ARM600?annotate=4.12.2.36
OS_CallASWI                                       EQU $0000006F
OS_AMBControl                                     EQU $00000070 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/AMBControl/main?annotate=4.1.3.1.8.5
OS_CallASWIR12                                    EQU $00000071
OS_SpecialControl                                 EQU $00000072
OS_EnterUSR32                                     EQU $00000073
OS_EnterUSR26                                     EQU $00000074
OS_VIDCDivider                                    EQU $00000075
OS_NVMemory                                       EQU $00000076 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/PMF/i2cutils?annotate=4.11.2.28
OS_ClaimOSSWI                                     EQU $00000077
OS_TaskControl                                    EQU $00000078
OS_DeviceDriver                                   EQU $00000079
OS_Hardware                                       EQU $0000007A
OS_IICOp                                          EQU $0000007B
OS_LeaveOS                                        EQU $0000007C
OS_ReadLine32                                     EQU $0000007D ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
OS_SubstituteArgs32                               EQU $0000007E ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
OS_HeapSort32                                     EQU $0000007F ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/HeapSort?annotate=4.2.2.5
OS_ConvertStandardDateAndTime                     EQU $000000C0 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5  PMF/convdate
OS_ConvertDateAndTime                             EQU $000000C1 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5  PMF/convdate
OS_ConvertHex1                                    EQU $000000D0
OS_ConvertHex2                                    EQU $000000D1
OS_ConvertHex4                                    EQU $000000D2
OS_ConvertHex6                                    EQU $000000D3
OS_ConvertHex8                                    EQU $000000D4
OS_ConvertCardinal1                               EQU $000000D5
OS_ConvertCardinal2                               EQU $000000D6
OS_ConvertCardinal3                               EQU $000000D7
OS_ConvertCardinal4                               EQU $000000D8
OS_ConvertInteger1                                EQU $000000D9
OS_ConvertInteger2                                EQU $000000DA
OS_ConvertInteger3                                EQU $000000DB
OS_ConvertInteger4                                EQU $000000DC
OS_ConvertBinary1                                 EQU $000000DD
OS_ConvertBinary2                                 EQU $000000DE
OS_ConvertBinary3                                 EQU $000000DF
OS_ConvertBinary4                                 EQU $000000E0
OS_ConvertSpacedCardinal1                         EQU $000000E1
OS_ConvertSpacedCardinal2                         EQU $000000E2
OS_ConvertSpacedCardinal3                         EQU $000000E3
OS_ConvertSpacedCardinal4                         EQU $000000E4
OS_ConvertSpacedInteger1                          EQU $000000E5
OS_ConvertSpacedInteger2                          EQU $000000E6
OS_ConvertSpacedInteger3                          EQU $000000E7
OS_ConvertSpacedInteger4                          EQU $000000E8
OS_ConvertFixedNetStation                         EQU $000000E9 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
OS_ConvertNetStation                              EQU $000000EA ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
OS_ConvertFixedFileSize                           EQU $000000EB ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
OS_ConvertFileSize                                EQU $000000EC ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
OS_ConvertVariform                                EQU $000000ED ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
OS_WriteI                                         EQU $00000100       ; $100-$1FF is VDU$00-VDU$FF https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
