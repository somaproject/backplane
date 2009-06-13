
import sys

import time
from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO

class DeviceLinkStatus(object):
    def __init__(self, SOMAIP):
        self.eio = NetEventIO(SOMAIP)
        self.src = eaddr.NETWORK

        self.eio.addRXMask(xrange(256), eaddr.SYSCONTROL)

        self.eio.start()
        
    def getLinkStatus(self, DEVN):

        # get the link status event 
        e = Event()
        e.src = self.src
        e.cmd = 0x20
        ea = eaddr.TXDest()
        ea[eaddr.SYSCONTROL] = 1

        self.eio.sendEvent(ea, e)

        erx = self.eio.getEvents()
        linkstatus_event = erx[0]

        # now parse the link status event
        status = []
            
        for i in range(DEVN):
            if (linkstatus_event.data[1] >> i) & 0x1 > 0:
                status.append(True)
            else:
                status.append(False)
        return status
    
    def getLinkCycleCount(self, DEVN):
        # now get all of the counter events        
        rx_set = {}
        for i in range(DEVN):
            e = Event()
            e.src = self.src
            e.cmd = 0x21
            e.data[0] = i

            ea = eaddr.TXDest()
            ea[eaddr.SYSCONTROL] = 1
            self.eio.sendEvent(ea, e)

            erx = self.eio.getEvents()

            rx_set[i] = erx
        cyclecnt = []
        for i in range(DEVN):
            cyclecnt.append(rx_set[i][0].data[2])
        return cyclecnt

##         print debug_event

##         for i in range(DEVN):
##             dly = (-1, -1)
##             if i in delays:
##                 dly = (delays[i] >> 8, delays[1] & 0xFF)

##             if (linkstatus_event.data[1] >> i) & 0x1 > 0:
##                 print "Device %2d : UP" % i, 
##             else:
##                 print "Device %2d :   " % i,
##             print "%d link cycles"  % (rx_set[i][0].data[2] )
    
    def getDLTiming(self):
        # now get the debug counters
        e = Event()
        e.src = self.src
        e.cmd = 0x22
        ea = eaddr.TXDest()
        ea[eaddr.SYSCONTROL] = 1
        self.eio.sendEvent(ea, e)
        
        erx = self.eio.getEvents()
        for e in erx:
            debug_event = erx[0]

        timings = []
        for ei in range(4):
            tpos = (debug_event.data[ei] >> 8 ) & 0xFF
            tlen = debug_event.data[ei] & 0xFF
            timings.append((tpos, tlen))
        
        return timings

    def stop(self):
        self.eio.stop()

if __name__ == "__main__":
    somaip = "10.0.0.2"
    
    dls = DeviceLinkStatus(somaip)

    print dls.getLinkStatus(4)
    print dls.getLinkCycleCount(4)
    print dls.getDLTiming()
    
    dls.stop()
    
    
    
