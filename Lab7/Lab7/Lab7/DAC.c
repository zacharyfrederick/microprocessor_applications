/*
 * ADC.c
 *
 * Created: 11/24/2018 2:05:24 PM
 *  Author: Zachary
 */ 
#include "DAC.h"
#include <avr/io.h>
#include "LUT.h"

void init_ADC()
{
	//set porta pin2 as an output
	//PORTA.DIRSET = PIN3_bm; 
	
	//enable channel 0 on the DAC, pin b 2
	DACA.CTRLB = DAC_CHSEL_SINGLE_gc; //| DAC_CH0TRIG_bm;
	
	//select 2.5v reference from port b
	DACA.CTRLC = DAC_REFSEL_AREFB_gc;
	
	//enable event channel 0 as source 
	//DACA.EVCTRL = DAC_EVSEL_0_gc;
	
	//enable the dac
	DACA.CTRLA = DAC_CH0EN_bm | DAC_ENABLE_bm;
}

void init_ADC2()
{
	
	//enable channel 0 on the DAC, pin  2
	DACA.CTRLB = DAC_CHSEL_SINGLE1_gc; //| DAC_CH0TRIG_bm;
	
	//select 2.5v reference from port b
	DACA.CTRLC = DAC_REFSEL_AREFB_gc;
	
	
	//enable the dac
	DACA.CTRLA = DAC_CH1EN_bm | DAC_ENABLE_bm;
}

void init_tc()
{
	//500hz
	TCC0.CNT = 0x00;
	TCC0.PER = 71;
	//TCC0.INTCTRLA = TC_OVFINTLVL_LO_gc;
}

void start_tc()
{
	TCC0.CTRLA = TC_CLKSEL_DIV1_gc;
}

void enable_pmic()
{
	PMIC_CTRL = PMIC_LOLVLEN_bm;
}

void enable_32mhz_clock() {
	OSC.CTRL = OSC_RC32MEN_bm;
	while ((OSC.STATUS & OSC_RC32MRDY_bm) == 0x00) {}
		
	CCP = CCP_IOREG_gc;
	CLK.CTRL = CLK_SCLKSEL_RC32M_gc;
	CLK.PSCTRL = CLK_PSADIV_1_gc;
}

void enable_event_sys()
{
	//sets event channel 0 source as tcc0 overflow
	EVSYS_CH0MUX = 0b11000000;
}

void enable_DMA() 
{
	DMA.CH0.REPCNT = 0;
	DMA.CH0.ADDRCTRL = DMA_CH_SRCRELOAD_TRANSACTION_gc | DMA_CH_SRCDIR_INC_gc | DMA_CH_DESTRELOAD_BURST_gc | DMA_CH_DESTDIR_INC_gc;
	DMA.CH0.TRIGSRC = DMA_CH_TRIGSRC_EVSYS_CH0_gc;
	DMA.CH0.TRFCNT = 512;
	DMA.CH0.CTRLA = DMA_CH_ENABLE_bm | DMA_CH_REPEAT_bm | DMA_CH_SINGLE_bm | DMA_CH_BURSTLEN_2BYTE_gc;
	DMA.CTRL = DMA_CH_ENABLE_bm;
	
	DMA.CH0.DESTADDR0 = (((uint16_t) &DACA.CH0DATA) >> 0) & 0xFF;
	DMA.CH0.DESTADDR1 = (((uint16_t) &DACA.CH0DATA) >> 8) & 0xFF;
	DMA.CH0.DESTADDR2 = 0;

	DMA.CH0.SRCADDR0 = (((uint16_t) lookupSine) >> 0) & 0xFF;
	DMA.CH0.SRCADDR1 = (((uint16_t) lookupSine) >> 8) & 0xFF;
	DMA.CH0.SRCADDR2 = 0;
}

void enable_DMA2()
{
	DMA.CH0.REPCNT = 0;
	DMA.CH0.ADDRCTRL = DMA_CH_SRCRELOAD_BLOCK_gc | DMA_CH_SRCDIR_INC_gc | DMA_CH_DESTRELOAD_BURST_gc | DMA_CH_DESTDIR_INC_gc;
	DMA.CH0.TRIGSRC = DMA_CH_TRIGSRC_EVSYS_CH0_gc;
	DMA.CH0.TRFCNT = 512;
	DMA.CH0.CTRLA = DMA_CH_ENABLE_bm | DMA_CH_REPEAT_bm | DMA_CH_SINGLE_bm | DMA_CH_BURSTLEN_2BYTE_gc;
	DMA.CTRL = DMA_CH_ENABLE_bm;

	DMA.CH0.DESTADDR0 = (((uint16_t) &DACA.CH1DATA) >> 0) & 0xFF;
	DMA.CH0.DESTADDR1 = (((uint16_t) &DACA.CH1DATA) >> 8) & 0xFF;
	DMA.CH0.DESTADDR2 = 0;

	DMA.CH0.SRCADDR0 = (((uint16_t) lookupSine) >> 0) & 0xFF;
	DMA.CH0.SRCADDR1 = (((uint16_t) lookupSine) >> 8) & 0xFF;
	DMA.CH0.SRCADDR2 = 0;
}

