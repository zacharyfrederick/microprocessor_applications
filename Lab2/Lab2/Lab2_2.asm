;Lab:			Lab2 part 2
;Name:			Zachary Frederick
;Section #:		13067
;PI Name:		Wesley Piard & Chris Crary
;Description:	Create a square wave with a 10ms delay function attempting to create a frequency of 10Hz

;include file
.include "ATxmega128A1Udef.inc"

;Equates
.equ STACK_START		= 0x3FFF	;stack pointer initial location
.equ PORTA0				= 0x01		;bit mask to set pin 0 on PORTA to output
.equ DELAY_INNER		= 0xF8		;timer for the inner loop of the delay function
.equ DELAY_OUTER		= 0x10		;value for the outer loop of the delay function
.equ DELAY_MULT_10HZ	= 0x05		;value for the delay of the function. Approximately 10Hz square wave

;START
.org 0x0000
	rjmp MAIN						;jmp to main at 0x200 to avoid interrupt vectors 

;MAIN
.org 0x200							
MAIN:
	ldi r16, low(STACK_START)		;load r16 with the low byte of the desired stack pointer 
	out CPU_SPL, r16				;put the stack pointer low byte into the stack pointer low register
	ldi r16, high(STACK_START)		;load r16 with the high byte of the desired stack pointer
	out CPU_SPH, r16				;put the stack pointer high byte into the stack pointer high register
	ldi r16, PORTA0					;load the register with PORTA0
	sts PORTA_DIRSET, r16			;declare pin 0 on PORTA as an output. (available for probing)
	ldi r17, DELAY_MULT_10HZ		;load the value of the delay register into r17. Delay subroutine expects the delay to be placed into r17

MAIN_LOOP:
	ldi r16, 0x01					;load r16 with the value of 1. Sets probe pin to be high
	sts PORTA_OUT, r16				;set the out register for the port to the value of register (Sets pin high)
	rcall DELAY_X_10MS				;call the delay to let  the value be high for appropriate period
	ldi r16, 0x00					;loads the value of zero into r16
	sts PORTA_OUT, r16				;sets the pin low
	rcall DELAY_X_10MS				;keep the pin low forthe appropriate time 
	rjmp MAIN_LOOP					;return to the main loop and do it all again
	
;----------------------DELAY_10MS sub---------------------------------------
DELAY_10MS:
	push r18						;push the value onto the stack to preserve its value
	push r19						;push the value onto the stack to preserve its value
	ldi r18, DELAY_INNER			;load r18 with the inner loop timer
	dec r18							;decrement the counter because we are in the first loop
	ldi r19, DELAY_OUTER			;load the register with the outer loop counter
	dec r19							;decrement the counter because we are in the first loop

LOOP1:
	cpi r18, 0x00					;compare the inner loop value with 0
	breq CHECK_LOOP					;if r18 is equal to zero then the inner loop has completed
	dec r18							;if not then decrement the counter
	rjmp LOOP1						;return to the top of the inner loop

CHECK_LOOP:
	cpi r19, 0x00					;compare outer loop counter with 0
	breq DELAY_10MS_END				;if they are equal then we branch to the end of the subroutine
	ldi r18, 249					;reload the register with the inner loop value. Alternating between this 248 and this value results in greater precision
	dec r19							;decrement the outer loop counter
	rjmp LOOP1						;jump back to the start of a new inner loop

DELAY_10MS_END:
	pop r19							;pop the value off the stack to preserve the original register value
	pop r18							;pop the value off the stack to preserve original register value
	ret								;return from the subroutine
;---------------------end DELAY_10MS sub-------------------------------

DELAY_X_10MS:
	cpi r17, 0x00					;compare the r17 register with 00 to check for a zero delay function  call
	breq END_DELAY_X_WO_POP			;if the value is zero(zero delay requested) jump to the end of the subroutine without popping value off the stack
	push r17						;push the value of r17 onto the stack
	dec r17							;decrement r17

LOOP_TEST:
	rcall DELAY_10MS				;call the delay function
	cpi r17, 0x00					;compare the counter value to zero
	breq END_DELAY_X_10MS			;if they are equal branch to the end of the function
	dec r17							;decrement the counter
	rjmp LOOP_TEST					;jump to the top of the loop test

END_DELAY_X_10MS:
	pop r17							;pop the value from the stack to preserve its value

END_DELAY_X_WO_POP:	
	ret								;return from sub 