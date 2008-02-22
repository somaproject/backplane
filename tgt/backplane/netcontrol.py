import sys
from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO

import struct


eio = NetEventIO("10.0.0.2")

eio.addRXMask(xrange(256), eaddr.NETCONTROL)

eio.start()

rxevents = []

for i in xrange(20):
    e = Event()
    e.src = eaddr.NETWORK
    e.cmd =  0x40
    e.data[0] = i
    
    ea = eaddr.TXDest()
    ea[eaddr.NETCONTROL] = 1
    print "about to send", e
    eio.sendEvent(ea, e)
    
    erx = eio.getEvents()
    rxevents +=  erx



eio.stop()

for e in rxevents:
    print e
