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
    
    def jump(self, args):
        destname = args[0]
        destaddr = self.locmap[destname]
        return opcodes.jumpop("ALWAYS", destaddr)
    
    def add(self, args):

        destreg = args[0]
        srcreg = args[1]

        return opcodes.aluop("ADD", destreg, srcreg)

