from events import * 
import time    

JTAGADDR = 0x07
BOOTSTOREADDR = 0x03


def handle_test():
    """
    Get the file handle
    """
    
    m = Mask()
    m.setAddr(BOOTSTOREADDR)
    setMask(m)

    
    a = Event()
    a.cmd = 0x90
    a.src = JTAGADDR
    a.setAddr(BOOTSTOREADDR)
    a.data[0] = 0x0000
    a.data[1] = 0x0000
    a.data[2] = 0x0000
    a.data[3] = 0x0000
    a.data[4] = 0x0000

    sendEvent(a)

    reads = 0 
    e = None
    while e == None:
        e = readEvent()
        reads += 1
    handle = e.data[1]
    print e
    print "The handle is ", handle

    return handle

def handle_yield(handle):
    """
    Yield the file handle
    """
    
    m = Mask()
    m.setAddr(BOOTSTOREADDR)
    setMask(m)

    
    a = Event()
    a.cmd = 0x94
    a.src = JTAGADDR
    a.setAddr(BOOTSTOREADDR)
    a.data[0] = handle << 8
    a.data[1] = 0x0000
    a.data[2] = 0x0000
    a.data[3] = 0x0000
    a.data[4] = 0x0000

    sendEvent(a)

    reads = 0 

def openfile_test(handle):
    m = Mask()
    m.setAddr(BOOTSTOREADDR)
    setMask(m)

    
    a = Event()
    a.cmd = 0x92
    a.src = JTAGADDR
    a.setAddr(BOOTSTOREADDR)
    a.data[0] = handle << 8
    a.data[1] = 0x0000
    a.data[2] = 0x0000
    a.data[3] = 0x0000
    a.data[4] = 0x0000

    sendEvent(a)

    reads = 0 
    e = None
    while e == None:
        e = readEvent()
        reads += 1
    print "Opening file"
    while e != None:
        print e, reads
        e = readEvent()

def send_filename(handle, filename):
    """
    send the filename
    """

    txfilename = ""
    for i in range(32):
        if len(filename) > i:
            txfilename += filename[i]
        else:
            txfilename += "\000"
    print filename

    for i in range(4):
        m = Mask()
        m.setAddr(BOOTSTOREADDR)
        setMask(m)
        
        
        a = Event()
        a.cmd = 0x91
        a.src = JTAGADDR
        a.setAddr(BOOTSTOREADDR)
        a.data[0] = (handle << 8) | i*8
        a.data[1] = (ord(txfilename[i*8 + 0]) << 8) | (ord(txfilename[i*8 + 1]))
        a.data[2] = (ord(txfilename[i*8 + 2]) << 8) | (ord(txfilename[i*8 + 3]))
        a.data[3] = (ord(txfilename[i*8 + 4]) << 8) | (ord(txfilename[i*8 + 5]))
        a.data[4] = (ord(txfilename[i*8 + 6]) << 8) | (ord(txfilename[i*8 + 7]))
        print "sending", a
        sendEvent(a)
        
    reads = 0 


def readfile_test(handle):
    m = Mask()
    m.setAddr(BOOTSTOREADDR)
    setMask(m)

    
    a = Event()
    a.cmd = 0x93
    a.src = JTAGADDR
    a.setAddr(BOOTSTOREADDR)
    a.data[0] = handle << 8
    a.data[1] = 0x0000
    a.data[2] = 0x0000
    a.data[3] = 0x0000
    a.data[4] = 0x0040

    sendEvent(a)

    reads = 0 
    e = None
    while e == None:
        e = readEvent()
        reads += 1
    print "readfile event outputs:"
    while e != None:
        print e, reads
        e = readEvent()

    
handle = handle_test()
send_filename(handle, "blink.bit")
openfile_test(handle)
readfile_test(handle)
handle_yield(handle)

    
