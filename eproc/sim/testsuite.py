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
    
    suite.addTest(vhdlTestCase("alu"))
    suite.addTest(vhdlTestCase("basicload"))
    suite.addTest(vhdlTestCase("jump"))
    suite.addTest(vhdlTestCase("eproc"))
    
runner = unittest.TextTestRunner()
runner.run(suite)
