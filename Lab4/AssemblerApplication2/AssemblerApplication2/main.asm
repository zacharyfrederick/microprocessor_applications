.include "ATxmega128a1udef.inc"

.cseg
.equ DEBOUNCE_PER = 0x4e20

.org 0x0000
	rjmp MAIN

.org PORTF_INT0_vect
	rjmp PORT_INTR

.org TCE0_OVF_vect
	rjmp DEBOUNCE_ISR

.org 0x200
MAIN:
	ldi r17, 0xff
	sts PORTA_DIRSET, r17
	sts PORTA_OUTCLR, r17

	;initialize r18 as counter
	clr r18

	;initialize LED for testing
	ldi r17, 0b01000000
	sts PORTD_DIRSET, r17
	sts PORTD_OUTSET, r17

	;initialize PORTC for leds
	ldi r17, 0xff
	sts PORTC_DIRSET, r17
	sts PORTC_OUTSET, r17

	;initialize TC
	rcall INIT_TC_DB

	ldi r17, 0xff
	sts PORTA_DIRCLR, r17
	sts PORTC_DIRSET, r17
	sts PORTD_DIRSET, r17
	sts PORTD_OUTSET, r17

	ldi r17, 0xff
	sts PORTF_DIRCLR, r17
	ldi r17, 0x01
	sts PORTF_INTCTRL, r17
	ldi r17, 0b00001100
	sts PORTF_INT0MASK, r17
	ldi r17, 0x02
	sts PORTF_PIN2CTRL, r17

	ldi r17, 0x01
	sts PMIC_CTRL, r17
	sei

	rcall INIT_TC_DB

END:
	ldi r17, 0b01000000
	sts PORTD_OUTTGL, r17
	rjmp END

PORT_INTR:
	ldi r17, 0x01
	sts TCE0_CTRLA, r17
	ldi r17, 0x00
	sts PORTF_INTCTRL, r17
	reti

INIT_TC_DB:
	push r17
	ldi r17, low(DEBOUNCE_PER)
	sts TCE0_PER, r17
	ldi r17, high(DEBOUNCE_PER)
	sts TCE0_PER+1, r17
	ldi r17, 0x01
	sts TCE0_INTCTRLA, r17 
	pop r17
	ret

DEBOUNCE_ISR:
	push r17
	ldi r17, 0x00
	sts TCE0_CTRLA, r17
	sts TCE0_CNT, r17
	sts TCE0_CNT+1, r17
	lds r17, PORTF_IN
	cpi r17, 0x08
	breq INCR_COUNT
	rjmp END_ISR

INCR_COUNT:
	inc r18
	mov r19, r18
	com r19
	sts PORTC_OUT, r19

END_ISR:
	ldi r17, 0x01
	sts PORTF_INTCTRL, r17
	pop r17
	reti

