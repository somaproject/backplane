"""

There are four device types that we can boot at the moment. There are
19 possible device links total:

DSPboards: 16 possible, 0-15. Map to boot lines 4-19.
ADIO : boot line 3
SYS  :
NEP  : 


The step for each class of device is basically as follows:
1. Configure the DL FPGA
2. wait for the DL to be up by reading the status register
3. send the relevant YOU-ARE commands.

"""
import sys
from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO

import struct
import time
from optparse import OptionParser

import os.path

device_to_config_bits = {16 : 3,
                         17 : 2,
                         18 : 1}
for i in range(16):
    device_to_config_bits[i] = i + 4

def reallysend(eio, ea, ed):
    while True:
        try:
            eio.sendEvent(ea, ed)
            break
        except IOError:
            print "Whoa, we didn't hear the answer" 
            pass


def parse_linkstatus(e):
    ls =  [(e.data[1] >> i) & 0x1 > 0 for i in range(16)]
    for i in range(4):
        ls.append((e.data[0] >> i & 0x1))
    return ls

def manual_boot_dsp(filename, dspnums):
    devicenums = [x for x in dspnums]

    youares = []
    for d in devicenums:
        for i in range(4):
            youares.append( d* 4 + i + 8)
            
    manual_boot_device(filename, devicenums, youares)

def manual_boot_adio(filename):
    devicenums = [16]
    youares = [0x49, 0x4a, 0x4b]
    
    manual_boot_device(filename, devicenums, youares)

    
def manual_boot_device(filename, devicenums, youares):
    """
    Devicenums are the device link nums. Note that they do not
    map directly onto the configuration bit lines
    """

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
    #int_devicenums = [int(x) for x in devicenums]
    for d in devicenums: # [device_to_config_mapping[x] for x in int_devicenums]:
        cfg_line = device_to_config_bits[d]
        wrd |= (1 << cfg_line)
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
            for i in devicenums:
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
    for deviceid in youares:
             e = Event()
             e.cmd = EVENTCMD_YOUARE
             e.src = eaddr.NETWORK
             
             e.data[0] = deviceid
             ea = eaddr.TXDest()
             ea[deviceid] = 1
             print "Sending youare for ", deviceid, e
             
             reallysend(eio, ea, e)                        


    eio.stop()

if __name__ == "__main__":
    print "NOTE THE FORMAT OF THE BOOT COMMAND HAS CHANGED"

    parser = OptionParser()
    parser.add_option("-f", "--file", dest="bitfile",
                     help = "Bitfile to boot")

    parser.add_option("-t", "--target", dest="target",
                      choices=['dsp', 'adio'], 
                      help = "name of target we're booting (dsp, adio)")

    (options, args) = parser.parse_args()

    if not options.bitfile:
        raise Exception("Must specify filename")
        
    if not os.path.isfile(options.bitfile):
        raise Exception("%s not found" % options.bitfile)
    
    if options.target == 'adio':
        manual_boot_adio(options.bitfile)
    elif options.target == 'dsp':
        if len(args) == 0:
            raise Exception("Must specify _which_ dsps to boot (0-15)")

        devicenums = [int(x) for x in args]
        manual_boot_dsp(options.bitfile, devicenums)
