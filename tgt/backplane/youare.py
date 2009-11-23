"""
Force "YOU ARE" signal. 

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

def youare(devicenums):

    eio = NetEventIO("10.0.0.2")
    for d in devicenums:
        eio.addRXMask(xrange(256), int(d))

    eio.start()

    EVENTCMD_YOUARE = 0x01


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

    devicenums = sys.argv[1:]
    if len(devicenums) == 0:
        print "must specify target devices"
        sys.exit(1)


    youare(devicenums)
