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


def toByteList(s):
    bytestr = ''.join(s.split(' '))
    N = len(bytestr)
    da = n.zeros(N/2, n.uint8)

    for i in range(N/2):
        wordstr = bytestr[i*2:(i+1)*2]
        #print wordstr, len(wordstr), i, N, N/4
        da[i] = int(wordstr, 16)

    return da

def writePacketsToFile(pktlist, ofile,
                       update = True, fcsappend = False):
    """ take a list of packet bytes
    and writes them to the indicated file """

    
    # segment packet strings into lists of bytes
    for da in pktlist:


        # now we have the output packets in numerical form; perform the update
        # of the ip sequence and then the relevant header checksum update

        if update:
            da[19] = 0
            da[20] = 0

            # zero udp chksum
            da[40] = 0
            da[41] = 0

        updateIPHeader(da)
        
        # generate fcs
        if fcsappend:
            dastr = "".join([chr(x) for x in da])
            crc = frame.generateFCS(dastr)
            da = n.resize(da, len(da)+4)
            da[-4] = ord(crc[0])
            da[-3] = ord(crc[1])
            da[-2] = ord(crc[2])
            da[-1] = ord(crc[3])
        
        
        # now we print our normal format
        ofile.write("%d " % (len(da)/2 + 1))
        ofile.write("%4.4X " % (len(da)))

        for i in range(len(da) / 2):
            ofile.write("%2.2X%2.2X " % (da[i*2], da[i*2+1]))
        ofile.write('\n')




fid = file('data.tcpdump')


l = fid.readline()
inpkt = False
pktstr = "" 

pktstrs = []
bytelist = []
while l != "":
    # blah
    l = fid.readline()
    if l[:2] == "IP":
        if len(pktstr) > 0:
            pktstrs.append( pktstr)
            bytelist.append(toByteList(pktstr))
        pktstr = "" 
    else:
        pktstr += l[10:-1]

bytelist.append(toByteList(pktstr))


# filter out the TX from the RX by port
os = 14 + 20
PORT = 5100

clientreq = [pl for pl in bytelist if pl[os+2] == (PORT / 256) and pl[os+3] ==  (PORT % 256)]

servresp = [pl for pl in bytelist if pl[os] == (PORT / 256) and pl[os+1] == (PORT % 256)]

writePacketsToFile(clientreq, file("client_requests.txt", 'w'),
                   update=False, fcsappend = True)
writePacketsToFile(servresp, file("server_response.txt", 'w'), update=True)


#writePacketsToFile(pktstrs, file('data.txt', 'w'))
