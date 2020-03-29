;Lab:			Lab2 part 4
;Name:			Zachary Frederick
;Section #:		13067
;PI Name:		Wesley Piard & Chris Crary
;Description:	Simple animation editor and player using the button and led backpack. S1 adds a frame to the animation, s2 plays the animation	

;include header file for specific chip equates
.include "ATxmega128A1Udef.inc"

;Equates
.equ FRAME_TABLE	= 0x2000		;starting address of the output table to hold the animation 'frames'
.equ DIP_SWITCH_DIR = 0x00			;DIRSET value for the dip switches to mark them as inputs
.equ LEDS_DIR		= 0xFF			;DIRSET value for leds to mark them as outputs	
.equ BTN_DIR		= 0x00			;DIRSET value for buttons
.equ S1_MASK		= 0b00000100	;mask for S1. Necessary because my board has errors that cause 
.equ S2_MASK		= 0b00001000	;mask for S2. multiple values to be triggered when I hit each tactile button. Must filter output
.equ DEBOUNCE_MULT	= 0x01			;Debounce multiplier for the debounce subroutine. 0x05 translates to 5 X 10ms or 50ms
.equ ANIM_MULT		= 5		;Animation multiplier. A value of ten (0x0A) corresponds to a frequency of 20Hz
.equ DELAY_INNER	= 0xF8			;timer for the inner loop of the delay function
.equ DELAY_OUTER	= 0x10			;value for the outer loop of the delay function
.equ STACK_INIT		= 0x3fff		;stack pointer initialization value

;Defines
.def DIP_R18 = r18					;define the r18 register as the value that holds the current value of the DIP Switches for each cycle  of the loop

;START
.org 0x0000
	rjmp MAIN						;jmp to main to allow for interrupt vector space

;MAIN
.org 0x200
MAIN:
	ldi r16, low(STACK_INIT)		;load the low byte of the sp location into r16
	out CPU_SPL, r16				;load the low byte of the stack pointer with r16
	ldi r16, high(STACK_INIT)		;load the high byte of the sp location into r16
	out CPU_SPH, r16				;load the high byte into the stack pointer
	ldi XL, low(FRAME_TABLE)		;Load the frame table low byte into XL
	ldi XH, high(FRAME_TABLE)		;Load the frame table high byte into XH
	ldi r16, DIP_SWITCH_DIR			;Load the register with the direction for the DIP Switches
	sts PORTA_DIRSET, r16			;store the dip switch direction into the DIRSET register
	ldi r16, LEDS_DIR				;load the register with the LED direction
	sts PORTC_DIRSET, r16			;store the LED direction into dirset register
	ldi r16, BTN_DIR				;load the btn direction
	sts PORTF_DIRSET, r16			;store the value into the DIRSET register
	rjmp MAIN_LOOP					;jmp to the MAIN_LOOP

MAIN_LOOP:
	lds DIP_R18, PORTA_IN			;Load the value of the dip switches into r18
	sts PORTC_OUT, DIP_R18			;Display the dip switches on the LEDS
	lds r16, PORTF_IN				;Load the in value for the Tactile button port
	ldi r17, S1_MASK				;Load r17 with the S1_MASK
	AND r17, r16					;AND value to check if proper bit is set 
	breq S1_PRESSED					;if the values are equal the button has been pressed
	ldi r17, S2_MASK				;if S1 wasn't pressed load r17 with the S2_MASK
	and r17, r16					;AND values together
	breq S2_PRESSED					;if the values are equal jump to S2 pressed
	rjmp MAIN_LOOP					;if neither buttons were pressed jump back to the top of the main loop

S1_PRESSED:
	rcall BOUNCE_SWITCH				;If S1 was pressed call the subroutine to bounce the switch

WAIT_FOR_RELEASE_S1:
	lds r16, PORTF_IN				;load the values of the button ports into r16
	ldi r17, S1_MASK				;load r17 with the mask
	and r17, r16					;and value with mask
	breq WAIT_FOR_RELEASE_S1		;if they are equal return to top of loop because button is still pressed
	rcall BOUNCE_SWITCH				;bounce the switch again after it was released for 50ms
	ST X+, DIP_R18					;store the current dip switch configuration into the frame table and increment the pointer
	rjmp MAIN_LOOP					;return back to the main loop

S2_PRESSED:
	rcall BOUNCE_SWITCH				;when s2 is initially pressed bounce the switch

WAIT_FOR_RELEASE_S2:
	lds r16, PORTF_IN				;load the register with the value for the port register
	ldi r17, S2_MASK				;load r17 with the mask for s2
	and r17, r16					;and the values togetheer to test the bit
	breq WAIT_FOR_RELEASE_S2		;if the value is equal then the button hasn't been released and return to top of loop
	rcall BOUNCE_SWITCH				;if the button was released bounce the switch for 50ms
	rcall PLAY_MODE					;call the PLAY_MODE subroutine 
	rjmp MAIN_LOOP					;after PLAY_MODE has exited return to the main loop

BOUNCE_SWITCH:
	push r17						;push r17 onto the stack 
	ldi r17, DEBOUNCE_MULT			;load r17 with the debounce time multiplier 
	rcall DELAY_X_10MS				;call the delay subroutine passing in the value of the multiplier through r17
	pop r17							;after subroutine has returned pop the value from the stack back into r17 to preserve its value
	ret								;return 

PLAY_MODE: ;aka sicko mode
	push r16						;push the two registers onto the stack to preserve their value		
	push r17						;push the second register onto the stack to preserve their value

START_ANIM:
	ldi YL, low(FRAME_TABLE)		;load the low byte into YL, when the animation repeats this value gets loaded into the value again to restart the animation
	ldi YH, high(FRAME_TABLE)		;load the high byte into YH

ANIM_LOOP:
	lds r16, PORTF_IN				;load the value for the  button ports into r16
	ldi r17, S2_MASK				;load the register with the mask to test whether s2 was pressed
	and r17, r16					;and the values together
	breq PLAY_MODE_END				;if the values are equal the button was pressed and we end the PLAY_MODE and return to edit mode
	ld r16, Y+						;if the button wasn't pressed load r16 with the first value of the frame table and increment the pointer 
	sts PORTC_OUT, r16				;store the value of the dip switches into the led out register
	ldi r17, ANIM_MULT				;load the register with the animation multiplier
	rcall DELAY_X_10MS				;call the delay subroutine for ANIM_MULT x 10ms. Should be approximately 20Hz
	cp XL, YL						;Compare the value of XL and YL
	breq START_ANIM					;If we have reached the end of the frame table return to the start of the animation loop
	rjmp ANIM_LOOP					;if we haven't reached the end of the frame table, return to the loop and load the next frame

PLAY_MODE_END:
	rcall BOUNCE_SWITCH				;S2 has been pressed so we need to bounce it first

WAIT_FOR_RELEASE_PLAY:
	lds r16, PORTF_IN				;Load the button ports into a register 
	ldi r17, S2_MASK				;load r17 with the mask			
	and r17, r16					;and the values together 
	breq WAIT_FOR_RELEASE_PLAY		;if the values are equal the button hasn't been released so keep waiting
	rcall BOUNCE_SWITCH				;if the button was released bounce the switch again
	pop r17							;pop the value of the stack to preserve the original r17 value
	pop r16							;pop the next value off the stack to preserve the original r16 value
	ret								;return from the subroutine

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
	ldi r18, DELAY_INNER			;reload the register with the inner loop value
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