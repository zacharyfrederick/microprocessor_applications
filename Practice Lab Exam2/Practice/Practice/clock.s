#include <avr/io.h>

.global clock_init
clock_init:
	
	;push any used registers
	push r16

	;write clock initialization code here
	ldi r16,  OSC_RC32MEN_bm
	sts OSC_CTRL, r16

check_status:
	lds r16, OSC_STATUS
	sbrs r16, 1
	rjmp check_status

	ldi r16, 0xd8
	STS CPU_CCP, r16
	
	ldi r16, 0x01
	sts CLK_CTRL, r16

	;pop any used registers
	pop r16

	ret