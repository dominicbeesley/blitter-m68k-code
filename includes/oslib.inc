;	OS Entry points

	macro	OSBYTE
	trap	#1
	endm

	macro	OSWORD
	trap	#2
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