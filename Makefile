
TARGETS=petvid.hex petvid.lst
OBJS=petvid.o videoloop.o

DEVICE=attiny2313

CC=avr-gcc
OBJDUMP=avr-objdump
OBJCOPY=avr-objcopy
OBJSIZE=avr-size

CC_FLAGS=-g -O
CC_OPTS=$(CC_FLAGS) -mmcu=$(DEVICE)
LD_FLAGS=-g
LD_OPTS=$(LD_FLAGS) -mmcu=$(DEVICE)

.PHONY: default clean program

default: $(TARGETS)

petvid.elf: $(OBJS)
	$(CC) $(LD_OPTS) -o $@ $(OBJS)

%.o: %.c
	$(CC) $(CC_OPTS) -c $<

%.o: %.S
	$(CC) $(CC_OPTS) -c $<

%.hex: %.elf
	$(OBJCOPY) -j .text -j .data -O ihex $< $@

%.lst: %.elf
	$(OBJDUMP) -S -d $< > $@
	$(OBJSIZE) -x $< >> $@

program: petvid.hex
	avrdude -p t2313 -U petvid.hex

clean:
	$(RM) *.o *.elf *.v *.lst *.hex
