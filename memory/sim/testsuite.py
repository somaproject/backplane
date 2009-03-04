#!/usr/bin/python

import vhdltest
import unittest
import sys


suite = unittest.TestSuite()

vhdlTestCase = vhdltest.ModelVhdlSimTestCase

if len(sys.argv) > 1 :
    # run those from the command line
    for i in sys.argv[1:]:
        suite.addTest(vhdlTestCase(i))
        
else:

    # core components
    suite.addTest(vhdlTestCase("memory"))
    suite.addTest(vhdlTestCase("memdebug"))

    
runner = unittest.TextTestRunner()
runner.run(suite)
