


//	OS Constants
#define OSFILE_LOAD 0xFF
#define OSFILE_SAVE 0x00
#define OSFILE_CAT 0x05
#define OSFILE_OFS_FILENAME 0x00
#define OSFILE_OFS_LOAD 0x02
#define OSFILE_OFS_EXEC 0x06
#define OSFILE_OFS_LEN 0x0A
#define OSFILE_OFS_START 0x0A
#define OSFILE_OFS_ATTR 0x0E
#define OSFILE_OFS_END 0x0E
#define OSFIND_CLOSE 0x00
#define OSFIND_OPENIN 0x40
#define OSFIND_OPENOUT 0x80
#define OSFIND_OPENUP 0xC0
#define OSWORD_SOUND 0x07
#define OSWORD_ENVELOPE 0x08
#define OSARGS_cmdtail 0x01
#define OSARGS_EXT 0x02
#define OSGBPB_WRITE_PTR 0x00
#define OSGBPB_WRITE_NOPTR 0x02
#define OSGBPB_READ_PTR 0x03
#define OSGBPB_READ_NOPTR 0x04
#define OSGBPB_READ_TITLE 0x05
#define OSGBPB_READ_DIR 0x06
#define OSGBPB_READ_LIB 0x07
#define OSGBPB_GET_DIRENT 0x08
#define SERVICE_0_NOP 0x0
#define SERVICE_1_ABSWKSP_REQ 0x1
#define SERVICE_2_RELWKSP_REQ 0x2
#define SERVICE_3_AUTOBOOT 0x3
#define SERVICE_4_UKCMD 0x4
#define SERVICE_5_UKINT 0x5
#define SERVICE_6_BRK 0x6
#define SERVICE_7_UKOSBYTE 0x7
#define SERVICE_7_UKOSWORD 0x8
#define SERVICE_9_HELP 0x9
#define SERVICE_A_ABSWKSP_CLAIM 0xA
#define SERVICE_B_NMI_RELEASE 0xB
#define SERVICE_C_NMI_CLAIM 0xC
#define SERVICE_D_ROMFS_INIT 0xD
#define SERVICE_E_ROMFS_GETB 0xE
#define SERVICE_F_FSVEC_CLAIMED 0xF
#define SERVICE_10_SPOOL_CLOSE 0x10
#define SERVICE_11_FONT_BANG 0x11
#define SERVICE_12_INITFS 0x12
#define SERVICE_13_SERIAL_CHAR 0x13
#define SERVICE_14_PRINT_CHAR 0x14
#define SERVICE_15_100Hz 0x15
#define SERVICE_25_FSINFO 0x25
#define FSCV_6_NewFS 0x06
// Handler Numbers
#define HANDLER_0_MemoryLimit 0x00
#define HANDLER_1_UndefinedInstruction 0x01
#define HANDLER_2_PrefetchAbort 0x02
#define HANDLER_3_DataAbort 0x03
#define HANDLER_4_AddressException 0x04
#define HANDLER_5_OtherException 0x05
#define HANDLER_6_Error 0x06
#define HANDLER_7_CallBack 0x07
#define HANDLER_8_BreakPoint 0x08
#define HANDLER_9_Escape 0x09
#define HANDLER_10_Event 0x0A
#define HANDLER_11_Exit 0x0B
#define HANDLER_12_UnusedSWI 0x0C
#define HANDLER_13_ExceptionRegisters 0x0D
#define HANDLER_14_ApplicationSpace 0x0E
#define HANDLER_15_CurrentlyActiveObject 0x0F
#define HANDLER_16_UpCall 0x10
// OSBYTEs
#define OSBYTE_13_ENABLE_EVENT 13
#define OSBYTE_14_ENABLE_EVENT 14
#define OSBYTE_108_WRITE_SHADOW_STATE 108
#define OSBYTE_119_CLOSE_SPOOL_AND_EXEC 119
#define OSBYTE_126_ESCAPE_ACK 126
#define OSBYTE_129_INKEY 129
#define OSBYTE_142_SERVICE_CALL 143
#define OSBYTE_156_SERIAL_STATE 156
#define OSBYTE_160_READ_VDU_VARIABLE 160
#define OSBYTE_168_READ_ROM_POINTER_TABLE 168
#define OSBYTE_171_ROMTAB 170
#define OSBYTE_232_VAR_IRQ_MASK_SERIAL 232
#define OSBYTE_234_VAR_TUBE 234
#define OSBYTE_253_VAR_LAST_RESET 253
#define vduvar_ix_GRA_WINDOW 0x00
//Current graphics window left column in pixels
#define vduvar_ix_GRA_WINDOW_LEFT 0x00
//Current graphics window bottom row in pixels
#define vduvar_ix_GRA_WINDOW_BOTTOM 0x02
//Current graphics window right column in pixels
#define vduvar_ix_GRA_WINDOW_RIGHT 0x04
//Current graphics window top row in pixels
#define vduvar_ix_GRA_WINDOW_TOP 0x06
//Current text window left hand column
#define vduvar_ix_TXT_WINDOW_LEFT 0x08
//Current text window bottom row
#define vduvar_ix_TXT_WINDOW_BOTTOM 0x09
//Current text window right hand column
#define vduvar_ix_TXT_WINDOW_RIGHT 0x0A
//Current text window top column
#define vduvar_ix_TXT_WINDOW_TOP 0x0B
//Current graphics origin in external coordinates
#define vduvar_ix_GRA_ORG_EXT 0x0C
//Current graphics cursor in external coordinates
#define vduvar_ix_GRA_CUR_EXT 0x10
//Old graphics cursor in external coordinates
#define vduvar_ix_GRA_CUR_INT_OLD 0x14
//Current text cursor X
#define vduvar_ix_TXT_CUR_X 0x18
//Current text cursor Y
#define vduvar_ix_TXT_CUR_Y 0x19
//Line within current graphics cell of graphics cursor
#define vduvar_ix_GRA_CUR_CELL_LINE 0x1A
#define vduvar_ix_VDU_Q_START 0x1B
//end of VDU Q (well 1 after!)
#define vduvar_ix_VDU_Q_END 0x24
//Current graphics cursor in internal coordinates
#define vduvar_ix_GRA_CUR_INT 0x24
//Bitmap read from screen by OSBYTE 135, various coordinate routines
#define vduvar_ix_TEMP_8 0x28
//Graphics workspace
#define vduvar_ix_GRA_WKSP 0x30
//Text cursor address for 6845
#define vduvar_ix_6845_CURSOR_ADDR 0x4A
//Text window width in bytes
#define vduvar_ix_TXT_WINDOW_WIDTH_BYTES 0x4C
//High byte of bottom of screen memory
#define vduvar_ix_SCREEN_BOTTOM_HIGH 0x4E
//Bytes per character for current mode
#define vduvar_ix_BYTES_PER_CHAR 0x4F
//Screen display start address for 6845
#define vduvar_ix_6845_SCREEN_START 0x50
//Bytes per screen row
#define vduvar_ix_BYTES_PER_ROW 0x52
//Screen memory size high byte
#define vduvar_ix_SCREEN_SIZE_HIGH 0x54
//Current screen mode
#define vduvar_ix_MODE 0x55
//Memory map type: 0 - 20K, 1 - 16K, 2 - 10K, 3 - 8K, 4 - 1K
#define vduvar_ix_MODE_SIZE 0x56
//Foreground text colour
#define vduvar_ix_TXT_FORE 0x57
//Background text colour
#define vduvar_ix_TXT_BACK 0x58
//Foreground graphics colour
#define vduvar_ix_GRA_FORE 0x59
//Background graphics colour
#define vduvar_ix_GRA_BACK 0x5A
//Foreground plot mode
#define vduvar_ix_GRA_PLOT_FORE 0x5B
//Background plot mode
#define vduvar_ix_GRA_PLOT_BACK 0x5C
//General VDU jump vector
#define vduvar_ix_VDU_VEC_JMP 0x5D
//Cursor start register previous setting
#define vduvar_ix_CUR_START_PREV 0x5F
//Number logical colours -1
#define vduvar_ix_COL_COUNT_MINUS1 0x60
//Pixels per byte -1 (zero if text only mode)
#define vduvar_ix_PIXELS_PER_BYTE_MINUS1 0x61
//Leftmost pixel colour mask
#define vduvar_ix_LEFTMOST_PIX_MASK 0x62
//Rightmost pixel colour mask
#define vduvar_ix_RIGHTMOST_PIX_MASK 0x63
//Text input cursor X
#define vduvar_ix_TEXT_IN_CUR_X 0x64
//Text input cursor Y
#define vduvar_ix_TEXT_IN_CUR_Y 0x65
//Teletext output cursor character
#define vduvar_ix_MO7_CUR_CHAR 0x66
//Font explosion flags, b1=224-255 in RAM, b7=32-63 in RAM
#define vduvar_ix_EXPLODE_FLAGS 0x67
//Font location, characters 32-63
#define vduvar_ix_FONT_LOC32_63 0x68
//Font location, characters 64-95 
#define vduvar_ix_FONT_LOC64_95 0x69
//Font location, characters 96-127
#define vduvar_ix_FONT_LOC96_127 0x6A
//Font location, characters 128-159
#define vduvar_ix_FONT_LOC128_159 0x6B
//Font location, characters 160-191
#define vduvar_ix_FONT_LOC160_191 0x6C
//Font location, characters 192-223
#define vduvar_ix_FONT_LOC192_223 0x6D
//Font location, characters 224-255
#define vduvar_ix_FONT_LOC224_255 0x6E
//Palette for colours 0 to 15
#define vduvar_ix_PALLETTE 0x6F


