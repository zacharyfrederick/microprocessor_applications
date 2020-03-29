/*
 * EBI_TEST.asm
 *
 *  Created: 10/11/2018 3:09:38 PM
 *   Author: Zachary
 */ 

.include "ATxmega128a1udef.inc"

.org 0x0000
	rjmp MAIN

.org TCC0_OVF_vect
	rjmp TC_ISR

.org 0x200
MAIN:
	ldi r17, 0xff
	sts PORTC_DIRSET, r17
	rcall INIT_TC
	ldi r17, 0xff
	sts PORTA_DIRCLR, r17
	ldi r17, 0x37
	sts PORTH_DIR, r17
	ldi r17, 0x33
	sts PORTH_OUT, r17
	ldi r17, 0xff
	sts PORTK_DIR, r17
	ldi r17, 0b00000001
	sts EBI_CTRL, r17
	ldi r17, 0b00010001
	sts EBI_CS1_CTRLA, r17
	ldi r17, 0x70
	sts EBI_CS1_BASEADDR, r17
	ldi r17, 0x03
	sts EBI_CS1_BASEADDR+1, r17
	ldi XL, byte1(0x37000)
	ldi XH, byte2(0x37000)
	ldi r17, byte3(0x37000)
	out CPU_RAMPX, r17
	sei

END:
	ld r17, X
	lds r18, PORTA_IN
	add r18, r17
	st X, r18
	rjmp END

INIT_TC:
	ldi r17, 0xFF
	ldi r18, 0xF0
	sts TCC0_PER, r17
	sts TCC0_PER+1, r18
	ldi r17, 0x01
	sts TCC0_INTCTRLA, r17
	sts PMIC_CTRL, r17
	ldi r17, 0b0100
	sts TCC0_CTRLA, r17
	ret

TC_ISR:
	ld r17, X
	com r17
	st X, r17
	reti