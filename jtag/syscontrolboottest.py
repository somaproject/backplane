import events
import sys
import struct

"""
This is a simple attempt to test if we can boot
a device FPGA via the bootserialperipheral interface
on the SysControl EProc

"""


SYSCONTROLADDR = 0x01
JTAGADDR = 0x07

def toggleProg():
    """
    Toggle EPROG
    """

    maskevtlow = events.Event()
    maskevtlow.cmd = 100
    maskevtlow.src = JTAGADDR
    maskevtlow.setAddr(SYSCONTROLADDR)
    maskevtlow.data[0] = 0xFFFF
    maskevtlow.data[1] = 0xFFFF
    events.sendEvent(maskevtlow)
    
    a = events.Event()
    a.cmd = 102
    a.src = JTAGADDR
    a.setAddr(SYSCONTROLADDR)
    a.data[0] = 0xFF

    events.sendEvent(a)

def sendDataWords(data):
    """
    Sends  4 16-bit data words to be placed in the TX
    buffer

    data[0] becomes event[0]
        
    """
    
    a = events.Event()
    a.cmd = 101
    a.src = JTAGADDR
    a.setAddr(SYSCONTROLADDR)
    for i, d in enumerate(data):
        a.data[i] = d
    events.sendEvent(a)


def commitData():
    """
    Commits the current data buffer
    """

    a = events.Event()
    a.cmd = 103
    a.src = JTAGADDR
    a.setAddr(SYSCONTROLADDR)
    events.sendEvent(a)

def bitfileread(filename):
    """
    Returns the bytes in a bitfile as a string
    """
    fid = file(filename, 'rb')

    fid.seek(72)

    return fid.read()

def writeStringToSerPeripheral(s, status=False):
    """
    Writes the bytestring s to the serial peripheral in 32-byte
    chunks. Optionally displays status
    """
    # chunk the file:
    pos = 0
    while pos < len(s):
        chunk = s[pos:pos+32]
        # pad chunk to 32 bytes
        if len(chunk) < 32:
            chunk = chunk + "\000"*(32-len(chunk))
        for i in range(4):
            words = [0, 0, 0, 0]

            for w in range(4):
                wpos = i * 8 + w*2
                c = chunk[wpos:(wpos + 2)]
                word = struct.unpack(">H", c)[0]
                words[w] = word
            sendDataWords(words)
        commitData()
                
        pos += 32
        print pos, len(s), "%3.2f" % (float(pos)/len(s) * 100)

def bootWithFile(filename):
    bits = bitfileread(filename)

    toggleProg()
    writeStringToSerPeripheral(bits)

filename = sys.argv[1]
bootWithFile(filename)


#sendDataWords([0x01, 0x02, 0x03, 0x04])
#commitData()
