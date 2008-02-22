"""
Manually boot some subset of the DSP FPGAs with the indicated bitfile

manual-boot-dsp.py dspnum bitfile.bit

"""
import sys
from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO

import struct
import time

dspnum = sys.argv[1]
filename = sys.argv[2]

eio = NetEventIO("10.0.0.2")

eio.addRXMask(xrange(256), eaddr.SYSCONTROL)

eio.start()

MANBOOTSER_SETMASK = 0xA0
MANBOOTSER_TOGPROG = 0xA1
MANBOOTSER_WRITEBYTES = 0xA2


# Create event and set mask
e = Event()
e.src = eaddr.NETWORK
e.cmd =  MANBOOTSER_SETMASK
e.data[0] = 0xFFFF
e.data[1] = 0xFFF0

ea = eaddr.TXDest()
ea[eaddr.SYSCONTROL] = 1
eio.sendEvent(ea, e)

# toggle FPROG
e.cmd =  MANBOOTSER_TOGPROG
eio.sendEvent(ea, e)

# send the actual data
fid = file(filename)
fid.seek(72)

data = fid.read(8)
pos = 0
ecnt = 0

sys.exit(1) ## DEBUGGING

while pos == 0:
    e.cmd = MANBOOTSER_WRITEBYTES
    e.src = eaddr.NETWORK
    ea = eaddr.TXDest()
    ea[eaddr.SYSCONTROL] = 1


    if len(data) < 8:
        print "The end" 
        data = data + "       "
    for i in xrange(4):
        e.data[i] = struct.unpack(">H", data[(i*2):(i*2+2)])[0]

    print "To send", e
    eio.sendEvent(ea, e)
    print "senddone" 
    if ecnt % 100 == 0:
        time.sleep(1)
    
    erx = eio.getEvents()
    for q in erx:
        print q
    
    data =fid.read(8)
    pos += 8

    ecnt  += 1
    
    print pos


eio.stop()

