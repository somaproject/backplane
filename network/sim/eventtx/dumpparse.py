#!/usr/bin/python
import numpy as n


def computeIPHeader(octetlist):
    header = octetlist[14:14+20]
    x = 0
    for i in range(10):
        s = "%s%s" % (header[i*2],  header[i*2+1])
        a = int(s, 16)
        if i != 5:
            x += a
            #print hex(a), hex(x) 
    y = ((x & 0xFFFF) + (x >> 16)) 
    return ( ~ y) & 0xFFFF

def updateIPHeader(octetlist):
    iphdr = hex(computeIPHeader(octetlist))

    if octetlist[12] == '08' and octetlist[13] == '00':
        csum = computeIPHeader(octetlist)
        o1 = "%2.2X" % (csum >> 8)
        o2 = "%2.2X" % (csum & 0xFF)
        octetlist[24] = o1
        octetlist[25] = o2
        #print octetlist[14:14+20]
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

    da[19] = 0
    da[20] = 0


    
    updateIPHeader(da)
    
    # now we print our normal format

    ofile.write("%4.4X " % len(da))

    for i in range(len(da) / 2):
        ofile.write("%2.2X%2.2X " % (da[i*2], da[i*2+1]))
    ofile.write('\n')
    
        
