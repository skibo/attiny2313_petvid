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
 */


#include <avr/io.h>
#define F_CPU 20000000UL

#define y_ctr		r20
#define x_ctr		r21
#define y2_ctr		r22
#define line_ptr_h	r25
#define line_ptr_l	r24

/* XXX: These must match defines in petvid.c. */
#define V_DAT		PB2
#define V_VERT		PB3
#define V_HORZ		PB4
	
.global video_loop
video_loop:
	ldi	r16, (1 << OCF1B) 	; clear counter bit
	out	_SFR_IO_ADDR(TIFR), r16

top:
	;; 20 blank lines
	ldi	y_ctr, 20
1:
        rcall	blank_line
	dec	y_ctr
	brne	1b
        
        ;; 200 lines of active video, alternating patt1 and patt2...
        ldi     y2_ctr, 5
2:
        ldi     y_ctr, 20
3:
        rcall   patt1_line
        dec     y_ctr
        brne    3b

        ldi     y_ctr, 20
4:
        rcall   patt2_line
        dec     y_ctr
        brne    4b
        dec     y2_ctr
        brne    2b

	;; 20 blank lines
	ldi	y_ctr, 20
1:
        rcall	blank_line
	dec	y_ctr
	brne	1b

;;;  vert sync (20 lines)
        
        ldi     r16, 231	; ~1180 clocks
2:
        nop
        nop
        dec     r16
        brne    2b
        
        cbi     _SFR_IO_ADDR(PORTB), V_VERT ; clear VERT signal
        ldi     y_ctr, 20
3:
        rcall   blank_line
        dec     y_ctr
        brne    3b
        
        ldi     r16, 231	; ~1180 clocks
2:
        nop
        nop
        dec     r16
        brne    2b
        
        sbi     _SFR_IO_ADDR(PORTB), V_VERT ; set VERT signal
        
        rjmp    top

        
blank_line:
        lds     r16, TIFR
	sbrs	r16, OCF1B 		; wait for timer match
	rjmp	blank_line

	ldi	r16, (1 << OCF1B) 	; clear timer match status bit
	out	_SFR_IO_ADDR(TIFR), r16

	ret


white_line:
        lds     r16, TIFR
	sbrs	r16, OCF1B 		; wait for timer match
	rjmp	white_line

	ldi	r16, (1 << OCF1B) 	; clear timer match status bit
	out	_SFR_IO_ADDR(TIFR), r16
        
        ldi     r16, 118        ; delay 360 clocks
1:
        dec     r16
        brne    1b

        cbi     _SFR_IO_ADDR(PORTB), V_DAT ; set pixel

        ldi     r16, 199	; delay 800 clocks
2:
        nop
        dec     r16
        brne    2b

        sbi     _SFR_IO_ADDR(PORTB), V_DAT ; clr pixel

        ret

patt1_line:
        lds     r16, TIFR
	sbrs	r16, OCF1B 		; wait for timer match
	rjmp	patt1_line

	ldi	r16, (1 << OCF1B) 	; clear timer match status bit
	out	_SFR_IO_ADDR(TIFR), r16
        
        ldi     r16, 118        ; delay 360 clocks
1:
        dec     r16
        brne    1b
        
        ldi     x_ctr,8
2:      
        cbi     _SFR_IO_ADDR(PORTB), V_DAT ; set pixel

        ldi     r16, 15	; delay 50 clocks
3:
        dec     r16
        brne    3b
        nop
        nop

        sbi     _SFR_IO_ADDR(PORTB), V_DAT ; clr pixel

        dec     x_ctr
        brne    4f
        ret
4:      

        ldi     r16, 15                    ; delay 50 clocks
5:
        dec     r16
        brne    5b
        nop
        
        rjmp    2b

patt2_line:
        lds     r16, TIFR
	sbrs	r16, OCF1B 		; wait for timer match
	rjmp	patt2_line

	ldi	r16, (1 << OCF1B) 	; clear timer match status bit
	out	_SFR_IO_ADDR(TIFR), r16
        
        ldi     r16, 118        ; delay 360 clocks
1:
        dec     r16
        brne    1b
        
        ldi     x_ctr,8
2:      
        sbi     _SFR_IO_ADDR(PORTB), V_DAT ; clr pixel

        ldi     r16, 15	; delay 50 clocks
3:
        dec     r16
        brne    3b
        nop
        nop

        dec     x_ctr
        brne    4f
        ret
4:      
        cbi     _SFR_IO_ADDR(PORTB), V_DAT ; set pixel
        ldi     r16, 15                    ; delay 50 clocks
5:
        dec     r16
        brne    5b
        nop
        
        rjmp    2b

vert_sync:
	ldi	y_ctr, 20
1:      
        lds     r16, TIFR
        sbrs    r16, OCF1B
        rjmp    1b

        cbi     _SFR_IO_ADDR(PORTB), V_VERT ; start vsync

	ldi	r16, (1 << OCF1B) 	; clear timer match status bit
	out	_SFR_IO_ADDR(TIFR), r16

        dec     y_ctr
        brne    1b
        
        sbi     _SFR_IO_ADDR(PORTB), V_VERT ; end vsync

        ret
        
