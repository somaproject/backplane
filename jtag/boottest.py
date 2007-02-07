import events
m = events.Mask()
m.setAddr(3)
events.setMask(m)

# Dummy read of 0x01234567
a = events.Event()
a.cmd = 0x20
a.src = 0x01
a.setAddr(0x2)
a.data[0] = 0xFFFF
a.data[1] = 0xFFFF
a.data[2] = 0x0110
a.data[3] = 0x0800

events.sendEvent(a)
