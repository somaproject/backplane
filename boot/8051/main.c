#include <C8051F340.h>
//#include <c8051f340.h>

#include "tff.h"

#include "mmc.h" 


__xdata unsigned char buffer[BLOCK_SIZE];

__xdata FATFS  filesysobj; 
 

#define FPGA_CCLK P2_7
#define FPGA_DIN P2_6 
#define FPGA_PROG P2_5
#define FPGA_INIT P2_4


void general_setup()
{
  
  int i; 

  OSCICN = 0x83; 
  OSCICL = 0x00; 
  PCA0MD &= ~0x40; 

  // set up the clock multiplier, per instructions on page 146 of manual
  CLKMUL = 0; 
  CLKMUL |= 0x80; // enable clock multipler
  // delay
  for (i = 0; i < 1000; i++) {
    // 
  }
  
  CLKMUL |= 0xC0; // initalize
  
  while (CLKMUL & 0x20 == 0) {

    // loop
  } 

  // now initialzied; 
  
  
  //CLKSEL = 0x02; 

}

void configure_port_0()
{
  P0MDOUT  |= 0x0F; // port 0 is Push-Pull

}

void configure_port_1()
{
  //P1MDIN = 0x00; 
  P1MDOUT  |= 0xFF; // port 1 is Push-Pull
  
}


void configure_port_2()
{

  P2MDOUT  = 0xEF; // port 2 is Push-Pull
  // except FPGA_INIT is open-drain 
  FPGA_PROG = 1; 
  FPGA_DIN = 0; 
  FPGA_CCLK = 0; 
  
}


int mmcsimpletest()
{
  int q; 
  int x; 
  int c; 
  

  mmc_configure_spi(); 
  mmc_init_card(); 
  mmc_configure_card(); 
  //mmc_read_stats(buffer); 

  //mmc_read_block(0, buffer); 

  
  for(;;) {
    for (q = 0; q < 10; q++) {
      P0_1 = 0;  // dummy wait; 
    } 
    P0_0 = 1;
    P0_0 = 0; 
    for (q = 0; q < 10; q++) {
      for (x = 0; x < 8; x++ ) 
	{
	  //c = buffer[q]; 
	  //c = c >> (7 - x); 
	  
	  //P0_1 = c & 1; 
	  
	}
      P0_1 = 0; 
    }

    P0_0 = 0; 
  }

}

char _sdcc_external_startup()
{

  PCA0MD &= ~0x40;  // disable watchdog
  
  return 0; 
}


void checkOK(FRESULT fres) 
{
  if (fres == FR_OK) {
    return; 
  } else {
    for (;;) {
      P0_1 = 0; 
      P0_1 = 1;
      
    }
    
  }
}
  

// now, how to read a xilinx file? 
void FPGA_send_bits(char * buffer, int len);

void FPGA_boot()
{
  static __xdata FIL fileobject; 

  FRESULT fres; 
  int t = 0; 
  unsigned int bytesread = 0; 

  fres = f_open(&fileobject , "blink.bit", FA_READ); 
  checkOK(fres); 

  // first stage of boot; 
  
  for (t = 0; t < 10; t++) {
    FPGA_PROG = 0; 
    
  }
  FPGA_PROG = 1; 

  // wait for init to be pulled high
  while (FPGA_INIT == 0 ) {
    // do nothing
  }

  // now, the real work; open the file; read the file, dump the bytes

  fres = f_read(&fileobject, buffer, BLOCK_SIZE, &bytesread); 
  checkOK(fres); 
  
  FPGA_send_bits(&buffer[72], bytesread-72); 

  // now send the rest of the file

  
  while (bytesread == BLOCK_SIZE){ 

    fres = f_read(&fileobject, buffer, BLOCK_SIZE, &bytesread);  
    checkOK(fres);  
    FPGA_send_bits(buffer, bytesread);  
  }  
  

  // extra ticks to push through configuration

  for (t = 0; t < 100; t++) {
    FPGA_CCLK = 0; 
    FPGA_CCLK = 1; 
    FPGA_CCLK = 0; 
  } 
  /* 
     

  */


}





