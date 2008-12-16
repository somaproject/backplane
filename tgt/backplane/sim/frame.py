#!/usr/bin/python

"""

"""
import re
import struct
import crcmod

CRCPOLY = 0x104C11DB7


PROTO_IP = 0x0800
PROTO_ARP = 0x0806

def macdecode(macstring):
    macre = re.compile("(\w\w):(\w\w):(\w\w):(\w\w):(\w\w):(\w\w)")
    bytes = macre.match(macstring).groups()
    result = [0, 0, 0, 0, 0, 0]
    for i in range(6):
        result[i] = int(bytes[i], 16)

    return struct.pack("BBBBBB", result[0], result[1], result[2], result[3], result[4], result[5])


class frame:
    """
    Ethernet frame simulation code in python; this is designed for both
    extracting data from an ethernet frame and for generating ethernet
    frames out of chunks of data
    
    note MAC addresses are strings of the form "AA:BB:CC:DD:EE:FF"
    
    
    """

    def __init__(self, destmac, srcmac, ethertype, data):
        # for encoding
        if isinstance(destmac, str):
            self.destmac = macdecode(destmac)
        else:
            self.destmac = struct.pack("BBBBBB", destmac[0], destmac[1],
                                       destmac[2], destmac[3], destmac[4],
                                       destmac[5])

        if isinstance(srcmac, str):
            self.srcmac = macdecode(srcmac)
        else:
            self.srcmac = struct.pack("BBBBBB", srcmac[0], srcmac[1],
                                      srcmac[2], srcmac[3], srcmac[4],
                                      srcmac[5])
        
            
        self.ethertype = ethertype
        self.data = data


    def getWire(self, preamble=7, SFD=True):
        # returns a string containing the wire-representation of the
        # frame

        length = 6 + 6 + 2 + len(self.data) + 4

        
        frame = self.destmac + self.srcmac + \
                struct.pack("BB", self.ethertype / 256, self.ethertype % 256)+\
                self.data


        outdata = frame + generateFCS(frame)

        if SFD:
            outdata = '\xd5' + outdata

        for i in range(preamble):
            outdata = '\x55' + outdata; 


        return outdata
        

def intflip(x, width=32):
    """ return X with its MSB as its LSB and vice versa """

    out = 0
    for i in range(width):
        out = (out << 1) | (x & 0x01)
        x = x >> 1
    print hex(x), hex(out)
    return out

def generateFCS(data):
    """
    Generates the ethernet frame check sequence, by computing
    the CRCPOLY-based CRC and then inverting and putting the MSB first. 

    note that CRC 
    """

    fcscrc = crcmod.Crc(CRCPOLY, initCrc=~0L, rev=True, initialize=True)
    fcscrc.update(data)
        
    i = struct.unpack('i', fcscrc.digest())[0]
    invcrc = struct.pack('I', ~i)

    return invcrc[3] + invcrc[2] + invcrc[1] + invcrc[0]

def computeCRC(data):
    fcscrc = crcmod.Crc(CRCPOLY, initCrc=~0L, rev=True, initialize=True)
    fcscrc.update(data)
    i = struct.unpack('i', fcscrc.digest())[0]
    invcrc = struct.pack('I', intflip(i))

    return invcrc[3] + invcrc[2] + invcrc[1] + invcrc[0]

def main():
    testdata = "\x00\x00\x00"
    fcs = genFCS(testdata)
    
    
    print [hex(ord(x)) for x in computeCRC(testdata +fcs)]
    

if __name__ == "__main__":
    main()
