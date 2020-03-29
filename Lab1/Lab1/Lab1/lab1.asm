;Lab 1
;Name:			Zachary Frederick
;Section #:		13067
;PI Name:		Wesley Piard & Chris Crary
;Description:	Loading data from a table and performing operations on it to reveal a message

.include "ATxmega128A1Udef.inc"	

;equates
.equ table_size			=	16				;holds the table size
.equ bit_test			=	0b11000000		;bit mask to test whether bits 7 and 6 are active
.equ condition1_filter	=	0x60			;condition one checks whether value is greater than > 0x60
.equ condition2_filter	=	84				;condition two checks whether value is less than or equal to 84 (0x54)
.equ EOT				=	0X00			;used to see when counter is zero

;redefining register names
.def table_value_r16	=	r16				;holds the current value for the table
.def bit_test_r17		=	r17				;register to hold the bit mask to test bits 6 and 7
.def temp_r18			=	r18				;register to hold temporary calculations and values
.def cnt_r19			=	r19				;holds the counter value 

;PROGRAM START
.org 0x0000
	rjmp MAIN								;jump to main to avoid interuppt space in memory

;DEFINE INPUT TABLE
.org 0xF0D0									;Program memory address 0x01E1A0
Table: .db 0b11101010, 0x5E, 0124, 0x24, 0b01011111, \
'B',044, 0x5D, 0xC8, 'P', 0b01100000, 0134, 0x24, 37, 'W', 0x00		;Continued from above

;DEFINE OUTPUT TABLE
.dseg 
.org 0x3000
Outs:	.byte 1 ;Unknown final table size. Define first byte to hold first value

.cseg
.org 0x200									;location of main program
MAIN:	
		ldi YL, byte1(Outs)					;load low byte of output table address to YL
		ldi YH, byte2(Outs)					;load high byte of output table address to YH

		ldi ZL, byte3(Table << 1)			;load third byte of Input table left shifted into ZL
		out cpu_rampz, ZL					;load ZL into the cpu_rampz register for extended memory addressing
		ldi ZH, byte2(Table << 1)			;load ZH with byte2 of the input table address shifted left 
		ldi ZL, byte1(Table << 1)			;load ZL with byte1 of the input table address shifted left


LOOP:
		elpm table_value_r16, Z+			;load from program memory into r16  and increment z
		cpi table_value_r16, EOT			;check for end of table value
		breq END

CONDITION_1:
		ldi bit_test_r17, bit_test			;load r17 with the bit test mask
		mov temp_r18, table_value_r16		;move r16 into temp register to preserve value 
		and temp_r18, bit_test_r17			;and table_value with bit mask to test for individual bits
		cpi temp_r18, bit_test				;compare to see if they are equal 
		brne CONDITION_2					;branches to check the second condition if they arent equal
		lsr table_value_r16					;right shift table_value_r16 (divide by 2)
		ldi temp_r18, condition1_filter		;load temp register with value to check against
		neg temp_r18						;2s complement value
		add temp_r18, table_value_r16		;add them together
		brmi LOOP							;return to loop value less than 0x60
		breq LOOP							;return to loop	value equal to 0x60
		rjmp STORE_VALUE					;if not negative and not equal store the value in the table

CONDITION_2:
		ldi temp_r18, condition2_filter		;load temp_register with value to check against (84)
		cp temp_r18, table_value_r16		;compare register and test value
		brlt LOOP							;branch if 84 is less than test value
		ldi temp_r18, 4						;load temp register with 4
		sub table_value_r16, temp_r18		;subtract 4 from table value	
		rjmp STORE_VALUE;					;jmp to store value

STORE_VALUE:
		st Y+, table_value_r16				;store value in data memory pointed to by Y and increment 
		rjmp LOOP							;jump back to loop

END:
		rjmp END							;end loop
