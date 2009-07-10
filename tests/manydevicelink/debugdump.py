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

# test
IR = "0x3E3"

USER1 = "0x3C2"
USER2 = "0x3C3"
USER3 = "0x3E2"
USER4 = "0x3E3"
if int(sys.argv[1]) == 4:
    IR = USER4
elif int(sys.argv[1]) == 3:
    IR = USER3
else:
    raise Exception("Must specify a valid user register")

jtagprog = "/home/jonas/XC3Sprog/xc3sprog"
jtagpos = 0

N = 1000
for addr in range(N + 1):
    addrl = addr & 0xFF
    addrh = (addr >> 8 ) & 0xFF
    dr = "%2.2X %2.2X" % (addrl,  addrh)
    
    args = [jtagprog, str(jtagpos), str(IR), str(dr)]
#    print args
    p = subprocess.Popen(args, stdout= subprocess.PIPE)
    x = p.stdout.read()
    bytes = x.split()
    if addr > 0:
        newaddr = addr - 1
        if (newaddr % 0x100 == 0):
            print
            print "%4.4X packet:" % newaddr
        
        print "%2.2X%2.2X" %  (int(bytes[1],16), 
                                int(bytes[0], 16)), 
        
        
