"""
The xilinx data2mem program does not generate the correct parity
bits for a block ram in it's vhdl-constant-generator

So we generate them with this script.

useage:

genrom.py  foo.bmm foo.imem bar.imem 

We extract out the instance info from foo.mem and the data from foo.imem

Note, this is very limited

"""

import sys
import os
import numpy as n

def createRAMFile(filename):
    fid = file(filename + "_mem.vhd", 'w')

    fid.write("library ieee;\n")
    fid.write("use ieee.std_logic_1164;\n")
    fid.write("package %s_mem_pkg is\n" % filename)
    return fid

def closeRAMFile(fid, base):

    fid.write("end %s_mem_pkg;\n" % base)
    


def writeRAM(fid, instance, d, p):
    """
    Writes data d and parity info p to a list of constants
    in the package filename_pkg (in file filename.vhd)

    """


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
    
    
def getRamInstances(fid):
    """
    Extract out the instances from a bmm
    """

    line = fid.readline()
    instances = []
    while line:
        ls =  line.split(" ")[0].strip().upper()
        if ls == "BUS_BLOCK":
            instline = fid.readline()
            inst = instline.split(" ")[0]
            instances.append(inst)
        
        line = fid.readline()
    
    return instances

def createBram():
    """
    Assume the 18-kb ram
    """

    d = n.zeros(2**10, dtype=n.uint16)
    p = n.zeros(2**10, dtype=n.uint8)

    return (d, p)

def loadIMEMFile(filename):
    """ load in an imem file """
    imemfid = file(filename)    
    d, p = createBram()

    pos = 0

    for w in imemfid.readlines():
        ws = w.strip()
        assert len(ws) == 18
        val = 0
        for v in ws:
            val = val << 1
            if v == '1':
                val |= 1

        d[pos] = val % (2**16)
        p[pos] = (val >> 16 ) & 0x3

        pos += 1

    return (d, p)


def getFromBMM() :
    bmmfile = sys.argv[1]


    bmmfid = file(bmmfile)
    instances = getRamInstances(bmmfid)

    base = os.path.basename(bmmfile)[:-4]

    rfid = createRAMFile(base)

    for i, s in enumerate(sys.argv[2:]):
        d, p = loadIMEMFile(s)

        writeRAM(rfid, instances[i], d, p)
    closeRAMFile(rfid, base)

def simpleGenVHDL():
    """
    Simply generate the VHDL constants

    assume we have a single imem file and we're going to
    turn that into an array of constants
    
    """

    filename = sys.argv[2]
    base = sys.argv[3]

    rfid = createRAMFile(base)
    filenames = [filename]
    instances = [base]
    for i, s in enumerate(filenames):
        d, p = loadIMEMFile(s)

        writeRAM(rfid, instances[i], d, p)
    closeRAMFile(rfid, base)


if __name__ == "__main__":
    if sys.argv[1] == "-s":
        # simple
        simpleGenVHDL()
    else:
        getFromBMM()
    
