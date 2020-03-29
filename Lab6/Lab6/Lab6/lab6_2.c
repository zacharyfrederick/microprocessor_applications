/*;Lab:			Lab6 part 2
;Name:			Zachary Frederick
;Section #:		13067
;PI Name:		Wesley Piard & Chris Crary
;Description:	use the event system to read from the photocell every 100hz
*/

#include <avr/io.h>
#include "ADC.h"
#include <avr/interrupt.h>

//int main(void)
//{
	////init timer counter and enable interrupts and pmic
	//tcc0_init();
	//enable_sei();
	//enable_pmic();
	//enable_event_sys();
	//adc_init();
	//enable_red_pwm();
	//
	////start the timer 
	//start_tcc0();
	//
	//
	//while(1)
	//{
		//
	//}
	//
//}

//ISR(ADCA_CH0_vect) 
//{
	//int16_t volatile result = ADCA_CH0_RES;
	//PORTD.OUTTGL = 0x10;	
//}