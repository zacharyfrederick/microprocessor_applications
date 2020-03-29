#include <avr/io.h>
#include <avr/interrupt.h>

#include "spi.h"
#include "LSM330.h"

uint8_t volatile xL, xH;
uint8_t volatile yL, yH;
uint8_t volatile zL, zH;
uint8_t volatile accel_flag = 0;

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
	
	//accel_init();
	accel_init();
	init_usart();
	
	while (1) {
		if (accel_flag == 1) {
			send_char_usart(0x03);
			send_char_usart(xL);
			send_char_usart(xH);
			send_char_usart(yL);
			send_char_usart(yH);
			send_char_usart(zL);
			send_char_usart(zH);
			send_char_usart(0xFC);
			accel_flag = 0;
		}
	}
}

ISR(PORTC_INT0_vect) {
	
	PORTD.OUTTGL = 0xff;
	xL = accel_read(0x28);
	xH = accel_read(0x29);
	
	yL = accel_read(0x2a);
	yH = accel_read(0x2b);
	
	zL = accel_read(0x2c);
	zH = accel_read(0x2d);
	
	accel_flag = 1;
	
}


ISR(USARTD0_RXC_vect) {
	USARTD0.DATA = USARTD0.DATA;
}