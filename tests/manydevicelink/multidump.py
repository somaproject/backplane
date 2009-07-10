#!/usr/bin/python
"""
Script to dump the USER registers that are currently
connected to the two dincapture interfaces. This is useful
for visualizing the time evolution of the state machine
and verifying what we are receiving on devicelink 0. 

Unlike debugdump.py, this dumps multiple dincapture's out side-by-side


"""
import os
import subprocess
import sys

# test
IR = "0x3E3"

jtagprog = "/home/jonas/XC3Sprog/xc3sprog"
jtagpos = 0


USER1 = "0x3C2"
USER2 = "0x3C3"
USER3 = "0x3E2"
USER4 = "0x3E3"
REGS = {1 : USER1, 
        2 : USER2, 
        3 : USER3, 
        4 : USER4}

tgtregs = [3, 4]

regdata = {}

for reg in tgtregs:
    IR = REGS[reg]
    regdata[reg] = []

    N = 1024
    currentbuffer = []
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
                if newaddr != 0:
                    regdata[reg].append(currentbuffer)
                currentbuffer = []
            currentbuffer.append(int(bytes[1], 16) * 256 +  int(bytes[0], 16)) 
    regdata[reg].append(currentbuffer)

print len(regdata)
for i in range(4):
    print "Buffer %d" % i
    for j in range(256):
        print "%04d " % j, 
        for k, v in regdata.iteritems():
            print "%4.4X " % v[i][j],
        print
            
        
