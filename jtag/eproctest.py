from events import * 

def echo_test():
    
    # this is a loopback test
    JTAGADDR = 0x07
    EPROCADDR = 0x01
    
    m = Mask()

    m.setAddr(EPROCADDR)

    setMask(m)

    
    a = Event()
    a.cmd = 128
    a.src = JTAGADDR
    a.setAddr(EPROCADDR)
    a.data[0] = 0xDEAD
    a.data[1] = 0x4567
    a.data[2] = 0x89AB
    a.data[3] = 0xCDEF
    a.data[4] = 0xAABB

    for i in range(4):
        a.data[0] = i
        sendEvent(a)

    reads = 0 
    e = None
    while e == None:
        e = readEvent()
        reads += 1
        
    while e != None:
        print e, reads
        e = readEvent()
    

echo_test()
