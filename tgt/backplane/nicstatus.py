"""

This is a port from the jtag debug 'readpointers.py'

"""

import sys
from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO
sys.path.append("../../jtag")
import jtag

if len(sys.argv) > 1 and sys.argv[1] == "jtag":
    eio = jtag.JTAGEventIO()
    src = eaddr.JTAG
else:
    eio = NetEventIO("10.0.0.2")
    src = eaddr.NETWORK


eio.addRXMask(xrange(256), eaddr.NETCONTROL)

eio.start()

def readreg(val):
    e = Event()
    e.src = src
    e.cmd =  0x30
    
    e.data[0] = 0
    e.data[1] = val
    e.data[2] = 0
    e.data[3] = 0

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
    return "%4.4X %4.4X" % (cntevt.data[1], cntevt.data[2])

print "debug word:"
print readreg(0)
print "pointers: "
print readreg(6)
print readreg(7)
print "status:----------------------------------"

pname = {}
pname[0x0e] = "RXMEMCRCERR"
pname[0x0f] = "TXIOCRCERR"
pname[0x10] = "TXMEMCRCERR"
pname[0x11] = "TXF"
pname[0x12] = "RXF"
pname[0x13] = "TXFIFOWERR"
pname[0x14] = "RXFIFOWERR"
pname[0x15] = "RXPHYERR"
pname[0x16] = "RXOFERR"
pname[0x17] = "RXCRCERR"
pname[0x00] = "NOP (0x01234567)"
pname[0x01] = "RESET PHY"
pname[0x02] = "PHYSTATUS"
pname[0x03] = "NOP (0x89ABCDEF)"
pname[0x04] = "??"
pname[0x05] = "??"
pname[0x06] = "RX BP / FBBP"
pname[0x07] = "TX BP / FBBP"
pname[0x08] = "PHYADR"
pname[0x09] = "PHYDI"
pname[0x0A] = "PHYDO"





for i in range(0x0, 0x19):
    s = ""
    if i in pname:
        s = pname[i]
        
    print "%2.2X %15.15s %s" % (i, s, readreg(i))


