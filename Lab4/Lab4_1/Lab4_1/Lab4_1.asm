;Lab:			Lab4 part 1
;Name:			Zachary Frederick
;Section #:		13067
;PI Name:		Wesley Piard & Chris Crary
;Description:	Toggles a pin using a TC and an interrupt. Configured to interrupt every 100ms

;include header file for specific chip equates
.include "ATxmega128A1Udef.inc"

.equ STACKPOINTER		= 0x3fff
.equ PERIOD				= 0x30D
.equ PORTA_PIN0_DIR		= 0x01
.equ PORTA_LOWLVL_INTR	= 0x01

.org 0x0000
	rjmp MAIN

.org TCC0_OVF_vect
	rjmp TC_ISR

MAIN:
.org 0x200
	;set the stackpointer to 0x3fff
	ldi r17, low(STACKPOINTER)
	out CPU_SPL, r17
	ldi r17, high(STACKPOINTER)
	out CPU_SPH, r17

	;set the direction of PORTA pin 0 to be an output
	ldi r17, PORTA_PIN0_DIR
	sts PORTA_DIRSET, r17

	;initialize the TC
	rcall INIT_TC

END:
	;endless loop
	rjmp END
	
INIT_TC:
	;load the counter with the period
	ldi r17, low(PERIOD)
	sts TCC0_PER, r17
	ldi r17, high(PERIOD)
	sts TCC0_PER+1, r17

	;set the TC to have a low level interrupt enabled
	ldi r17, PORTA_LOWLVL_INTR
	sts TCC0_INTCTRLA, r17

	;set the PMIC to enable low level interrupts
	sts PMIC_CTRL, r17

	;set the clock to use the clk/256 divisor and start the counter
	ldi r17, TC_CLKSEL_DIV256_gc
	sts TCC0_CTRLA, r17

	;enable global interrupts
	sei

	;return
	ret

TC_ISR:
	;toggle PORTA Pin 0
	ldi r17, PORTA_PIN0_DIR
	sts PORTA_OUTTGL, r17
	reti