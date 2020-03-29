;
; LabExam.asm
;
; Created: 10/11/2018 1:29:20 PM
; Author : Zachary
;


; Replace with your application code
.include "ATxmega128a1udef.inc"

.org 0x0000
	rjmp MAIN


.org 0x01C
	rjmp TC_ISR

.org 0x200
MAIN:
	ldi r17, 0xff
	sts PORTC_DIRSET, r17
	sts PORTC_OUTSET, r17
	sts PORTA_DIRCLR, r17
	rcall INIT_TC

END:
	rjmp END

INIT_TC:
	ldi r17, 0x0c
	ldi r18, 0x01
	sts TCC0_PER, r17
	sts TCC0_PER+1, r18
	ldi r17, 0x01
	sts TCC0_INTCTRLA, r17
	sts PMIC_CTRL, r17
	ldi r17, 0b0001
	sts TCC0_CTRLA, r17
	sei
	ret

TC_ISR:
	ldi r17, 0xff
	sts PORTC_OUTTGL, r17
	reti