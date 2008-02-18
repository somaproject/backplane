#!/usr/bin/python
"""
Convert mnemonics to actual ops for decode


"""
import opcodes

class MnemonicConvert(object):

    def __init__(self, locmap):
        """
        locmap is a map from strings for labels to address locations

        """
        self.locmap = locmap

    
    def nop(self, args):
        """ NO OP  -- eats a tick """ 
        return opcodes.aluop("PASSA", 0, 0)

    def immload(self, args):

        tgtreg = args[0]
        immbyte = args[1]
        
        assert ( immbyte < 256) and (immbyte >= 0)
        return opcodes.immop("PASSB", immbyte, tgtreg)

    def immhighload(self, args):
        """
        
        """
        tgtreg = args[0]
        immbyte = args[1]
        assert ( immbyte < 256) and (immbyte >= 0)
        
        return opcodes.immop("MOVBTOHLOW", immbyte, tgtreg)
    
    def addrloadl(self, args):
        """
        
        """
        tgtreg = args[0]
        addrname = args[1]
        addr = self.locmap[addrname]

        return self.immload((tgtreg, addr & 0xFF))

    def addrloadh(self, args):
        """
        
        """

        tgtreg = args[0]
        addrname = args[1]
        addr = self.locmap[addrname]

        return self.immhighload((tgtreg, (addr >> 8)& 0xFF))

        
    
    def procLabel(self, args):
        pass

    def label(self, args):
        pass
    

    def convert(self, mn, args):
        """
        each mnemonic can only map to a single opcode; Any additional
        syntactic sugar needs to be added by "proc"
        
        """
        return eval("self.%s" % mn)(args)
    
    def regmove(self, args):

        destreg = args[0]
        srcreg = args[1]

        return opcodes.aluop("PASSB", destreg, srcreg)

    def eventmove(self, args):
        destreg = args[0]
        srcreg = args[1]
        print "Eventmove", destreg, srcreg

        return opcodes.aluop("PASSA", destreg, srcreg, True, eaddr = srcreg)

        
    def output(self, args):
        destaddr = args[0]
        srcreg = args[1]
        
        return opcodes.portop(1, destaddr, srcreg)
    
    def input(self, args):
        srcaddr = args[0]
        destreg = args[1]
        
        return opcodes.portop(0, srcaddr, destreg)
    
    def inputreg(self, args):
        srcaddr = args[0]
        destreg = args[1]
        
        return opcodes.portop(0, srcaddr, destreg, True)
    
    def jump(self, args):
        destname = args[0]
        destaddr = self.locmap[destname]
        return opcodes.jumpop("ALWAYS", destaddr)
    
    def jz(self, args):
        destname = args[0]
        destaddr = self.locmap[destname]
        return opcodes.jumpop("ZERO", destaddr)
    
    def jltz(self, args):
        destname = args[0]
        destaddr = self.locmap[destname]
        return opcodes.jumpop("LTZ", destaddr)
    
    def jgtz(self, args):
        destname = args[0]
        destaddr = self.locmap[destname]
        return opcodes.jumpop("GTZ", destaddr)
    
    def add(self, args):

        destreg = args[0]
        srcreg = args[1]

        return opcodes.aluop("ADD", destreg, srcreg)

    def addc(self, args):

        destreg = args[0]
        srcreg = args[1]

        return opcodes.aluop("ADDC", destreg, srcreg)

    def sub(self, args):

        destreg = args[0]
        srcreg = args[1]

        return opcodes.aluop("SUB", destreg, srcreg)

    def subc(self, args):

        destreg = args[0]
        srcreg = args[1]

        return opcodes.aluop("SUBC", destreg, srcreg)

    def swapbytes(self, args):

        destreg = args[0]
        srcreg = args[1]

        return opcodes.aluop("SWAPB", destreg, srcreg)

    # Immediate ALU ops
    def immadd(self, args):
        """
        immediate add -- add an immediate to reg and store in reg

        """
        destreg = args[0]
        immval = args[1]

        return opcodes.immop("ADD", immval, destreg)
    
