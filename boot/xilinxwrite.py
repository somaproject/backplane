#!/usr/bin/python

import sys
import struct

def flipbits(x):
    """ given a byte, flips its bits such that the LSB is now the MSB """

    newbyte = 0

    x = struct.unpack('B', x)[0]
    
    
    for i in range(8):
        newbyte += ((x >> i) % 2) * 2**(7 - i)
    return struct.pack('B', newbyte)



#assert flipbits('\x01') == '\x80'
#assert flipbits('\x55') == '\xAA'
    
fid = file(sys.argv[1], 'rb')
fout = file(sys.argv[2], 'wb')

fid.seek(72)

for i in fid.read():
    #fout.write(flipbits(i))
    fout.write(i)
    
fid.close()
fout.close()
