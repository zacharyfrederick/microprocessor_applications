#include <avr/io.h>
#include <avr/interrupt.h>
#include "DAC.h"
#include "LUT.h"

volatile int switchSource = 0;
volatile int source = 0;
volatile int turnOff = 0;
volatile int turnOn = 0;
volatile int keyPressed = 0;
volatile int keyReleased = 0;
volatile char oldKey;
volatile int dataRecieved = 0;
volatile waveStarted = 0;

int main() {
	enable_32mhz_clock();
	enable_event_sys();
	enable_pmic();
	usartd0_init();
	//enable_DMA2();
	sei();
	init_tc();
	init_ADC2();
	//start_tc();
	
	TCC1.CNT = 0x0;
	TCC1.PER = 40000;
	TCC1.INTCTRLA = TC_OVFINTLVL_LO_gc;
	
	enable_DMA2();
	start_tc();
	while(1) {
		
	}
}

ISR(USARTD0_RXC_vect)
{
	char data = USARTD0.DATA;

	if (data == 's') {
		switchSource = 1;
		source = !source;
		} else {
		TCC1.CTRLA = TC_CLKSEL_DIV1024_gc;
		
		if (waveStarted == 0) {
			switch(source) {
				case 0:
				enable_DMA_sine();
				break;
				case 1:
				enable_DMA_saw();
				break;
			}
			start_tc();
			waveStarted = 1;
		}
	}
}

ISR(TCC1_OVF_vect) {
	TCC0.CTRLA = 0;
	disable_dma();
	waveStarted = 0;
}