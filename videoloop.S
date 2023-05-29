/*-
 * Copyright (c) 2017 Thomas Skibo. <thomas@skibo.net>
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
 */


#include <avr/io.h>
#define F_CPU 20000000UL

#include "petvid.h"

#define y_ctr		r20
#define x_ctr		r21
#define y2_ctr		r22

; void video_loop(void);
;
.global video_loop
video_loop:
	ldi     y_ctr, 0	; counts 0..199 in active lines
	ldi     y2_ctr, 0	; counts 0..59, only in inactive lines

1:      rjmp    1b              ; let interrupt handle everything.


	/* TIMER1 COMPB interrupt occurs at rising edge of V_HORZ signal. */
.global TIMER1_COMPB_vect
TIMER1_COMPB_vect:
	cpi     y2_ctr, 20
	brsh    1f

	;; first 20 lines are blank.  Do nothing.
	;;
	inc     y2_ctr
	reti

1:
	cpi	y2_ctr, 20
	brne    1f

	;; lines 20-219 are visible.
	;;
	ldi     r16, 114	; ~360 clocks
2:
	dec     r16
	brne    2b

	sbrs    y_ctr, 3
	rjmp    patt2

	;; Pattern 1
	ldi     x_ctr, 8
3:
	cbi     _SFR_IO_ADDR(PORTB), V_DAT ; set pixel

	ldi     r16, 16        ; ~50 clocks
2:
	dec     r16
	brne    2b

	sbi     _SFR_IO_ADDR(PORTB), V_DAT ; clr pixel

	ldi     r16, 15         ; ~50 clocks
2:
	dec     r16
	brne    2b
	dec     x_ctr
	brne    3b
	rjmp    doneln

patt2:
	;; Pattern 2
	ldi     x_ctr, 8
3:
	sbi     _SFR_IO_ADDR(PORTB), V_DAT ; clr pixel

	ldi     r16, 16        ; ~50 clocks
2:
	dec     r16
	brne    2b

	cbi     _SFR_IO_ADDR(PORTB), V_DAT ; set pixel

	ldi     r16, 15         ; ~50 clocks
2:
	dec     r16
	brne    2b
	dec     x_ctr
	brne    3b

	sbi     _SFR_IO_ADDR(PORTB), V_DAT ; clr pixel
doneln:
	inc     y_ctr
	cpi     y_ctr, 200
	brlo    2f
	inc     y2_ctr
	ldi     y_ctr, 0
2:
	reti

1:
	cpi     y2_ctr, 40
	brne    1f

	ldi     r16, 231        ; delay ~1180 clocks
2:
	nop
	nop
	dec     r16
	brne    2b

	;; start vert
	cbi     _SFR_IO_ADDR(PORTB), V_VERT ; clear VERT signal
	inc     y2_ctr
	reti

1:
	cpi     y2_ctr, 60
	brne    1f

	ldi     r16, 230        ; delay ~1180 clocks
2:
	nop
	nop
	dec     r16
	brne    2b

	;; stop vert
	sbi     _SFR_IO_ADDR(PORTB), V_VERT ; set VERT signal
	ldi     y2_ctr, 0
	reti
1:
	inc     y2_ctr
	reti
