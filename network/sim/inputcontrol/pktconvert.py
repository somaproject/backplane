#!/usr/bin/python
import sys
sys.path.append('../../crc/code')
import frame

"""
Take a packet from the thingie and generate .crc and .crcerror packets
"""

filename = sys.argv[1]
fid = file(filename)

# read in as a string
lenword = fid.readline()
l = int(lenword, 16)
print l

data = ""
for i in range((l+1)/2 ):
    dw = fid.readline()
    data += chr(int(dw[:2], 16))
    data += chr(int(dw[2:], 16))

if l % 2 == 1:
    data = data[:-1]

crc = frame.generateFCS(data)

totaldata = data + crc

# write valid packet
fid = file(filename + ".crc", 'w')
fid.write("%4.4X\n" % len(totaldata))

outdata = totaldata + '\x00'
for i in range(len(totaldata) / 2):
    fid.write("%2.2X%2.2X\n" % (ord(outdata[2*i]), ord(outdata[2*i+1])))

# write corrupt packet
fid = file(filename + ".crcerror", 'w')
fid.write("%4.4X\n" % len(totaldata))

outdata = totaldata + '\x00'
outdata = outdata[:7] + '\x27' +  outdata[8:]

for i in range(len(totaldata) / 2):
    fid.write("%2.2X%2.2X\n" % (ord(outdata[2*i]), ord(outdata[2*i+1])))

