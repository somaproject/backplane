#!/usr/bin/python
"""
Script to dump the USER registers that are currently
connected to the two dincapture interfaces. This is useful
for visualizing the time evolution of the state machine
and verifying what we are receiving on devicelink 0. 

"""
import os
import subprocess
import sys


def getbits(val, s, e):
    v1 = val >> s
    v2 = v1 % (1 << (e-s))

    return v2

def decode(addr, val):

    print "%08X" % val

# test
IR = "0x3E3"

USER1 = "0x3C2"
USER2 = "0x3C3"
USER3 = "0x3E2"
USER4 = "0x3E3"

IR = USER4

jtagprog = "/home/jonas/XC3Sprog/xc3sprog"
jtagpos = 0

BUFSIZE = 512
BUFCNT = 8


for addr in range(BUFSIZE*BUFCNT + 1):
    addrl = addr & 0xFF
    addrh = (addr >> 8 ) & 0xFF
    dr = "%2.2X %2.2X 00 80 00 00 00 00" % (addrl,  addrh) # 80 enables the reading
    
    args = [jtagprog, str(jtagpos), str(IR), str(dr)]
    #print args
#    print args
    p = subprocess.Popen(args, stdout= subprocess.PIPE)
    x = p.stdout.read()
    bytes = x.split()
    if addr > 0:
        newaddr = addr - 1
        if (newaddr % BUFSIZE == 0):
            print
            print "%4.4X packet:" % newaddr
        val = int(bytes[3],16) * (1 << 24) \
              + int(bytes[2], 16) * (1 << 16) \
              + int(bytes[1], 16) * (1 << 8) \
              + int(bytes[0], 16) 
        #print bytes
        decode(addr, val)