void FPGA_send_bits(char * buffer, int len)
{
  static __data int i;
  static __data char b; 
  static __data char byte; 
  static __data char txbit = 0; 
  
  P0_0 = 0; 
  P0_0 = 1;


  for (i = 0; i < len; i++) {
    byte = buffer[i]; 

    // manual loop unrolling? really? 

    txbit = byte & 0x80; 
    if (txbit) { FPGA_DIN =  1; } else { FPGA_DIN = 0; }
    FPGA_CCLK = 0; FPGA_CCLK = 1; FPGA_CCLK = 0; 
    byte <<= 1; 

    txbit = byte & 0x80; 
    if (txbit) { FPGA_DIN =  1; } else { FPGA_DIN = 0; }
    FPGA_CCLK = 0; FPGA_CCLK = 1; FPGA_CCLK = 0; 
    byte <<= 1; 

    txbit = byte & 0x80; 
    if (txbit) { FPGA_DIN =  1; } else { FPGA_DIN = 0; }
    FPGA_CCLK = 0; FPGA_CCLK = 1; FPGA_CCLK = 0; 
    byte <<= 1 ;

    txbit = byte & 0x80; 
    if (txbit) { FPGA_DIN =  1; } else { FPGA_DIN = 0; }
    FPGA_CCLK = 0; FPGA_CCLK = 1; FPGA_CCLK = 0; 
    byte <<= 1 ;

    txbit = byte & 0x80; 
    if (txbit) { FPGA_DIN =  1; } else { FPGA_DIN = 0; }
    FPGA_CCLK = 0; FPGA_CCLK = 1; FPGA_CCLK = 0; 
    byte <<= 1 ;

    txbit = byte & 0x80; 
    if (txbit) { FPGA_DIN =  1; } else { FPGA_DIN = 0; }
    FPGA_CCLK = 0; FPGA_CCLK = 1; FPGA_CCLK = 0; 
    byte <<= 1 ;

    txbit = byte & 0x80; 
    if (txbit) { FPGA_DIN =  1; } else { FPGA_DIN = 0; }
    FPGA_CCLK = 0; FPGA_CCLK = 1; FPGA_CCLK = 0; 
    byte <<= 1 ;

    txbit = byte & 0x80; 
    if (txbit) { FPGA_DIN =  1; } else { FPGA_DIN = 0; }
    FPGA_CCLK = 0; FPGA_CCLK = 1; FPGA_CCLK = 0; 
    byte <<= 1 ;


  
  
  }
  P0_0 = 0; 
}
void testcode()
{
  static __xdata FIL fileobject; 
  int x = 0; 
  unsigned int bytesread = 0; 
  FRESULT fres; 

  fres = f_open(&fileobject , "out.dat", FA_READ); 
  checkOK(fres); 

  fres = f_read(&fileobject, buffer, BLOCK_SIZE, &bytesread); 
  checkOK(fres); 

  for(;;) {
    for (x = 0; x < bytesread; x++) {
      P0_0 = 0; 
      P0_0 = 1; 
      P0_0 = 0; 

    }
    
    for (x = 0; x < 512; x++) {
      P0_0 = 0; 
      P0_0 = 0; 
      P0_0 = 0; 
    }
  }


}
int main(void)
{
  int x = 0; 
  unsigned int bytesread = 0; 
  FRESULT fres; 
  
  general_setup(); 
  configure_port_0(); 
  configure_port_1(); 
  configure_port_2(); 

  // enable crossbar 
  XBR1 |= 0x40; 
  P0_0 = 1; 

  // filesystem operations
  
  fres = f_mount(0, &filesysobj); 
  checkOK(fres); 

  FPGA_boot();
  for(;;) {
    P0_0 = 1; 
    P0_0 = 0; 

  }
}
