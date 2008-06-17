#include "diskiommc.h"
#include "mmc.h"



static MMC_IS_INIT = MMC_INIT_NO; 

int MMC_disk_initialize() {
  // taken from http://elm-chan.org/fsw/ff/en/dinit.html 
  // (and similar on-disk docs)


  mmc_configure_spi(); 

  mmc_init_card(); 
  mmc_configure_card(); 
    

  //mmc_read_stats(buffer); 

  // we should do something intelligent with the status, but
  // not for now
  MMC_IS_INIT = MMC_INIT_YES; 

  return 1; 
}
int MMC_disk_status() {
  // it's really not clear what we should do here; we assume that the
  // disk is always init, right? 
  return MMC_IS_INIT; 

}

int MMC_disk_read(BYTE * buff, DWORD sector, BYTE count) {
  
  DWORD addr = sector * BLOCK_SIZE; 
  BYTE* ppos = buff; 
  BYTE c = 0; 
  for (c = 0; c < count; c++ ) {
    // read block into current buffer location
    mmc_read_block(addr, ppos); 
    
    ppos += BLOCK_SIZE; 
    
    addr += BLOCK_SIZE; 

  }
  
  return 0; 
}

int MMC_disk_write(const BYTE * buff, DWORD sector, BYTE count) {
  // NOT IMPLEMENTED, BITCHES
  return 0; 
}

int MMC_disk_ioctl(BYTE ctrl, void * buff){
  return 0; 
}

