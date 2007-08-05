#!/usr/bin/python
import sys
from socket import *
import numpy as n
import struct

MYPORT=5000
    
class Event:
    def __init__(self):
        self.cmd  = 0
        self.src = 0
        self.data = n.zeros(5, dtype=n.uint16)
    def __init__(self, str):
        assert len(str) == 12
        res = struct.unpack(">BBHHHHH", str)
        self.cmd = res[0]
        self.src = res[1]
        self.data = n.zeros(5, dtype=n.uint16)
        
        self.data[0] = res[2]
        self.data[1] = res[3]
        self.data[2] = res[4]
        self.data[3] = res[5]
        self.data[4] = res[6]

def assertContinuous(EventSetPacketList):
    seq = EventSetPacketList[0][0]
    
    for j, e in enumerate(EventSetPacketList[1:]):
        assert e[0] == seq + 1
        seq = e[0]
    

def decodeEvents(buffer):
    """ Decode an event packet"""
    pos = 4
    # get sequence number
    seqidstr = buffer[0:4]
    seqid = struct.unpack(">I", seqidstr)[0]

    # now event sets:
    EventSets = []
    while pos < len(buffer):
        evtsetlenstr = buffer[pos:pos+2]
        pos += 2

        evtsetlen = struct.unpack(">H", evtsetlenstr)[0]
        EventSet = []
        for i in range(evtsetlen):
            # get the events
            event = Event(buffer[pos:pos+12])
            EventSet.append(event)
            pos +=12
        EventSets.append(EventSet)
    return (seqid, EventSets)


if __name__ == "__main__":
    host = ""
    port = 5000
    buflen = 1500
    addr = (host,port)

    UDPSock = socket(AF_INET,SOCK_DGRAM)


    UDPSock.setsockopt(SOL_SOCKET, SO_BROADCAST, True)
    UDPSock.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
    UDPSock.bind(addr)
    datacnt = 10000
    data = []
    
    for i in xrange(datacnt):
        databuf,addr = UDPSock.recvfrom(buflen)
        data.append(databuf)

    EventSetPackets = []
    for i in xrange(datacnt):
        EventSetPackets.append(decodeEvents(data[i]))

        
    assertContinuous( EventSetPackets)
    
