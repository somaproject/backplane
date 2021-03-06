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
    STORESPI_SCLK = 1; 
    STORESPI_SCLK = 1; 
    STORESPI_SCLK = 0; 
    STORESPI_SCLK = 0; 
    STORESPI_SCLK = 0; 
  }
  // FIXME DEBUGGING: 
  STORESPI_MOSI = 0x00; 
}


unsigned char storespi_rx() {
  // bit-banging
  unsigned char buf = 0;
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

  P0MDOUT &= 0xF7;
  STORESPI_CS = 1; 
}

extern __xdata char buffer[]; 

void bootstore() {
  static __xdata FIL fileobject; 
  FRESULT fres; 
  unsigned long filelen, bytesread; 
  char fopenres; 
  int pos; 
  char cpos; 
  char cmd; 
  char dummy; 

  unsigned long freadoffset, freadlen; 

  unsigned long cacheaddr = -1; 
  unsigned long CACHESIZE=512; 

  for(;;) {
    if (STORESPI_MISO == 1 ) {
      STORESPI_CS = 0; // extra ticks
      STORESPI_CS = 0; 
      STORESPI_CS = 0; 
      
      storespi_tx(STORESPI_CMDREQ);
      storespi_tx(0x00);

      dummy = storespi_rx();             
      cmd = storespi_rx();

      
      if (cmd == STORESPI_FOCMD) {
	// ----------------------------------------------
	// FILE READ CMD
	// -----------------------------------------------

	// get offset
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
	    fopenres = 1;
	  } else if (fres == FR_NO_FILE) {
	    fopenres = 2; 
	    filelen = filename[0];
	    filelen = (filelen << 8) | filename[1]; 
	    filelen = (filelen << 8) | filename[2]; 
	    filelen = (filelen << 8) | filename[3]; 

	  } else {
	    fopenres = 3;
	    filelen = fres; 
	  }
	
	cacheaddr = 0; 
	f_read(&fileobject, buffer, CACHESIZE, &bytesread); 

	storespi_tx(fopenres);
	storespi_tx(0x00);
	storespi_tx((filelen >> 24) & 0xFF);
	storespi_tx((filelen >> 16) & 0xFF);
	storespi_tx((filelen >> 8) & 0xFF);
	storespi_tx((filelen >> 0) & 0xFF);
      } else if (cmd == STORESPI_FRCMD) {
	// ----------------------------------------------
	// FILE READ CMD
	// -----------------------------------------------
	
/* 	freadoffset = storespi_rx();                                   */
/* 	freadoffset = (freadoffset << 8) | storespi_rx();                       */
/* 	freadoffset = (freadoffset << 8) | storespi_rx();                     */
/* 	freadoffset = (freadoffset << 8) | storespi_rx();  */

	
/* 	freadlen = storespi_rx();                                   */
/* 	freadlen = (freadlen << 8) | storespi_rx();                       */
/* 	freadlen = (freadlen << 8) | storespi_rx();                     */
/* 	freadlen = (freadlen << 8) | storespi_rx();  */
	
/* 	fres = f_lseek(&fileobject, freadoffset);  */

/* 	fres = f_read(&fileobject, buffer, freadlen, &bytesread);  */

/* 	for (pos = 0; pos < freadlen; pos++) { */
/* 	  storespi_tx(buffer[pos]);  */
/* 	} */
	// ----------------------------------------------
	// FILE READ CMD
	// -----------------------------------------------
	
	freadoffset = storespi_rx();                                  
	freadoffset = (freadoffset << 8) | storespi_rx();                      
	freadoffset = (freadoffset << 8) | storespi_rx();                    
	freadoffset = (freadoffset << 8) | storespi_rx(); 

	
	freadlen = storespi_rx();                                  
	freadlen = (freadlen << 8) | storespi_rx();                      
	freadlen = (freadlen << 8) | storespi_rx();                    
	freadlen = (freadlen << 8) | storespi_rx(); 

	if ((cacheaddr <= freadoffset) & ((freadoffset + freadlen) < 
					  (cacheaddr + CACHESIZE))) {
	  
	  // we're looking for something we recently acquired; 
	  
	  for (pos = 0; pos < freadlen; pos++) {
	    storespi_tx(buffer[pos + (freadoffset - cacheaddr)]); 
	  }
	  
	} else {
	  
	  fres = f_lseek(&fileobject, freadoffset); 
	  
	  fres = f_read(&fileobject, buffer, CACHESIZE, &bytesread); 
	  
	  cacheaddr = freadoffset; 
	  
	  for (pos = 0; pos < freadlen; pos++) {
	    storespi_tx(buffer[pos]); 
	  }
	  
	}      
      }
    }
    STORESPI_CS = 1; 
    

  }





}
