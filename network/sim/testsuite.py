#!/usr/bin/python

import vhdltest
import unittest
import sys


suite = unittest.TestSuite()

vhdlTestCase = vhdltest.SymphonyVhdlSimTestCase

if len(sys.argv) > 1 :
    # run those from the command line
    for i in sys.argv[1:]:
        suite.addTest(vhdlTestCase(i))
        
else:

    # core components
    
    suite.addTest(vhdlTestCase("txmux"))
    suite.addTest(vhdlTestCase("inputcontrol"))
    suite.addTest(vhdlTestCase("pingresponse"))
    suite.addTest(vhdlTestCase("arpresponse"))
    suite.addTest(vhdlTestCase("eventtx"))
    suite.addTest(vhdlTestCase("datapacketgen"))
    suite.addTest(vhdlTestCase("eventrx"))
    
runner = unittest.TextTestRunner()
runner.run(suite)
