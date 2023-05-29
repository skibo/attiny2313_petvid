/*-
 * Copyright (c) 2017 Thomas Skibo.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 * petvid.c
 *
 *	Atmel ATtiny2313 generates video test pattern for Commodore PET.
 *
 *	PB2 =	Video data
 *	PB3 =	VERT
 *	PB4 =	HORZ
 *
 *	Expects 20 Mhz crystal.  Program lfuse to 0xEF:
 *		avrdude -p t2313 -U lfuse:w:0xEF:m
 */

#include <avr/interrupt.h>
#include <avr/io.h>
#define F_CPU 20000000UL
#include <util/delay.h>

#include "petvid.h"

extern void video_loop(void);

void
PORT_Init()
{
	PORTB = (1 << V_VERT) | (1 << V_DAT);
	DDRB = ((1 << V_DAT) | (1 << V_VERT) | (1 << V_HORZ));

	PORTD = 0;
	DDRD = 0;
}

void
Timer_Init()
{
	TCCR1A = (1 << COM1B0) | (1 << COM1B1) | (1 << WGM11) | (1 << WGM10);
	TCCR1B = (1 << WGM13) | (1 << WGM12) | (1 << CS10);

	/* HORZ signal period = 1280 50ns clocks for 64us. */
	OCR1AH = 0x05;
	OCR1AL = 0x00;

	/* HORZ signal set for 480, clear for 800 clocks. */
	OCR1BH = 0x03;
	OCR1BL = 0x20;

	/* Enable interrupt. */
	TIMSK = (1 << OCIE1B);
}

int
main(void)
{
	PORT_Init();
	Timer_Init();
	sei();

	video_loop();

	return 0;
}
