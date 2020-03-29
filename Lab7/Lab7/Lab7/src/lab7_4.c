#include <avr/io.h>
#include <avr/interrupt.h>
#include "DAC.h"
#include "LUT.h"

int main() {
	
	enable_32mhz_clock();
	enable_event_sys();
	init_tc();
	init_ADC2();
	enable_DMA2();
	prevent_shutdown();
	start_tc();
	
	while(1) {
		
	}
}
