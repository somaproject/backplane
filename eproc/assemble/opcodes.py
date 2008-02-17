#!/usr/bin/python
"""

Functions for turning opcodes into bitstrings


"""

ALUOPS = { "PASSA" : 0,
           "PASSB" : 1,
           "SWAPB" : 2,
           "MOVBTOHLOW" : 3,
           "AXORB" : 5,
           "AANDB" : 6,
           "AORB" : 7,
           "ADD" : 8,
           "ADDC" : 9,
           "SUB" : 10,
           "SUBC" : 11}

JUMPTYPES  = { "ALWAYS" : 0,
               "ZERO" : 1,
               "GTZ" : 2,
               "LTZ" : 3 }

from bitstring import BitString
import unittest

def newOp() :
    return BitString(18)

def aluop(ALUop, rega, regb, useEvent = False, eaddr = 0):
    """
    execute some ALU operation, optionally using the event data
    
    """
    op = newOp()
    op[17:16] = [0,0]
    op[15:12] = ALUOPS[ALUop]
    if useEvent :
        op[11] = 1
        op[10:8] = eaddr
    else:
        op[11] = 0
    op[7:4] = regb
    op[3:0] = rega

    return op
      
def immop(ALUop, immbyte, tgtreg):
    """
    tgtreg: target register #
    immbyte: immediate byte that we want to do stuff with
    
    """
    
    op = newOp()
    
    op[17:16] = [1, 0]
    op[15:12] = ALUOPS[ALUop]
    op[11:4] = immbyte
    op[3:0] = tgtreg

    return op


def portop(direction, addr, reg,  useRegAddr=False):
    """
    direction = 0 ==> input
    direction = 1 ==> output

    if useRegAddr == True, then
    addr is actually a register # that we use

    """
    op = newOp()
    op[17:16] = [1, 1]
    op[15] = direction
    
    if useRegAddr:
        op[14] = 1
        op[8:4] = addr
    else:
        op[14] = 0
        op[11:4] = addr

    op[3:0] = reg

    return op

    
def jumpop(type, dest):
    """

    """
    op = newOp()
    op[17:16] = [0, 1]
    op[15:14] = JUMPTYPES[type]
    op[13:4] = dest

    return op
