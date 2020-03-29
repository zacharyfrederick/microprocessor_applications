;Lab:			Lab4 part 6
;Name:			Zachary Frederick
;Section #:		13067
;PI Name:		Wesley Piard & Chris Crary
;Description:	Transmit a string over USART with a baud rate of 115,200

;include header file for specific chip equates
.include "ATxmega128A1Udef.inc"

.org 0x100
STRING: .db 'Z', 'A','C','H','A','R','Y',' ','T','H','O','M','A','S',' ','F','R','E','D','E','R','I','C','K','\n', 0
.org 0x0000
	rjmp MAIN

.org 0x200
MAIN:
	rcall USART_INIT
	ldi ZL, low(STRING << 1)
	ldi ZH, high(STRING << 1)
	ldi r17, byte3(STRING << 1)
	out CPU_RAMPZ, r17
	rcall OUT_STRING

END:
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

	;enable TX and RX
	ldi r17, 0b00011000
	sts USARTD0_CTRLB, r17

	;subroutine epilogue
	pop r17
	ret

OUT_CHAR:
	;subroutine prologue
	;uses r17 as the parameter for the character to be passed
	push r16

LOOP:
	;loads the usart status register
	lds r16, USARTD0_STATUS

	;checks if the Data Register Empty Flag is 0. Zero indicates data needs to be sent 
	sbrs r16, 0x05
	rjmp loop

	;send the data 
	sts USARTD0_DATA, r17
	
	;function epilogue
	pop r16
	ret

OUT_STRING:
	;load from program memory the character
	lpm r17, Z+

	;compare it to zero (termination character)
	cpi r17, 0x00
	breq END_OUT_STRING

	;if not equal to the termination character send the character
	rcall OUT_CHAR
	rjmp OUT_STRING

END_OUT_STRING:
	ret