.include "ATxmega128A1Udef.inc"

.equ MAX_VALUE = 0xFF
.equ ZERO = 0x00

.org 0x0000
	rjmp MAIN

.org 0x200
MAIN:
	ldi r16, 0xFF
	sts PORTC_DIRSET, r16
	ldi r16, ZERO
	sts TCC0_CNT, r16
	sts TCC0_CNT+1, r16
	ldi r16, low(MAX_VALUE)
	sts TCC0_PER, r16
	ldi r16, high(MAX_VALUE)
	sts TCC0_PER+1, r16
	ldi r16, TC_CLKSEL_DIV1024_gc
	sts TCC0_CTRLA, r16
LOOP:
	lds r16, TCC0_CNT
	sts PORTC_OUT, r16
	rjmp LOOP