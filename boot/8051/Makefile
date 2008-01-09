all: mmc.ihx

CC = sdcc
AS = asx8051

XDATA_START = 0x100

MODEL = --model-small --debug
CCFLAGS = -mmcs51 $(MODEL) --xram-loc $(XDATA_START)   --stack-auto
LDFLAGS = $(MODEL)  --xram-loc $(XDATA_START) --stack-auto

ASFLAGS = -losa

OBJS = main.rel mmc.rel diskiommc.rel diskio.rel tff.rel bootstore.rel

TARGET= mmc.ihx


.SUFFIXES: .rel .ihx

.PHONY: .clean


$(TARGET): $(OBJS)
	$(CC) -o $@ $(LDFLAGS) $(OBJS)

.s.rel:
	$(AS) $(ASFLAGS) $<

.c.rel:
	$(CC) -M $(CCFLAGS) $< > $(<:.c=.d)
	$(CC) $(CCFLAGS) -c $<

clean: 
	rm *.rel *.ihx *.lnk *.lst *.map *.mem *.rst *.sym *.d  *.asm
