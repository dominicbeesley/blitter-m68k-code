		include "mos.inc"
		include "oslib.inc"
		
		SECTION "code"

		xdef	mostbl_SYSVAR_DEFAULT_SETTINGS

;; ----------------------------------------------------------------------------
;; MOS VARIABLES DEFAULT SETTINGS
mostbl_SYSVAR_DEFAULT_SETTINGS				; LD976
		dc.w	sysvar_OSVARADDR - $A6			; A6 default osvar base (minus A6 for osbyte offset)
		dc.w	0 ; 68API - not applicable		; A8 default start of extended vector table
		dc.w	oswksp_ROMTYPE_TAB			; AA default start of rom info table
		dc.w	0 ; 68API - not applicable		; AC default start of keyboard to ASCII table
		
		dc.w	vduvars_start				; AE base of VDU variables
		dc.b	$00					; B0 CFS timeout
		dc.b	$00					; B1 input source number (keyboard=0/serial=1/etc)
		dc.b	$FF					; B2 keyboard semaphore
		dc.b	$00					; B3 primary OSHWM for exploded font
		dc.b	$00					; B4  B4 OSHWM
		dc.b	$01 					; B5 Serial mode
		
		dc.b	$00					; B6 char def exploded state
		dc.b	$00					; B7 cassette/rom switch
		dc.b	$00					; B8 video ULA copy (CTL)
		dc.b	$00					; B9 video ULA copy (PAL?)
		dc.b	$00					; BA ROM number active at BREAK
		dc.b	$FF					; BB BASIC ROM number
		dc.b	$04					; BC ADC channel
		dc.b	$04					; BD Max ADC channel

		dc.b	$00					; BE ADC conv type
		dc.b	$FF					; BF RS423 use flag
		dc.b	$56					; C0 RS423 ctl flag
		dc.b	$19					; C1 flash counter
		dc.b	$19					; C2 flash mark
		dc.b	$19					; C3 flash space
		dc.b	$32					; C4 keyboard autorepeat delay
		dc.b	$08					; C5 keyboard autorepeat rate

		dc.b	$00					; C6 *EXEC handle
		dc.b	$00					; C7 *SPOOL handle
		dc.b	$00					; C8 ESCAPE effect
		dc.b	$00					; C9 keyboard disable
		dc.b	$20					; CA keyboard status
		dc.b	$09					; CB Serial handshake extent
		dc.b	$00					; CC Serial suppression flag
		dc.b	$00					; CD Serial/cassette select flag


		dc.b	$00					; CE Econet OS Call intercept status
		dc.b	$00					; CF Econet read char intercept status
		dc.b	$00					; D0 Econet write char intercept status
		dc.b	$50					; D1 Speech suppress $50=speak
		dc.b	$00					; D2 Sound suppress
		dc.b	$03					; D3 Bell channel
		dc.b	$90					; D4 Bell vol, H, S
		dc.b	$64					; D5 Bell freq

		dc.b	$06					; D6 Bell duration
		dc.b	$81					; D7 Startup message suppress/!BOOT lock
		dc.b	$00					; D8 Soft key string
		dc.b	$00					; D9 lines since page
		dc.b	$00					; DA VDU Q len
		dc.b	$09					; DB TAB char
		dc.b	$1B					; DC ESCAPE char
		dc.b	$01					; DD Input buffer C0-CF interpretation

		dc.b	$D0					; DE Input buffer D0-DF interpretation
		dc.b	$E0					; DF Input buffer E0-EF interpretation
		dc.b	$F0					; E0 Input buffer F0-FF interpretation
		dc.b	$01					; E1 fnKey status 80-8F
		dc.b	$80					; E2 fnKey status 90-9F
		dc.b	$90					; E3 fnKey status A0-AF
		dc.b	$00					; E4 fnKey status B0-BF
		dc.b	$00					; E5 ESCAPE key action

		dc.b	$00					; E6 ESCAPE effects
		dc.b	$FF					; E7 IRQ mask for user VIA
		dc.b	$FF					; E8 IRQ mask for 6850 
		dc.b	$FF					; E9 IRQ mask for system VIA
		dc.b	$00					; EA TUBE flag
		dc.b	$00					; EB Speech flag
		dc.b	$00					; EC char dest status
		dc.b	$00					; ED cursor edit status
		
		dc.b	$00					; EE location 27E (keypad numeric base Master)
		dc.b	$00					; EF location 27F (?)
		dc.b	$00					; F0 location 280 (Country code)
		dc.b	$00					; F1 location 281 (user flag)
		;TODO this default changed to 9,600 baud
		dc.b	$64					; F2 Serial ULA copy - original
;;	IF MACH_BEEB && NOICE
;;		dc.b	$40					; F2 Serial ULA copy - 19200 for noice
;;	ELSE
;;		dc.b	$52					; F2 Serial ULA copy - 4,800 for HOSTFS
;;	ENDIF
		dc.b	$05					; F3 Timer switch state
		dc.b	$FF					; F4 Soft key consistency
		dc.b	$01					; F5 Printer dest

		dc.b	$0A					; Printer ignore
		dc.b	$00					; break vector jmp
		dc.b	$00					; break vector hi
		dc.b	$00					; break vectro lo
		dc.b	$00
		dc.b	$00
		dc.b	$FF					;	D9C6
