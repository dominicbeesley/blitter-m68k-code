;	OS Entry points

		macro SWI
		move.l #\1,A0
		trap #12
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
; OSCLI						:=	$FFF7
; 
; PRSTRING					:=	$FF9B
; CLICOM					:=	$FFB9
; ERRJMP					:=	$FFBC
; OSINIT					:=	$FFBF
; SCANHEX					:=	$FFA1
; OSQUIT					:=	$FFA7
; PRHEX						:=	$FFAA
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


; Handler Numbers
HANDLER_0_MemoryLimit			:=	$00
HANDLER_1_UndefinedInstruction		:=	$01
HANDLER_2_PrefetchAbort			:=	$02
HANDLER_3_DataAbort			:=	$03
HANDLER_4_AddressException		:=	$04
HANDLER_5_OtherException		:=	$05
HANDLER_6_Error				:=	$06
HANDLER_7_CallBack			:=	$07
HANDLER_8_BreakPoint			:=	$08
HANDLER_9_Escape			:=	$09
HANDLER_10_Event			:=	$0A
HANDLER_11_Exit				:=	$0B
HANDLER_12_UnusedSWI			:=	$0C
HANDLER_13_ExceptionRegisters		:=	$0D
HANDLER_14_ApplicationSpace		:=	$0E
HANDLER_15_CurrentlyActiveObject	:=	$0F
HANDLER_16_UpCall			:=	$10



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

