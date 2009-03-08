"""
memdebug: debug our memory interface

"""

import sys
from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO
sys.path.append("../../jtag")
import jtag
import time
import numpy as np

src = 0
ECMD_READ =  0x55
ECMD_WRITE = 0x54

# commands
class memdebug:
    debugreg = 0
    reset = 1
    memready = 2
    rowtgt = 3
    addr = 4
    bufferwr = 5
    ifsel = 7
    bufferrd = 9
    memrd = 12
    memwr = 13
    nonce = 14
    
def mysrc():
    return src

def reallysend(eio, ea, e):
    while True:
        try:
            eio.sendEvent(ea, e)
            break
        except IOError:
            print "reallysend retransmitting"
            pass

def setBufferAddress(eio, addr):
    """
    assumes EIO is running, receiving correct masks

    """
    e = Event()
    e.src = mysrc()
    e.cmd = ECMD_WRITE

    e.data[0] = memdebug.addr
    e.data[1] = addr
    ea = eaddr.TXDest()
    ea[eaddr.NETCONTROL] = 1
    reallysend(eio, ea, e)

def getBufferAddress(eio):
    e = Event()
    e.src = mysrc()
    e.cmd = ECMD_READ

    e.data[0] = memdebug.addr
    e.data[1] = 0
    ea = eaddr.TXDest()
    ea[eaddr.NETCONTROL] = 1
    reallysend(eio, ea, e)
    erx = eio.getEvents()
    return erx[0].data[1]

def readwritedebug(eio):
    e = Event()
    e.src = mysrc()
    e.cmd = ECMD_WRITE

    e.data[0] = memdebug.debugreg
    e.data[1] = 0x1122
    e.data[2] = 0x0000

    ea = eaddr.TXDest()
    ea[eaddr.NETCONTROL] = 1
    reallysend(eio, ea, e)

    e = Event()
    e.src = mysrc()
    e.cmd = ECMD_READ

    e.data[0] = memdebug.debugreg
    e.data[1] = 0
    e.data[2] = 0
    e.data[3] = 0
    e.data[4] = 0

    ea = eaddr.TXDest()
    ea[eaddr.NETCONTROL] = 1

    reallysend(eio, ea, e)

    erx = eio.getEvents()
    cntevt = erx[0]
    print cntevt

def resetramIF(eio):
    eio.addRXMask(xrange(256), eaddr.NETCONTROL)

    eio.start()

    # select debug interface
    e = Event()
    e.src = src
    e.cmd =  ECMD_WRITE

    e.data[0] = memdebug.ifsel
    e.data[1] = 0x0001

    ea = eaddr.TXDest()
    ea[eaddr.NETCONTROL] = 1
    reallysend(eio, ea, e)

    # then assert reset
    e = Event()
    e.src = src
    e.cmd =  ECMD_WRITE

    e.data[0] = memdebug.reset
    e.data[1] = 0x0001

    ea = eaddr.TXDest()
    ea[eaddr.NETCONTROL] = 1

    #then deassert reset

    time.sleep(1)
    e = Event()
    e.src = src
    e.cmd =  ECMD_WRITE

    e.data[0] = memdebug.reset
    e.data[1] = 0x0000

    ea = eaddr.TXDest()
    ea[eaddr.NETCONTROL] = 1
    reallysend(eio, ea, e)

def debug_dump_read(eio):
    """
    read each reg and dump the value there
    
    """
    for regi in range(16):
        e = Event()
        e.src = src
        e.cmd =  ECMD_READ
        
        e.data[0] = regi
        e.data[1] = 0
    
        ea = eaddr.TXDest()
        ea[eaddr.NETCONTROL] = 1
        reallysend(eio, ea, e)
        
        erx = eio.getEvents()
        assert erx[0].cmd == ECMD_READ
        print erx[0]
        d = erx[0].data[1]

def grabMemIF(eio):
    # select debug interface
    e = Event()
    e.src = src
    e.cmd =  ECMD_WRITE

    e.data[0] = memdebug.ifsel
    e.data[1] = 0x0001

    ea = eaddr.TXDest()
    ea[eaddr.NETCONTROL] = 1
    reallysend(eio, ea, e)


        
def word_write(eio, addr, data):
    setBufferAddress(eio, addr)
    a = getBufferAddress(eio)
    if addr != a :
        raise Exception("error on address readback, addr= %4.4X, read address %4.4X" % (addr, a))
    
    
    # write the word
    e = Event()
    e.src = src
    e.cmd =  ECMD_WRITE
    
    e.data[0] = memdebug.bufferwr
    e.data[1] = data
    ea = eaddr.TXDest()
    ea[eaddr.NETCONTROL] = 1
    reallysend(eio, ea, e)

def word_read(eio, addr):
    setBufferAddress(eio, addr)
    a = getBufferAddress(eio)
    assert addr == a

    # write the wordg
    e = Event()
    e.src = src
    e.cmd =  ECMD_READ
    
    e.data[0] = memdebug.bufferrd
    e.data[1] = addr
    
    ea = eaddr.TXDest()
    ea[eaddr.NETCONTROL] = 1
    reallysend(eio, ea, e)
    
    erx = eio.getEvents()
    assert erx[0].cmd == ECMD_READ
    d = erx[0].data[1]
    d2 = erx[0].data[2]
    return d

