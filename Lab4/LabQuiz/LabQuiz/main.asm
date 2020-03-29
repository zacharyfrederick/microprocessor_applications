;Lab:			Lab4 part 8
;Name:			Zachary Frederick
;Section #:		13067
;PI Name:		Wesley Piard & Chris Crary
;Description:	Input a character over usart using interrupts

;include header file for specific chip equates
.include "ATxmega128A1Udef.inc"

.equ DEBOUNCE_PER = 0xffff
.equ BITMASK = 0b00001100

.org USARTD0_RXC_vect
	rjmp RXC_ISR

.org PORTF_INT0_vect
	rjmp PORT_INTR

.org TCE0_OVF_vect
	rjmp DEBOUNCE_ISR

.org 0x0000
	rjmp MAIN

.org 0x200
MAIN:
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

	ldi r17, 0b01110000
	sts PORTD_DIRSET, r17
	sts PORTD_OUTSET, r17
	rcall USART_INIT

END:
	rjmp END

USART_INIT:
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

	;set BSCALE and BSEL for 115,200 baud rate
	ldi r17, 11
	sts USARTD0_BAUDCTRLA, r17
	ldi r17, (0x09 << 4)|(11>>8)
	sts USARTD0_BAUDCTRLB, r17

	;enable interrupts
	ldi r17, 0b00010000
	sts USARTD0_CTRLA, r17
	
	;enable PMIC For low level interrupts
	ldi r17, 0x01
	sts PMIC_CTRL, r17

	;enable TX and RX
	ldi r17, 0b00011000
	sts USARTD0_CTRLB, r17

	;enable global interrupts
	sei

	;subroutine epilogue
	pop r17
	ret

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

RXC_ISR:
	push r16
	push r17
	lds r17, USARTD0_DATA
	
	cpi r17, 82
	breq ENABLE_RED

	cpi r17, 71
	breq ENABLE_GREEN

	cpi r17, 66
	breq ENABLE_BLUE

	rjmp END_RXC

ENABLE_BLUE:
	ldi r17, 0b01000000
	sts PORTD_OUTTGL, r17
	rjmp END_RXC

ENABLE_GREEN:
	ldi r17, 0b00100000
	sts PORTD_OUTTGL, r17
	rjmp END_RXC

ENABLE_RED:
	ldi r17, 0b00010000
	sts PORTD_OUTTGL, r17
	rjmp END_RXC

END_RXC:
	pop r17
	pop r16
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

PORT_INTR:
	;enable to timer to start debouncing
	ldi r17, 0x02
	sts TCE0_CTRLA, r17
	
	;disable external interrupt
	ldi r17, 0x00
	sts PORTF_INTCTRL, r17

	;return
	reti

DEBOUNCE_ISR:
	;turn off the timer and reset it back to 0
	push r17
	ldi r17, 0x00
	sts TCE0_CTRLA, r17
	sts TCE0_CNT, r17
	sts TCE0_CNT+1, r17

	;read in the portf values(s1 and s2)
	lds r17, PORTF_IN
	sbrc r17, 2
	;mov r19, r17
	;andi r19, BITMASK

	;compare values to the "pressed value"
	;cpi r19, 0x08
	;breq INCR_COUNT

	
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