XOS_WriteC                                         EQU $00020000 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
XOS_WriteS                                         EQU $00020001 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
XOS_Write0                                         EQU $00020002 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
XOS_NewLine                                        EQU $00020003 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
XOS_ReadC                                          EQU $00020004
XOS_CLI                                            EQU $00020005 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Oscli
XOS_Byte                                           EQU $00020006 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/PMF/osbyte
XOS_Word                                           EQU $00020007 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/PMF/osword?annotate=4.4.2.8
XOS_File                                           EQU $00020008
XOS_Args                                           EQU $00020009
XOS_BGet                                           EQU $0002000A ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
XOS_BPut                                           EQU $0002000B ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
XOS_GBPB                                           EQU $0002000C
XOS_Find                                           EQU $0002000D
XOS_ReadLine                                       EQU $0002000E ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
XOS_Control                                        EQU $0002000F ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
XOS_GetEnv                                         EQU $00020010 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
XOS_Exit                                           EQU $00020011 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
XOS_SetEnv                                         EQU $00020012 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
XOS_IntOn                                          EQU $00020013
XOS_IntOff                                         EQU $00020014
XOS_CallBack                                       EQU $00020015 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
XOS_EnterOS                                        EQU $00020016
XOS_BreakPt                                        EQU $00020017 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38 Middle?annotate=4.15.2.30
XOS_BreakCtrl                                      EQU $00020018
XOS_UnusedSWI                                      EQU $00020019 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38 Middle?annotate=4.15.2.30
XOS_UpdateMEMC                                     EQU $0002001A ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5 MEMC1?annotate=4.1.7.1 MEMC2?annotate=4.1.7.1
XOS_SetCallBack                                    EQU $0002001B ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
XOS_Mouse                                          EQU $0002001C ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
XOS_Heap                                           EQU $0002001D ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/HeapMan?annotate=4.5.2.4.2.1
XOS_Module                                         EQU $0002001E ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ModHand?annotate=4.11.2.13
XOS_Claim                                          EQU $0002001F ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
XOS_Release                                        EQU $00020020 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
XOS_ReadUnsigned                                   EQU $00020021 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
XOS_GenerateEvent                                  EQU $00020022 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/NewIRQs?annotate=4.10.2.26
XOS_ReadVarVal                                     EQU $00020023 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Arthur2?annotate=4.6.2.10
XOS_SetVarVal                                      EQU $00020024 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Arthur2?annotate=4.6.2.10
XOS_GSInit                                         EQU $00020025 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Arthur2?annotate=4.6.2.10
XOS_GSRead                                         EQU $00020026 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Arthur2?annotate=4.6.2.10
XOS_GSTrans                                        EQU $00020027 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Arthur2?annotate=4.6.2.10
XOS_BinaryToDecimal                                EQU $00020028 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
XOS_FSControl                                      EQU $00020029 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
XOS_ChangeDynamicArea                              EQU $0002002A ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26 Utility?annotate=4.6.2.8
XOS_GenerateError                                  EQU $0002002B ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
XOS_ReadEscapeState                                EQU $0002002C ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
XOS_EvaluateExpression                             EQU $0002002D ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Arthur3?annotate=4.3.2.11
XOS_SpriteOp                                       EQU $0002002E
XOS_ReadPalette                                    EQU $0002002F
XOS_ServiceCall                                    EQU $00020030 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
XOS_ReadVduVariables                               EQU $00020031 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
XOS_ReadPoint                                      EQU $00020032
XOS_UpCall                                         EQU $00020033 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
XOS_CallAVector                                    EQU $00020034 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
XOS_ReadModeVariable                               EQU $00020035 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
XOS_RemoveCursors                                  EQU $00020036 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
XOS_RestoreCursors                                 EQU $00020037 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
XOS_SWINumberToString                              EQU $00020038 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/SWINaming?annotate=4.5.2.8
XOS_SWINumberFromString                            EQU $00020039 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/SWINaming?annotate=4.5.2.8
XOS_ValidateAddress                                EQU $0002003A ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
XOS_CallAfter                                      EQU $0002003B ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/TickEvents?annotate=4.4.2.4
XOS_CallEvery                                      EQU $0002003C ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/TickEvents?annotate=4.4.2.4
XOS_RemoveTickerEvent                              EQU $0002003D ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/TickEvents?annotate=4.4.2.4
XOS_InstallKeyHandler                              EQU $0002003E
XOS_CheckModeValid                                 EQU $0002003F ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
XOS_ChangeEnvironment                              EQU $00020040 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
XOS_ClaimScreenMemory                              EQU $00020041
XOS_ReadMonotonicTime                              EQU $00020042
XOS_SubstituteArgs                                 EQU $00020043 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
XOS_PrettyPrint                                    EQU $00020044 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
XOS_Plot                                           EQU $00020045 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduplot?annotate=4.2.2.5 vduswis?annotate=4.6.2.21
XOS_WriteN                                         EQU $00020046 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
XOS_AddToVector                                    EQU $00020047 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
XOS_WriteEnv                                       EQU $00020048 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
XOS_ReadArgs                                       EQU $00020049 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
XOS_ReadRAMFsLimits                                EQU $0002004A ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
XOS_ClaimDeviceVector                              EQU $0002004B
XOS_ReleaseDeviceVector                            EQU $0002004C
XOS_DelinkApplication                              EQU $0002004D ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
XOS_RelinkApplication                              EQU $0002004E ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
XOS_HeapSort                                       EQU $0002004F ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/HeapSort?annotate=4.2.2.5
XOS_ExitAndDie                                     EQU $00020050 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
XOS_ReadMemMapInfo                                 EQU $00020051 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26
XOS_ReadMemMapEntries                              EQU $00020052 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26
XOS_SetMemMapEntries                               EQU $00020053 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26
XOS_AddCallBack                                    EQU $00020054 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
XOS_ReadDefaultHandler                             EQU $00020055 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
XOS_SetECFOrigin                                   EQU $00020056
XOS_SerialOp                                       EQU $00020057 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
XOS_ReadSysInfo                                    EQU $00020058 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
XOS_Confirm                                        EQU $00020059 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
XOS_ChangedBox                                     EQU $0002005A ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
XOS_CRC                                            EQU $0002005B ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
XOS_ReadDynamicArea                                EQU $0002005C ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26
XOS_PrintChar                                      EQU $0002005D ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/PMF/oseven?annotate=4.2.2.3
XOS_ChangeRedirection                              EQU $0002005E
XOS_RemoveCallBack                                 EQU $0002005F ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
XOS_FindMemMapEntries                              EQU $00020060 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26
XOS_SetColour                                      EQU $00020061
XOS_ClaimSWI                                       EQU $00020062
XOS_ReleaseSWI                                     EQU $00020063
XOS_Pointer                                        EQU $00020064 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/PMF/mouse?annotate=4.3.2.4
XOS_ScreenMode                                     EQU $00020065 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
XOS_DynamicArea                                    EQU $00020066 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26
XOS_AbortTrap                                      EQU $00020067
XOS_Memory                                         EQU $00020068 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MemInfo?annotate=4.4.2.26
XOS_ClaimProcessorVector                           EQU $00020069 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ExtraSWIs?annotate=4.1.8.2
XOS_Reset                                          EQU $0002006A
XOS_MMUControl                                     EQU $0002006B ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
XOS_ResyncTime                                     EQU $0002006C ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/PMF/realtime?annotate=4.3.2.4
XOS_PlatformFeatures                               EQU $0002006D ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
XOS_SynchroniseCodeAreas                           EQU $0002006E ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ARM600?annotate=4.12.2.36
XOS_CallASWI                                       EQU $0002006F
XOS_AMBControl                                     EQU $00020070 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/AMBControl/main?annotate=4.1.3.1.8.5
XOS_CallASWIR12                                    EQU $00020071
XOS_SpecialControl                                 EQU $00020072
XOS_EnterUSR32                                     EQU $00020073
XOS_EnterUSR26                                     EQU $00020074
XOS_VIDCDivider                                    EQU $00020075
XOS_NVMemory                                       EQU $00020076 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/PMF/i2cutils?annotate=4.11.2.28
XOS_ClaimOSSWI                                     EQU $00020077
XOS_TaskControl                                    EQU $00020078
XOS_DeviceDriver                                   EQU $00020079
XOS_Hardware                                       EQU $0002007A
XOS_IICOp                                          EQU $0002007B
XOS_LeaveOS                                        EQU $0002007C
XOS_ReadLine32                                     EQU $0002007D ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
XOS_SubstituteArgs32                               EQU $0002007E ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
XOS_HeapSort32                                     EQU $0002007F ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/HeapSort?annotate=4.2.2.5
XOS_ConvertStandardDateAndTime                     EQU $000200C0 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5  PMF/convdate
XOS_ConvertDateAndTime                             EQU $000200C1 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5  PMF/convdate
XOS_ConvertHex1                                    EQU $000200D0
XOS_ConvertHex2                                    EQU $000200D1
XOS_ConvertHex4                                    EQU $000200D2
XOS_ConvertHex6                                    EQU $000200D3
XOS_ConvertHex8                                    EQU $000200D4
XOS_ConvertCardinal1                               EQU $000200D5
XOS_ConvertCardinal2                               EQU $000200D6
XOS_ConvertCardinal3                               EQU $000200D7
XOS_ConvertCardinal4                               EQU $000200D8
XOS_ConvertInteger1                                EQU $000200D9
XOS_ConvertInteger2                                EQU $000200DA
XOS_ConvertInteger3                                EQU $000200DB
XOS_ConvertInteger4                                EQU $000200DC
XOS_ConvertBinary1                                 EQU $000200DD
XOS_ConvertBinary2                                 EQU $000200DE
XOS_ConvertBinary3                                 EQU $000200DF
XOS_ConvertBinary4                                 EQU $000200E0
XOS_ConvertSpacedCardinal1                         EQU $000200E1
XOS_ConvertSpacedCardinal2                         EQU $000200E2
XOS_ConvertSpacedCardinal3                         EQU $000200E3
XOS_ConvertSpacedCardinal4                         EQU $000200E4
XOS_ConvertSpacedInteger1                          EQU $000200E5
XOS_ConvertSpacedInteger2                          EQU $000200E6
XOS_ConvertSpacedInteger3                          EQU $000200E7
XOS_ConvertSpacedInteger4                          EQU $000200E8
XOS_ConvertFixedNetStation                         EQU $000200E9 ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
XOS_ConvertNetStation                              EQU $000200EA ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
XOS_ConvertFixedFileSize                           EQU $000200EB ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
XOS_ConvertFileSize                                EQU $000200EC ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
XOS_ConvertVariform                                EQU $000200ED ; https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
XOS_WriteI                                         EQU $00020100       ; $100-$1FF is VDU$00-VDU$FF https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38



		macro 	WRITES
		SWI	OS_WriteS
		dc.b	\1,0
		align	1
		endm

		macro 	XWRITES
		SWI	XOS_WriteS
		dc.b	\1,0
		align	1
		endm

