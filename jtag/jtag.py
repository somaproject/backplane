#!/usr/bin/python
"""

This is a simple event interface to the xc3s-based jtag interface we created

"USER1     (111100 0010)," & -- Not available until after configuration
"USER2     (111100 0011)," & -- Not available until after configuration
"USER3     (111110 0010)," & -- Not available until after configuration
"USER4     (111110 0011)," & -- Not available until after configuration
 
import os

"""

USER1 = "0xC2"
USER2 = "0xC3"
USER3 = "0xE2"
USER4 = "0xE3"

import os
import sys
from somapynet.event import Event
from somapynet import eaddr
import time
import numpy as n

class JTAGEventIO(object):
    """
    An interface to the jtag debug event port, designed to behave
    like the soma pynet event IO, and eventually be included
    in that suite of tools
    """

    def __init__(self, jtagprog=None, jtagpos=None) :
        if jtagprog == None:
            self.jtagprog = "/home/jonas/XC3Sprog/xc3sprog"
        else:
            self.jtagprog = jtagprog
            
        if jtagpos == None:
            self.jtagpos = 0
        else:
            self.jtagpos = jtagpos
        
        self.sourcemasks = eaddr.TXDest()
        self.stop()
        while(self.getEvents(False) != []) :
            # eat up old events
            pass
        
    def addRXMask(self, cmd, src):
        """
        add cmd list and source list to list of events
        we want to receive

        NOTE: jtag interface only supports selecting by src,
        such that attempts to restrict events will fail
        """
        incmds = [x for x in cmd]
        if incmds != range(256):
            raise Exception("Cannot restrict event cmds for this Event Server")

        
        #for s in src:
        self.sourcemasks[src] = 1
        
    def sendEvent(self, ea, e):
        IR = USER1
        self._callJtag(IR, event_and_addr_to_octet_string(ea, e))

    def start(self):
        """
        Simple, just sets the masks
        """

        self._setMask(self.sourcemasks)
        
    def stop(self):
        """
        Just clears the masks by setting them to empty
        """
        self._setMask(eaddr.TXDest())
        while(self.getEvents(False) != []) :
            # eat up old events
            pass
        
    def _setMask(self, m):
        IR = USER2
        self._callJtag(IR, eaddr_mask_to_octet_string(m))

    def getEvents(self, blocking=True):
        """
        Slightly different semantics, can't handle null
        event cmd, which should be fine as we'll never return it anyway
        
        """
        while True:
            IR = USER3
            resp = self._callJtag(IR, "00 00 00 00 00 00 00 00 00 00 00 00")

            e = Event()
            octets = resp.split()
            e.cmd = int(octets[0], 16)
            e.src = int(octets[1], 16)
            for epos in range(5):
                e.data[epos] = (int(octets[2 + epos * 2], 16) << 8) | int(octets[3 + epos * 2], 16)
            
            if e.cmd == 0:
                if not blocking:
                    return []
            else:
                return [e]



    def _callJtag(self, IR, dr):
        (ofid, ifid) = os.popen2([self.jtagprog, str(self.jtagpos), str(IR), str(dr)])
        x = ifid.read()
        return x
    
    
def eaddr_mask_to_octet_string(ea):
    m = n.zeros(10, n.uint8)
    for ID in range(80):
        if ea[ID]: 
            pos = ID / 8
            m[pos] |= (1 << (ID % 8))
        
    os = ""

    for i in m:
        os += "%2.2X " % i
        
    return os[:-1]
        
        
def event_and_addr_to_octet_string(ea, event):
    """
    Create the total TX string
    """
    
    os = ""
    m = n.zeros(10, n.uint8)
    for ID in range(80):
        if ea[ID]: 
            pos = ID / 8
            m[pos] |= (1 << (ID % 8))

    for i in m:
        os += "%2.2X " % i


    os += "%2.2X %2.2X "  % (event.cmd, event.src)

    for i in event.data:
        os+= "%2.2X %2.2X "  % ( (i >> 8) & 0xFF, i & 0xFF)

    return os[:-1]
    
    
    


def loopback_test():
    """
    Send an event to the jtag interface and get
    a response
    
    """

    jtagio = JTAGEventIO()
    jtagio.addRXMask(xrange(256), eaddr.JTAG)
    a = Event()
    a.cmd = 0x30
    a.src = eaddr.JTAG
    a.data[0] = 0x0123
    a.data[1] = 0x4567
    a.data[2] = 0x89AB
    a.data[3] = 0xCDEF
    a.data[4] = 0xAABB

    jtagio.start()

    ea = eaddr.TXDest()
    ea[eaddr.JTAG] = 1

    jtagio.sendEvent(ea, a)

    print jtagio.getEvents()[0]

    jtagio.stop()
    
def timestamp_test():
    """
    Just capture timestamps
    """

    jtagio = JTAGEventIO()
    jtagio.addRXMask(xrange(256), eaddr.TIMER)
    jtagio.start()

    reads = 0 
    e = None
    e = None
    for i in range(100):
        e = jtagio.getEvents()
        print "%03d: %s" % (i, e[0])

    jtagio.stop()
    
if __name__ == "__main__":
    if sys.argv[1] == "loopback":
        loopback_test()
    elif sys.argv[1] == "timestamp":
        timestamp_test()
    else:
        raise Exception("Unknown test")
