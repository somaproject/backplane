#!/usr/bin/python
import sys
from socket import *
import struct

MYPORT=5000

def decodeEvent(buffer):
    pos = 4
    # get sequence number
    seqidstr = buffer[0:4]
    seqid = struct.unpack(">I", seqidstr)[0]
    print seqid
    # now event sets:
    while pos < len(buffer):
        evtlenstr = buffer[pos:pos+2]
        pos += 2

        evtlen = struct.unpack(">H", evtlenstr)[0]
        print "evtlen = " , evtlen
        for i in range(evtlen):
            pos += 12
    
    
if sys.argv[1] == "server":
    s = socket(AF_INET, SOCK_DGRAM)
    #s.bind(('', 0))
    s.setsockopt(SOL_SOCKET, SO_BROADCAST, 1)
    data = "testing", 
    s.sendto("testing", ('<broadcast>', 6000))
    
    
elif sys.argv[1] == "client":
    host = ""
    port = 5000
    buf = 1500
    addr = (host,port)

    UDPSock = socket(AF_INET,SOCK_DGRAM)


    UDPSock.setsockopt(SOL_SOCKET, SO_BROADCAST, True)
    UDPSock.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
    UDPSock.bind(addr)
    data,addr = UDPSock.recvfrom(buf)
    print len(data)
    decodeEvent(data)
    
