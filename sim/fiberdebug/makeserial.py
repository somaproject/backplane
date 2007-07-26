#!/usr/bin/python

"""
Generate serial data for unit test
"""

def binstr(x):
    """ returns an 8-bit str of x in binary"""
    xs = binary_repr(x)

    outstr = xs;
    for i in range(8 - len(xs)):
        outstr = '0' +  outstr
    return outstr

class writeAcq(object):
    def __init__(self):
        self.cmdid = 0
        self.cmdsts = 0
        self.pktpos = 0

    def sendPacket(self, fid):
        fid.write('1 10111100\n');
        fid.write('0 %s\n' % binstr(self.cmdsts));
        # now the data
        for i in range(10):
            datah = (i + self.pktpos) >> 8
            datal = (i + self.pktpos) & 0xFF
            fid.write('0 %s\n' % binstr(datah))
            fid.write('0 %s\n' % binstr(datal))
        fid.write('0 %s\n' % binstr(self.cmdid))
        fid.write('0 00000000\n')
        fid.write('0 00000000\n')
    
        self.pktpos = (self.pktpos + 0x1000) % 2**16
        
        
        
        
from scipy import *

fid = file('serialdata.dat', 'w')

acq = writeAcq()

for i in range(10):
    acq.cmdid = i
    acq.pktpos = 0
    for j in range(10):
        acq.sendPacket(fid)
    
    
