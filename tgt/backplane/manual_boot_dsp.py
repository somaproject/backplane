"""

Manually boot some subset of the DSP FPGAs with the indicated bitfile

manual-boot-dsp.py bitfile.bit dspnum

Now also waits for devicelink status to be UP

"""
import sys
from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO

import struct
import time

# This is an awful hack: right now our config
# line settings are 0-19, but we have remapped
# the physical locations (pins) of the other devices
# on the board. So this is how we get around it.

device_to_config_mapping = { 0 : 0,
                             1 : 1,
                             2 : 6,
                             3 : 7}

def reallysend(eio, ea, ed):
    while True:
        try:
            eio.sendEvent(ea, ed)
            break
        except IOError:
            print "Whoa, we didn't hear the answer" 
            pass


def parse_linkstatus(e):
    return [(e.data[1] >> i) & 0x1 > 0 for i in range(16)]
    
def manual_boot_dsp(filename, devicenums):

    eio = NetEventIO("10.0.0.2")

    eio.addRXMask(xrange(256), eaddr.SYSCONTROL)

    eio.start()

    MANBOOTSER_SETMASK = 0xA0
    MANBOOTSER_TOGPROG = 0xA1
    MANBOOTSER_WRITEBYTES = 0xA2
    MANBOOTSER_SENDBYTES = 0xA3

    EVENTCMD_YOUARE = 0x01
    EVENTCMD_LINKSTATUS = 0x20
    

    e = Event()
    e.src = eaddr.NETWORK
    e.cmd =  MANBOOTSER_SETMASK

    wrd = 0
    int_devicenums = [int(x) for x in devicenums]
    for d in [device_to_config_mapping[x] for x in int_devicenums]:
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
            #print "The end" 
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

    # loop and query the linkstatus register to see if our links
    # are up yet, and once they are, go.

    up_delay = False
    allup = False
    for i in range(20):
        e = Event()
        e.cmd = EVENTCMD_LINKSTATUS
        e.src = eaddr.NETWORK
        ea = eaddr.TXDest()
        ea[eaddr.SYSCONTROL] = 1

        reallysend(eio, ea, e)

        erx =  eio.getEvents(False)
        device_status_event = None
        
        if erx != None:
            for e in erx:
                if e.cmd == EVENTCMD_LINKSTATUS:
                    device_status_event = e

        if device_status_event:
            stat = parse_linkstatus(device_status_event)
            allup = True
            for i in int_devicenums:
                if not stat[i]:
                    allup = False
        if allup:
            break
        up_delay += 1
        time.sleep(1)
        
    if not allup:
        print "Was unable to bring up the requested links"
        sys.exit(1)
    else:
        print "links up after", up_delay, "secs"
    
    #now send the YOUARE so the device knows who it is
    for i in devicenums:
        devicelinknum = int(i)

        for device in xrange(4):
             e = Event()
             e.cmd = EVENTCMD_YOUARE
             e.src = eaddr.NETWORK
             deviceid = 8  + devicelinknum * 4 + device
             
             e.data[0] = deviceid
             ea = eaddr.TXDest()
             ea[deviceid] = 1
             print "Sending youare for ", deviceid, e
             
             reallysend(eio, ea, e)                        


    eio.stop()

if __name__ == "__main__":

    filename = sys.argv[1]
    devicenums = sys.argv[2:]
    if len(devicenums) == 0:
        print "must specify target devices"
        sys.exit(1)

    manual_boot_dsp(filename, devicenums)
