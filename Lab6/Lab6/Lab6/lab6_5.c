///*;Lab:			Lab6 part 5
//;Name:			Zachary Frederick
//;Section #:		13067
//;PI Name:		Wesley Piard & Chris Crary
//;Description:	changing inputs over USART and outputing results to terminal
//*/
//
////include files
//#include <avr/io.h>
//#include "ADC.h"
//#include <avr/interrupt.h>
//
////global variables
//volatile int conversionComplete = 0;
//volatile uint16_t result;
//volatile int inputSource = 0; //0=CDS cell, 1=J3 jumper
//volatile int inputChanged = 1; //indicates whether the input has been updated. Done to avoid using a subroutine call in an ISR
//
//int main(void)
//{
	////initialize everything
	//tcc0_init2();
	//enable_sei();
	//enable_pmic();
	//enable_event_sys();
	//adc_init();
	//enable_red_pwm();
	//usartd0_init();
	//start_tcc02();
	//
	//while(1)
	//{
	//
		//if (inputChanged == 0) {
			//change_inputs(inputSource);
			//inputChanged = 1;
		//}	
		//
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
//
//ISR(USARTD0_RXC_vect) 
//{
	////collect the data
	//char data = USARTD0.DATA;
	//
	////change input only if incoming transmission is 1 or 2 and ignore all other inputs
	//if (data == '1') {
		//inputSource = 0;
		//inputChanged = 0;
	//} else if (data == '2') {
		//inputSource = 1;
		//inputChanged = 0;
	//}
//}