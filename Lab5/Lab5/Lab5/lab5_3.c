///*
 //* lab5_3.c
 //*
 //* Created: 11/4/2018 2:23:43 PM
 //*  Author: Zachary
 //*/ 
//#include <avr/io.h>
//#include <avr/interrupt.h>
//
//#include "spi.h"
//#include "LSM330.h"
//
//int main() 
//{
	//
	//spi_init();
	//PORTF.DIRSET = 0b00000100;
	//PORTF.OUTSET = 0b00000100;
	//
	//PORTA.DIRCLR = 0b00010000;
	//PORTA.OUTCLR = 0b00010000;
	//
	//PORTD.DIRSET = 0xff;
	//PORTD.OUTSET = 0xff;
//
	////set pin 7 as input
	//PORTC.DIRCLR= 0b11000000;
	////enable low level interrupts
	//PORTC.INTCTRL = 0x01;
	////enable external interrupts on pin 7
	//PORTC.INT0MASK = 0b11000000;
	//
	//PMIC.CTRL = 0x01;
	//sei();
		//
	//uint8_t volatile data;
	//
	//accel_init();
	//accel_init();
	//
	//while (1) {
		//data = accel_read(0x0f);
	//}
//}
//
//ISR(PORTC_INT0_vect) {
	//PORTD.OUTTGL = 0xff;
//}