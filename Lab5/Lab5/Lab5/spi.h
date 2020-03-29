/*
 * spi.h
 *
 * Created: 11/1/2018 8:08:21 PM
 *  Author: Zachary
 */ 
#ifndef SPI_H
#define SPI_H

#include <avr/io.h>

void spi_init(void);
uint8_t spi_write(uint8_t data);
uint8_t spi_read(void);
void accel_write(uint8_t reg_addr, uint8_t data);
uint8_t accel_read(uint8_t reg_addr);
void accel_init(void);
void enable_external_interrupt(void);
void init_usart(void);
void send_char_usart(uint8_t data);

#endif
