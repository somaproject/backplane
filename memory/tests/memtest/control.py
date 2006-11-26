#!/usr/bin/python
"""
Takes the hacked-up output from our xc3sprog and extracts out an event

USER1 : 1111000010 0x3C2
USER2 : 1111000011 0x3C3
USER3 : 1111100010 0x3E2
USER4 : 1111100011 0x3C3

"""
import os
import sys
import time
import numpy as n
from numpy import random


USER1 = 0x3C2
USER2 = 0x3C3
USER3 = 0x3E2
USER4 = 0x3E3


def bytereverse(x):
    res = 0
    for i in range(8):
        # xtract 
        b = (x >> i) & 0x1
        res |= (b << (7-i))
    return res


xc3sprog = "~/XC3Sprog/xc3sprog"

def readbuffer(pos, rowtgt):
    
    performAction(pos, rowtgt, 'read')
    time.sleep(1)
    for i in range(512):

        cmdstr = xc3sprog + (' %d 0x%3.3X "%2.2X %2.2X 00 00 00 00 00 00"' % (pos, USER2, i & 0xFF, (i >> 8) & 0xFF))

        fid = os.popen(cmdstr)
        bytesstr = fid.read().split()
        bytes = [int(b, 16) for b in bytesstr]
        if i > 0: # because the first read doesn't return real values
            for b in bytes:
                print "%2.2X" % b, 
        print

            
def readDataBuffer(pos, rowtgt):
    """ Designed to extract out the releveant write
    commands and write into an appropriate numpy buffer and return said buffer
    for evaluation"""

    
    performAction(pos, rowtgt, 'read')
    dataout = n.zeros(256, dtype=n.uint32)
    time.sleep(1)
    for i in range(512):

        cmdstr = xc3sprog + (' %d 0x%3.3X "%2.2X %2.2X 00 00 00 00 00 00"' % (pos, USER2, i & 0xFF, (i >> 8) & 0xFF))

        fid = os.popen(cmdstr)
        bytesstr = fid.read().split()
        bytes = [int(b, 16) for b in bytesstr]
        
        if i > 0: # because the first read doesn't return real values
            if bytes[-1] == 0x80:
                
                # this is a write
                addr = bytes[5]
                data = bytes[0] | (bytes[1] << 8) | (bytes[2] << 16) | (bytes[3] << 24)
                dataout[addr] = data
    return dataout
            


def writeword(pos, addr, val):
    v1 = val & 0xFF
    v2 = (val >> 8)  & 0xFF
    v3 = (val >> 16) & 0xFF
    v4 = (val >> 24) & 0xFF

    cmdstr = xc3sprog + (' %d 0x%3.3X "%2.2X %2.2X %2.2X %2.2X %2.2X"' % (pos,
                                                                    USER3,
                                                                    addr,
                                                                    v1, v2,
                                                                    v3, v4))

    fid = os.popen(cmdstr)

def writeConstBuffer(pos, rowtgt, const):
    for i in range(256):
        writeword(pos, i, const)
    performAction(pos, rowtgt, 'write')
    
def writeSeqBuffer(pos, rowtgt):
    for i in range(256):
        a = (i*4) % 256
        b = (i*4 + 1) % 256
        c = (i*4 + 2) % 256
        d = (i*4 + 3) % 256
        writeword(pos, i, (d << 24) | (c << 16) | (b << 8) | a)
    performAction(pos, rowtgt, 'write')
    
    
def writeDataBuffer(pos, rowtgt, data):
    assert len(data) == 256
    
    for i in range(256):
        writeword(pos, i, data[i])
    performAction(pos, rowtgt, 'write')
    

def performAction(pos, rowtgt, action):
    r1 = rowtgt & 0xFF
    r2 = (rowtgt >> 8) & 0xFF
    
    if action == "read":
        cmdstr = xc3sprog + (' %d 0x%3.3X "%2.2X %2.2X 00 00 00"' % (pos,
                                                                     USER1,
                                                                     r1, r2))
        fid = os.popen(cmdstr)
    
    elif action == "write":
        cmdstr = xc3sprog + (' %d 0x%3.3X "%2.2X %2.2X 01 00 00"' % (pos,
                                                                     USER1,
                                                                     r1, r2))
        fid = os.popen(cmdstr)
    
    else:
        raise "invalid action"


def readStatus(pos):
    cmdstr = xc3sprog + (' %d 0x%3.3X "00 00 00 00 00"' % (pos, USER4))

    fid = os.popen(cmdstr)
    bytesstr = fid.read().split()
    bytes = [int(b, 16) for b in bytesstr]
    print " %2.2X%2.2X%2.2X%2.2X%2.2X" % (bytes[4], bytes[3], bytes[2],
                                          bytes[1], bytes[0])

def manwrite():
    row = random.randint(1000)
    
   
    print "Writing..."
    writeSeqBuffer(1, row)
    print "Write done. Waiting."
    time.sleep(1)
    print "Reading..."
    readbuffer(1, row)

def randwrite():
   datain = (n.random.rand(256) * 2**32).astype(n.uint32)
   row = random.randint(1000)
   writeDataBuffer(1, row, datain)
   dataout = readDataBuffer(1, row)
   for i in range(256):
       print "%3d : %8.8X %8.8X " % (i, datain[i], dataout[i])
       

print "getting status:"
readStatus(1)
manwrite()

