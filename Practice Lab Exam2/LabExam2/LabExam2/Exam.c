/*
 * Exam.c
 *
 * Created: 12/3/2018 6:20:26 PM
 *  Author: Zachary
 */ 
#include "Exam.h"
#include <avr/io.h>

void init_ADC() {
	ADCA_CTRLB = ADC_CONMODE_bm | ADC_RESOLUTION_12BIT_gc;
	ADCA_REFCTRL = ADC_REFSEL_AREFB_gc;
	ADCA_CH0_CTRL = ADC_CH_INPUTMODE_DIFFWGAIN_gc;
	ADCA_CH0_MUXCTRL = ADC_CH_MUXPOS_PIN0_gc | ADC_CH_MUXNEG_PIN4_gc;
	ADCA.PRESCALER = ADC_PRESCALER_DIV512_gc;
	ADCA_CH0_INTCTRL = ADC_CH_INTMODE_COMPLETE_gc | ADC_CH_INTLVL_LO_gc;
	ADCA_EVCTRL = ADC_EVSEL_0123_gc | ADC_EVACT_CH01_gc;
	ADCA_CTRLA |= ADC_ENABLE_bm;
}

void enable_event_sys()
{
	//sets event channel 0 source as tcc0 overflow
	EVSYS_CH0MUX = 0b11000000;
}


void tcc0_init()
{
	//initialize count to zero
	TCC0_CNT = 0x00;
	//set period to 15625
	TCC0_PER = 4400;
	
	TCC0_INTCTRLA = TC_OVFINTLVL_LO_gc;
}

void start_tcc0() {
	TCC0_CTRLA = TC_CLKSEL_DIV1_gc;
}

void enable_32mhz_clock() {
	OSC.CTRL = OSC_RC32MEN_bm;
	while ((OSC.STATUS & OSC_RC32MRDY_bm) == 0x00) {}
	
	CCP = CCP_IOREG_gc;
	CLK.CTRL = CLK_SCLKSEL_RC32M_gc;
	CLK.PSCTRL = CLK_PSADIV_1_gc;
}

void init_DAC() {
	DACA.CTRLB = DAC_CHSEL_SINGLE_gc;
	DACA.CTRLC = DAC_REFSEL_AREFB_gc;
	DACA.CTRLA = DAC_ENABLE_bm | DAC_CH0EN_bm;
}

void usartd0_init()
{
	PORTD.DIRSET = PIN3_bm;
	PORTD.DIRCLR = PIN2_bm;
	
	USARTD0.CTRLA = USART_RXCINTLVL_LO_gc;
	USARTD0.CTRLC = USART_CMODE_ASYNCHRONOUS_gc |
	USART_PMODE_ODD_gc |
	USART_CHSIZE_8BIT_gc;
	
	USARTD0.BAUDCTRLA = (uint8_t)3355;
	USARTD0.BAUDCTRLB = (uint8_t)
	( ((-6) << 4)|(3355>>8) );
	USARTD0.CTRLB = USART_RXEN_bm | USART_TXEN_bm;
}