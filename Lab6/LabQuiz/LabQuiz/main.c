/*
 * LabQuiz.c
 *
 * Created: 11/19/2018 8:33:58 PM
 * Author : Zachary
 */ 

#include <avr/io.h>
#include <avr/interrupt.h>
#include "ADC.h"

volatile int conversionComplete = 0;
volatile uint16_t result;

int main(void)
{
    tcc0_init2();
    enable_sei();
    enable_pmic();
    enable_event_sys();
    adc_init();
    enable_red_pwm();
    usartd0_init();
    start_tcc02();
	
    while (1) 
    {
		if (conversionComplete == 1) {
			int lowByte = (result >> (8 * 0)) & 0xff;
			int highByte = (result >> (8 * 1)) & 0xff;
			
			send_char_usart(0x03);
			send_char_usart(lowByte);
			send_char_usart(highByte);
			send_char_usart(0xfc);
			conversionComplete = 0;
		}
		
		if (result < 980) {
			PORTD.OUTSET = 0x40;	
		} 
		
		if (result > 1100) {
			PORTD.OUTCLR = 0x40;
		}
    }
}

ISR(ADCA_CH0_vect)
{
	conversionComplete = 1;
	result = ADCA_CH0_RES;
	//PORTD.OUTTGL = 0x40;
}