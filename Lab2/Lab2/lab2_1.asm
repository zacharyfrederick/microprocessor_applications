	;Lab:			Lab2 part 1
	;Name:			Zachary Frederick
	;Section #:		13067
	;PI Name:		Wesley Piard & Chris Crary
	;Description:	Continuously loads the value from the dip switches and displays the values on the LEDS of the switch and led backpack

	;include file
	.include "ATxmega128A1Udef.inc"

	;equates
	.equ LED_PORTS = 0xFF				;DIRSET value for the leds (outputs)
	.equ DIP_PORTS = 0x00				;DIRSET value for the dip switch (inputs)

	;Start
	.org 0x0000
		rjmp MAIN						;jump to main at 0x200

	;Main
	.org 0x200
	MAIN:
		ldi r16, LED_PORTS				;load r16 with led DIRSET direction
		sts PORTC_DIRSET, r16			;store the value into the PORTC_DIRSET register, (port c corresponds to LEDS according to schematic)
		ldi r16, DIP_PORTS				;load the direction of the dip switches into r16
		sts PORTA_DIRSET, r16			;store r16 into PORTA_DIRSET. PORTA corresponds to DIP switches on schematic
	
	LOOP:
		lds r17, PORTA_IN				;load the values of the dip switch into the register 
		sts PORTC_OUT, r17				;store the value of the dip switches into the LED out register
		rjmp LOOP						;jump back to the beginning of the loop