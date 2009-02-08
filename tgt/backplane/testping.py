
import sys
sys.path.append("../")

from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO

eio = NetEventIO("10.0.0.2")

ECMD_PINGREQ = 0x08
ECMD_PINGRESP = 0x09
eio.addRXMask(ECMD_PINGRESP, eaddr.SYSCONTROL)

eio.start()

e = Event()
e.src = eaddr.NETWORK
e.cmd = ECMD_PINGREQ
ea = eaddr.TXDest()
ea[eaddr.SYSCONTROL] = 1
print "sending request", e

eio.sendEvent(ea, e)
eio.sendEvent(ea, e)
eio.sendEvent(ea, e)
eio.sendEvent(ea, e)
rxevents = []
while len(rxevents) < 4:
    erx = eio.getEvents()
    rxevents += erx
print "responses"

for e in  rxevents:
    print e


eio.stop()

