#!/usr/bin/python
import sys
import socket
import numpy as n
import time
import struct
import threading

"""

Tests if the event RX and eventTX infrastructure is working by sending
an event and trying to receive it. Also checks for proper RX of event
set packets by checking for sequence id agreement.


"""

EVENTTXPORT =5000
SOMAIP = "10.0.0.2"
EVENTRXPORT = 5100

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
    def __str__(self):
        return "cmd=%d src=%d data = %4.4X %4.4X %4.4X %4.4X %4.4X" % (self.cmd, self.src, self.data[0], self.data[1], self.data[2], self.data[3], self.data[4])

class TXEvent:
    def __init__(self):
        self.cmd = 0
        self.src = 0
        self.data =  n.zeros(5, dtype=n.uint16)
        self.addr = n.zeros(80, dtype=n.bool)

    def toBytes(self):
        """
        return self as a 32-byte string, for transmission

        """
        # convert addresses to 16-bit words
        addrwords = []
        for i in range(5):
            resword = 0 
            for j in range(15, -1, -1):
                if self.addr[i*16 + j]:
                    resword |= 1
                resword = resword << 1
            addrwords.append(resword >> 1)
        addrstr = struct.pack("!HHHHH", addrwords[0],
                              addrwords[1], addrwords[2],
                              addrwords[3], addrwords[4])
        
        eventstr = struct.pack("!BBHHHHH", self.cmd, self.src,
                    self.data[0], self.data[1],
                    self.data[2], self.data[3], self.data[4])

        padstr = struct.pack(">HHHHH", 0, 0, 0, 0, 0)
        return addrstr + eventstr + padstr

    
def sendEvents(TXEventList):
    """
    We take in a list of TX events, format them, and send them

    """

    nonce = n.random.randint(2**15)

    hdrstr = struct.pack(">HH", nonce, len(TXEventList))
    estr = ""
    for e in TXEventList:
        estr = estr + e.toBytes()
    packet = hdrstr + estr
    
    addr = (SOMAIP, EVENTRXPORT)

    UDPSock = socket.socket(socket.AF_INET,
                            socket.SOCK_DGRAM)
    
    UDPSock.sendto(packet, addr)
    data,addr = UDPSock.recvfrom(4)
    (rxnonce, rxsuccess) = struct.unpack("!HH", data)

    assert rxnonce == nonce

def assertContinuous(EventSetPacketList):
    seq = EventSetPacketList[0][0]
    

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



def computeEventStats(EventSetPackets):
    """
    Take in a list of EventSetPackets and
    return statistics on the contained events

    """

    cmddict = {}
    lastval = None

    seqErrCnt = 0

    for es in EventSetPackets:
        if lastval != None:
            if lastval != es[0] -1:
                seqErrCnt += 1
        lastval = es[0]

        for evtset in es[1]:
            for evt in evtset:
                if evt.cmd in cmddict:
                    cmddict[evt.cmd] += 1
                else:
                    cmddict[evt.cmd] = 1
    print "sequence errors:" , seqErrCnt
    
    for k, v in cmddict.iteritems():
        print k, v
        
                
def getEventsFromSetPackets(EventSetPackets):
    events = []
    for esp in EventSetPackets:
        for e in esp[1]:
            events.extend(e[:])

    return events        
    
class ReceiveEvents(threading.Thread):

    def run(self):

        host = ""
        port = 5000
        buflen = 1500
        addr = (host,port)

        UDPSock = socket.socket(socket.AF_INET,
                                socket.SOCK_DGRAM)


        UDPSock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, True)
        UDPSock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        UDPSock.bind(addr)
        datacnt = 50000
        data = []
        print "Acquiring events..." 
        for i in xrange(datacnt):
            databuf,addr = UDPSock.recvfrom(buflen)
            data.append(databuf)
        print "done"
        self.data = data
        
    def process(self):

        EventSetPackets = []
        for i in xrange(len(self.data)):
            EventSetPackets.append(decodeEvents(self.data[i]))

        return EventSetPackets
        
def sendLoopBack():

    # send command event 200 to all devices, to try and RX it
    txloop = TXEvent()
    
    txloop.cmd = 200
    txloop.src = 40
    txloop.data[0] = 0x0123
    txloop.data[1] = 0x4567
    txloop.data[2] = 0x89AB
    txloop.data[3] = 0xCDEF
    txloop.data[4] = 0xAABB
    
    txloop.addr[3] = True

    sendEvents([txloop])
    
if __name__ == "__main__":

    if sys.argv[1] == "client":
        sendLoopBack()
    else:

        rethread = ReceiveEvents()
        rethread.start()
        time.sleep(0.4)
        sendLoopBack()
        time.sleep(0.4)

        rethread.join()

        eventsetpackets = rethread.process()
        assertContinuous(eventsetpackets)
        computeEventStats(eventsetpackets)
        # extract out the events

        events = getEventsFromSetPackets(eventsetpackets)
        present = False
        # look for the event
        for e in events:
            if e.cmd == 200 and e.src == 40:
                if e.data[0] == 0x0123 and e.data[1] == 0x4567 and \
                   e.data[2] == 0x89AB and e.data[3] == 0xCDEF and \
                   e.data[4] == 0xAABB :
                    present = True
        assert present
            
