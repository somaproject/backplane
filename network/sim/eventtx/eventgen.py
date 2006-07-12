#!/usr/bin/python
import numpy as n
from socket import *
import struct

N = 80

class EventCycle(object):
    def __init__(self):
        self.addr = n.zeros(80)
        self.data = n.zeros((N, 6), n.uint16)

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

    for ec in el:
        outstr = ""
        for k in range(len(ec.addr)):
            if ec.addr[k] > 0:
                s = struct.pack(">HHHHHH",  ec.data[k][0],ec.data[k][1],
                                ec.data[k][2],ec.data[k][3],
                                ec.data[k][4],ec.data[k][5] )
                outstr += s
        
    l = ec.addr.sum()
    data = struct.pack(">H", l) + outstr
    UDPSock.sendto(data,addr)

if __name__ == "__main__":

    es = []
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
    

    fid = file('test.txt', 'w')
    for e in es:
        e.write(fid)
    sendEventList(es)
