#!/usr/bin/python
"""
Code to take raw text-octect export from ethereal along with frame filenames
and packetize it into DIN/DOUT formats

"""

import sys
import re


filename = sys.argv[1]

fid = open(filename)

while True:
    

    f = fid.readline()
    if f == "":
        break
    
    if f.strip() != "":
        outfilename = f.strip()
        ofid = file(outfilename, 'w')
        l = fid.readline()

        alloctets = []
        while (l.strip() != ""):
            bytestr = l[6:53]
            octetsraw = bytestr.split(' ')
            octets = [x for x in octetsraw if x != '']
            alloctets += octets

    
            l = fid.readline()


        framelen = len(alloctets)
        ofid.write("%4.4X\n" % (int(framelen) + 2))

        for i in range(framelen/2):
            ofid.write(alloctets[i*2] +  alloctets[i*2+1] + '\n' )

        if framelen % 2 == 1:
            ofid.write(alloctets[-1] + '00' + '\n')
            
        
