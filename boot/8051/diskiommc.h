#ifndef DISKIOMMC_H
#define DISKIOMMC_H


/* --------------------------------------------------------------- */
/* Low-level interface to our own MMC code, in the fashion of what */
/* FatFs-Tiny expects */
/* --------------------------------------------------------------- */

#include "diskio.h"

#define MMC_INIT_YES 1
#define MMC_INIT_NO 0

int MMC_disk_initialize();
int MMC_disk_status();
int MMC_disk_read(BYTE * buff, DWORD sector, BYTE count);
int MMC_disk_write(const BYTE * buff, DWORD sector, BYTE count);
int MMC_disk_ioctl(BYTE ctrl, void * buff);

#endif // DISKIO_MMC
