#include <avr/io.h>
#include <avr/interrupt.h>
#include "DAC.h"
#include "LUT.h"

volatile uint8_t counter = 0;

int main() {
	
	enable_32mhz_clock();
	init_tc();
	init_ADC();
	//enable_pmic();
	//sei();
	PORTD.DIRSET = 0xff;
	start_tc();	
	while(1) {
		if (TCC0.INTFLAGS & TC_OVFINTLVL_LO_gc == 0x01)  {
			TCC0.INTFLAGS |= TC_OVFINTLVL_LO_gc;
			while(DACA.STATUS != 0x03) {}
			
			DACA.CH0DATA = lookup[counter];
			
			counter++;
		}
	}
}

ISR(TCC0_OVF_vect) {
	PORTD.OUTTGL = 0xff;
	while(DACA.STATUS != 0x03) {}
		
	DACA.CH0DATA = lookup[counter];
	
	counter++;
}