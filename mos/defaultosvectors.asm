		
		xdef defaultosvectors

		section "code"

defaultosvectors
	dc.l	brkBadCommand-*			;  LD940 USERV
	dc.l	mos_DEFAULT_BRK_HANDLER-*	;  LD942 BRKV
	dc.l	kernel_irq1v_handle-*		;	mos_IRQ1V_default_entry		;  LD944 IRQ1V
	dc.l	kernel_irq2v_handle-*		;	mos_IRQ2V_default_entry		;  LD946 IRQ2V
	dc.l	brkBadCommand-*			;	mos_CLIV_default_handler	;  LD948 CLIV
	dc.l	SWI_OS_Byte_Handle-*		;	mos_default_BYTEV_handler	;  LD94A BYTEV
	dc.l	SWI_OS_Word_Handle-*		;	mos_WORDV_default_entry		;  LD94C WORDV
	dc.l	mos_WRCH_default_entry-*	;  LD94E WRCHV
	dc.l	mos_RDCHV_default_entry-*	;	mos_RDCHV_default_entry		;  LD950 RDCHV
	dc.l	brkBadCommand-*			;	dummy_vector_RTS		;  LD952 FILEV
	dc.l	brkBadCommand-*			;	mos_OSARGS			;  LD954 ARGSV
	dc.l	brkBadCommand-*			;	dummy_vector_RTS		;  LD956 BGETV
	dc.l	brkBadCommand-*			;	dummy_vector_RTS 		;  LD958 BPUTV
	dc.l	brkBadCommand-*			;	dummy_vector_RTS		;  LD95A GBPBV
	dc.l	brkBadCommand-*			;	mos_FINDV_default_handler	;  LD95C FINDV
	dc.l	brkBadCommand-*			;	mos_FSCV_default_handler	;  LD95E FSCV
	dc.l	mos_EVENTV_default-*		;	dummy_vector_RTS		;  LD960 EVNTV
	dc.l	brkBadCommand-*			;	dummy_vector_RTS		;  LD962 UPTV
	dc.l	NETV_dummy-*			;	dummy_vector_RTS		;  LD964 NETV
	dc.l	brkBadCommand-*			;	dummy_vector_RTS		;  LD966 VDUV
	dc.l	KEYV_default-*			;	KEYV_default			;  LD968 KEYV
	dc.l	mos_INSV_default_entry_point-*	;	mos_INSV_default_entry_point	;  LD96A INSV
	dc.l	mos_REMV_default_entry_point-*	;	mos_REMV_default_entry_point	;  LD96C REMV
	dc.l	mos_CNPV_default_entry_point-*	;	mos_CNPV_default_entry_point	;  LD96E CNPV
