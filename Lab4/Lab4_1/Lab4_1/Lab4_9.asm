;Lab:			Lab4 part 2
;Name:			Zachary Frederick
;Section #:		13067
;PI Name:		Wesley Piard & Chris Crary
;Description:	Toggles the blue led and uses a debounced external interrupt to count button pressed on PORTC leds

;include header file for specific chip equates
.include "ATxmega128A1Udef.inc"

.equ DEBOUNCE_PER = 0x4e20
.equ BITMASK = 0b00001100
.equ PLAYMODE = 0x00
.equ EDITMODE = 0xff
.equ FRAME_TABLE	= 0x2000
.equ S1_PRESSED = 0x08
.equ S2_PRESSED = 0x04 
.equ ANIM_PER = 0xc350

.org PORTF_INT0_vect
	rjmp EXTERN_INTR

.org TCE0_OVF_vect
	rjmp DEBOUNCE_ISR

.org TCE1_OVF_vect
	rjmp ANIM_ISR

.org USARTD0_RXC_vect
	rjmp RXC_ISR


.org 0x0000
	rjmp MAIN

.org 0x200
MAIN:
	clr r18
	rcall INIT_LEDS
	rcall INIT_DIPS
	rcall INIT_TCE0
	rcall INIT_USART
	rcall INIT_EXTERN_INTR
	rcall INIT_ANIM_TIMER
	rcall LOAD_FRAME_TABLE
	rcall TOGGLE_EDIT_MODE
	rcall RESET_Y_PTR

MAIN_LOOP:
	cpi r20, EDITMODE
	breq EDITMODE_LOOP
	rjmp MAIN_LOOP

EDITMODE_LOOP:
	rcall DISPLAY_DIPS
	rjmp MAIN_LOOP

END:
	rjmp END

ANIM_ISR:
	push r17

	ld r17, Y+
	sts PORTC_OUT, r17

	cp YL, XL
	breq RESET_POINTER
	rjmp END_ANIM_ISR

RESET_POINTER:
	rcall RESET_Y_PTR

END_ANIM_ISR:
	pop r17
	reti 

TURN_ON_ANIM:
	push r17
	ldi r17, 0x01
	sts TCE1_CTRLA, r17
	pop r17
	ret

TURN_OFF_ANIM:
	push r17
	ldi r17, 0x00
	sts TCE1_CTRLA, r17
	pop r17
	ret

RESET_Y_PTR:
	ldi YL, low(FRAME_TABLE)
	ldi YH, high(FRAME_TABLE)
	ret

INIT_ANIM_TIMER:
	push r17
	ldi r17, low(ANIM_PER)
	sts TCE1_PER, r17
	ldi r17, high(ANIM_PER)
	sts TCE1_PER+1, r17

	;enable low level overflow interrupts
	ldi r17, 0x01
	sts TCE1_INTCTRLA, r17 
	pop r17

	;return
	ret
	
TOGGLE_EDIT_MODE:
	ldi r20, EDITMODE
	rcall TURN_OFF_ANIM
	ret

TOGGLE_PLAY_MODE:
	ldi r20, PLAYMODE
	rcall TURN_ON_ANIM
	rcall RESET_Y_PTR
	ret

ENABLE_TCE0:
	push r17
	ldi r17, 0x01
	sts TCE0_CTRLA, r17
	pop r17
	ret

DISABLE_EXTERN_INTR:
	push r17

	ldi r17, 0x00
	sts PORTF_INTCTRL, r17

	pop r17
	ret

EXTERN_INTR:
	push r17

	rcall ENABLE_TCE0
	rcall DISABLE_EXTERN_INTR

	pop r17
	reti

RESET_COUNTER:
	push r17
	ldi r17, 0x00
	sts TCE0_CTRLA, r17
	sts TCE0_CNT, r17
	sts TCE0_CNT+1, r17
	pop r17
	ret

ENABLE_EXTERN_INTR:
	push r17
	ldi r17, 0x01
	sts PORTF_INTCTRL, r17
	pop r17
	ret

DEBOUNCE_ISR:
	push r17
	rcall RESET_COUNTER

	lds r17, PORTF_IN
	andi r17, BITMASK

	cpi r17, S1_PRESSED
	breq S1
	cpi r17, S2_PRESSED
	breq S2
	rjmp END_DEBOUNCE

