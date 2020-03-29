.include "ATxmega128A1Udef.inc"

.equ BTN_DIR = 0x00 ;configure PORT E as an input
.equ S1_MASK = 0b00000010 ;MASK for S1 on E1
.equ DELAY_INNER	= 0xF8			;timer for the inner loop of the delay function
.equ DELAY_OUTER	= 0x10	
.equ DEBOUNCE_MULT	= 0x01
.equ LEDS_DIR		= 0xFF

.def COUNT_r18 = r18

.org 0x0000
	rjmp MAIN

.org 0x200
MAIN:
	ldi r16, BTN_DIR
	sts PORTE_DIRSET, r16
	clr COUNT_r18
	ldi r16, LEDS_DIR				;load the register with the LED direction
	sts PORTC_DIRSET, r16


MAIN_LOOP:
	mov r19, r18
	com r19
	sts PORTC_OUT, r19
	lds r16, PORTE_IN
	ldi r17, S1_MASK
	and r17, r16
	breq S1_PRESSED
	rjmp MAIN_LOOP

S1_PRESSED:
	rcall BOUNCE_SWITCH				;If S1 was pressed call the subroutine to bounce the switch

WAIT_FOR_RELEASE_S1:
	lds r16, PORTE_IN				;load the values of the button ports into r16
	ldi r17, S1_MASK				;load r17 with the mask
	and r17, r16					;and value with mask
	breq WAIT_FOR_RELEASE_S1		;if they are equal return to top of loop because button is still pressed
	rcall BOUNCE_SWITCH	
	inc COUNT_r18
	rjmp MAIN_LOOP					;return back to the main loop

BOUNCE_SWITCH:
	push r17						;push r17 onto the stack 
	ldi r17, DEBOUNCE_MULT			;load r17 with the debounce time multiplier 
	rcall DELAY_X_10MS				;call the delay subroutine passing in the value of the multiplier through r17
	pop r17							;after subroutine has returned pop the value from the stack back into r17 to preserve its value
	ret								;return 
	

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
	ldi r18, DELAY_INNER			;reload the register with the inner loop value
	dec r19							;decrement the outer loop counter
	rjmp LOOP1						;jump back to the start of a new inner loop

DELAY_10MS_END:
	pop r19							;pop the value off the stack to preserve the original register value
	pop r18							;pop the value off the stack to preserve original register value
	ret		


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
	ret				
