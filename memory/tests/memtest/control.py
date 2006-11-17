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
        writeword(pos, i, 0xFFFF0000 + i)
    performAction(pos, rowtgt, 'write')
    
    
def writebuffer(pos, rowtgt):
    for i in range(256):
        writeword(pos, i, i + i*2**16)
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

print "getting status:"
readStatus(1)

print "Writing..."
writeSeqBuffer(1, 8)
print "Write done. Waiting."
time.sleep(1)
print "Reading..."
readbuffer(1, 8)
