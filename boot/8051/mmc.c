#include "mmc.h" 

/*

Low-level MMC interface, inspired by Silicon Labs AN189 with some
bits copied from the FatFS examples. 

Analog devices app note EE-264


http://elm-chan.org/docs/mmc/mmc_e.html is invaluable. 


We have a few basic functions: 

mmc_configure_spi()
mmc_init_card()
mmc_get_card_parameters()
mmc_read_block()

At the moment, we only support reading, and 
we only read a single block at a time. Oh well. 


*/ 



__code COMMAND commandprops[] = {
  {0, ARG_NONE, 0x95,  RESPONSE_R1, DATA_NO},      // GO_IDLE_STATE
  {1, ARG_NONE, 0xFF,  RESPONSE_R1, DATA_NO},      // SEND_OP_COND
  {9, ARG_NONE, 0xFF,  RESPONSE_R1, DATA_YES},     // SEND_CSD
  {10, ARG_NONE, 0xFF, RESPONSE_R1, DATA_YES},     // SEND_CID
  {12, ARG_NONE, 0xFF, RESPONSE_R1B, DATA_NO},     // STOP_TRANSMISSION
  {16, ARG_REQUIRED, 0xFF, RESPONSE_R1, DATA_NO},  // SET_BLOCKLEN 
  {17, ARG_REQUIRED, 0xFF, RESPONSE_R1, DATA_YES}, // READ_SINGLE_BLOCK
  {18, ARG_REQUIRED, 0xFF, RESPONSE_R1, DATA_YES}, // READ_MULTIPLE_BLOCK
  {23, ARG_REQUIRED, 0xFF, RESPONSE_R1, DATA_NO},  // SET_BLOCK_COUNT
  {24, ARG_REQUIRED, 0xFF, RESPONSE_R1, DATA_YES}, // WRITE_BLOCK
  {25, ARG_REQUIRED, 0xFF, RESPONSE_R1, DATA_YES}, // WRITE_MULTIPLE_BLOCK
  {58, ARG_NONE, 0xFF, RESPONSE_R3, DATA_NO} };    // READ_OCR 

void mmc_set_cs(int val) {
  // sets the CS to the passed in value
  SPI_CS = val; 

}


void xmit_spi(char dat) {
  // sadly, we can't use the built-in SPI interface so we get to bit-bang
  int i = 0; 
  char buf = dat; 
  for (i = 0; i < 8; i++ ) {
    buf = dat;  // really slow; should do in ASM
    buf = buf >> (7 - i); 
    SPI_MOSI = buf & 0x01; 
    SPI_SCLK = 0; 
    SPI_SCLK = 1; 
    SPI_SCLK = 0; 
  }

}

#define USE_ASM

#ifndef USE_ASM 

char recv_spi() {
  // bit-banging
  char buf = 0;
  char i = 0;

  buf <<=  1;
  buf |= SPI_MISO;
  SPI_SCLK = 1;
  SPI_SCLK = 1;
  SPI_SCLK = 0;

  buf <<=  1;
  buf |= SPI_MISO;
  SPI_SCLK = 1;
  SPI_SCLK = 1;
  SPI_SCLK = 0;

  buf <<=  1;
  buf |= SPI_MISO;
  SPI_SCLK = 1;
  SPI_SCLK = 1;
  SPI_SCLK = 0;

  buf <<=  1;
  buf |= SPI_MISO;
  SPI_SCLK = 1;
  SPI_SCLK = 1;
  SPI_SCLK = 0;

  buf <<=  1;
  buf |= SPI_MISO;
  SPI_SCLK = 1;
  SPI_SCLK = 1;
  SPI_SCLK = 0;

  buf <<=  1;
  buf |= SPI_MISO;
  SPI_SCLK = 1;
  SPI_SCLK = 1;
  SPI_SCLK = 0;

  buf <<=  1;
  buf |= SPI_MISO;
  SPI_SCLK = 1;
  SPI_SCLK = 1;
  SPI_SCLK = 0;

  buf <<=  1;
  buf |= SPI_MISO;
  SPI_SCLK = 1;
  SPI_SCLK = 1;
  SPI_SCLK = 0;

  return buf;
}

#else