//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
#define OS_WriteC 0x00000000
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
#define OS_WriteS 0x00000001
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
#define OS_Write0 0x00000002
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
#define OS_NewLine 0x00000003
#define OS_ReadC 0x00000004
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Oscli
#define OS_CLI 0x00000005
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/PMF/osbyte
#define OS_Byte 0x00000006
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/PMF/osword?annotate=4.4.2.8
#define OS_Word 0x00000007
#define OS_File 0x00000008
#define OS_Args 0x00000009
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
#define OS_BGet 0x0000000A
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
#define OS_BPut 0x0000000B
#define OS_GBPB 0x0000000C
#define OS_Find 0x0000000D
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
#define OS_ReadLine 0x0000000E
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
#define OS_Control 0x0000000F
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
#define OS_GetEnv 0x00000010
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
#define OS_Exit 0x00000011
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
#define OS_SetEnv 0x00000012
#define OS_IntOn 0x00000013
#define OS_IntOff 0x00000014
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
#define OS_CallBack 0x00000015
#define OS_EnterOS 0x00000016
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38 Middle?annotate=4.15.2.30
#define OS_BreakPt 0x00000017
#define OS_BreakCtrl 0x00000018
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38 Middle?annotate=4.15.2.30
#define OS_UnusedSWI 0x00000019
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5 MEMC1?annotate=4.1.7.1 MEMC2?annotate=4.1.7.1
#define OS_UpdateMEMC 0x0000001A
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
#define OS_SetCallBack 0x0000001B
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
#define OS_Mouse 0x0000001C
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/HeapMan?annotate=4.5.2.4.2.1
#define OS_Heap 0x0000001D
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ModHand?annotate=4.11.2.13
#define OS_Module 0x0000001E
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
#define OS_Claim 0x0000001F
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
#define OS_Release 0x00000020
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
#define OS_ReadUnsigned 0x00000021
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/NewIRQs?annotate=4.10.2.26
#define OS_GenerateEvent 0x00000022
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Arthur2?annotate=4.6.2.10
#define OS_ReadVarVal 0x00000023
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Arthur2?annotate=4.6.2.10
#define OS_SetVarVal 0x00000024
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Arthur2?annotate=4.6.2.10
#define OS_GSInit 0x00000025
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Arthur2?annotate=4.6.2.10
#define OS_GSRead 0x00000026
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Arthur2?annotate=4.6.2.10
#define OS_GSTrans 0x00000027
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
#define OS_BinaryToDecimal 0x00000028
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
#define OS_FSControl 0x00000029
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26 Utility?annotate=4.6.2.8
#define OS_ChangeDynamicArea 0x0000002A
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
#define OS_GenerateError 0x0000002B
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
#define OS_ReadEscapeState 0x0000002C
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Arthur3?annotate=4.3.2.11
#define OS_EvaluateExpression 0x0000002D
#define OS_SpriteOp 0x0000002E
#define OS_ReadPalette 0x0000002F
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
#define OS_ServiceCall 0x00000030
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
#define OS_ReadVduVariables 0x00000031
#define OS_ReadPoint 0x00000032
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
#define OS_UpCall 0x00000033
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
#define OS_CallAVector 0x00000034
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
#define OS_ReadModeVariable 0x00000035
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
#define OS_RemoveCursors 0x00000036
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
#define OS_RestoreCursors 0x00000037
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/SWINaming?annotate=4.5.2.8
#define OS_SWINumberToString 0x00000038
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/SWINaming?annotate=4.5.2.8
#define OS_SWINumberFromString 0x00000039
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
#define OS_ValidateAddress 0x0000003A
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/TickEvents?annotate=4.4.2.4
#define OS_CallAfter 0x0000003B
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/TickEvents?annotate=4.4.2.4
#define OS_CallEvery 0x0000003C
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/TickEvents?annotate=4.4.2.4
#define OS_RemoveTickerEvent 0x0000003D
#define OS_InstallKeyHandler 0x0000003E
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
#define OS_CheckModeValid 0x0000003F
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
#define OS_ChangeEnvironment 0x00000040
#define OS_ClaimScreenMemory 0x00000041
#define OS_ReadMonotonicTime 0x00000042
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
#define OS_SubstituteArgs 0x00000043
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
#define OS_PrettyPrint 0x00000044
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduplot?annotate=4.2.2.5 vduswis?annotate=4.6.2.21
#define OS_Plot 0x00000045
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
#define OS_WriteN 0x00000046
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
#define OS_AddToVector 0x00000047
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
#define OS_WriteEnv 0x00000048
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
#define OS_ReadArgs 0x00000049
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
#define OS_ReadRAMFsLimits 0x0000004A
#define OS_ClaimDeviceVector 0x0000004B
#define OS_ReleaseDeviceVector 0x0000004C
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
#define OS_DelinkApplication 0x0000004D
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
#define OS_RelinkApplication 0x0000004E
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/HeapSort?annotate=4.2.2.5
#define OS_HeapSort 0x0000004F
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
#define OS_ExitAndDie 0x00000050
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26
#define OS_ReadMemMapInfo 0x00000051
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26
#define OS_ReadMemMapEntries 0x00000052
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26
#define OS_SetMemMapEntries 0x00000053
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
#define OS_AddCallBack 0x00000054
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
#define OS_ReadDefaultHandler 0x00000055
#define OS_SetECFOrigin 0x00000056
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
#define OS_SerialOp 0x00000057
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
#define OS_ReadSysInfo 0x00000058
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
#define OS_Confirm 0x00000059
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
#define OS_ChangedBox 0x0000005A
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
#define OS_CRC 0x0000005B
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26
#define OS_ReadDynamicArea 0x0000005C
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/PMF/oseven?annotate=4.2.2.3
#define OS_PrintChar 0x0000005D
#define OS_ChangeRedirection 0x0000005E
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
#define OS_RemoveCallBack 0x0000005F
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26
#define OS_FindMemMapEntries 0x00000060
#define OS_SetColour 0x00000061
#define OS_ClaimSWI 0x00000062
#define OS_ReleaseSWI 0x00000063
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/PMF/mouse?annotate=4.3.2.4
#define OS_Pointer 0x00000064
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
#define OS_ScreenMode 0x00000065
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26
#define OS_DynamicArea 0x00000066
#define OS_AbortTrap 0x00000067
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MemInfo?annotate=4.4.2.26
#define OS_Memory 0x00000068
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ExtraSWIs?annotate=4.1.8.2
#define OS_ClaimProcessorVector 0x00000069
#define OS_Reset 0x0000006A
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
#define OS_MMUControl 0x0000006B
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/PMF/realtime?annotate=4.3.2.4
#define OS_ResyncTime 0x0000006C
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
#define OS_PlatformFeatures 0x0000006D
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ARM600?annotate=4.12.2.36
#define OS_SynchroniseCodeAreas 0x0000006E
#define OS_CallASWI 0x0000006F
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/AMBControl/main?annotate=4.1.3.1.8.5
#define OS_AMBControl 0x00000070
#define OS_CallASWIR12 0x00000071
#define OS_SpecialControl 0x00000072
#define OS_EnterUSR32 0x00000073
#define OS_EnterUSR26 0x00000074
#define OS_VIDCDivider 0x00000075
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/PMF/i2cutils?annotate=4.11.2.28
#define OS_NVMemory 0x00000076
#define OS_ClaimOSSWI 0x00000077
#define OS_TaskControl 0x00000078
#define OS_DeviceDriver 0x00000079
#define OS_Hardware 0x0000007A
#define OS_IICOp 0x0000007B
#define OS_LeaveOS 0x0000007C
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
#define OS_ReadLine32 0x0000007D
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
#define OS_SubstituteArgs32 0x0000007E
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/HeapSort?annotate=4.2.2.5
#define OS_HeapSort32 0x0000007F
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5  PMF/convdate
#define OS_ConvertStandardDateAndTime 0x000000C0
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5  PMF/convdate
#define OS_ConvertDateAndTime 0x000000C1
#define OS_ConvertHex1 0x000000D0
#define OS_ConvertHex2 0x000000D1
#define OS_ConvertHex4 0x000000D2
#define OS_ConvertHex6 0x000000D3
#define OS_ConvertHex8 0x000000D4
#define OS_ConvertCardinal1 0x000000D5
#define OS_ConvertCardinal2 0x000000D6
#define OS_ConvertCardinal3 0x000000D7
#define OS_ConvertCardinal4 0x000000D8
#define OS_ConvertInteger1 0x000000D9
#define OS_ConvertInteger2 0x000000DA
#define OS_ConvertInteger3 0x000000DB
#define OS_ConvertInteger4 0x000000DC
#define OS_ConvertBinary1 0x000000DD
#define OS_ConvertBinary2 0x000000DE
#define OS_ConvertBinary3 0x000000DF
#define OS_ConvertBinary4 0x000000E0
#define OS_ConvertSpacedCardinal1 0x000000E1
#define OS_ConvertSpacedCardinal2 0x000000E2
#define OS_ConvertSpacedCardinal3 0x000000E3
#define OS_ConvertSpacedCardinal4 0x000000E4
#define OS_ConvertSpacedInteger1 0x000000E5
#define OS_ConvertSpacedInteger2 0x000000E6
#define OS_ConvertSpacedInteger3 0x000000E7
#define OS_ConvertSpacedInteger4 0x000000E8
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
#define OS_ConvertFixedNetStation 0x000000E9
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
#define OS_ConvertNetStation 0x000000EA
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
#define OS_ConvertFixedFileSize 0x000000EB
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
#define OS_ConvertFileSize 0x000000EC
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
#define OS_ConvertVariform 0x000000ED
//$100-$1FF is VDU$00-VDU$FF https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
#define OS_WriteI 0x00000100

