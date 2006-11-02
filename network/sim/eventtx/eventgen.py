#!/usr/bin/python
import numpy as n
from socket import *
import struct

N = 80

class EventCycle(object):
    def __init__(self):
        self.addr = n.zeros(80, int)
        self.data = n.zeros((N, 6), n.uint16)

    def count(self):
        s = 0
        for i in self.addr:
            if i:
                s += 1
        return s
    
    def write(self, fid):
        for i in self.addr:
            fid.write("%d" % i)
        fid.write('\n')

        for i in range(N):
            for j in range(6):
                fid.write("%4.4X " % self.data[i][j])

        fid.write('\n')
        
        


def sendEventList(el):
    host = "192.168.0.255"
    port = 5000
    buf = 1024
    addr = (host,port)
    UDPSock = socket(AF_INET,SOCK_DGRAM)

    UDPSock.bind(("192.168.0.2", 40000))
    
      
    UDPSock.setsockopt(SOL_SOCKET, SO_BROADCAST, 1)   


    eccnt = 0

    
    id = 0
    data = "" 

    sendcount = 0
    
    for ec in el:
        s = ec.count()

        datalen = len(data)
        framelen = 6 + 6 + 2 + 2
        iplen = 20
        udplen = 8
        idlen = 4 
        maxpktspace = 1024 - (framelen + iplen + udplen + idlen)
        
        print "datalen =", datalen, "ec.count*16=", s*16, " remaining =", maxpktspace - (s * 16 + len(data))
        
        if (datalen > 0 and (maxpktspace - (s*16 + len(data) ) < 0)) or eccnt == 5:
            
            ostr = struct.pack(">i",  id) + data
            
            UDPSock.sendto(ostr,addr)
            sendcount += 1
            
            totaltxsize =  len(ostr) + framelen + iplen + udplen
            assert totaltxsize < 1024
            
            id += 1 

            eccnt = 0
            data = ""
            
        outstr = ""
        for k in range(len(ec.addr)):
            if ec.addr[k] > 0:
                s = struct.pack(">HHHHHH",  ec.data[k][0],ec.data[k][1],
                                ec.data[k][2],ec.data[k][3],
                                ec.data[k][4],ec.data[k][5] )
                outstr += s
        l = ec.addr.sum()
        data += struct.pack(">H", l) + outstr

        eccnt += 1
        

    print "There were",  sendcount, " packets sent" 
    
if __name__ == "__main__":


    es = []
    # three times:
    for i in range(3) :
        # single event and then four empty ones, to trigger a write

        a = EventCycle()
        a.addr[0] = 1
        a.data[0][0] = 0x1234
        a.data[0][1] = 0x0102
        a.data[0][2] = 0x0304
        a.data[0][3] = 0x0506

        es.append(a)


        b = EventCycle()  # empty
        es.append(b)
        es.append(b)
        es.append(b)
        es.append(b)

    # now generate a big event cycle with the full range of events
    a = EventCycle()

    for i in range(78):
        a.addr[i] = 1

        a.data[i][0] = (i << 8) + i
        a.data[i][1] = i + 1
        a.data[i][2] = i + 2
        a.data[i][3] = i + 3
        a.data[i][4] = i + 4
        a.data[i][5] = i + 5
    es.append(a)
    

    # now generate random event cycles
    
    for j in range(100):
        a = EventCycle()
        size = n.random.rand() 
        for i in range(78):
            if n.random.rand() > size:
                a.addr[i] = 1 

                a.data[i][0] = int(n.random.rand()* 2**16)
                a.data[i][1] = int(n.random.rand()* 2**16)
                a.data[i][2] = int(n.random.rand()* 2**16)
                a.data[i][3] = int(n.random.rand()* 2**16)
                a.data[i][4] = int(n.random.rand()* 2**16)
                a.data[i][5] = int(n.random.rand()* 2**16)
        es.append(a)

    
    fid = file('events.txt', 'w')
    for e in es:
        e.write(fid)
    sendEventList(es)

