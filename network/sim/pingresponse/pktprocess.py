#!/usr/bin/python
"""
Code to take raw text-octect export from ethereal along with frame filenames
and packetize it into DIN/DOUT formats

We also recompute the ip header for each packet such that we can be
sure we're reflecting any modifications to the source file from the
original ethereal dump, such as changing the response/verification ID field

"""

import sys
import re


def computeIPHeader(octetlist):
    header = octetlist[14:14+20]
    x = 0
    for i in range(10):
        s = "%s%s" % (header[i*2],  header[i*2+1])
        a = int(s, 16)
        if i != 5:
            x += a
            print hex(a), hex(x) 
    y = ((x & 0xFFFF) + (x >> 16)) 
    return ( ~ y) & 0xFFFF

def updateIPHeader(octetlist):
    iphdr = hex(computeIPHeader(alloctets))

    if octetlist[12] == '08' and octetlist[13] == '00':
        csum = computeIPHeader(octetlist)
        o1 = "%2.2X" % (csum >> 8)
        o2 = "%2.2X" % (csum & 0xFF)
        octetlist[24] = o1
        octetlist[25] = o2
        print octetlist[14:14+20]
    else:
        pass



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



        print outfilename
        
        updateIPHeader(alloctets)
        framelen = len(alloctets)
        ofid.write("%4.4X\n" % (int(framelen) + 2))

        for i in range(framelen/2):
            ofid.write(alloctets[i*2] +  alloctets[i*2+1] + '\n' )

        if framelen % 2 == 1:
            ofid.write(alloctets[-1] + '00' + '\n')
            
        