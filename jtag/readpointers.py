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
    return e


print "debug:"
print readreg(0)
print "pointers: "
print readreg(6)
print readreg(7)

for i in range(13, 18):
    print i, readreg(i)

