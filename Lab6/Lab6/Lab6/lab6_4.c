/*;Lab:			Lab6 part 4
;Name:			Zachary Frederick
;Section #:		13067
;PI Name:		Wesley Piard & Chris Crary
;Description:	output the values from conversion to the data visualizer and make an oscilloscope
*/

//include files
#include <avr/io.h>
#include "ADC.h"
#include <avr/interrupt.h>

//global variables
//volatile int conversionComplete = 0;
//volatile int16_t result;

//int main(void)
//{
	////init timer counter and enable interrupts and pmic
	//tcc0_init2();
	//enable_sei();
	//enable_pmic();
	//enable_event_sys();
	//adc_init();
	//enable_red_pwm();
	//usartd0_init();
	//
	////start the timer
	//start_tcc02();
	//
	//while(1)
	//{
		//if (conversionComplete == 1) {
			//int lowByte = (result >> (8 * 0)) & 0xff;
			//int highByte = (result >> (8 * 1)) & 0xff;
			//
			//send_char_usart(0x03);
			//send_char_usart(lowByte);
			//send_char_usart(highByte);
			//send_char_usart(0xfc);
			//conversionComplete = 0;
		//}
	//}
	//
//}
//
//ISR(ADCA_CH0_vect)
//{
	//conversionComplete = 1;
	//result = ADCA_CH0_RES;
	//PORTD.OUTTGL = 0x10;
//}