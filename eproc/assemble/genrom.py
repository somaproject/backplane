"""
The xilinx data2mem program does not generate the correct parity
bits for a block ram in it's vhdl-constant-generator

So we generate them with this script.

useage:

genrom.py  foo.bmm foo.imem

We extract out the instance info from foo.mem and the data from foo.imem

Note, this is very limited

"""

import sys
import os
import numpy as n


def writeRAM(filename, instance, d, p):
    """
    Writes data d and parity info p to a list of constants
    in the package filename_pkg (in file filename.vhd)

    """

    fid = file(filename + "_mem.vhd", 'w')

    fid.write("library ieee;\n")
    fid.write("use ieee.std_logic_1164;\n")
    fid.write("package %s_mem_pkg is\n" % filename)

    sinstance = instance.replace("/", "_")

    for i in range(64):
        fid.write("\t\tconstant %s_INIT_%2.2X : bit_vector(0 to 255) := X" % 
                  (sinstance, i))
        fid.write('"')
        strsum = ""
        for j in range(16):
            strsum = ("%4.4X" % d[j + i * 16]) + strsum
        fid.write(strsum)
        fid.write('";\n')

    # now the parity bits
    for i in range(8):
        fid.write("\t\tconstant %s_INITP_%2.2X : bit_vector(0 to 255) := X" % 
                  (sinstance, i))
        fid.write('"')
        strsum = ""
        for j in range(64):

            val = (p[j*2 + 1 +  i * 128] << 2)  | (p[j*2 + i * 128])
            strsum = ("%1.1X" % val) + strsum
        fid.write(strsum)
        fid.write('";\n')

    fid.write("end %s_mem_pkg;\n" % filename)
    
    
def getRamInstance(file):
    """
    Extract out the instance from a bmm
    """
    addrblock = file.readline()
    busblock = file.readline()
    instline = file.readline()
    inst = instline.split(" ")[0]

    return inst

def createBram():
    """
    Assume the 18-kb ram
    """

    d = n.zeros(2**10, dtype=n.uint16)
    p = n.zeros(2**10, dtype=n.uint8)

    return (d, p)
bmmfile = sys.argv[1]
imemfile = sys.argv[2]

bmmfid = file(bmmfile)
imemfid = file(imemfile)

inst = getRamInstance(bmmfid)

d, p = createBram()

pos = 0

base = os.path.basename(bmmfile)[:-4]
for w in imemfid.readlines():
    ws = w.strip()
    assert len(ws) == 18
    val = 0
    for v in ws:
        val = val << 1
        if v == '1':
            val |= 1
    print ws, "%5.5X" % val

    d[pos] = val % (2**16)
    p[pos] = (val >> 16 ) & 0x3
    
    pos += 1
    
print base

writeRAM(base, inst, d, p)
