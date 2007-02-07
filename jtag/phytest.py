import events
import sys
m = events.Mask()
m.setAddr(5)
events.setMask(m)

# Dummy read of 0x01234567
a = events.Event()
a.cmd = 0x30
a.src = 0x07
a.setAddr(0x5)
a.data[0] = 0x00
a.data[1] = 0x03
a.data[2] = 0x00
a.data[3] = 0x00

events.sendEvent(a)
e = events.readEvent()
nonecnt = 0
while e == None:
    e = events.readEvent()
    nonecnt += 1
print e, nonecnt


# Dummy read of 0x89abcdef
a = events.Event()
a.cmd = 0x30
a.src = 0x07
a.setAddr(0x5)
a.data[0] = 0x00
a.data[1] = 0x03
a.data[2] = 0x00
a.data[3] = 0x00

events.sendEvent(a)
e = events.readEvent()
print e
e = events.readEvent()
print e

# bring phy out of reset
print "Bring the phy out of reset"

m = events.Mask()
m.setAddr(5)
events.setMask(m)

a = events.Event()
a.cmd = 0x30
a.src = 0x07
a.setAddr(0x5)
a.data[0] = 0x01
a.data[1] = 0x01
a.data[2] = 0x00
a.data[3] = 0x01

events.sendEvent(a)
e = events.readEvent()
print e
e = events.readEvent()
print e

# read the current phy base 0x0 register


# write the address 
print "write the address" 
a = events.Event()
a.cmd = 0x30
a.src = 0x07
a.setAddr(0x5)
a.data[0] = 0x01
a.data[1] = 0x08
a.data[2] = 0x00
a.data[3] = 0x00

events.sendEvent(a)
e = events.readEvent()
print e
e = events.readEvent()
print e

# read the addr reg to see if we're done
for i in range(5):
    print "read the addr reg to see if we're done" 
    a = events.Event()
    a.cmd = 0x30
    a.src = 0x07
    a.setAddr(0x5)
    a.data[0] = 0x00
    a.data[1] = 0x08
    a.data[2] = 0x00
    a.data[3] = 0x00

    events.sendEvent(a)
    e = events.readEvent()
    print e
    e = events.readEvent()
    print e

# read the actual value
print "read the actual value" 
a = events.Event()
a.cmd = 0x30
a.src = 0x07
a.setAddr(0x5)
a.data[0] = 0x00
a.data[1] = 0x0A
a.data[2] = 0x00
a.data[3] = 0x00

events.sendEvent(a)
e = events.readEvent()
print e
e = events.readEvent()
print e

# 

print "now, writing dout reg"
a = events.Event()
a.cmd = 0x30
a.src = 0x07
a.setAddr(0x5)
a.data[0] = 0x01
a.data[1] = 0x09
a.data[2] = 0x1140
a.data[3] = 0x1140

events.sendEvent(a)
e = events.readEvent()
print e
e = events.readEvent()
print e

print "now, read phydo reg"
a = events.Event()
a.cmd = 0x30
a.src = 0x07
a.setAddr(0x5)
a.data[0] = 0x00
a.data[1] = 0x09
a.data[2] = 0x0
a.data[3] = 0x0

events.sendEvent(a)
e = events.readEvent()
print e
e = events.readEvent()
print e


print "setting address bits"
a = events.Event()
a.cmd = 0x30
a.src = 0x07
a.setAddr(0x5)
a.data[0] = 0x01
a.data[1] = 0x08
a.data[2] = 0x00
a.data[3] = 0x20

events.sendEvent(a)
e = events.readEvent()
print e
e = events.readEvent()
print e





for i in range(5):
    print "read the addr reg to see if we're done" 
    a = events.Event()
    a.cmd = 0x30
    a.src = 0x07
    a.setAddr(0x5)
    a.data[0] = 0x00
    a.data[1] = 0x08
    a.data[2] = 0x00
    a.data[3] = 0x00

    events.sendEvent(a)
    e = events.readEvent()
    print e
    e = events.readEvent()
    print e


print "read the phy addr 0 back out: set the address bits" 
a = events.Event()
a.cmd = 0x30
a.src = 0x07
a.setAddr(0x5)
a.data[0] = 0x01
a.data[1] = 0x08
a.data[2] = 0x00
a.data[3] = 0x00

events.sendEvent(a)
e = events.readEvent()
print e
e = events.readEvent()
print e


for i in range(5):
    print "read the addr reg to see if we're done" 
    a = events.Event()
    a.cmd = 0x30
    a.src = 0x07
    a.setAddr(0x5)
    a.data[0] = 0x00
    a.data[1] = 0x08
    a.data[2] = 0x00
    a.data[3] = 0x00

    events.sendEvent(a)
    e = events.readEvent()
    print e
    e = events.readEvent()
    print e

print "read the actual value" 
a = events.Event()
a.cmd = 0x30
a.src = 0x07
a.setAddr(0x5)
a.data[0] = 0x00
a.data[1] = 0x0A
a.data[2] = 0x00
a.data[3] = 0x00

events.sendEvent(a)
e = events.readEvent()
print e
e = events.readEvent()
print e

