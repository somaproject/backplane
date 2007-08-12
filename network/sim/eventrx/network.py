#!/usr/bin/python

"""
simple example client for event transmission; sends an event set and then
awaits the response



"""

import numpy as n
from socket import *
import pylab
import struct
import sys

def randEvent():
    e = Event()
    e.eaddr = (n.random.rand(10) * 2**8).astype(n.uint8)
    e.edata = (n.random.rand(12) * 2**8).astype(n.uint8)

    return e

class Event(object):

    def __init__(self):
        self.eaddr = n.zeros(10, dtype = n.uint8)
        self.edata = n.zeros(12, dtype = n.uint8)

    def write(self,fid):
        for i in self.eaddr[::-1]:
            fid.write(pylab.base_repr(i, 16, 2))

        fid.write(' ')
        
        for i in self.edata[::-1]:
            fid.write(pylab.base_repr(i, 16, 2))
       
        fid.write('\n')

def server():
    port = 5100

    svrsocket = socket(AF_INET, SOCK_DGRAM)

    svrsocket.bind(('',port))
    
    while True:
        data, address = svrsocket.recvfrom(256)
        print "Client sent:", len(data[:4])
        print "Client at:", address

        (nonce, ecnt) = struct.unpack(">HH", data[:4])

        respdata = struct.pack(">HH", nonce, 1)

        svrsocket.sendto(respdata, address)


def sendEvents(eventlist):

    nonce = int(round(n.random.rand()* (2**16-1)))
    ecnt = len(eventlist)
    
    data = struct.pack(">HH", nonce, ecnt)
    
    for e in eventlist:
        for a in e.eaddr:
            data += struct.pack("B", a)
        for d in e.edata:
            data += struct.pack("B", d)

        data += "          "

    assert (len(data) - 4) % 32 == 0
    
    
    host = "10.0.1.110"
    port = 5100

    addr = (host,port)
    UDPSock = socket(AF_INET,SOCK_DGRAM)
    
    UDPSock.sendto(data,addr)

    resp = UDPSock.recv(100)
    (nonceresp, suc) = struct.unpack(">HH", resp)
    print nonceresp, nonce, "success = ", suc
    
def client():
    eventsets = []
    
    for j in range(100):
        el = []

        for i in range(int(round(n.random.rand() * 8))):
            el.append(randEvent())
        eventsets.append(el)
        
    for es in eventsets:
        sendEvents(es)

    # write out the events
    fid = file('events.txt', 'w')
    for es in eventsets:
        for e in es:
            e.write(fid)
            
        
if __name__ == "__main__":
    if sys.argv[1] == "server":
        server()
    else:
        client()
