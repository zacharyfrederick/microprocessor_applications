;Lab:			Lab4 part 7
;Name:			Zachary Frederick
;Section #:		13067
;PI Name:		Wesley Piard & Chris Crary
;Description:	Input a character over USART using polling

;include header file for specific chip equates
.include "ATxmega128A1Udef.inc"

.org 0x0000
	rjmp MAIN

.org 0x200
MAIN:
	ldi r17, 0b01110000
	sts PORTD_DIRCLR, r17
	sts PORTD_OUTCLR, r17
	rcall USART_INIT

END:
	rcall IN_CHAR
	rjmp END

USART_INIT:
	;subroutine prologue
	push r17

	;set PORTD2 high?
	ldi r17, 0x08
	sts PORTD_OUTSET, r17

	;set PORTD2(Transmit) as output, and PORTD3 as input
	sts PORTD_DIRSET, r17

	;configure USART for appropriate settings
	ldi r17, 0b00110011
	sts USARTD0_CTRLC, r17

	;set BSCALE and BSEL for 115,200 baud rate
	ldi r17, 11
	sts USARTD0_BAUDCTRLA, r17
	ldi r17, (0x09 << 4)|(11>>8)
	sts USARTD0_BAUDCTRLB, r17

	;enable interrupts
	ldi r17, 0b00010000
	sts USARTD0_CTRLA, r17
	
	;enable PMIC For low level interrupts
	ldi r17, 0x01
	sts PMIC_CTRL, r17

	;enable TX and RX
	ldi r17, 0b00011000
	sts USARTD0_CTRLB, r17

	;enable global interrupts
	sei

	;subroutine epilogue
	pop r17
	ret