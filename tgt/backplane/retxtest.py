"""
What happens when we request the retransmission of a packet?

"""


import socket
import struct
import pylab
import numpy as n
import sys

SOMAIP = "10.0.0.2"
def createDataReTxReq(src, typ, seq):
    return struct.pack(">BBI", src, typ, seq)

def createEventReTxReq(seq):
    return struct.pack(">I", seq)

retxsock = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)

retxsock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
retxsock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

datasock = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
datasock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
datasock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

datasock.bind(('', 4000))
## for i in range(1000):
##     retxsock.sendto(createDataReTxReq(0, 0, 0), (SOMAIP, 4400))

retxsock.sendto(createEventReTxReq(0), (SOMAIP, 5500))
