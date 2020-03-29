#include <avr/io.h>
#include <avr/interrupt.h>
#include "DAC.h"
#include "LUT.h"

volatile uint8_t counter = 0;

int main() {
	
	enable_32mhz_clock();
	enable_event_sys();
	init_tc();
	init_ADC();
	enable_DMA();
	start_tc();
	
	while(1) {
		
	}
}
