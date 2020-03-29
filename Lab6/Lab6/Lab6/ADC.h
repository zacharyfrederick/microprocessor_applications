/*
 * ADC.h
 *
 * Created: 11/16/2018 3:15:46 PM
 *  Author: Zachary
 */ 
#ifndef ADC_H
#define ADC_H

#include <avr/io.h>

void adc_init(void);
void tcc0_init(void);
void tcc0_init2(void); //used for part 4 of the lab
void start_tcc0(void);
void start_tcc02(void); //used for part 4 of the lab
void enable_sei(void);
void enable_pmic(void);
void enable_event_sys(void);
void enable_red_pwm(void);
void usartd0_init(void);
void output_voltage(float voltage, int result);
void send_char_usart(char data);
float calculate_voltage(int16_t result);
int8_t convert_int_ascii(int num);
char convert_int_hex(int num);
void change_inputs(int mode);

#endif