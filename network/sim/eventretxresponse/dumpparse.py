#!/usr/bin/python
import numpy as n
import sys
sys.path.append('../../crc/code')
import frame


def computeIPHeader(octetlist):
    header = octetlist[14:14+20]
    x = 0
    for i in range(10):
        s = "%2.2X%2.2X" % (header[i*2],  header[i*2+1])
        a = int(s, 16)
        if i != 5:
            x += a
            #print hex(a), hex(x) 
    y = ((x & 0xFFFF) + (x >> 16)) 
    return ( ~ y) & 0xFFFF

def updateIPHeader(octetlist):
    iphdr = hex(computeIPHeader(octetlist))
    if octetlist[12] == 8 and octetlist[13] == 0:
        csum = computeIPHeader(octetlist)
        octetlist[24] =(csum >> 8)
        octetlist[25] =(csum & 0xFF) 

    else:
        pass



fid = file('data.tcpdump')


l = fid.readline()
inpkt = False
pktstr = "" 

pktstrs = []
while l != "":
    # blah
    l = fid.readline()
    if l[:2] == "IP":
        if len(pktstr) > 0:
            pktstrs.append( pktstr)
            
        pktstr = "" 
    else:
        pktstr += l[10:-1]

if len(pktstr) > 0:
    pktstrs.append( pktstr)
    pktstr = "" 

ofile = file('data.txt', 'w')

# segment packet strings into lists of bytes
for s in pktstrs:

    bytestr = ''.join(s.split(' '))
    N = len(bytestr)
    da = n.zeros(N/2, n.uint8)

    for i in range(N/2):
        wordstr = bytestr[i*2:(i+1)*2]
        #print wordstr, len(wordstr), i, N, N/4
        da[i] = int(wordstr, 16)
        
                      
    # now we have the output packets in numerical form; perform the update
    # of the ip sequence and then the relevant header checksum update
    
    dastr = "".join([chr(x) for x in da])
    crc = frame.generateFCS(dastr)
    da = n.resize(da, len(da)+4)
    da[-4] = ord(crc[0])
    da[-3] = ord(crc[1])
    da[-2] = ord(crc[2])
    da[-1] = ord(crc[3])
    
    # now we print our normal format
    ofile.write("%d " % (len(da)/2 + 1))
    ofile.write("%4.4X " % len(da))

    for i in range(len(da) / 2):
        ofile.write("%2.2X%2.2X " % (da[i*2], da[i*2+1]))
    ofile.write('\n')
    
        
