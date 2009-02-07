"""
Talk to the NetControl EProc and extract out transmit and
error counters


"""

import sys
from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO
import struct


def getnum(evt):
    """
    Turns an event into a number

    """

    num = 0
    num = evt.data[1]
    num = num << 16
    num |= evt.data[2]
    num = num << 16
    num |= evt.data[3]
    return num

eio = NetEventIO("10.0.0.2")

eio.addRXMask(xrange(256), eaddr.NETCONTROL)

eio.start()

rxevents = []

TXCOUNTERS = {}
TXCOUNTERS[0] = "EVENT TX"
TXCOUNTERS[1] = "DATA TX"
TXCOUNTERS[2] = "DATA RETX"
TXCOUNTERS[3] = "EVENT RETX"
TXCOUNTERS[4] = "EVENT RX"
TXCOUNTERS[5] = "ARP     "
TXCOUNTERS[6] = "ICMP     "

ERRORCNT = {}
ERRORCNT[0] = "RXIOCRCERROR"
ERRORCNT[1] = "UNKNOWN ETHER"
ERRORCNT[2] = "UNKNOWN IP"
ERRORCNT[3] = "UNKNOWN ARP"
ERRORCNT[4] = "UNKNOWN UDP"

print
print "Event counters---------------------------------------"
for i in xrange(7):
    # first query the count
    e = Event()
    e.src = eaddr.NETWORK
    e.cmd =  0x40
    e.data[0] = i*2+1
    
    ea = eaddr.TXDest()
    ea[eaddr.NETCONTROL] = 1
    while True:
        try:
            eio.sendEvent(ea, e)
            break
        except IOError:
            pass
    
    erx = eio.getEvents()
    cntevt = erx[0]

    #then get the legnt
    e = Event()
    e.src = eaddr.NETWORK
    e.cmd =  0x40
    e.data[0] = i*2
    
    ea = eaddr.TXDest()
    ea[eaddr.NETCONTROL] = 1
    while True:
        try:
            eio.sendEvent(ea, e)
            break
        except IOError:
            pass
    
    erx = eio.getEvents()
    lenevt = erx[0]
    print "%s \t%10d packets \t%10d bytes (%f MB) " % (TXCOUNTERS[i], getnum(cntevt), getnum(lenevt), getnum(lenevt)/1e6)
print

print "Network error Counters ----------------------------------"
for i in xrange(5):
    e = Event()
    e.src = eaddr.NETWORK
    e.cmd =  0x40
    e.data[0] = i + 0x10
    
    ea = eaddr.TXDest()
    ea[eaddr.NETCONTROL] = 1
    while True:
        try:
            eio.sendEvent(ea, e)
            break
        except IOError:
            pass
    
    
    erx = eio.getEvents()
    cntevt = erx[0]
    print "%s \t %10d packets" % (ERRORCNT[i], getnum(cntevt))

    

eio.stop()

for e in rxevents:
    print e
