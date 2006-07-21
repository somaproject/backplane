#!/usr/bin/python
import numpy as n
from socket import *
import struct

N = 80


class DataPacketGen(object):
    """ Returns a randomly-generated data packet """
    
    def __init__(self):
        self.ids = n.zeros((4, 2**6), dtype=n.uint32)

    def generatePacket(self):
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
            data[i+6] = (i+typ+src) % 256

        return (typ, src, id, data)
    
        
        
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


    
if __name__ == "__main__":

    # first we generate a bit list of data packets

    outfid = file('dataprops.txt', 'w')
    
    dpg = DataPacketGen()
    datapackets = []
    N = 1000
    for i in range(N):
        (typ, src, id, data) = dpg.generatePacket()
        datapackets.append(data)
        outfid.write("%2.2X %2.2X %8.8X \n" % (typ, src, id))
        
    # write them in the event cycles:

    for dp in datapackets:
        sendDataPacket(dp)
