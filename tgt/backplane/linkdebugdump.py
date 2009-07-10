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
import pickle

def getbits(val, s, e):
    v1 = val >> s
    v2 = v1 % (1 << (e-s))

    return v2

def decode(addr, val):
    print "%8.8X" % val
    din = getbits(val, 0, 8)
    kin = getbits(val, 11, 12)
    ecycle = getbits(val, 15, 16)
    return ecycle, kin, din

def parsebuffer(vals):
    print "parsing ", len(vals), "values"
    cycles =[ getbits(v, 16, 18) for v in vals]
    breakpoint = 0
    for i in range(len(cycles)):
        if cycles[i] != cycles[i+1]:
            breakpoint = i
            break
    consec = vals[(breakpoint+1):] + vals[0:(breakpoint+1)]
    print "consec len=", len(consec)
    data = []
    for i, v in enumerate(consec):
        data.append(decode(i, v))

    return data

        
        
# test
IR = "0x3E3"

USER1 = "0x3C2"
USER2 = "0x3C3"
USER3 = "0x3E2"
USER4 = "0x3E3"

IR = USER4

jtagprog = "/home/jonas/XC3Sprog/xc3sprog"
jtagpos = 0

BUFSIZE = 1024
BUFCNT = 4

allbufs = []

datalist = []

for addr in range(BUFSIZE*BUFCNT + 1):
    addrl = addr & 0xFF
    addrh = (addr >> 8 ) & 0xFF
    dr = "%2.2X %2.2X 00 00 00 00 00 00" % (addrl,  addrh) # 80 enables the reading
    
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
            allbufs.append(datalist)
            datalist = []
        val = 0
        for b in bytes[::-1]:
            val = val * 256 + int(b, 16)
        datalist.append(val)
bufs = []
print len(allbufs)

for b in allbufs:
    bufs.append(parsebuffer(b))

pickle.dump(bufs, file('dump.pickle', 'w'))