//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
#define XOS_WriteC 0x00020000
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
#define XOS_WriteS 0x00020001
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
#define XOS_Write0 0x00020002
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
#define XOS_NewLine 0x00020003
#define XOS_ReadC 0x00020004
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Oscli
#define XOS_CLI 0x00020005
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/PMF/osbyte
#define XOS_Byte 0x00020006
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/PMF/osword?annotate=4.4.2.8
#define XOS_Word 0x00020007
#define XOS_File 0x00020008
#define XOS_Args 0x00020009
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
#define XOS_BGet 0x0002000A
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
#define XOS_BPut 0x0002000B
#define XOS_GBPB 0x0002000C
#define XOS_Find 0x0002000D
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
#define XOS_ReadLine 0x0002000E
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
#define XOS_Control 0x0002000F
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
#define XOS_GetEnv 0x00020010
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
#define XOS_Exit 0x00020011
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
#define XOS_SetEnv 0x00020012
#define XOS_IntOn 0x00020013
#define XOS_IntOff 0x00020014
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
#define XOS_CallBack 0x00020015
#define XOS_EnterOS 0x00020016
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38 Middle?annotate=4.15.2.30
#define XOS_BreakPt 0x00020017
#define XOS_BreakCtrl 0x00020018
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38 Middle?annotate=4.15.2.30
#define XOS_UnusedSWI 0x00020019
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5 MEMC1?annotate=4.1.7.1 MEMC2?annotate=4.1.7.1
#define XOS_UpdateMEMC 0x0002001A
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
#define XOS_SetCallBack 0x0002001B
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
#define XOS_Mouse 0x0002001C
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/HeapMan?annotate=4.5.2.4.2.1
#define XOS_Heap 0x0002001D
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ModHand?annotate=4.11.2.13
#define XOS_Module 0x0002001E
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
#define XOS_Claim 0x0002001F
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
#define XOS_Release 0x00020020
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
#define XOS_ReadUnsigned 0x00020021
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/NewIRQs?annotate=4.10.2.26
#define XOS_GenerateEvent 0x00020022
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Arthur2?annotate=4.6.2.10
#define XOS_ReadVarVal 0x00020023
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Arthur2?annotate=4.6.2.10
#define XOS_SetVarVal 0x00020024
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Arthur2?annotate=4.6.2.10
#define XOS_GSInit 0x00020025
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Arthur2?annotate=4.6.2.10
#define XOS_GSRead 0x00020026
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Arthur2?annotate=4.6.2.10
#define XOS_GSTrans 0x00020027
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
#define XOS_BinaryToDecimal 0x00020028
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
#define XOS_FSControl 0x00020029
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26 Utility?annotate=4.6.2.8
#define XOS_ChangeDynamicArea 0x0002002A
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
#define XOS_GenerateError 0x0002002B
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
#define XOS_ReadEscapeState 0x0002002C
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Arthur3?annotate=4.3.2.11
#define XOS_EvaluateExpression 0x0002002D
#define XOS_SpriteOp 0x0002002E
#define XOS_ReadPalette 0x0002002F
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
#define XOS_ServiceCall 0x00020030
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
#define XOS_ReadVduVariables 0x00020031
#define XOS_ReadPoint 0x00020032
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
#define XOS_UpCall 0x00020033
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
#define XOS_CallAVector 0x00020034
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
#define XOS_ReadModeVariable 0x00020035
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
#define XOS_RemoveCursors 0x00020036
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
#define XOS_RestoreCursors 0x00020037
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/SWINaming?annotate=4.5.2.8
#define XOS_SWINumberToString 0x00020038
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/SWINaming?annotate=4.5.2.8
#define XOS_SWINumberFromString 0x00020039
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
#define XOS_ValidateAddress 0x0002003A
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/TickEvents?annotate=4.4.2.4
#define XOS_CallAfter 0x0002003B
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/TickEvents?annotate=4.4.2.4
#define XOS_CallEvery 0x0002003C
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/TickEvents?annotate=4.4.2.4
#define XOS_RemoveTickerEvent 0x0002003D
#define XOS_InstallKeyHandler 0x0002003E
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
#define XOS_CheckModeValid 0x0002003F
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
#define XOS_ChangeEnvironment 0x00020040
#define XOS_ClaimScreenMemory 0x00020041
#define XOS_ReadMonotonicTime 0x00020042
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
#define XOS_SubstituteArgs 0x00020043
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
#define XOS_PrettyPrint 0x00020044
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduplot?annotate=4.2.2.5 vduswis?annotate=4.6.2.21
#define XOS_Plot 0x00020045
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
#define XOS_WriteN 0x00020046
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
#define XOS_AddToVector 0x00020047
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
#define XOS_WriteEnv 0x00020048
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
#define XOS_ReadArgs 0x00020049
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
#define XOS_ReadRAMFsLimits 0x0002004A
#define XOS_ClaimDeviceVector 0x0002004B
#define XOS_ReleaseDeviceVector 0x0002004C
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
#define XOS_DelinkApplication 0x0002004D
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ArthurSWIs?annotate=4.8.2.20
#define XOS_RelinkApplication 0x0002004E
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/HeapSort?annotate=4.2.2.5
#define XOS_HeapSort 0x0002004F
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
#define XOS_ExitAndDie 0x00020050
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26
#define XOS_ReadMemMapInfo 0x00020051
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26
#define XOS_ReadMemMapEntries 0x00020052
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26
#define XOS_SetMemMapEntries 0x00020053
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
#define XOS_AddCallBack 0x00020054
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
#define XOS_ReadDefaultHandler 0x00020055
#define XOS_SetECFOrigin 0x00020056
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
#define XOS_SerialOp 0x00020057
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
#define XOS_ReadSysInfo 0x00020058
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
#define XOS_Confirm 0x00020059
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
#define XOS_ChangedBox 0x0002005A
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
#define XOS_CRC 0x0002005B
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26
#define XOS_ReadDynamicArea 0x0002005C
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/PMF/oseven?annotate=4.2.2.3
#define XOS_PrintChar 0x0002005D
#define XOS_ChangeRedirection 0x0002005E
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
#define XOS_RemoveCallBack 0x0002005F
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26
#define XOS_FindMemMapEntries 0x00020060
#define XOS_SetColour 0x00020061
#define XOS_ClaimSWI 0x00020062
#define XOS_ReleaseSWI 0x00020063
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/PMF/mouse?annotate=4.3.2.4
#define XOS_Pointer 0x00020064
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/vdu/vduswis?annotate=4.6.2.21
#define XOS_ScreenMode 0x00020065
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ChangeDyn?annotate=4.9.2.26
#define XOS_DynamicArea 0x00020066
#define XOS_AbortTrap 0x00020067
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MemInfo?annotate=4.4.2.26
#define XOS_Memory 0x00020068
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ExtraSWIs?annotate=4.1.8.2
#define XOS_ClaimProcessorVector 0x00020069
#define XOS_Reset 0x0002006A
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
#define XOS_MMUControl 0x0002006B
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/PMF/realtime?annotate=4.3.2.4
#define XOS_ResyncTime 0x0002006C
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
#define XOS_PlatformFeatures 0x0002006D
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/ARM600?annotate=4.12.2.36
#define XOS_SynchroniseCodeAreas 0x0002006E
#define XOS_CallASWI 0x0002006F
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/AMBControl/main?annotate=4.1.3.1.8.5
#define XOS_AMBControl 0x00020070
#define XOS_CallASWIR12 0x00020071
#define XOS_SpecialControl 0x00020072
#define XOS_EnterUSR32 0x00020073
#define XOS_EnterUSR26 0x00020074
#define XOS_VIDCDivider 0x00020075
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/PMF/i2cutils?annotate=4.11.2.28
#define XOS_NVMemory 0x00020076
#define XOS_ClaimOSSWI 0x00020077
#define XOS_TaskControl 0x00020078
#define XOS_DeviceDriver 0x00020079
#define XOS_Hardware 0x0002007A
#define XOS_IICOp 0x0002007B
#define XOS_LeaveOS 0x0002007C
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Middle?annotate=4.15.2.30
#define XOS_ReadLine32 0x0002007D
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/MoreSWIs?annotate=4.3.2.10
#define XOS_SubstituteArgs32 0x0002007E
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/HeapSort?annotate=4.2.2.5
#define XOS_HeapSort32 0x0002007F
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5  PMF/convdate
#define XOS_ConvertStandardDateAndTime 0x000200C0
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5  PMF/convdate
#define XOS_ConvertDateAndTime 0x000200C1
#define XOS_ConvertHex1 0x000200D0
#define XOS_ConvertHex2 0x000200D1
#define XOS_ConvertHex4 0x000200D2
#define XOS_ConvertHex6 0x000200D3
#define XOS_ConvertHex8 0x000200D4
#define XOS_ConvertCardinal1 0x000200D5
#define XOS_ConvertCardinal2 0x000200D6
#define XOS_ConvertCardinal3 0x000200D7
#define XOS_ConvertCardinal4 0x000200D8
#define XOS_ConvertInteger1 0x000200D9
#define XOS_ConvertInteger2 0x000200DA
#define XOS_ConvertInteger3 0x000200DB
#define XOS_ConvertInteger4 0x000200DC
#define XOS_ConvertBinary1 0x000200DD
#define XOS_ConvertBinary2 0x000200DE
#define XOS_ConvertBinary3 0x000200DF
#define XOS_ConvertBinary4 0x000200E0
#define XOS_ConvertSpacedCardinal1 0x000200E1
#define XOS_ConvertSpacedCardinal2 0x000200E2
#define XOS_ConvertSpacedCardinal3 0x000200E3
#define XOS_ConvertSpacedCardinal4 0x000200E4
#define XOS_ConvertSpacedInteger1 0x000200E5
#define XOS_ConvertSpacedInteger2 0x000200E6
#define XOS_ConvertSpacedInteger3 0x000200E7
#define XOS_ConvertSpacedInteger4 0x000200E8
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
#define XOS_ConvertFixedNetStation 0x000200E9
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
#define XOS_ConvertNetStation 0x000200EA
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
#define XOS_ConvertFixedFileSize 0x000200EB
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
#define XOS_ConvertFileSize 0x000200EC
//https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Convrsions?annotate=4.3.2.5
#define XOS_ConvertVariform 0x000200ED
//$100-$1FF is VDU$00-VDU$FF https://www.riscosopen.org/viewer/view/castle/RiscOS/Sources/Kernel/s/Kernel?annotate=4.12.2.38
#define XOS_WriteI 0x00020100




