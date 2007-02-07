import events
import sys
m = events.Mask()
m.setAddr(4)
events.setMask(m)

## Dummy read of 0x01234567

for i in range(0, 32):
    a = events.Event()
    a.cmd = 0x40
    a.src = 0x07
    a.setAddr(0x4)
    a.data[0] = i
    a.data[1] = 0x00
    a.data[2] = 0x00
    a.data[3] = 0x00

    events.sendEvent(a)
    e = events.readEvent()
    nonecnt = 0
    while e == None:
        events.sendEvent(a)
        e = events.readEvent()
        nonecnt += 1
    print e, nonecnt
