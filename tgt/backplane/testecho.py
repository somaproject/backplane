
import sys
sys.path.append("../")

from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO

eio = NetEventIO("10.0.0.2")

eio.addRXMask(xrange(256), eaddr.SYSCONTROL)

eio.start()

e = Event()
e.src = eaddr.NETWORK
e.cmd = 0xA2
ea = eaddr.TXDest()
ea[eaddr.SYSCONTROL] = 1
print e

eio.sendEvent(ea, e)
eio.sendEvent(ea, e)
eio.sendEvent(ea, e)
eio.sendEvent(ea, e)
rxevents = []
while len(rxevents) < 4:
    erx = eio.getEvents()
    rxevents += erx
    
print rxevents


eio.stop()

