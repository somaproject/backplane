#ifndef MMC_H
#define MMC_H
#include <C8051F340.h>
//#include <c8051f340.h>

// SPI Pins

#define SPI_CS    P1_6
#define SPI_MOSI  P1_5
#define SPI_MISO  P1_0
#define SPI_SCLK  P1_2


//define MMC Commands
#define GO_IDLE_STATE        0
#define SEND_OP_COND         1
#define SEND_CSD             2
#define SEND_CID             3
#define STOP_TRANSMISSION    4
#define SET_BLOCKLEN         5  
#define READ_SINGLE_BLOCK    6
#define READ_MULTIPLE_BLOCK  7
#define SET_BLOCK_COUNT      8
#define WRITE_BLOCK          9
#define WRITE_MULTIPLE_BLOCK 10
#define READ_OCR             11

#define RESPONSE_R1     0
#define RESPONSE_R1B    1
#define RESPONSE_R2     2
#define RESPONSE_R3     3

typedef struct  {
  char command_index;
  char argument;
  char crc; 
  char response; 
  char dataarg; 
} COMMAND; 

#define ARG_NONE     0
#define ARG_REQUIRED 1

#define DATA_YES 1
#define DATA_NO  0 

void mmc_set_cs(int val);
void xmit_spi(char dat);
char recv_spi();
char send_command (char cmd, unsigned long arg);
void mmc_init_card(); 
void mmc_configure_card(); 
void mmc_configure_spi(); 
void mmc_read_block(unsigned long addr, char * pbuffer); 
void mmc_read_stats(char * pbuffer); 

#define BLOCK_SIZE 512

#define SELECT()    mmc_set_cs(0)
#define DESELECT()  mmc_set_cs(1)


#endif // MMC_H
