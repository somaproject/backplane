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
# Try a simple move from reg 1 to reg 2:
oplist.append( opcodes.aluop("PASSB", 2, 1))
# try to swap the bytes
oplist.append( opcodes.aluop("SWAPB", 3, 2))
# complex logic
#load R5 with 0xF0F0
oplist.append( opcodes.immop("PASSB", 0xF0, 5))
oplist.append( opcodes.immop("MOVBTOHLOW", 0xF0, 5))
# and them
oplist.append( opcodes.aluop("AANDB", 5, 0) )
#load R6 with 0xF0F0
oplist.append( opcodes.immop("PASSB", 0xF0, 6))
oplist.append( opcodes.immop("MOVBTOHLOW", 0xF0, 6))
# or them
oplist.append( opcodes.aluop("AORB", 6, 0) )
# now test the event interface
#
# load Eaddr0 to register 7
oplist.append( opcodes.aluop("PASSA", 7, 0, True, 0))
oplist.append( opcodes.aluop("PASSA", 8, 0, True, 7))
               



for i in range(16):
    oplist.append( opcodes.portop(1, 0x80 + i, i))

outfile = file("program.iram", 'w')
for op in oplist:
    outfile.write("%s\n" % op)

    
