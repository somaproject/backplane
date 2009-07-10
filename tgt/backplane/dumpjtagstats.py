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

def jtagtxnimm(wordout):
    dr = "00 00 00 00 %2.2X 00 00 00" % wordout
    args = [jtagprog, str(jtagpos), str(IR), str(dr)]
    p = subprocess.Popen(args, stdout= subprocess.PIPE)
    x = p.stdout.read()
    bytes = x.split()
    return [int(x, 16) for x in bytes]

for i in range(12):
    jtagtxnimm(i)
    bytes = jtagtxnimm(i)
    word =  bytes[7] * (1<<24) +\
           bytes[6] * (1<<16) + \
           bytes[5]*256 + bytes[4] 
    
    print i, "%8.8X" % word
    

    
