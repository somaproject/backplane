
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

DEVN = 4
rx_set = {}
for i in range(DEVN):
    e = Event()
    e.src = src
    e.cmd = 0x21
    e.data[0] = i

    ea = eaddr.TXDest()
    ea[eaddr.SYSCONTROL] = 1
    eio.sendEvent(ea, e)

    erx = eio.getEvents()
    for e in erx:
        print i, e
        
    rx_set[i] = erx

# now get the debug counters
e = Event()
e.src = src
e.cmd = 0x22
ea = eaddr.TXDest()
ea[eaddr.SYSCONTROL] = 1
eio.sendEvent(ea, e)

erx = eio.getEvents()
for e in erx:
    debug_event = erx[0]

# decode the debug event
delays = {}
delays[0] = debug_event.data[0]
delays[1] = debug_event.data[1]
delays[6] = debug_event.data[2]
delays[7] = debug_event.data[3]
    
eio.stop()
print debug_event

for i in range(DEVN):
    dly = (-1, -1)
    if i in delays:
        dly = (delays[i] >> 8, delays[1] & 0xFF)
        
    if (linkstatus_event.data[1] >> i) & 0x1 > 0:
        print "Device %2d : UP" % i, 
    else:
        print "Device %2d :   " % i,
    print "%d link cycles"  % (rx_set[i][0].data[2] )
    



