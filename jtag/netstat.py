import events
import sys

NETCONTROLADDR = 0x04
JTAGADDR = 0x07

m = events.Mask()
m.setAddr(NETCONTROLADDR )
events.setMask(m)

def setMacAddr(addr):
    """
    Sets the mac address
    The address should be a list of bytes
    """
    
    a = events.Event()
    a.cmd = 0x42
    a.src = JTAGADDR
    a.setAddr(NETCONTROLADDR)
    a.data[0] = 0x03
    a.data[1] = addr[5] << 8 | addr[4]
    a.data[2] = addr[3] << 8 | addr[2]
    a.data[3] = addr[1] << 8 | addr[0]
    print a
    events.sendEvent(a)

def setIP(addrstr, bcast = False):
    ipaddr = addrstr.split(".")

    ip0 = int(ipaddr[0])
    ip1 = int(ipaddr[1])
    ip2 = int(ipaddr[2])
    ip3 = int(ipaddr[3])
    
    a = events.Event()
    a.cmd = 0x42
    a.src = JTAGADDR
    a.setAddr(NETCONTROLADDR)
    if bcast:
        a.data[0] = 0x02
    else:
        a.data[0] = 0x01
    a.data[1] = ip0 << 8 | ip1
    a.data[2] = ip2 << 8 | ip3
    events.sendEvent(a)
        

def getMacAddr() :
    a = events.Event()
    a.cmd = 0x43
    a.src = JTAGADDR
    a.setAddr(NETCONTROLADDR)
    a.data[0] = 0x03
    events.sendEvent(a)

    e = events.readEvent()
    nonecnt = 0
    while e == None:
        #events.sendEvent(a)
        e = events.readEvent()
        nonecnt += 1
    ma = [0, 0, 0, 0, 0, 0]

    lastEvt = None
    while e != None:
        lastEvt = e
        #events.sendEvent(a)
        e = events.readEvent()
        nonecnt += 1

    print e
    ma[5] = lastEvt.data[1] >> 8
    ma[4] = lastEvt.data[1] & 0xFF
    ma[3] = lastEvt.data[2] >> 8
    ma[2] = lastEvt.data[2] & 0xFF
    ma[1] = lastEvt.data[3] >> 8
    ma[0] = lastEvt.data[3] & 0xFF
    
    return ma

## Dummy read of 0x01234567

for i in range(0, 32):
    a = events.Event()
    a.cmd = 0x40
    a.src = JTAGADDR
    a.setAddr(NETCONTROLADDR)
    a.data[0] = i
    a.data[1] = 0x00
    a.data[2] = 0x00
    a.data[3] = 0x00

    events.sendEvent(a)
    e = events.readEvent()
    nonecnt = 0
    while e == None:
        #events.sendEvent(a)
        e = events.readEvent()
        nonecnt += 1
    print e, nonecnt

#print getMacAddr()
#print setMacAddr([7, 2, 3, 2, 5, 0x21])
#setIP("1.2.3.4")
#setIP("5.6.7.8", bcast=True)

#print getMacAddr()

