
import sys
sys.path.append("../")
sys.path.append("../../jtag")

import time
from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO
import jtag

if sys.argv[1] == "jtag":
    eio = jtag.JTAGEventIO()
    src = eaddr.JTAG
else:
    eio = NetEventIO("10.0.0.2")
    src = eaddr.NETWORK

eio.addRXMask(xrange(256), eaddr.SYSCONTROL)

eio.start()

e = Event()
e.src = src
e.cmd = 0x20
ea = eaddr.TXDest()
ea[eaddr.SYSCONTROL] = 1

eio.sendEvent(ea, e)

erx = eio.getEvents()
print erx[0]

eio.stop()

