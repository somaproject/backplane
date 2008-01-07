#!/usr/bin/python
"""
Take an environment and assemble it into a list of opcodes.



"""
import environment
import sys

from mnemonic import *

class ereg:
    cmd = 16
    src = 17
    edata = [18, 19, 20, 21, 22]

def assemble(env):
    """
    
    """
    procs = env.getProcList()

    # for each proc, go through and get ops
    ops = []
    for p in procs:
        ops += p.getOps()
    
    # assign a location to each op
    locmap = {}
    revlocmap = {}
    pos = 0
    for (op, args) in ops:
        if op == "procLabel" or op == "label":
            labelname = args[0]
            locmap[labelname] = pos
            if pos in revlocmap:
                revlocmap[pos].append(labelname)
            else:
                revlocmap[pos] = [labelname]
        else:
            pos += 1

    # now use the locmap for instruction dispatch
    # the ops know nothing about variables
    mn = MnemonicConvert(locmap)
    asmops = []
    pos = 0
    for op in ops:
        asmop =  mn.convert(op[0], op[1])
        if asmop:

            asmops.append(asmop)
            if pos in revlocmap:
                for l in revlocmap[pos]:
                    print "::", l, "::"
            print pos, op[0], op[1]

            pos += 1
    return asmops

if __name__ == "__main__":
    from environment import * 

    filename = sys.argv[1]
    outfile = file(sys.argv[2], 'w')
    
    execfile(filename)
    
    a = assemble(env)
    for o in a:
        outfile.write("%s\n" % o)
        
    
