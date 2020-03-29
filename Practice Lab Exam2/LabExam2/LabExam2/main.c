#include <avr/io.h>
#include <avr/interrupt.h>

volatile int conversionComplete = 0;
volatile int16_t result;
volatile int gain = 1;

int main(void)
{
	enable_32mhz_clock();
	init_ADC();
	init_DAC();
	enable_event_sys();
	tcc0_init();
	start_tcc0();
	usartd0_init();
	//toggle pin
	PORTC.DIRSET = 0xff;
	PMIC_CTRL = PMIC_LOLVLEN_bm;
	sei();
	
    /* Replace with your application code */
    while (1) 
    {
		if (conversionComplete == 1) {
			result = ADCA_CH0_RES;
			conversionComplete = 0;	
			while ((DACA.STATUS & 0x01) != 0x01) {}
			DACA.CH0DATA = (result * gain);	
		}
		
	}
}

ISR(ADCA_CH0_vect) {
	conversionComplete = 1;
	//result = ADCA_CH0_RES;
	//PORTD.OUTTGL = 0xff;
}

ISR(TCC0_OVF_vect) {
	PORTC.OUTTGL = 0xff;
}

ISR(USARTD0_RXC_vect) {
	uint8_t data = USARTD0.DATA;
	//USARTD0.DATA = data;
	switch (data) {
		case '0':
			gain = 0;
			break;
		case '1':
			gain = 1;
			break;
			
		case '2':
			gain = 2;
			break;
		default:
			break;
	}
}

