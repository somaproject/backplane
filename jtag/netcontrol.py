import events
import sys

NETCONTROLADDR = 4 
m = events.Mask()
m.setAddr(NETCONTROLADDR + 1)
events.setMask(m)

# Dummy read of 0x01234567
a = events.Event()
a.cmd = 0x31
a.src = 0x07
a.setAddr(NETCONTROLADDR)
a.data[0] = 0x00
a.data[1] = 0x00
a.data[2] = 0x00
a.data[3] = 0x00

events.sendEvent(a)

e = events.readEvent()
nonecnt = 0
while e == None:
    e = events.readEvent()
    nonecnt += 1
print e, nonecnt