/**********************************
 * SWI names and SWI reason codes *
 **********************************/
#undef  Sound_Configure
#define Sound_Configure                         0x40140
#undef  XSound_Configure
#define XSound_Configure                        0x60140
#undef  Sound_Enable
#define Sound_Enable                            0x40141
#undef  XSound_Enable
#define XSound_Enable                           0x60141
#undef  Sound_Stereo
#define Sound_Stereo                            0x40142
#undef  XSound_Stereo
#define XSound_Stereo                           0x60142
#undef  Sound_Speaker
#define Sound_Speaker                           0x40143
#undef  XSound_Speaker
#define XSound_Speaker                          0x60143
#undef  Sound_Mode
#define Sound_Mode                              0x40144
#undef  XSound_Mode
#define XSound_Mode                             0x60144
#undef  SoundMode_ReadConfiguration
#define SoundMode_ReadConfiguration             0x0
#undef  SoundMode_SetOversampling
#define SoundMode_SetOversampling               0x1
#undef  Sound_LinearHandler
#define Sound_LinearHandler                     0x40145
#undef  XSound_LinearHandler
#define XSound_LinearHandler                    0x60145
#undef  Sound_SampleRate
#define Sound_SampleRate                        0x40146
#undef  XSound_SampleRate
#define XSound_SampleRate                       0x60146
#undef  SoundSampleRate_ReadCount
#define SoundSampleRate_ReadCount               0x0
#undef  SoundSampleRate_ReadCurrent
#define SoundSampleRate_ReadCurrent             0x1
#undef  SoundSampleRate_Lookup
#define SoundSampleRate_Lookup                  0x2
#undef  SoundSampleRate_Select
#define SoundSampleRate_Select                  0x3
#undef  Sound_Volume
#define Sound_Volume                            0x40180
#undef  XSound_Volume
#define XSound_Volume                           0x60180
#undef  Sound_SoundLog
#define Sound_SoundLog                          0x40181
#undef  XSound_SoundLog
#define XSound_SoundLog                         0x60181
#undef  Sound_LogScale
#define Sound_LogScale                          0x40182
#undef  XSound_LogScale
#define XSound_LogScale                         0x60182
#undef  Sound_InstallVoice
#define Sound_InstallVoice                      0x40183
#undef  XSound_InstallVoice
#define XSound_InstallVoice                     0x60183
#undef  SoundInstallVoice_ReadName
#define SoundInstallVoice_ReadName              0x0
#undef  SoundInstallVoice_AddNamedVoice
#define SoundInstallVoice_AddNamedVoice         0x1
#undef  SoundInstallVoice_ReadLocalName
#define SoundInstallVoice_ReadLocalName         0x2
#undef  SoundInstallVoice_ChangeLocalName
#define SoundInstallVoice_ChangeLocalName       0x3
#undef  Sound_RemoveVoice
#define Sound_RemoveVoice                       0x40184
#undef  XSound_RemoveVoice
#define XSound_RemoveVoice                      0x60184
#undef  Sound_AttachVoice
#define Sound_AttachVoice                       0x40185
#undef  XSound_AttachVoice
#define XSound_AttachVoice                      0x60185
#undef  Sound_ControlPacked
#define Sound_ControlPacked                     0x40186
#undef  XSound_ControlPacked
#define XSound_ControlPacked                    0x60186
#undef  Sound_Tuning
#define Sound_Tuning                            0x40187
#undef  XSound_Tuning
#define XSound_Tuning                           0x60187
#undef  Sound_Pitch
#define Sound_Pitch                             0x40188
#undef  XSound_Pitch
#define XSound_Pitch                            0x60188
#undef  Sound_Control
#define Sound_Control                           0x40189
#undef  XSound_Control
#define XSound_Control                          0x60189
#undef  Sound_AttachNamedVoice
#define Sound_AttachNamedVoice                  0x4018A
#undef  XSound_AttachNamedVoice
#define XSound_AttachNamedVoice                 0x6018A
#undef  Sound_ReadControlBlock
#define Sound_ReadControlBlock                  0x4018B
#undef  XSound_ReadControlBlock
#define XSound_ReadControlBlock                 0x6018B
#undef  Sound_WriteControlBlock
#define Sound_WriteControlBlock                 0x4018C
#undef  XSound_WriteControlBlock
#define XSound_WriteControlBlock                0x6018C
#undef  Sound_QInit
#define Sound_QInit                             0x401C0
#undef  XSound_QInit
#define XSound_QInit                            0x601C0
#undef  Sound_QSchedule
#define Sound_QSchedule                         0x401C1
#undef  XSound_QSchedule
#define XSound_QSchedule                        0x601C1
#undef  Sound_QRemove
#define Sound_QRemove                           0x401C2
#undef  XSound_QRemove
#define XSound_QRemove                          0x601C2
#undef  Sound_QFree
#define Sound_QFree                             0x401C3
#undef  XSound_QFree
#define XSound_QFree                            0x601C3
#undef  Sound_QSDispatch
#define Sound_QSDispatch                        0x401C4
#undef  XSound_QSDispatch
#define XSound_QSDispatch                       0x601C4
#undef  Sound_QTempo
#define Sound_QTempo                            0x401C5
#undef  XSound_QTempo
#define XSound_QTempo                           0x601C5
#undef  Sound_QBeat
#define Sound_QBeat                             0x401C6
#undef  XSound_QBeat
#define XSound_QBeat                            0x601C6
#undef  Sound_QInterface
#define Sound_QInterface                        0x401C7
#undef  XSound_QInterface
#define XSound_QInterface                       0x601C7
#undef  Sound_QSchedule32
#define Sound_QSchedule32                       0x401C8
#undef  XSound_QSchedule32
#define XSound_QSchedule32                      0x601C8
#undef  SoundQSchedule32_CallControlPacked
#define SoundQSchedule32_CallControlPacked      0x0
#undef  SoundQSchedule32_CallRoutine
#define SoundQSchedule32_CallRoutine            0x0
#undef  SoundQSchedule32_CallSWI
#define SoundQSchedule32_CallSWI                0x1
#undef  Service_Sound
#define Service_Sound                           0x54
#undef  Event_StartOfBar
#define Event_StartOfBar                        0xC
