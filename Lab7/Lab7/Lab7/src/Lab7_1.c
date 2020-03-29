/*
 * Lab7.c
 *
 * Created: 11/24/2018 2:02:36 PM
 * Author : Zachary
 */ 

#include <avr/io.h>
#include "DAC.h"

int main(void)
{
	init_ADC();
	
    while (1) 
    {
		while ((DACA.STATUS & 0x01) != 0x01) {}
			
		DACA.CH0DATA = 1600;
    }
}

