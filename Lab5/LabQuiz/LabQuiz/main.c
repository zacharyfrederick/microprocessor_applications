/*
 * lab5_3.c
 *
 * Created: 11/4/2018 2:23:43 PM
 *  Author: Zachary
 */ 
#include <avr/io.h>
#include <avr/interrupt.h>

#include "spi.h"

signed int volatile xL, xH, zL, zH, yL, yH;
signed int volatile x, y, z;
int volatile accel_flag = 0;
int volatile out_char;

int main() 
{
	
	spi_init();
	PORTF.DIRSET = 0b00000100;
	PORTF.OUTSET = 0b00000100;
	
	PORTA.DIRCLR = 0b00010000;
	PORTA.OUTCLR = 0b00010000;
	
	PORTD.DIRSET = 0xff;
	PORTD.OUTSET = 0xff;

	//set pin 7 as input
	PORTC.DIRCLR= 0b11000000;
	//enable low level interrupts
	PORTC.INTCTRL = 0x01;
	//enable external interrupts on pin 7
	PORTC.INT0MASK = 0b11000000;
	
	PMIC.CTRL = 0x01;
	sei();
		
	uint8_t volatile data;
	
	accel_init();
	accel_init();
	init_usart();
	
	while (1) {;
		
	
		
		if (accel_flag == 1) {
			if (zH >= 60 && zH <= 70) {
				out_char = 0x54;
				accel_flag = 0;
			}
			
			if (zH >= 180 && zH <= 199) {
				out_char = 0x42;
				accel_flag = 0;
			}
			
			if ((zH >= 245 && zH <= 255) || (zH >=0 && zH <= 20)) {
				if (xH >= 180 && xH <= 220) {
					out_char = 0x4c;
					accel_flag = 0;
				}
				
				if (xH >= 45 && xH <= 70) {
					out_char = 0x52;
					accel_flag = 0;
				}
				
				if (yH >= 55 && yH <= 75) {
					out_char = 0x46;
					accel_flag = 0;
				}
				
				if (yH >= 190 && yH <= 210) {
					out_char = 0x7a;
					accel_flag = 0;
				}
			}
			send_char_usart(out_char);
			accel_flag = 0;
		}
	}
}

ISR(PORTC_INT0_vect) {
	xL = accel_read(0x28);
	xH = accel_read(0x29);
	
	yL = accel_read(0x2a);
	yH = accel_read(0x2b);
	
	zL = accel_read(0x2c);
	zH = accel_read(0x2d);
	
	x = xL+xH;
	y = yL + yH;
	z = zL + zH;
	accel_flag = 1;
	PORTD.OUTTGL = 0xff;
}