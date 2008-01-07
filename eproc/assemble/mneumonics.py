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
        

    def convert(self, mn, args):
        """
        each mnemonic can only map to a single opcode; Any additional
        syntactic sugar needs to be added by "proc"
        
        """
        
        return self.__dict__(mn)(args)
    
    def nop(self, args):
        """ NO OP  -- eats a tick """ 
        return aluop("PASSA", 0, 0)
    
