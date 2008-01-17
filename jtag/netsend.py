import events
import sys
m = events.Mask()
m.setAddr(4)
m.setAddr(40)
events.setMask(m)

# send

## a = events.Event()
## a.cmd = 0x41
## a.src = 0x07
## a.setAddr(0x4)
## a.data[0] = 0xFFFF
## a.data[1] = 0xFFFF
## a.data[2] = 0xFFFF
## a.data[3] = 0xFFFF
## a.data[4] = 0xFFFF


e = events.readEvent()
nonecnt = 0
while e == None:
    #events.sendEvent(a)
    e = events.readEvent()
    nonecnt += 1
print e, nonecnt
