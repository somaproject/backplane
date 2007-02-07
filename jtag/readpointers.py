import events
m = events.Mask()
m.setAddr(5)
events.setMask(m)

def readreg(val):

    a = events.Event()
    a.cmd = 0x30
    a.src = 0x07
    a.setAddr(0x5)
    a.data[0] = 0x00
    a.data[1] = val
    a.data[2] = 0x00
    a.data[3] = 0x00

    events.sendEvent(a)
    e = None
    while e == None:
        e = events.readEvent()
        if e == None:
            events.sendEvent(a)
    return e


print "debug:"
print readreg(0)
print "pointers: "
print readreg(6)
print readreg(7)
print "status:"

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