void prevent_shutdown() 
{
	PORTC.OUTSET = PIN7_bm;
	PORTC.DIRSET = PIN7_bm;
}

void usartd0_init()
{
	PORTD.DIRSET = PIN3_bm;
	PORTD.DIRCLR = PIN2_bm;
	
	USARTD0.CTRLA = USART_RXCINTLVL_LO_gc;
	USARTD0.CTRLC = USART_CMODE_ASYNCHRONOUS_gc |
	USART_PMODE_DISABLED_gc |
	USART_CHSIZE_8BIT_gc;
	
	USARTD0.BAUDCTRLA = (uint8_t)3317;
	USARTD0.BAUDCTRLB = (uint8_t)
	( ((-4) << 4)|(3317>>8) );     
	USARTD0.CTRLB = USART_RXEN_bm | USART_TXEN_bm;
}

void disable_dma() 
{
	DMA.CTRL = 0x00;	
	DMA.CH0.CTRLA = DMA_CH_REPEAT_bm | DMA_CH_SINGLE_bm | DMA_CH_BURSTLEN_2BYTE_gc;
	
}

void reset_dma() {
	DMA.CH0.REPCNT = 0;
	DMA.CH0.ADDRCTRL = DMA_CH_SRCRELOAD_TRANSACTION_gc | DMA_CH_SRCDIR_INC_gc | DMA_CH_DESTRELOAD_BURST_gc | DMA_CH_DESTDIR_INC_gc;
	DMA.CH0.TRIGSRC = DMA_CH_TRIGSRC_EVSYS_CH0_gc;
	DMA.CH0.TRFCNT = 512;
	DMA.CH0.CTRLA = DMA_CH_ENABLE_bm | DMA_CH_REPEAT_bm | DMA_CH_SINGLE_bm | DMA_CH_BURSTLEN_2BYTE_gc;
	DMA.CTRL = DMA_CH_ENABLE_bm;
}

void switch_source(int source)
{
	TCC0.CTRLA = 0;
	disable_dma();
	switch (source) {
		case 0:
			enable_DMA_sine();
			break;
		case 1:
			enable_DMA_saw();
			break;
	}
	start_tc();
}

void enable_DMA_sine()
{
	DMA.CH0.REPCNT = 0;
	DMA.CH0.ADDRCTRL = DMA_CH_SRCRELOAD_TRANSACTION_gc | DMA_CH_SRCDIR_INC_gc | DMA_CH_DESTRELOAD_BURST_gc | DMA_CH_DESTDIR_INC_gc;
	DMA.CH0.TRIGSRC = DMA_CH_TRIGSRC_EVSYS_CH0_gc;
	DMA.CH0.TRFCNT = 512;
	DMA.CH0.CTRLA = DMA_CH_ENABLE_bm | DMA_CH_REPEAT_bm | DMA_CH_SINGLE_bm | DMA_CH_BURSTLEN_2BYTE_gc;
	DMA.CTRL = DMA_CH_ENABLE_bm;
	
	DMA.CH0.DESTADDR0 = (((uint16_t) &DACA.CH1DATA) >> 0) & 0xFF;
	DMA.CH0.DESTADDR1 = (((uint16_t) &DACA.CH1DATA) >> 8) & 0xFF;
	DMA.CH0.DESTADDR2 = 0;

	DMA.CH0.SRCADDR0 = (((uint16_t) lookupSine) >> 0) & 0xFF;
	DMA.CH0.SRCADDR1 = (((uint16_t) lookupSine) >> 8) & 0xFF;
	DMA.CH0.SRCADDR2 = 0;
}

void enable_DMA_saw()
{
	DMA.CH0.REPCNT = 0;
	DMA.CH0.ADDRCTRL = DMA_CH_SRCRELOAD_TRANSACTION_gc | DMA_CH_SRCDIR_INC_gc | DMA_CH_DESTRELOAD_BURST_gc | DMA_CH_DESTDIR_INC_gc;
	DMA.CH0.TRIGSRC = DMA_CH_TRIGSRC_EVSYS_CH0_gc;
	DMA.CH0.TRFCNT = 512;
	DMA.CH0.CTRLA = DMA_CH_ENABLE_bm | DMA_CH_REPEAT_bm | DMA_CH_SINGLE_bm | DMA_CH_BURSTLEN_2BYTE_gc;
	DMA.CTRL = DMA_CH_ENABLE_bm;
	
	DMA.CH0.DESTADDR0 = (((uint16_t) &DACA.CH1DATA) >> 0) & 0xFF;
	DMA.CH0.DESTADDR1 = (((uint16_t) &DACA.CH1DATA) >> 8) & 0xFF;
	DMA.CH0.DESTADDR2 = 0;

	DMA.CH0.SRCADDR0 = (((uint16_t) lookupSawtooth) >> 0) & 0xFF;
	DMA.CH0.SRCADDR1 = (((uint16_t) lookupSawtooth) >> 8) & 0xFF;
	DMA.CH0.SRCADDR2 = 0;
}

