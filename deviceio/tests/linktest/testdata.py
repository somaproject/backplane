#!/usr/bin/python2.4
"""
An attempt to use the output of tinyscope to verify our deserialization

"""


"""

we can use a number of tests


"""

from numpy import *
import sys

import tinyscope.analyze as tinyscope

def extractValidBits(DOUT, DOEN):

    return DOUT.compress(DOEN)

def verifyWords(words):

    errors = []
    for i in range(len(words)):
        if i > 0:
            if not (words[i] == words[i-1]).all():

                errors.append(i)

    return errors


if __name__ == "__main__":

    filename = sys.argv[2]

    if sys.argv[1] == "verify":
        
        e = tinyscope.ExtractBits()
        x = e.NCI_GoLogic(filename)

        print "Verification of bitstream %s ..." % filename, 
        for bsnum, bitstream in enumerate(x[:-1]):

            y = tinyscope.deserialize(bitstream)

            DOUT = y[:,7]
            DOEN = y[:,6]
            z = extractValidBits(DOUT, DOEN)
            z = z[:( (len(z)/32) * 32)]
            r = z.reshape((-1, 32))
            errors = verifyWords(r)
            print bsnum, len(bitstream)
            if len(errors) > 0 :
                print "errors in block %s at :" % bsnum, errors 


        print "verify complete"
    elif sys.argv[1] == "samples":
        """
        exportsamples -- exports the sampled bits

        """
        blocknum = sys.argv[3]

        e = tinyscope.ExtractBits()
        x = e.NCI_GoLogic(filename)

        bs = x[int(blocknum)]
        
        y = tinyscope.deserialize(bs)

        bits = y[:, 0:4]
        for b in bits:
            print "%d%d%d%d" % ( b[3], b[2], b[1], b[0])
