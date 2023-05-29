# attiny2313_petvid
An Atmel ATTiny2313 creates a test-pattern video signal for Commodore PETs.

I/O pin assignments:

  PB2 =	Video Data
  
  PB3 =	VERT Drive
  
  PB4 =	HORZ Drive
 
 Expects 20 Mhz crystal.  Program lfuse to 0xEF: (External Oscillator, no divider.)
 
 		avrdude -p t2313 -U lfuse:w:0xEF:m
