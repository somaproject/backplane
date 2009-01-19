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

filename = sys.argv[1]
devicenums = sys.argv[2:]
if len(devicenums) == 0:
    print "must specify target devices"
    sys.exit(1)
eio = NetEventIO("10.0.0.2")

eio.addRXMask(xrange(256), eaddr.SYSCONTROL)

eio.start()

MANBOOTSER_SETMASK = 0xA0
MANBOOTSER_TOGPROG = 0xA1
MANBOOTSER_WRITEBYTES = 0xA2
EVENTCMD_YOUARE = 0x01


e = Event()
e.src = eaddr.NETWORK
e.cmd =  MANBOOTSER_SETMASK
# FIXME: 
e.data[0] = 0xFFFF # right now we just boot everyone
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

while data:
    e.cmd = MANBOOTSER_WRITEBYTES
    e.src = eaddr.NETWORK
    ea = eaddr.TXDest()
    ea[eaddr.SYSCONTROL] = 1


    if len(data) < 8:
        print "The end" 
        data = data + "       "
    for i in xrange(4):
        e.data[i] = struct.unpack(">H", data[(i*2):(i*2+2)])[0]

    #print "To send", e
    eio.sendEvent(ea, e)
    #print "senddone" 

    
    erx = eio.getEvents()
    #for q in erx:
    #    print q
    
    data =fid.read(8)
    pos += 8

    ecnt  += 1

    print "pos = ", pos, ecnt


time.sleep(1) # superfluous sleep to allow for boot up

#now send the YOUARE so the device knows who it is
for i in devicenums:
    devicelinknum = int(i)
    
    for device in xrange(4):
         e.cmd = EVENTCMD_YOUARE
         e.src = eaddr.NETWORK
         deviceid = 8  + devicelinknum * 4 + device
         print "Sending youare for ", deviceid
         e.data[0] = deviceid
         ea = eaddr.TXDest()
         ea[deviceid] = 1
         eio.sendEvent(ea, e)


eio.stop()

