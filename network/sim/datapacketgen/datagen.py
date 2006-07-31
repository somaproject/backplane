#!/usr/bin/python
import numpy as n
from socket import *
import struct

N = 80


class DataPacketGen(object):
    """ Returns a randomly-generated data packet """
    
    def __init__(self):
        self.ids = n.zeros((4, 2**6), dtype=n.uint32)

    def generatePacket(self, N = 0):
        if N == 0:
            N = int(round(n.rand()*290)*2) # max length is two 
        src = int(round(n.rand() * (2**6-1)))
        typ = int(round(n.rand() * (2**2-1)))
        
        id = self.ids[typ, src]
        
        self.ids[typ, src] = self.ids[typ, src] + 1
        
        
        data = n.zeros(N+6, dtype=n.uint8)

        data[0] = (id >> 24) & 0xFF
        data[1] = (id >> 16) & 0xFF
        data[2] = (id >> 8) & 0xFF
        data[3] = (id) & 0xFF
        data[4] = typ
        data[5] = src

        # random data
        for i in range(N):
            data[i+6] = int(n.rand() * 255)

        return (src, typ, data)
    
        
        
def sendDataPacket(dp):
    
    host = "192.168.0.255"
    port = 4000
    port += dp[4]*64 + dp[5]
    
    buf = 1024
    addr = (host,port)
    UDPSock = socket(AF_INET,SOCK_DGRAM)

    UDPSock.bind(("192.168.0.2", 40000))
    
      
    UDPSock.setsockopt(SOL_SOCKET, SO_BROADCAST, 1)   

    data = ""
    for i in dp:
        data += struct.pack("B", i)
        
    
    UDPSock.sendto(data,addr)


def writePacket(fid, packet):
    """ randomly writes the packet at some random location inside
    of the event cycle and fills in the other cycles.

    We use an offset of 4 to strip off the calculated ids.
    
    """
    os = 4
    
    N = len(packet)-os
    M = 980
    startrange = M - N
    p = int(n.rand()*startrange)

    s = 1000 - N - p
    
    for i in range(p):
        fid.write("0 00\n")

    for i in packet[os:]:
        fid.write("1 %2.2X\n" % i)

    for i in range(s):
        fid.write("0 00\n")

    
def writeEmpty(fid):
    for i in range(1000):
        fid.write("0 00\n")
    
    
if __name__ == "__main__":

    # first we generate a bit list of data packets

    dpg = DataPacketGen()
    datapackets = []
    N = 1000
    propsfid = file('dataprops.txt', 'w')
    
    for i in range(1, 5):
        (src, typ, data) = dpg.generatePacket(N=i*2)
        propsfid.write("%d %d %d\n" % (src, typ, len(data)) ) 
        datapackets.append(data)
    
    for i in range(N):
        (src, typ, data) = dpg.generatePacket()
        propsfid.write("%d %d %d\n" % (src, typ, len(data)) ) 

        datapackets.append(data)

    pktcnt = len(datapackets)

        
    # write them in the event cycles:

    pos = 0

    fida = file('dataa.txt', 'w')
    fidb = file('datab.txt', 'w')
    
    while pos < pktcnt:
        # flip two coins, for tx on A and B;
        asend = n.rand() > 0.2
        if asend :
            writePacket(fida, datapackets[pos])
            pos += 1
        else:
            writeEmpty(fida)

        bsend = n.rand() > 0.2

        if pos != pktcnt:
            if bsend :
                writePacket(fidb, datapackets[pos])
                pos += 1
            else:
                writeEmpty(fidb)

    for dp in datapackets:
        sendDataPacket(dp)
