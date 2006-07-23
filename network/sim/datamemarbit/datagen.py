#!/usr/bin/python
import numpy as n
from socket import *
import struct

N = 80


class DataPacketGen(object):
    """ Returns a randomly-generated data packet """
    
    def __init__(self):
        self.ids = n.zeros((4, 2**6), dtype=n.uint32)

    def generatePacket(self):
        N = int(round(n.rand()*290)) + (2+6+6+2+20+8+4+2)/2
        src = int(round(n.rand() * (2**6-1)))
        typ = int(round(n.rand() * (2**2-1)))
        
        id = self.ids[typ, src]
        
        self.ids[typ, src] = self.ids[typ, src] + 1

        
        data = n.zeros(N, dtype=n.uint16)

        data[0] = N*2
        os = 1 + 3 + 3 + 1 + 10 + 4
        data[os + 0] = (id >> 16) & 0xFFFF
        data[os + 1] = id & 0xFFFF
        data[os + 2] = (typ << 8) | src

        # random data
        for i in range(os + 3, N):
            data[i] = (i+typ+src + id) % 0xFFFF

        return (typ, src, id, data)
    
if __name__ == "__main__":

    # first we generate a bit list of data packets

        
    dpg = DataPacketGen()
    datapackets = []
    
    N = 5000
    typs = n.empty(N, dtype = n.uint8)
    srcs = n.empty(N, dtype= n.uint8)
    ids = n.empty(N, dtype = n.uint32)
    
    for i in range(N):
        (typ, src, id, data) = dpg.generatePacket()
        typs[i] = typ
        srcs[i] = src
        ids[i] = id
        datapackets.append(data)

    fid = file('data.txt', 'w')
    for dp in datapackets:
        delay = int(n.random.uniform(1, 1000))
        fid.write("%d " % delay)
        fid.write("%d " % len(dp))
        for d in dp:
            fid.write("%4.4X " % d)
        fid.write('\n')

    # now we generate our retx requests
    reTXrate = 0.1
    retxes = (n.rand(N) < reTXrate).nonzero()[0]

    p = 0.02
    retxreqfid = file('retxreq.txt', 'w')
    for i in retxes:
        # we wait until each of these packets have been sent, and then
        # pick a packet < 250 packets before it.
        r = n.random.geometric(p)

        distprev =  min(r, 250) + 2 
        pos = max(0, i - distprev)

        retxreqfid.write('%d ' % i)
        retxreqfid.write("%8.8X %2.2X %2.2X "  % (ids[pos], typs[pos],
                                                  srcs[pos]))

        retxreqfid.write("%d " % len(datapackets[pos]))
        
        for d in datapackets[pos]:
            retxreqfid.write("%4.4X " % d)
        retxreqfid.write('\n')

    
        
