;Lab:			Lab2 part 3
;Name:			Zachary Frederick
;Section #:		13067
;PI Name:		Wesley Piard & Chris Crary
;Description:	Create a timer from 0 to 255 using the largest prescaler (slowest timer) and output values to a  port 

;include file for specific chip
.include "ATxmega128A1Udef.inc"

;Equates
.equ MAX_VALUE	= 0xFF						;holds the max value for the counter (period)
.equ ZERO		= 0x00						;zero
.equ OUTPUTDIR	= 0xFF						;output direction

;Start
.org 0x0000
	rjmp MAIN								;jump to main at 0x200 to avoid interrup vectors

;Main
.org 0x200
MAIN:
	ldi r16, OUTPUTDIR						;load r16 with the max value for the counter (255)
	sts PORTC_DIRSET, r16					;set PORTC to be an output (using the max malue as a shortcut
	ldi r16, ZERO							;load r16 with zero
	sts TCC0_CNT, r16						;load the low byte of the count register with 0
	sts TCC0_CNT+1, r16						;load the high byte of the count register with 0
	ldi r16, low(MAX_VALUE)					;load r16 with the low byte of the MAX_VALUE
	sts TCC0_PER, r16						;load the low part of the period register with r16
	ldi r16, high(MAX_VALUE)				;load the high byte of the max value into r16
	sts TCC0_PER+1, r16						;load the period register high with r16
	ldi r16, TC_CLKSEL_DIV1024_gc			;load r16 with the largest prescaler for the slowest clock
	sts TCC0_CTRLA, r16						;place the prescaler into the CRTLA register. This starts the timer

LOOP:
	lds r16, TCC0_CNT						;Load r16 with the low byte of the current count
	sts PORTC_OUT, r16						;store r16 into the out register of PORTC
	rjmp LOOP								;jump back to the beginning of the loop

	
