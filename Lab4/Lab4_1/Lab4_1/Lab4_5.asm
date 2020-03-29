;Lab:			Lab4 part 5
;Name:			Zachary Frederick
;Section #:		13067
;PI Name:		Wesley Piard & Chris Crary
;Description:	Transmitting a character and measuring the baud rate using DADdy

;include header file for specific chip equates
.include "ATxmega128A1Udef.inc"

.org 0x0000
	rjmp MAIN

.org 0x200
MAIN:
	rcall USART_INIT
	ldi r17, 85

END:
	rcall OUT_CHAR
	rjmp END

USART_INIT:
	;subroutine prologue
	push r17

	;set PORTD2 high?
	ldi r17, 0x08
	sts PORTF_OUTSET, r17

	;set PORTD2(Transmit) as output, and PORTD3 as input
	sts PORTF_DIRSET, r17

	;configure USART for appropriate settings
	ldi r17, 0b00110011
	sts USARTF0_CTRLC, r17

	;set BSCALE and BSEL for 115,200 baud rate
	ldi r17, 11
	sts USARTF0_BAUDCTRLA, r17
	ldi r17, (0x09 << 4)|(11>>8)
	sts USARTF0_BAUDCTRLB, r17

	;enable TX and RX
	ldi r17, 0b00011000
	sts USARTF0_CTRLB, r17

	;subroutine epilogue
	pop r17
	ret

OUT_CHAR:
	;subroutine prologue
	;uses r17 as the parameter for the character to be passed
	push r16

LOOP:
	;loads the usart status register
	lds r16, USARTF0_STATUS

	;checks if the Data Register Empty Flag is 0. Zero indicates data needs to be sent 
	sbrs r16, 0x05
	rjmp loop

	;send the data 
	sts USARTF0_DATA, r17
	
	;function epilogue
	pop r16
	ret
