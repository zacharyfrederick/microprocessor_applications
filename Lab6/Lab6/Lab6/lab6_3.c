/*;Lab:			Lab6 part 3
;Name:			Zachary Frederick
;Section #:		13067
;PI Name:		Wesley Piard & Chris Crary
;Description:	Output ADC results to the terminal over USART
*/

//include files
#include <avr/io.h>
#include "ADC.h"
#include <avr/interrupt.h>

//global variables
volatile int conversionComplete = 0;
volatile int16_t result;

int main(void)
{
	//init timer counter and enable interrupts and pmic
	tcc0_init();
	enable_sei();
	enable_pmic();
	enable_event_sys();
	adc_init();
	enable_red_pwm();
	usartd0_init();
	
	//start the timer 
	start_tcc0();
	
	while(1)
	{
		if (conversionComplete == 1) {
			output_voltage(calculate_voltage(result), result);
			conversionComplete = 0;
		}
	}
	
}

ISR(ADCA_CH0_vect) 
{
	conversionComplete = 1;
	result = ADCA_CH0_RES;
	PORTD.OUTTGL = 0x10;	
}