#!/usr/bin/python
import numpy as n
from socket import *
import struct

def sendDataPacket(data):
    
    host = "192.168.0.1"
    port = 4400
    
    buf = 1024
    addr = (host,port)
    UDPSock = socket(AF_INET,SOCK_DGRAM)

    UDPSock.bind(("192.168.0.2", 40000))
    
      
    UDPSock.setsockopt(SOL_SOCKET, SO_BROADCAST, 1)   
    
    UDPSock.sendto(data,addr)


fid = file('dataprops.txt', 'w')

for i in range(1000):

    id = int(round(n.rand() * (2**32 - 1)))
    src = int(round(n.rand() * 63))
    typ = int(round(n.rand() * 3))

    data = struct.pack(">BBI",  typ, src,  id)
    
    fid.write("%2.2X %2.2X %8.8X \n" % (typ, src, id))

    sendDataPacket(data)

