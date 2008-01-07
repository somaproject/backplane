#!/usr/bin/python
"""
An "environment" is a collection of global variables, processeses, and
dispatch locations.

"""

from process import Process
EVTJUMPADDR = 0x88

class Environment(object):

    def __init__(self):
        self.vars = {}
        self.procs = {}
        self.eprocs = {}
        self.ecycproc = None
        self.uniqueLabelPos = 0

    def generateUniqueLabel(self):
        self.uniqueLabelPos += 1
        return "__env_unique_%d" % self.uniqueLabelPos
    
    def createVariable(self, name):
        assert not (name in self.vars)
        # find first free register
        rpos = 0
        for i in range(16):
            if not i in self.vars.values():
                rpos = i
                break
        # rpos should now be the first reg not in vars
        assert not (rpos in self.vars)
        self.vars[name] = rpos
        return rpos
    
        
    def createProc(self, name):
        p = Process(self, name)
        self.procs[name] = p
        return p

    def createEProc(self, cmdrange, srcrange):
        """
        Create an event-handling process,
        which is just a regular eproc except we'll check to make
        sure it's not too many ops, and we have some syntactic
        sugar to assemble the eproc dispatch table
                
        """
        p = Process(self, "EProc_%d_%d_%d_%d" % (cmdrange[0], cmdrange[1],
                                           srcrange[0], srcrange[1]))
        self.eprocs[(cmdrange, srcrange)] = p
        return p

    def createECycleProc(self):
        """
        create the once-per-event cycle proc
        """
        p = Process(self, "ECycleProc")
        self.ecycproc = p
        return p
    
        
    def getProcList(self):
        """
        Returns the ordered list of processes

        by default, we have:
        1. any automatically-generated start-up code, such as eproc setup
        2. all naked procs
        3. the ECycleProc, if there is one
        4. all the EProcs
        """

        proclist = []

        # startup code
        if self.ecycproc != None:
            proclist.append(self.createECycleProcLoadProc())
            proclist.append(self.createEProcLoadProc())
            
        for k, v in self.procs.iteritems():
            proclist.append( v)
        # then the ecycle proc:
        if self.ecycproc != None:
            
            proclist.append(self.ecycproc)
            
        # then the eprocs
        for k, ep in self.eprocs.iteritems():
            self.epVerifyAndWrap(ep)
            
            proclist.append(ep)

        return proclist

    def __getattr__(self, name):
        return self.vars[name]

    def createECycleProcLoadProc(self):
        p = Process(self, "ECycleProcLoad")
        tmpaddr = p.createVariable("tmpaddr")
        assert self.ecycproc != None
        p.load(tmpaddr, self.ecycproc)
        p.output(EVTJUMPADDR, tmpaddr)
        
        return p

    def epVerifyAndWrap(self, ep):
        """
        takes in an EProc and

        1. verifies that it's at most 12
        substantive ("do-something") ops long

        2. adds a superfluous call to "foreverloop" at the bottom
        
        """
        if ep.effectiveLen() > 12:
            raise "Error, eproc too long"
        ep.foreverLoop()
        
    
    def createEProcLoadProc(self):
        """
        set up the dispatch table, all entries
        """
        p = Process(self, "EProcLoad")
        pos = 0
        tempreg = p.createVariable("tempreg")
        for k, v in self.eprocs.iteritems():
            (cmdrange, srcrange) = k
            proc = v
            baseaddr = 0x40 + pos*4
            # first the address
            p.load(tempreg, proc)
            p.output(baseaddr, tempreg)
            # The Command Range
            cmdlow = cmdrange[0]
            cmdhigh = cmdrange[1]
            
            p.load(tempreg, (cmdhigh << 8) | cmdlow)
            p.output(baseaddr + 1, tempreg)
            
            # The Source Range
            srclow = srcrange[0]
            srchigh = srcrange[1]
            
            p.load(tempreg, (srchigh << 8) | srclow)
            p.output(baseaddr +2, tempreg)
            

            pos += 1
        for remaining in range(pos, 16):
            ## fill in the missing ones
            baseaddr = 0x40 + remaining * 4
            p.load(tempreg, 0x0001) # a contradictory condition
            p.output(baseaddr + 1, tempreg)
        return p
        
        
def createEnvironment():
    x = Environment()
    return x