char recv_spi()  {
  _asm; 

	mov	c,_P1_0
	clr	a
	rlc	a
	mov	r2,a

	setb	_P1_2

	setb	_P1_2

	clr	_P1_2

	mov	a,r2
	add	a,r2
	mov	r2,a

	mov	c,_P1_0
	clr	a
	rlc	a
	orl	ar2,a

	setb	_P1_2

	setb	_P1_2

	clr	_P1_2

	mov	a,r2
	add	a,r2
	mov	r2,a

	mov	c,_P1_0
	clr	a
	rlc	a
	orl	ar2,a

	setb	_P1_2

	setb	_P1_2

	clr	_P1_2

	mov	a,r2
	add	a,r2
	mov	r2,a

	mov	c,_P1_0
	clr	a
	rlc	a
	orl	ar2,a

	setb	_P1_2

	setb	_P1_2

	clr	_P1_2

	mov	a,r2
	add	a,r2
	mov	r2,a

	mov	c,_P1_0
	clr	a
	rlc	a
	orl	ar2,a

	setb	_P1_2

	setb	_P1_2

	clr	_P1_2

	mov	a,r2
	add	a,r2
	mov	r2,a

	mov	c,_P1_0
	clr	a
	rlc	a
	orl	ar2,a

	setb	_P1_2

	setb	_P1_2

	clr	_P1_2

	mov	a,r2
	add	a,r2
	mov	r2,a

	mov	c,_P1_0
	clr	a
	rlc	a
	orl	ar2,a

	setb	_P1_2

	setb	_P1_2

	clr	_P1_2

	mov	a,r2
	add	a,r2
	mov	r2,a

	mov	c,_P1_0
	clr	a
	rlc	a
	orl	ar2,a

	setb	_P1_2

	setb	_P1_2

	clr	_P1_2

	mov	dpl,r2

	  ret

  _endasm; 


}

#endif 

static
char send_command (char cmd, unsigned long arg)
{
  // note that this leaves the card selected!!!

  // get command byte
  char cmdbyte, arg0, arg1, arg2, arg3, crc, n, res; 
  cmdbyte  = commandprops[cmd].command_index; 
  cmdbyte &= 0x3F; 
  cmdbyte |= 0x40; 
  
  arg0 = arg >> 24; 
  arg1 = arg >> 16; 
  arg2 = arg >> 8; 
  arg3 = arg; 
  
  crc = commandprops[cmd].crc; 

  DESELECT(); 
  SELECT(); 
  
  // send the bytes
  xmit_spi(cmdbyte); 
  xmit_spi(arg0); 
  xmit_spi(arg1); 
  xmit_spi(arg2); 
  xmit_spi(arg3); 
  xmit_spi(crc); 

  n = 10; 
  do {
    res = recv_spi(); 
  } while ((res & 0x80) && --n); 

  // now get the data


  // get the argument
  return res; 
  
}

void mmc_configure_spi()
{
  DESELECT();

}


void mmc_init_card() {
  
  int i = 0; 
  char res = 0; 

  DESELECT(); 
  // Power on reset -- apply more than 74 SCLK pulses
  for (i = 0; i < 10; i++ ) {
    xmit_spi(0xFF); 
  }

  // Send IDLE command
  while (res != 0x01 ) {
    res = send_command(GO_IDLE_STATE, 0); 
  }
  
  // we should be in the idle state to receive commands now; 
  
  // send the SEND_OP_COND and loop 
  res = 0x01; 
  while (res != 0x00 ) {
    res = send_command(SEND_OP_COND, 0); 
  }
  
}

void read_block_response(char * pbuffer)
{
  // this simply acquires the data packet and places it in pbuffer

  unsigned char res = 0; 
  int i = 0; 
  char * p = pbuffer; 

  while (res != 0xFE) {
    res = recv_spi(); 
  }

  // now get the actual data; 
  for (i = 0; i < BLOCK_SIZE; i++ ) {
    *p = recv_spi(); 
    p++; 
  }

  // read off the two CRC bytes
  recv_spi(); 
  recv_spi(); 
  // done! 

  DESELECT(); 

  // FIXME -- check for error token!!
}

void mmc_read_block(unsigned long addr, char * pbuffer)
{
  P0_0 = 0; 
  P0_0 = 1; 
  send_command(READ_SINGLE_BLOCK, addr); 
  read_block_response(pbuffer);   
  P0_0 = 0;
}

void mmc_read_stats(char * pbuffer)
{
  // Read the CSD and CID status registers
  // return: 
  //   pbuffer[0:15] is CSD
  //   pbuffer[16:31] is CID
  // stat register contents in 
  //  http://pdfserv.maxim-ic.com/en/an/AN4068.pdf

  unsigned char res = 0; 
  int i = 0; 
  char * p = pbuffer; 

  send_command(SEND_CSD, 0); 

  while (res != 0xFE) {
    res = recv_spi(); 
  }

  // now get the actual data; 
  for (i = 0; i < 16; i++ ) {
    *p = recv_spi(); 
    p++; 
  }

  // read off the two CRC bytes
  recv_spi(); 
  recv_spi(); 

  res = 0; 
  
  send_command(SEND_CID, 0); 

  while (res != 0xFE) {
    res = recv_spi(); 
  }

  // now get the actual data; 
  for (i = 0; i < 16; i++ ) {
    *p = recv_spi(); 
    p++; 
  }

  // read off the two CRC bytes
  recv_spi(); 
  recv_spi(); 

  // done

}
void mmc_configure_card() {

  send_command(SET_BLOCKLEN, BLOCK_SIZE); 
  

}
