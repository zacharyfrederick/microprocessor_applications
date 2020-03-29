#include "spi.h"
#include <avr/io.h>
#define BSCALE9600	0x9	 // -7
#define BSEL9600	1539

void spi_init() {
	
	//configure mosi and sck and /ss as output
	PORTF.DIRSET = 0b10111000;
	
	//enable sp
	SPIF.CTRL = 0b01011100;
}

uint8_t spi_write(uint8_t data) {
	SPIF.DATA = data;
	
	while ((SPIF.STATUS & 0x80) == 0) {}
	
	uint8_t inData = SPIF.DATA;
	return inData;
}

uint8_t spi_read() {
	return spi_write(0xff);
}

void accel_write(uint8_t reg_addr, uint8_t data) 
{
	uint8_t writePrefix = 0b00000000;
	reg_addr |= writePrefix;	
	
	//set /SS low 
	PORTF.OUTCLR = 0b00001000;
	
	//write the mode and data
	spi_write(reg_addr);
	spi_write(data);
	
	//set /SS high
	PORTF.OUTSET = 0b00001000;
}

uint8_t accel_read(uint8_t reg_addr)
{
	uint8_t readPrefix = 0b10000000;
	reg_addr |= readPrefix;
	
	//set /SS low
	PORTF.OUTCLR = 0b00001000;
	
	//write the mode and random data
	 
	 spi_write(reg_addr);
	 uint8_t readData = spi_write(0xff);
	
	//set /SS high
	PORTF.OUTSET = 0b00001000;
	
	return readData;
}

void accel_init(void) 
{
	uint8_t reg4_a = 0x23;
	uint8_t data = 0b10011000;
	accel_write(reg4_a, data);
	
	uint8_t reg5_a = 0x20;
	data = 0b10010111;
	accel_write(reg5_a, data);
}

void init_usart(void) 
{
	PORTD.DIRSET = PIN3_bm;
	PORTD.DIRCLR = PIN2_bm;
	
	PMIC.CTRL |= PMIC_MEDLVLEN_bm;

	USARTD0.CTRLA = USART_RXCINTLVL_MED_gc;
	USARTD0.CTRLC = USART_CMODE_ASYNCHRONOUS_gc | USART_PMODE_ODD_gc| USART_CHSIZE_8BIT_gc;
	
	USARTD0.BAUDCTRLA = 11;
	USARTD0.BAUDCTRLB = (0x09 << 4)|(11>>8);
	USARTD0.CTRLB = USART_RXEN_bm | USART_TXEN_bm;
}

void send_char_usart(uint8_t data) 
{
 	
}