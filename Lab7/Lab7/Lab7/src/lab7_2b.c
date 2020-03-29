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
	
	start_tc();
	
	
	while(1) {
		while (DACA.STATUS != 0x03) {};
		DACA.CH0DATA = lookup[counter];
		counter++;
		
	}
}
