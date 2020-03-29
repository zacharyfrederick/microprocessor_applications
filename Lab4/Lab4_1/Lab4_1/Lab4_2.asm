;Lab:			Lab4 part 2
;Name:			Zachary Frederick
;Section #:		13067
;PI Name:		Wesley Piard & Chris Crary
;Description:	Toggles the blue led and uses a debounced external interrupt to count button pressed on PORTC leds

;include header file for specific chip equates
.include "ATxmega128A1Udef.inc"

.cseg
.equ DEBOUNCE_PER = 0x4e320
.equ BITMASK = 0b00001100

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

	;enable external interrupts on PORTF pin 2
	ldi r17, 0xff
	sts PORTF_DIRCLR, r17
	ldi r17, 0x01
	sts PORTF_INTCTRL, r17

	;configure pins 2 to trigger interrupts
	ldi r17, 0b00001100
	sts PORTF_INT0MASK, r17

	;configure interrupt to be triggered on falling edge 
	ldi r17, 0x02
	sts PORTF_PIN2CTRL, r17

	;enable low level interrupts in the PMIC
	ldi r17, 0x01
	sts PMIC_CTRL, r17

	;enable global interrupts
	sei

	rcall INIT_TC_DB

END:
	;toggle the blue led on the micropad
	ldi r17, 0b01000000
	sts PORTD_OUTTGL, r17

	;read in portf for debugging
	lds r17, PORTF_IN
	mov r19, r17
	andi r19, BITMASK
	rjmp END

PORT_INTR:
	;enable to timer to start debouncing
	ldi r17, 0x02
	sts TCE0_CTRLA, r17
	
	;disable external interrupt
	ldi r17, 0x00
	sts PORTF_INTCTRL, r17

	;return
	reti

INIT_TC_DB:
	;set the period of the TC to the debounce period
	push r17
	ldi r17, low(DEBOUNCE_PER)
	sts TCE0_PER, r17
	ldi r17, high(DEBOUNCE_PER)
	sts TCE0_PER+1, r17

	;enable low level overflow interrupts
	ldi r17, 0x01
	sts TCE0_INTCTRLA, r17 
	pop r17

	;return
	ret

DEBOUNCE_ISR:
	;turn off the timer and reset it back to 0
	push r17
	ldi r17, 0x00
	sts TCE0_CTRLA, r17
	sts TCE0_CNT, r17
	sts TCE0_CNT+1, r17

	;read in the portf values(s1 and s2)
	lds r17, PORTF_IN
	mov r19, r17
	andi r19, BITMASK

	;compare values to the "pressed value"
	cpi r19, 0x08
	breq INCR_COUNT

	;if not equal then do nothing
	rjmp END_ISR

INCR_COUNT:
	;update the counter and display it on the leds on portc
	inc r18
	mov r19, r18
	com r19
	sts PORTC_OUT, r19

END_ISR:
	;enable external interrupts
	ldi r17, 0x01
	sts PORTF_INTCTRL, r17
	pop r17
	reti

