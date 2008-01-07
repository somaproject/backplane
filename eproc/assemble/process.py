#!/usr/bin/python
"""
A process is like a thread or subroutine: an atomic chunk of code.

The idea is that programs are written by saying :

proc.add(RegName, RegName, Regname)

where ideally RegName is some pre-defined meaningful register name,
but might also be a fixed register name

Locations, jumps, etc. can't be resolved until the final pass by
the environment, so each process simply stores up a list of
low-level to-assemble ops and labels.

"""

from functools import partial

import unittest

class Registers:
    pass # just a register type


class Process(object):
    def __init__(self, parentEnv, name):

        self.env = parentEnv
        self.name = name
        self.vars = {}
        self.ops = []
        self.ops.append(("procLabel", (name,)))
        

    def createVariable(self, varname):
        # first, make sure there's no name collision
        if self.env.vars.has_key(varname):
            raise "variabe %s is defined in enclosing environment" % varname
        if self.vars.has_key(varname):
            raise "variable %s is already defined in this proc" % varname

        rpos = 0
        for i in range(16):
            if not ((i in self.vars.values()) or (i in self.env.vars.values())):
                rpos = i
                break
        # rpos is now an unused register
            
        self.vars[varname] = rpos
        return rpos
        

    def addOp(self, opname, *opargs):
        """
        I feel like we should do variable lookup here
        
        """
        self.ops.append((opname, opargs))

    def getOps(self):
        return self.ops
    

    def load(self, destreg, value):
        """
        Synatic sugar for the loading ops
        """

        if isinstance(value, Process):
            self.addrloadl(destreg, value.name)
            self.addrloadh(destreg, value.name)
        else:

            if value < 0x100 and value >= 0:
                self.immload(destreg, value)
            else:
                lowbyte = value & 0xFF
                highbyte = (value >> 8) & 0xFF
                self.immload(destreg, lowbyte)
                self.immhighload(destreg, highbyte)

    def move(self, destreg, srcreg):
        """
        move value from source register to destination register
        
        """
        evtreg = False
        if srcreg < 16:
            self.regmove(destreg, srcreg)
        else:
            # event move
            self.eventmove(destreg, srcreg % 16)
            
    def foreverLoop(self):
        l = self.name + ":" + self.env.generateUniqueLabel()
        self.label(l)
        self.jump(l)

    def effectiveLen(self):
        """
        Returns the number of real (non-label)
        ops

        """
        num = 0
        for i in self.ops:
            if i[0] != "label" and i[0] != "procLabel":
                num += 1
        return num
        
    def __getattr__(self, name):
        """
        by default, return a procedure
        that will let us apped to our own internal op
        list
        """
        return partial(self.addOp, name)
