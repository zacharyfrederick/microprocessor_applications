/*
 * ADC.h
 *
 * Created: 11/24/2018 2:05:05 PM
 *  Author: Zachary
 */ 


#ifndef DAC_H_
#define DAC_H_

void init_ADC(void);
void init_ADC2(void);
void init_tc(void);
void start_tc(void);
void enable_pmic(void);
void enable_32mhz_clock(void);
void enable_event_sys(void);
void enable_DMA(void);
void enable_DMA2(void);
void prevent_shutdown(void);
void usartd0_init(void);
void disable_dma(void);
void reset_dma(void);
void switch_source(int source);
void enable_DMA_sine(void);
void enable_DMA_saw(void);

#endif /* ADC_H_ */