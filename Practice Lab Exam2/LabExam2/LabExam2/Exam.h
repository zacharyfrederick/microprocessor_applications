/*
 * Exam.h
 *
 * Created: 12/3/2018 6:20:13 PM
 *  Author: Zachary
 */ 



#ifndef EXAM_H_
#define EXAM_H_

void init_ADC(void);
void enable_event_sys();
void tcc0_init();
void start_tcc0();
void enable_32mhz_clock();
void init_DAC(void);
void usartd0_init();


#endif /* EXAM_H_ */