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

def reallysend(eio, ea, ed):
    while True:
        try:
            eio.sendEvent(ea, ed)
            break
        except IOError:
            print "Whoa, we didn't hear the answer" 
            pass

def manual_boot_dsp(filename, devicenums):

    eio = NetEventIO("10.0.0.2")

    eio.addRXMask(xrange(256), eaddr.SYSCONTROL)

    eio.start()

    MANBOOTSER_SETMASK = 0xA0
    MANBOOTSER_TOGPROG = 0xA1
    MANBOOTSER_WRITEBYTES = 0xA2
    MANBOOTSER_SENDBYTES = 0xA3

    EVENTCMD_YOUARE = 0x01


    e = Event()
    e.src = eaddr.NETWORK
    e.cmd =  MANBOOTSER_SETMASK

    wrd = 0
    for d in [int(x) for x in devicenums]:
        wrd |= (1 << (d + 4))
    #print "word = %8.8X" % wrd

    # FIXME: 
    e.data[0] = wrd >> 16 
    e.data[1] = wrd & 0xFFFF

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

        reallysend(eio, ea, e)

        # now push the bytes to the client device
        e.cmd = MANBOOTSER_SENDBYTES
        e.src = eaddr.NETWORK
        ea = eaddr.TXDest()
        ea[eaddr.SYSCONTROL] = 1

        reallysend(eio, ea, e)

        erx = eio.getEvents()


        data =fid.read(8)
        pos += 8

        ecnt  += 1


    time.sleep(8) # superfluous sleep to allow for boot up, since acquiring
     # link now takes 4-6 seconds

    #now send the YOUARE so the device knows who it is
    for i in devicenums:
        devicelinknum = int(i)

        for device in xrange(4):
             e.cmd = EVENTCMD_YOUARE
             e.src = eaddr.NETWORK
             deviceid = 8  + devicelinknum * 4 + device
             #print "Sending youare for ", deviceid
             e.data[0] = deviceid
             ea = eaddr.TXDest()
             ea[deviceid] = 1
             eio.sendEvent(ea, e)


    eio.stop()

if __name__ == "__main__":

    filename = sys.argv[1]
    devicenums = sys.argv[2:]
    if len(devicenums) == 0:
        print "must specify target devices"
        sys.exit(1)

    manual_boot_dsp(filename, devicenums)