S1:
	cpi r20, PLAYMODE
	breq S1_PLAYMODE
	cpi r20, EDITMODE
	breq S1_EDITMODE

S1_PLAYMODE:
	rcall TOGGLE_EDIT_MODE
	rjmp END_DEBOUNCE

S1_EDITMODE:
	lds r17, PORTA_IN
	st X+, r17
	rjmp END_DEBOUNCE

S2:
	cpi r20, PLAYMODE
	breq S2_PLAYMODE
	cpi r20, EDITMODE
	breq S2_EDITMODE

S2_PLAYMODE:
	rjmp END_DEBOUNCE

S2_EDITMODE:
	rcall TOGGLE_PLAY_MODE
	rjmp END_DEBOUNCE

END_DEBOUNCE:
	rcall ENABLE_EXTERN_INTR
	pop r17
	reti

INIT_EXTERN_INTR:
	push r17

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

	pop r17
	ret

DISPLAY_DIPS:
	push r17

	lds r17, PORTA_IN
	sts PORTC_OUT, r17

	pop r17
	ret

INIT_USART:
	;subroutine prologue
	push r17

	;set PORTD2 high?
	ldi r17, 0x08
	sts PORTD_OUTSET, r17

	;set PORTD2(Transmit) as output, and PORTD3 as input
	sts PORTD_DIRSET, r17

	;configure USART for appropriate settings
	ldi r17, 0b00110011
	sts USARTD0_CTRLC, r17

	;enable interrupts
	ldi r17, 0b00010000
	sts USARTD0_CTRLA, r17

	;set BSCALE and BSEL for 115,200 baud rate
	ldi r17, 11
	sts USARTD0_BAUDCTRLA, r17
	ldi r17, (0x09 << 4)|(11>>8)
	sts USARTD0_BAUDCTRLB, r17

	;enable TX and RX
	ldi r17, 0b00011000
	sts USARTD0_CTRLB, r17

	;subroutine epilogue
	pop r17
	ret

INIT_TCE0:
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

INIT_LEDS:
	push r17
	
	;set leds as outputs
	ldi r17, 0xff
	sts PORTC_DIRSET, r17

	;turn off leds
	sts PORTC_OUTSET, r17

	pop r17
	ret

INIT_DIPS:
	push r17

	;set DIPS as inputs
	ldi r17, 0xff
	sts PORTA_DIRCLR, r17

	pop r17
	ret

LOAD_FRAME_TABLE:
	push r17
	ldi XL, low(FRAME_TABLE)
	ldi XH, high(FRAME_TABLE)
	pop r17
	ret

RXC_ISR:
	lds r17, USARTD0_DATA
	
	cpi r20, EDITMODE
	breq RXC_EDITMODE

	cpi r20, PLAYMODE
	breq RXC_PLAYMODE

	rjmp RXC_ISR_END

RXC_PLAYMODE:
	cpi r17, 108
	breq  RXC_SWITCH_MODE
	rjmp RXC_ISR_END

RXC_SWITCH_MODE:
	rcall TOGGLE_EDIT_MODE
	rjmp RXC_ISR_END
	
RXC_EDITMODE:
	cpi r17, 50
	breq RXC_ENABLE_PLAY
	cpi r17, 13
	breq RXC_ADD_FRAME
	rjmp RXC_ISR_END

RXC_ADD_FRAME:
	rcall ADD_FRAME_TO_TABLE
	rjmp RXC_ISR_END

RXC_ENABLE_PLAY:
	rcall TOGGLE_PLAY_MODE 

RXC_ISR_END:
	reti

OUT_CHAR:
	;subroutine prologue
	;uses r17 as the parameter for the character to be passed
	push r16

LOOP:
	;loads the usart status register
	lds r16, USARTD0_STATUS

	;checks if the Data Register Empty Flag is 0. Zero indicates data needs to be sent 
	sbrs r16, 0x05
	rjmp loop

	;send the data 
	sts USARTD0_DATA, r17
	
	;function epilogue
	pop r16
	ret

ADD_FRAME_TO_TABLE:
	push r17
	lds r17, PORTA_IN
	st X+, r17
	pop r17
	ret

OUT_STRING:
	;load from program memory the character
	lpm r17, Z+

	;compare it to zero (termination character)
	cpi r17, 0x00
	breq END_OUT_STRING

	;if not equal to the termination character send the character
	rcall OUT_CHAR
	rjmp OUT_STRING

END_OUT_STRING:
	ret