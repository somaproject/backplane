#!/usr/bin/python
import sys
sys.path.append("../../assemble")
import opcodes

oplist = []
oplist.append( opcodes.immop("PASSB", 0x01, 0))
oplist.append( opcodes.immop("PASSB", 0x23, 1))
oplist.append( opcodes.immop("PASSB", 0x45, 2))
oplist.append( opcodes.immop("PASSB", 0x67, 3))

for i in range(16):
    oplist.append( opcodes.portop(1, 0x80 + i, i))

outfile = file("program.iram", 'w')
for op in oplist:
    outfile.write("%s\n" % op)

    
