#!/usr/bin/python

import os

# test
IR = "0x3E3"


jtagprog = "/home/jonas/XC3Sprog/xc3sprog"
jtagpos = 1

N = 2000
for addr in range(N + 1):
    addrl = addr & 0xFF
    addrh = (addr >> 8 ) & 0xFF
    dr = "%2.2X %2.2X" % (addrl,  addrh)
    

    (ofid, ifid) = os.popen2([jtagprog, str(jtagpos), str(IR), str(dr)])
    x = ifid.read()
    bytes = x.split()
    if addr > 0:
        newaddr = addr - 1
        if (newaddr % 0x100 == 0):
            print
            print "%4.4X packet:" % newaddr
        
        print "%2.2X %2.2X" %  (int(bytes[1],16), 
                                int(bytes[0], 16)), 
        
        
