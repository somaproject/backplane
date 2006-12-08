#!/usr/bin/python
"""
Takes the hacked-up output from our xc3sprog and extracts out an event

USER1 : 1111000010 0x3C2
USER2 : 1111000011 0x3C3
USER3 : 1111100010 0x3E2
USER4 : 1111100011 0x3C3

"""
import os
import sys
import time
import numpy as n
from numpy import random


USER1 = 0x3C2
USER2 = 0x3C3
USER3 = 0x3E2
USER4 = 0x3E3

xc3sprog = "~/XC3Sprog/xc3sprog"

def readbuffer(pos, rowtgt):
    
    performAction(pos, rowtgt, 'read')
    for i in range(512):

        cmdstr = xc3sprog + (' %d 0x%3.3X "%2.2X %2.2X 00 00 00 00 00 00"' % (pos, USER2, i & 0xFF, (i >> 8) & 0xFF))

        fid = os.popen(cmdstr)
        bytesstr = fid.read().split()
        bytes = [int(b, 16) for b in bytesstr]
        if i > 0: # because the first read doesn't return real values
            for b in bytes:
                print "%2.2X" % b, 
            print

            
def readDataBuffer(pos, rowtgt):
    """ Designed to extract out the releveant write
    commands and write into an appropriate numpy buffer and return said buffer
    for evaluation"""

    
    performAction(pos, rowtgt, 'read')
    writequery(pos)
    
    queryDoneBlock(pos)
    

    dataout = n.zeros(256, dtype=n.uint32)

    for i in range(512):

        cmdstr = xc3sprog + (' %d 0x%3.3X "%2.2X %2.2X 00 00 00 00 00 00"' % (pos, USER2, i & 0xFF, (i >> 8) & 0xFF))

        fid = os.popen(cmdstr)
        bytesstr = fid.read().split()
        bytes = [int(b, 16) for b in bytesstr]
        
        if i > 0: # because the first read doesn't return real values
            #for b in bytes:
                #print "%2.2X " % b, 
            #print
            if bytes[-1] == 0x80:

                # this is a write
                addr = bytes[5]
                data = bytes[0] | (bytes[1] << 8) | (bytes[2] << 16) | (bytes[3] << 24)
                dataout[addr] = data
    return dataout
            


def writeword(pos, addr, val):
    v1 = val & 0xFF
    v2 = (val >> 8)  & 0xFF
    v3 = (val >> 16) & 0xFF
    v4 = (val >> 24) & 0xFF

    cmdstr = xc3sprog + (' %d 0x%3.3X "%2.2X %2.2X %2.2X %2.2X %2.2X"' % (pos,
                                                                    USER3,
                                                                    addr,
                                                                    v1, v2,
                                                                    v3, v4))

    fid = os.popen(cmdstr)

    (dones, csregwr, rdsreg, wrsreg, dummy)  = query(pos)
    
    fid = file('/tmp/writeword.log', 'a')
    fid.write("%2.2X %8.8X " % (addr, val))
    fid.write("%2.2X " % dones)
    for i in csregwr:
        fid.write("%2.2X " % i)
    fid.write(" | ")

    for i in wrsreg:
        fid.write("%2.2X " % i)
    fid.write(" | ")

    for i in dummy:
        fid.write("%2.2X " % i)
    fid.write(" | ")

    
    
    fid.write('\n')
    
    

def queryDoneBlock(pos):
    # block on reading the query and waiting for done bit
    time.sleep(0.1)
    #print "Beginning queryDoneBlock done wait"
    res = query(pos)[0]
    qpos = 0
    while not res:
        results = query(pos)
        #print results
        res = results[0]
        qpos += 1
    #print "queryDoneBlock done wait took ", qpos, " ticks"

    #print "Beginning queryDoneBlock done clear"
    time.sleep(0.1)

    res = performAction(pos, 0, "resetdone")
    res = query(pos)[0]
    qpos = 0
    while res:
        time.sleep(0.1)

        res = performAction(pos, 0, "resetdone")
        results = query(pos)
        #print results
        res = results[0]
        qpos += 1
    #print "queryDoneBlock done clear took ", qpos, " ticks"
  
    
    
def writeConstBuffer(pos, rowtgt, const):
    for i in range(256):
        writeword(pos, i, const)
    performAction(pos, rowtgt, 'write')
    
def writeSeqBuffer(pos, rowtgt):
    for i in range(256):
        a = (i*4) % 256
        b = (i*4 + 1) % 256
        c = (i*4 + 2) % 256
        d = (i*4 + 3) % 256
        writeword(pos, i, (d << 24) | (c << 16) | (b << 8) | a)
    performAction(pos, rowtgt, 'write')
    
    
def writeDataBuffer(pos, rowtgt, data):
    """
    Write the entire row of 256xn.uint32 data to
    the targeted row.
    """
    
    assert len(data) == 256
    
    for i in range(256):
        writeword(pos, i, data[i])
    performAction(pos, rowtgt, 'write')
    #print "WriteDataBuffer query() =", query(pos)
    
    queryDoneBlock(pos)
    

def writequery(pos):
    (dones, csregwr, rdsreg, wrsreg, dummy)  = query(pos)
    
    fid = file('/tmp/query.log', 'a')
    for i in csregwr:
        fid.write("%2.2X " % i)
    fid.write(" | ")

    for i in wrsreg:
        fid.write("%2.2X " % i)
    fid.write(" | ")
    
    for i in rdsreg:
        fid.write("%2.2X " % i)
    fid.write(" | ")

    for i in dummy:
        fid.write("%2.2X " % i)
    fid.write(" | ")

    
    
    fid.write('\n')


