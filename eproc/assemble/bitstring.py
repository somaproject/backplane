#!/usr/bin/python
import unittest

class BitString:
    """
    a simple bitstring class, emulates a sequence
    
    """

    def __init__(self, val):
        if isinstance(val, int):
            # assume val was a len
            self._bits = [0 for x in range(val)]
        else:
            # assume val was a list
            if isinstance(val, list):
                self._bits = [0 for x in xrange(len(val))]
                boolvals = []
                for l in val:
                    if l > 0:
                        boolvals.append(1)
                    else:
                        boolvals.append(0)
                self._bits = boolvals[::-1]
            
    
    def __getitem__(self, key):
        if isinstance(key, slice):
            subbits = self._bits[key.stop:(key.start+1)]
            newbs = Bitstring(len(subbits))
            newbs._bits = subbits

            return newbs
        else:
            return self._bits[key]
        

    def __setitem__(self, key, value):
        if isinstance(value, BitString):
            # set them as if they were a list
            slen = key.start+1 - key.stop
            assert slen == len(value)
            for pos in xrange(slen):
                self._bits[key.stop + pos] = value._bits[pos]
                    
        elif isinstance(value, list):
            # set them as if they were not a list
            newBS = BitString(value)
            self[key] = newBS
            pass
        else:
            # now we check if it's a slice:
            if isinstance(key, slice):
                stop = 0
                if key.stop > 10000000 and key.start == 0:
                    slen = len(self)
                    newval = value
                    for i in xrange(slen):
                        self._bits[i] = newval % 2
                        newval = newval >> 1

                else:
                    slen = key.start+1 - key.stop
                # convert to a bitstring
                    newval = value
                    for i in xrange(slen):
                        self._bits[i + key.stop] = newval % 2
                        newval = newval >> 1

            else:
                #it's not a slice, so we better be assigning 0 or 1
                assert value == 0 or value == 1
                self._bits[key] = value
                
                    
                            
            return self._bits[key]
        
        
    def __add__(self, other):
        newbs = BitString(len(self) + len(other))
        newbs[len(newbs)-1:(len(newbs) - len(self) )] = self
        newbs[len(other)-1:0] = other
        return newbs
    
    def __len__(self):
        return len(self._bits)

    def __str__(self):
        """ convert to string """
        s = ""
        for b in self._bits[::-1]:
            if b > 0 :
                s += "1"
            else:
                s += "0"
        return s
        
class TestBitstring(unittest.TestCase):

    def testSimpleCreate(self):
        bs = BitString(10)
        self.assertEqual(len(bs), 10)
        self.assertEqual(str(bs), "0000000000")
        
    def testListCreate(self):
        bs = BitString([0, 1, 0, 1, 1, 1])
        self.assertEqual(len(bs), 6)
        self.assertEqual(str(bs), "010111")
        

    def testSingleSetters(self):
        bs = BitString(10)
        bs[0] = 0
        bs[1] = 1
        bs[2] = 0
        bs[3] = 1
        self.assertEqual(str(bs), "0000001010")

    def testComplexSetters(self):

        # setting with another bitstring
        bs1 = BitString(10)
        bs2 = BitString(5)
        bs2[0] = 1
        bs2[3] = 1
        bs2[4] = 1
        bs1[7:3] = bs2
        self.assertEqual(str(bs1), "0011001000")

        # setting with a list
        bs1 = BitString(10)

        bs1[9:5] = [1, 0, 1, 1, 1]
        bs1[4:3] = [0, 1]
        self.assertEqual(str(bs1),  "1011101000")

    def testConversion(self):
        """
        Test numeric conversion

        """

        bs1 = BitString(8)
        bs1[:] = 174
        self.assertEqual(str(bs1), "10101110")
        
        bs2 = BitString(8)
        bs2[:] = -1
        self.assertEqual(str(bs2), "11111111")

        bs3 = BitString(8)
        bs3[5:2] = 3
        self.assertEqual(str(bs3), "00001100")
        
    def testConcatenation(self):
        bs1 = BitString([0, 1, 0, 1, 1])
        bs2 = BitString([1, 1, 1, 0, 1])
        self.assertEqual(str(bs1 +  bs2), "0101111101")
        
    def testSilly(self):
        op = BitString(18)
        op[17:16] = [1, 0]
        self.assertEqual(str(op), "100000000000000000")

        op[15:12] = 2
        self.assertEqual(str(op), "100010000000000000")

        op[11:4] = 0x78
        self.assertEqual(str(op), "100010011110000000")

        op[3:0] = 3
        self.assertEqual(str(op), "100010011110000011")

        



if __name__ == '__main__':
    unittest.main()
