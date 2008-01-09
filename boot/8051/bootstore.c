#include <C8051F340.h>
#include "tff.h"
#include "bootstore.h" 


#define STORESPI_CMDREQ 01
#define STORESPI_FOCMD 01
#define STORESPI_FRCMD 02

// Pin definitions
#define STORESPI_CS P0_1
#define STORESPI_MOSI P0_2
#define STORESPI_MISO P0_3
#define STORESPI_SCLK P0_4

void storespi_tx(char x) {
  int i = 0; 
  char buf = x; 
  for (i = 0; i < 8; i++ ) {
    buf = x;  // really slow; should do in ASM
    buf = buf >> (7 - i); 
    STORESPI_MOSI = buf & 0x01; 
    STORESPI_SCLK = 0; 
    STORESPI_SCLK = 1; 
    STORESPI_SCLK = 0; 
  }
}



char storespi_rx() {
  // bit-banging
  char buf = 0;
  char i = 0;

  buf <<=  1;
  buf |= STORESPI_MISO;
  STORESPI_SCLK = 1;
  STORESPI_SCLK = 1;
  STORESPI_SCLK = 0;

  buf <<=  1;
  buf |= STORESPI_MISO;
  STORESPI_SCLK = 1;
  STORESPI_SCLK = 1;
  STORESPI_SCLK = 0;

  buf <<=  1;
  buf |= STORESPI_MISO;
  STORESPI_SCLK = 1;
  STORESPI_SCLK = 1;
  STORESPI_SCLK = 0;

  buf <<=  1;
  buf |= STORESPI_MISO;
  STORESPI_SCLK = 1;
  STORESPI_SCLK = 1;
  STORESPI_SCLK = 0;

  buf <<=  1;
  buf |= STORESPI_MISO;
  STORESPI_SCLK = 1;
  STORESPI_SCLK = 1;
  STORESPI_SCLK = 0;

  buf <<=  1;
  buf |= STORESPI_MISO;
  STORESPI_SCLK = 1;
  STORESPI_SCLK = 1;
  STORESPI_SCLK = 0;

  buf <<=  1;
  buf |= STORESPI_MISO;
  STORESPI_SCLK = 1;
  STORESPI_SCLK = 1;
  STORESPI_SCLK = 0;

  buf <<=  1;
  buf |= STORESPI_MISO;
  STORESPI_SCLK = 1;
  STORESPI_SCLK = 1;
  STORESPI_SCLK = 0;

  return buf;
}

void bootstore_setup()
{

  P0MDOUT &= 0xF6;
  STORESPI_CS = 1; 
}

void bootstore() {
  static __xdata FIL fileobject; 
  FRESULT fres; 
  unsigned long filelen; 
  char fopenres; 
  
  char cpos; 
  char cmd; 
  char dummy; 

  
  for(;;) {
    if (STORESPI_MISO == 1 ) {
      STORESPI_CS = 0; // extra ticks
      STORESPI_CS = 0; 
      STORESPI_CS = 0; 
      
      storespi_tx(STORESPI_CMDREQ);
      storespi_tx(0x00);
             
      cmd = storespi_rx();
      dummy = storespi_rx();
      
      if (cmd == STORESPI_FOCMD) {
	// ----------------------------------------------
	// FILE READ CMD
	// -----------------------------------------------

	// get filename
	char filename[32];
	for (cpos = 0; cpos < 32; ++cpos) {
	  filename[cpos] = storespi_rx();
	}
	
	fres = f_open(&fileobject, filename, FA_READ);
	
	filelen = 0;

	if (fres == FR_OK )
	  {
	    // success
	    filelen = fileobject.fsize;
	    fres = 1;
	  } else if (fres == FR_NO_FILE) {
	    fres = 2;
	  } else {
	    fres = 3;
	    filelen = fres;
	  }
	
	storespi_tx(fopenres);
	storespi_tx(0x00);
	storespi_tx((filelen >> 24) & 0xFF);
	storespi_tx((filelen >> 16) & 0xFF);
	storespi_tx((filelen >> 8) & 0xFF);
	storespi_tx((filelen >> 0) & 0xFF);
      }
      
      
      STORESPI_CS = 1;
    }
    STORESPI_CS = 1; 
      

  }





}
