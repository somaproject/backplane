#!/usr/bin/python
import sys
sys.path.append("../../assemble")
import opcodes

oplist = []
#load R0 with 0x1234
oplist.append( opcodes.immop("PASSB", 0x34, 0))
oplist.append( opcodes.immop("MOVBTOHLOW", 0x12, 0))
#load R1 with 0x5678
oplist.append( opcodes.immop("PASSB", 0x78, 1))
oplist.append( opcodes.immop("MOVBTOHLOW", 0x56, 1))
#test always-jump:
oplist.append( opcodes.jumpop("ALWAYS", 7))
oplist.append( opcodes.immop("PASSB", 0xFF, 2))
oplist.append( opcodes.immop("PASSB", 0xEE, 3))
oplist.append( opcodes.immop("PASSB", 0xAA, 4))
# test zero-jump
oplist.append( opcodes.immop("PASSB", 0x01, 5)) # clearly not zero
oplist.append( opcodes.jumpop("ZERO", 12))  # should not jump
oplist.append( opcodes.immop("PASSB", 0xAB, 6))
oplist.append( opcodes.immop("PASSB", 0xCD, 7))
oplist.append( opcodes.immop("PASSB", 0x00, 5)) # zero
oplist.append( opcodes.jumpop("ZERO", 16))  # should not jump
oplist.append( opcodes.immop("PASSB", 0xEE, 6))
oplist.append( opcodes.immop("PASSB", 0xFF, 7))
# should test the other jumps, but I'm not

               

for i in range(16):
    oplist.append( opcodes.portop(1, 0x80 + i, i))

outfile = file("program.iram", 'w')
for op in oplist:
    outfile.write("%s\n" % op)

    
