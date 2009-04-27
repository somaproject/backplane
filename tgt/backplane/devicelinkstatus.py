
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
linkstatus_event = erx[0]

# now get all of the counter events

rx_set = {}
for i in range(20):
    e = Event()
    e.src = src
    e.cmd = 0x21
    e.data[0] = i

    ea = eaddr.TXDest()
    ea[eaddr.SYSCONTROL] = 1
    eio.sendEvent(ea, e)

    erx = eio.getEvents()
    rx_set[i] = erx

    
eio.stop()
for i in range(20):
    if (linkstatus_event.data[1] >> i) & 0x1 > 0:
        print "Device %2d : UP" % i, 
    else:
        print "Device %2d :   " % i,
    print "%d link cycles"  % rx_set[i][0].data[2]



