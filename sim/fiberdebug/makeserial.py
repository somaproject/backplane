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

from scipy import *

fid = file('serialdata.dat', 'w')

for i in range(10000):
    if i % 25 == 0:
        fid.write('1 10111100\n');
    else :
        fid.write('0 %s\n' % binstr(i % 256));

    
