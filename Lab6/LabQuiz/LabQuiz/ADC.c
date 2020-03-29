/*
 * ADC.c
 *
 * Created: 11/16/2018 3:16:31 PM
 *  Author: Zachary
 */ 
#include "ADC.h"
#include <avr/io.h>
#include <avr/interrupt.h>

void adc_init() 
{
	ADCA_CTRLB = ADC_CONMODE_bm | ADC_RESOLUTION_12BIT_gc;
	ADCA_REFCTRL = ADC_REFSEL_AREFB_gc;
	ADCA_CH0_CTRL = ADC_CH_INPUTMODE_DIFFWGAIN_gc;
	ADCA_CH0_MUXCTRL = ADC_CH_MUXPOS_PIN1_gc | ADC_CH_MUXNEG_PIN6_gc;
	
	// delete:
	ADCA.PRESCALER = ADC_PRESCALER_DIV512_gc;
	
	//enable interrupt when conversion is complete
	ADCA_CH0_INTCTRL = ADC_CH_INTMODE_COMPLETE_gc | ADC_CH_INTLVL_LO_gc;
	
	//start a conversion when event channel 0 is triggered 
	ADCA_EVCTRL = ADC_EVSEL_0123_gc | ADC_EVACT_CH01_gc; 
	
	//enable the ADC
	ADCA_CTRLA |= ADC_ENABLE_bm;
}

void tcc0_init()
{
	//initialize count to zero
	TCC0_CNT = 0x00;
	//set period to 15625
	TCC0_PER = 15625;
}

void tcc0_init2()
{
	//initialize count to zero
	TCC0_CNT = 0x00;
	//set period to 15625
	TCC0_PER = 10000;
}

void start_tcc0()
{
	//start the timer with the 1024 prescaler
	TCC0_CTRLA = TC_CLKSEL_DIV64_gc;
}

void start_tcc02()
{
	//start the timer with the 1024 prescaler
	TCC0_CTRLA = TC_CLKSEL_DIV1_gc;
}

void enable_sei()
{
	sei();
}

void enable_pmic()
{
	PMIC_CTRL = PMIC_LOLVLEN_bm;
}

void enable_event_sys()
{
	//sets event channel 0 source as tcc0 overflow
	EVSYS_CH0MUX = 0b11000000;
}

void enable_red_pwm()
{
	//enables the red pwm led on PD4 and turns it off
	PORTD.DIRSET = 0x40;
	PORTD.OUTSET = 0x40;
}

void usartd0_init()
{
	PORTD.DIRSET = PIN3_bm;
	PORTD.DIRCLR = PIN2_bm;
	USARTD0.CTRLA = USART_RXCINTLVL_LO_gc; //set the recieve complete interrupt to be low level
	USARTD0.CTRLB = USART_RXEN_bm | USART_TXEN_bm;
	USARTD0.CTRLC = USART_CMODE_ASYNCHRONOUS_gc | USART_PMODE_DISABLED_gc | USART_CHSIZE_8BIT_gc;
	USARTD0.BAUDCTRLA = (uint8_t) 11;
	USARTD0.BAUDCTRLB = (uint8_t)((-7 << 4)|(11>>8));
}

void send_char_usart(char data)
{
		while ((USARTD0.STATUS & 0x20) == 0x00) {}
			
		USARTD0.DATA = data;
}

void output_voltage(float voltage, int result)
{
	//send_char_usart(12);
	//send the sign indicator
	if (voltage > 0) {
		send_char_usart(43);
		} else {
		send_char_usart(45);
	}
	
	int firstNumProcessed = 0;
	for(int i=0; i <3; i++) {
		
		int temp;
		int prevNum;
		float prevVoltage;
		
		//send the number in volts
		if (firstNumProcessed == 0) {
			temp = (int) voltage;
			prevNum = temp;
			prevVoltage = voltage;
			if (temp < 0) {
				temp *= -1;
			}
			send_char_usart(temp + 48);
			send_char_usart(46);
			firstNumProcessed = 1;
		} else {
			temp = (int) ((prevVoltage - prevNum) * 10);
			prevVoltage = (prevVoltage - prevNum) * 10; 
			prevNum = temp;
			if (temp < 0) {
				temp *= -1;
			}
			send_char_usart(temp + 48);
		}
	}
	
	//send space and unit indicator
	send_char_usart(' ');
	send_char_usart('V');
	
	send_char_usart(' ');
	send_char_usart('(');
	send_char_usart('0');
	send_char_usart('x');
	
	if (result < 0) {
		result *= -1;
	}
	
	float step1 = result / 16;
	int firstHex = (int) result % 16;
	float step2 = step1 / 16;
	int secondHex = (int) step1 % 16;
	float step3 = step2 / 16;
	int thirdHex = (int) step2 % 16;
	
	send_char_usart(convert_int_hex(thirdHex));
	send_char_usart(convert_int_hex(secondHex));
	send_char_usart(convert_int_hex(firstHex));
	
	
	send_char_usart(')');
	
	//new line and carriage return
	send_char_usart(10);
	send_char_usart(13);
}

char convert_int_hex(int num)
{
	if (num < 10) {
		return num + 48;
	} else {
		switch (num){
			case 10:
				return 'A';
				break;
			case 11:
				return 'B';
				break;
			case 12:
				return 'C';
				break;
			case 13:
				return 'D';
				break;
			case 14:
				return 'E';
				break;
			case 15:
				return 'F';
				break;
			default:
				return 'X';
				break;
		}
	}
}
float calculate_voltage(uint16_t result)
{
	volatile float val = (result / 4096.0) * 5.0 * 2.48;
	return val;
}

void change_inputs(int mode)
{
	//disable interrupts and ADCA 
	cli();
	ADCA.CTRLA = (0 << ADC_ENABLE_bp);
	
	switch (mode) {
		case 0:
			//sets the input as the CDS+ and CDS- pins
			ADCA_CH0_MUXCTRL = ADC_CH_MUXPOS_PIN1_gc | ADC_CH_MUXNEG_PIN6_gc;
			break;
		
		case 1:
			//sets the input as the INO+ and INO- pins
			ADCA_CH0_MUXCTRL = ADC_CH_MUXPOS_PIN4_gc | ADC_CH_MUXNEG_PIN5_gc;
			break;
		
		default:
			break;	
	}
		
	//re-enable ADCA and interrupts
	ADCA.CTRLA = ADC_ENABLE_bm;
	sei();
}