def bufferRead(eio, N=2**9):
    """
    Read the memdebug buffer and return the result as a
    numpy array
    """
    buf = np.zeros(N, dtype = np.uint16)
    
    for addr in range(N):
        a1 = word_read(eio, addr)
        buf[addr] = a1
            
    return buf

        
def bufferWrite(eio, data):
    """
    Write the memdebug buffer with data
    """
    for i, d in enumerate(data):
        time.sleep(0.01)
        word_write(eio, i, d)
        r =  word_read(eio, i)

def test_address(eio):
    errors = 0
    for  ain in range(200, 300):
        #ain = np.random.randint(0, 2**10)
        setBufferAddress(eio, ain)
        a = getBufferAddress(eio)
        print "sent %4.4X, read %4.4X" % (ain, a)
        if a != ain:
            errors += 1
            print "ERROR"
    print "errors: ", errors
    
def test_buffer_read_write(eio):
    """
    Write a buffer, and do a read-back
    """
    
    x = np.arange(0, 2**4, dtype=np.uint16)
    x = x * 46 +  0x100
    print "beginning buffer write" 
    bufferWrite(eio, x)
    print "end buffer write"
    print "beginning buffer read" 
    newx = bufferRead(eio)
    print "end buffer read"
    totalerrors = 0
    for i, d in enumerate(newx):
        print "%2d : %4.4X" % (i, d), 
        if d != x[i]:
            mismatch = True
            print "ERROR"
            totalerrors += 1
        else:
            mismatch = False
            print
    
    print "total errors:", totalerrors

def set_rowtgt_address(eio, addr):
    e = Event()
    e.src = mysrc()
    e.cmd = ECMD_WRITE

    e.data[0] = memdebug.rowtgt
    e.data[1] = addr
    ea = eaddr.TXDest()
    ea[eaddr.NETCONTROL] = 1
    reallysend(eio, ea, e)

    
    e = Event()
    e.src = mysrc()
    e.cmd = ECMD_READ

    e.data[0] = memdebug.rowtgt
    e.data[1] = 0
    ea = eaddr.TXDest()
    ea[eaddr.NETCONTROL] = 1
    reallysend(eio, ea, e)
    
    erx = eio.getEvents()
    assert addr == erx[0].data[1]

def read_memready(eio):
    e = Event()
    e.src = mysrc()
    e.cmd = ECMD_READ

    e.data[0] = memdebug.memready
    ea = eaddr.TXDest()
    ea[eaddr.NETCONTROL] = 1
    reallysend(eio, ea, e)

    e = eio.getEvents()
    print e[0].data[1]

def execute_txn(eio, type):
    nonce = np.random.randint(0, 2**16)

    e = Event()
    e.src = mysrc()
    e.cmd = ECMD_WRITE

    e.data[0] = type
    e.data[1] = nonce
    ea = eaddr.TXDest()
    ea[eaddr.NETCONTROL] = 1
    reallysend(eio, ea, e)

    # now loop until done!
    noncerx = None
    while noncerx  != nonce:
        noncerx = getnonce(eio)
        print "not done yet %4.4X != %4.4X" %( nonce, noncerx)
    print "Done"

def execute_read_txn(eio):
    return execute_txn(eio, memdebug.memrd)

def execute_write_txn(eio):
    return execute_txn(eio, memdebug.memwr)

def getnonce(eio):

    e = Event()
    e.src = mysrc()
    e.cmd = ECMD_READ

    e.data[0] = memdebug.nonce
    ea = eaddr.TXDest()
    ea[eaddr.NETCONTROL] = 1
    reallysend(eio, ea, e)

    es = eio.getEvents()
    e = es[0]
    return e.data[1]

def dumptest(eio):
    grabMemIF(eio)
    set_rowtgt_address(eio, 0x10)
    N = 2**9
    x = np.arange(0, N, dtype=np.uint16)
    x = x + 0x1205
    z = np.zeros(N, dtype=np.uint16)
    print "writing buffer" 
    bufferWrite(eio, x)
    print "beginning write transaction"
    execute_write_txn(eio)
    print "zeroing buffer"
    bufferWrite(eio, z)
    print "beginning read transaction"
    execute_read_txn(eio)
    print "reading buffer" 
    b = bufferRead(eio, N)
    print "the buffer"
    print "IN      OUT     DELTA"
    errors = 0
    for i in range(N):
        delta = x[i % N] ^ b[i]
        print "%4.4X  %4.4X   %4.4X " % (x[i % N], b[i], delta)
        if delta != 0:
            errors += 1
    print "total errors: %d"  % errors
    

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "jtag":
        eio = jtag.JTAGEventIO()
        src = eaddr.JTAG
    else:
        eio = NetEventIO("10.0.0.2")
        src = eaddr.NETWORK

    #eio.addRXMask(ECMD_READ, eaddr.NETCONTROL)
    eio.addRXMask(xrange(256), eaddr.NETCONTROL)

    eio.start()
    
    #smalltest(eio)
    #randtest(eio)
    #debug_dump_read(eio)
    #readwritedebug(eio)
    #resetramIF(eio)
    #grabMemIF(eio)
    #set_rowtgt_address(eio, 0x000)
    #test_address(eio)
    #test_buffer_read_write(eio)
    #test2()
    #read_memready(eio)
    dumptest(eio)
    eio.stop()
