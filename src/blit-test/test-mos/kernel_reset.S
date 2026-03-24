


		xdef kernel_handle_res


		.text

 **************************************************************************
 **************************************************************************
 **                                                                      **
 **                                                                      **
 **      RESET (BREAK) ENTRY POINT                                       **
 **                                                                      **
 **      Power up Enter with nothing set, 6522 System VIA IER bits       **
 **      0 to 6 will be clear                                            **
 **                                                                      **
 **      BREAK IER bits 0 to 6 one or more will be set 6522 IER          **
 **      not reset by BREAK                                              **
 **                                                                      **
 **************************************************************************

kernel_handle_res:	

		bra	kernel_go_todo
