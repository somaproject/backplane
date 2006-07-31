#!/usr/bin/python
import numpy as n
from socket import *
import struct

class DataPacket(object):
    def __init__(self, src, typ, id, data = None, N = 0):
        if data == None:
            self.data = (n.rand(N) * 2**16).astype(n.uint16)
        self.typ = typ
        self.src = src
        self.id = id

    def getInputData(self):
        data = n.zeros(len(self.data) + 1,  dtype=n.uint16)

        data[0] = (self.typ << 8) | self.src
        
        for i in range(len(self.data)):
            data[i+1] = self.data[i]
        
        return data

    def getAllData(self):
        data = n.zeros(len(self.data) + 3,  dtype=n.uint16)
        data[0] = self.id >> 16
        data[1] = self.id  & 0xFFFF
        data[2] = (self.typ << 8) | self.src
        
        for i in range(len(self.data)):
            data[i+3] = self.data[i]
        
        return data
        
class DataPacketGen(object):
    """ Returns a randomly-generated data packet  object"""
    
    def __init__(self):
        self.ids = n.zeros((4, 2**6), dtype=n.uint32)

    def generatePacket(self, N = 0, src = 0, typ = 0):
        if N == 0:
            N = int(round(n.rand()*290)*2) # max length is two 
        
        if src == 0:
            src = int(round(n.rand() * (2**6-1)))

        if typ == 0:
            typ = int(round(n.rand() * (2**2-1)))
        
        id = self.ids[typ, src]
        
        self.ids[typ, src] = self.ids[typ, src] + 1
        
        return DataPacket(src, typ, id, N=N)
    
    
def writePacket(fid, packet):
    """ randomly writes the packet at some random location inside
    of the event cycle and fills in the other cycles
    """

    indata = packet.getInputData()
    
    N = len(indata) * 2
    M = 980
    startrange = M - N
    p = int(n.rand()*startrange)

    s = 1000 - N - p
    
    for i in range(p):
        fid.write("0 00\n")

    for i in indata:
        fid.write("1 %2.2X\n" % ((i >> 8) & 0xFF))
        fid.write("1 %2.2X\n" % (i & 0xFF))

    for i in range(s):
        fid.write("0 00\n")

    
def writeEmpty(fid):
    for i in range(1000):
        fid.write("0 00\n")
    
    
if __name__ == "__main__":

    # first we generate a bit list of data packets

    dpg = DataPacketGen()

    pktsets = 20
    datapackets = []
    for i in range(pktsets):
        for src in range(64):
            N = 32*4 + 20 + (src % 4) * 2
            N = 2; 
            
            p = dpg.generatePacket(N = N)
            datapackets.append(p)

    pktcnt = len(datapackets)
    
    # write them in the event cycles:

    pos = 0

    fida = file('dataa.txt', 'w')
    fidb = file('datab.txt', 'w')


    # we want to write 64 packets per ms; we start off with writing
    # 64 at the beginning, waiting, writing another 64, etc. to make sure
    # this sort of extreme-behavior is safe

    for i in range(4):
        for i in range(32):
            writePacket(fida, datapackets[pos])
            pos += 1
            writePacket(fidb, datapackets[pos])
            pos += 1

        for i in range(50 - 32):
            writeEmpty(fida)
            writeEmpty(fidb)

        
    while pos < pktcnt:

        # flip two coins, for tx on A and B;
        asend = n.rand() > 0.3
        if asend :
            writePacket(fida, datapackets[pos])
            pos += 1
        else:
            writeEmpty(fida)

        bsend = n.rand() > 0.3

        if pos != pktcnt:
            if bsend :
                writePacket(fidb, datapackets[pos])
                pos += 1
            else:
                writeEmpty(fidb)



    # then write the actual data out:
    pktfid = file('data.txt', 'w')
    for i in datapackets:
        pktfid.write("%d %8.8X %d %d " % (len(i.data),
                                                i.id, i.src, i.typ))
        for j in i.getAllData():
            pktfid.write("%4.4X " % j)
        pktfid.write("\n")
