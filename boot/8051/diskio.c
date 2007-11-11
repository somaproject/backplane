/*-----------------------------------------------------------------------*/
/* Low level disk I/O module skeleton for FatFs     (C)ChaN, 2007        */
/*-----------------------------------------------------------------------*/
/* This is a stub disk I/O module that acts as front end of the existing */
/* disk I/O modules and attach it to FatFs module with common interface. */
/*-----------------------------------------------------------------------*/

#include "diskio.h"
#include "diskiommc.h"

/*-----------------------------------------------------------------------*/
/* Correspondence between drive number and physical drive                */
/* Note that Tiny-FatFs supports only single drive and always            */
/* accesses drive number 0.                                              */

#define MMC   0



/*-----------------------------------------------------------------------*/
/* Inidialize a Drive                                                    */

DSTATUS disk_initialize (
	BYTE drv				/* Physical drive nmuber (0..) */
)
{
	DSTATUS stat = 0;
	int result;

	result = MMC_disk_initialize();
	// translate the reslut code here

	stat &= ~STA_NOINIT; // clear NOINIT bit

	return stat;

}



/*-----------------------------------------------------------------------*/
/* Return Disk Status                                                    */

DSTATUS disk_status (
	BYTE drv		/* Physical drive nmuber (0..) */
)
{
	DSTATUS stat = 0;
	int result;


	result = MMC_disk_status();
	// translate the reslut code here
	if (result == MMC_INIT_YES) {
	  stat &= ~STA_NOINIT; // clear noinit
	} else {
	  stat |= STA_NOINIT; 
	}

	return stat;

}



/*-----------------------------------------------------------------------*/
/* Read Sector(s)                                                        */

DRESULT disk_read (
		   BYTE drv,		/* Physical drive number (0..) */
		   BYTE *buff,		/* Data buffer to store read data */
		   DWORD sector,	/* Sector number (LBA) */
		   BYTE count		/* Sector count (1..255) */
		   )
{
	DRESULT res = 0;
	int result;

	result = MMC_disk_read(buff, sector, count);
	// translate the reslut code here
	
	return RES_OK; 


}



/*-----------------------------------------------------------------------*/
/* Write Sector(s)                                                       */

#if _READONLY == 0
DRESULT disk_write (
	BYTE drv,			/* Physical drive nmuber (0..) */
	const BYTE *buff,	/* Data to be written */
	DWORD sector,		/* Sector number (LBA) */
	BYTE count			/* Sector count (1..255) */
)
{
	DRESULT res = 0;
	int result;

	result = MMC_disk_write(buff, sector, count);
	// translate the reslut code here
	
	return res;
	
	//return RES_PARERR;
}
#endif /* _READONLY */



/*-----------------------------------------------------------------------*/
/* Miscellaneous Functions                                               */

DRESULT disk_ioctl (
	BYTE drv,		/* Physical drive nmuber (0..) */
	BYTE ctrl,		/* Control code */
	void *buff		/* Buffer to send/receive control data */
)
{
	DRESULT res = 0;
	int result;

	result = MMC_disk_ioctl(ctrl, buff);
	// post-process here
	
	res = RES_OK; 

	return res;
	

	//return RES_PARERR;
}

