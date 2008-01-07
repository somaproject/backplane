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
           "ADD" : 8 }

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


def portop(direction, addr, reg):
    """
    direction = 0 ==> input
    direction = 1 ==> output

    """
    op = newOp()
    op[17:16] = [1, 1]
    op[15] = direction
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
