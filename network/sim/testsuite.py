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
    suite.addTest(vhdlTestCase("arpresponse"))
    suite.addTest(vhdlTestCase("bitcnt"))
    suite.addTest(vhdlTestCase("txmux"))
    suite.addTest(vhdlTestCase("inputcontrol"))
##     suite.addTest(vhdlTestCase("pingresponse"))
##     suite.addTest(vhdlTestCase("eventtx"))
##     suite.addTest(vhdlTestCase("datapacketgen"))
##     suite.addTest(vhdlTestCase("eventrx"))
##     #suite.addTest(vhdlTestCase("eventretx"))
##     suite.addTest(vhdlTestCase("data"))
##     suite.addTest(vhdlTestCase("dataretxresponse"))
##     suite.addTest(vhdlTestCase("eventretxresponse"))
##     suite.addTest(vhdlTestCase("ipchecksum"))
    
runner = unittest.TextTestRunner()
runner.run(suite)
