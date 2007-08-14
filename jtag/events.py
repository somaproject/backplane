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

import numpy as n


class Mask(object):
    def __init__(self):

        self.m = n.zeros(10, n.uint8)

    def setAddr(self, ID):
        """
        This sets the right bit in the address mask
        
        """

        pos = ID / 8
        self.m[pos] |= (1 << (ID % 8))
        
    def to_octet_string(self):
        os = ""

        for i in self.m:
            os += "%2.2X " % i
        
        return os[:-1]
        
        
class Event(object):
    def __init__(self):
        self.cmd = 0x0
        self.src = 0x0
        
        self.data = n.zeros(5, n.uint16)
        self.addr = n.zeros(10, n.uint8)

    def setAddr(self, ID):
        """
        This sets the right bit in the address mask
        
        """

        pos = ID / 8
        self.addr[pos] |= (1 << (ID % 8))
        
        
    def to_octet_string(self):
        os = ""

        for i in self.addr:
            os += "%2.2X " % i
        
        
        os += "%2.2X %2.2X "  % (self.cmd, self.src)

        for i in self.data:
            os+= "%2.2X %2.2X "  % ( (i >> 8) & 0xFF, i & 0xFF)

        return os[:-1]
    
    def __str__(self):
        s = "cmd: %2.2X src: %2.2X " % (self.cmd, self.src)
        for i in self.data:
            s += "%4.4X " % i
        return s
        
    

jtagprog = "/home/jonas/XC3Sprog/xc3sprog"
jtagpos = 1

def callJtag(IR, dr):
    
    (ofid, ifid) = os.popen2([jtagprog, str(jtagpos), str(IR), str(dr)])
    x = ifid.read()
    return x

    

def sendEvent(e):
    IR = USER1
    callJtag(IR, e.to_octet_string())
    
    
    
def setMask(m):
    IR = USER2
    callJtag(IR, m.to_octet_string())
    
def readEvent():
    IR = USER3
    resp = callJtag(IR, "00 00 00 00 00 00 00 00 00 00 00 00")

    e = Event()
    octets = resp.split()
    e.cmd = int(octets[0], 16)
    e.src = int(octets[1], 16)
    e.data[0] = int(octets[2] + octets[3], 16)
    e.data[1] = int(octets[4] + octets[5], 16)
    e.data[2] = int(octets[6] + octets[7], 16)
    e.data[3] = int(octets[8] + octets[9], 16)
    e.data[4] = int(octets[10] + octets[11], 16)

    if e.cmd == 0:
        #print "e.cmd == 0"
        return None
    else:
        return e
    

def loopback_test():
    
    # this is a loopback test
    JTAGADDR = 0x07

    m = Mask()

    m.setAddr(JTAGADDR)

    setMask(m)

    
    a = Event()
    a.cmd = 0x30
    a.src = JTAGADDR
    a.setAddr(JTAGADDR)
    a.data[0] = 0x0123
    a.data[1] = 0x4567
    a.data[2] = 0x89AB
    a.data[3] = 0xCDEF
    a.data[4] = 0xAABB

    sendEvent(a)
    reads = 0 
    e = None
    while e == None:
        e = readEvent()
        reads += 1
        
    while e != None:
        print e, reads
        e = readEvent()
    

if __name__ == "__main__":
    loopback_test()
    
