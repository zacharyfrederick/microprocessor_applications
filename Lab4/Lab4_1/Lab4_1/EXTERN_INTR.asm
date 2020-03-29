/*
 * EXTERN_INTR.asm
 *
 *  Created: 10/22/2018 12:11:25 AM
 *   Author: Zachary
 */ 

.org 0x0000
	rjmp MAIN

.org PORTF_INT0_vect
	rjmp PORT_INTR

.org 0x200
MAIN:
	ldi r17, 0xff
	sts PORTC_DIRSET, r17

	ldi r17, 0b00001000
	sts PORTF_DIRCLR, r17
	ldi r17, 0b11110111
	sts PORTF_DIRSET, r17
	sts PORTF_OUTCLR, r17
	ldi r17, 0x01
	sts PORTF_INTCTRL, r17
	ldi r17, 0b00001000
	sts PORTF_INT0MASK, r17
	sei 

END:
	ldi r17, 0xff
	sts PORTC_OUTTGL, r17
	rjmp END

PORT_INTR:
	ldi r17, 0xff
	sts PORTD_OUTTGL, r17
	reti