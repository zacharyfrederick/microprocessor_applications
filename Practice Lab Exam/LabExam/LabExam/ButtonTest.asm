/*
 * ButtonTest.asm
 *
 *  Created: 10/11/2018 3:42:17 PM
 *   Author: Zachary
 */ 

 .org 0x0000
	rjmp MAIN

.org 0x200
MAIN:
	ldi r17, 0b00001100
	sts PORTF_DIRCLR, r17
	;sts PORTF_OUTCLR, r17
	ldi r17, 0b11110011
	sts PORTF_DIRSET, r17
	;sts PORTF_OUTCLR, r17


LOOP:
	lds r18, PORTF_IN
	andi r18, 0x0C
	rjmp LOOP
;	sbrs r18, 3
;	rjmp CHECK_S1
;	rjmp S2_PRESSED

CHECK_S1:
	sbrs r18, 4
	rjmp S1_PRESSED

S1_PRESSED:
	inc r20
	rjmp LOOP

S2_PRESSED:
	inc r19
	rjmp LOOP