def query(pos):
    cmdstr = xc3sprog + (' %d 0x%3.3X "00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"' % (pos, USER1))
    
    fid = os.popen(cmdstr) 
    bytesstr = fid.read().split()
    bytes = [int(b, 16) for b in bytesstr]
    dones = bytes[0] & 0x1
    csregwr = bytes[1:3]
    rdsreg = bytes[3:11]
    wrsreg = bytes[11:16]
    dummy = bytes[16:18]
    
    return (dones, csregwr, rdsreg, wrsreg, dummy)


def performAction(pos, rowtgt, action):
    r1 = rowtgt & 0xFF
    r2 = (rowtgt >> 8) & 0xFF
    
    if action == "read":
        cmdstr = xc3sprog + (' %d 0x%3.3X "%2.2X %2.2X 00 01 00"' % (pos,
                                                                     USER1,
                                                                     r1, r2))
        fid = os.popen(cmdstr)
        return False
    
    elif action == "write":
        cmdstr = xc3sprog + (' %d 0x%3.3X "%2.2X %2.2X 01 01 00"' % (pos,
                                                                     USER1,
                                                                     r1, r2))
        fid = os.popen(cmdstr)
        return False
    elif action == "query" :
        cmdstr = xc3sprog + (' %d 0x%3.3X "00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"' % (pos, USER1))
        
        fid = os.popen(cmdstr) 
        bytesstr = fid.read().split()
        bytes = [int(b, 16) for b in bytesstr]
        print "bytestr: ", bytesstr
        dones = bytes[0] & 0x1
        csregwr = bytes[1:3]
        rdsreg = bytes[4:12]
        wrsreg = bytes[13:18]
        wrsreg = bytes[19:21]
        
        
        if (bytes[0] & 0x01 == 1):
            return True
        else:
            return False
        
    elif action == "resetdone" :
        cmdstr = xc3sprog + (' %d 0x%3.3X "00 00 00 02 00"' % (pos, USER1)) 
        fid = os.popen(cmdstr) 
       
       
    else:
        raise "invalid action"


def readStatus(pos):
    cmdstr = xc3sprog + (' %d 0x%3.3X "00 00 00 00 00"' % (pos, USER4))

    fid = os.popen(cmdstr)
    bytesstr = fid.read().split()
    bytes = [int(b, 16) for b in bytesstr]
    print " %2.2X%2.2X%2.2X%2.2X%2.2X" % (bytes[4], bytes[3], bytes[2],
                                          bytes[1], bytes[0])
    print "the high bits have delay", bytes[3]
    print "the low bits have delay ", bytes[1]

def manwrite():
    row = random.randint(1000)
    
   
    print "Writing..."
    writeSeqBuffer(1, row)
    print performAction(1, row,  "query")
    
    print "Reading..."
    readbuffer(1, row)
    

def randwrite(pos, row = None):
    """
    Fill a random row with random data, try and read it back, and look
    at the resulting bit error pattern.
    """
    
    datain = (n.random.rand(256) * 2**32).astype(n.uint32)
    if row == None:
        row = random.randint(2**15)
    print "trying row ", row
    writeDataBuffer(pos, row, datain)
    dataout = readDataBuffer(pos, row)
    for i in range(256):
        errorbits =  datain[i] ^ dataout[i]
        if errorbits > 0 :
            print "ERROR : %3d : %8.8X %8.8X %8.8X %d" % (i, datain[i], dataout[i],
                                                  errorbits, errorbits)
       

def rangetest(pos, start, stop, justread=False):
    """
    for rows between [start, stop] inclusive:
    
    write random data, spaced by _spacing_
    read that data back

    return the two sets of data for analysis
    """
    
    N = stop - start + 1 # inclusive range.

    errnum = 0

    spacing = 1 
    datain = (n.random.rand(N, 256) * 2**32).astype(n.uint32)
    #datain = n.zeros((N, 256), dtype=n.uint32)
    
    # write all of them
    if not justread:
        for row in range(N):
            print "writing row ", start + row*spacing
            writeDataBuffer(pos, start + row*spacing, datain[row])

    # read all back
    M = 1
    dataout = n.zeros((N, M, 256), dtype=n.uint32)

    for row in range(N):
        print "reading row", start + row*spacing, "..."
        for p in range(M):
            #print "Try", p, ":" 
            dataout[row, p] = readDataBuffer(pos, start+ row*spacing)
    return (datain, dataout)

def datacompare(din, dout):

    res = n.zeros(len(din), dtype=n.uint32)
    
    for i in range(len(din)):
        e = n.sum(din[i]^ dout[i])
        res[i] = e
    return res

def errcnt(row, rows):
    """
    returns the number of non-matching rows
    """
    results = []
    for r in rows :
        results.append(((r - row) != 0).sum())
    return results

def compare(din, dout):
    res = []
    for i in range(len(din)):
        res.append(n.argmin(errcnt(dout[i], din)))
    return res

#print "getting status:"
#readStatus(1)
#(datain, dataout) = rangetest(1, 120, 121, False)
#res = []

#randwrite(1, 1200)
#manwrite()

if __name__ == "__main__":
    readStatus(1)
    rstart = 120
    rstop = 130
    (datain, dataout) = rangetest(1, rstart, rstop, False)
    # simple verify
    errcnt = 0 
    for i in range(rstop - rstart + 1) :
        errcnt += n.sum(datain[i] - dataout[i])
        
    print "There were ", errcnt, "errors" 
        
    
