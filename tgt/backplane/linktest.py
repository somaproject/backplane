import dlstatlib
import manual_boot_dsp
import subprocess
import sys
import time

DSPPATH = "../../../dspboard/tgt/"
sys.path.append(DSPPATH)

import dspboard.fpgaping


dspbitfile = "/home/jonas/soma/bitfiles/dspboard.bit"
devices = range(8)
somaip = "10.0.0.2"

def boot_dsp():
    dspldr =  "/home/jonas/soma/bitfiles/dspboard.ldr"
    dspbootcmd = ["python", "../../../dspboard/tgt/dspboard/dspboot.py",
                  dspldr, "8-23"]

    # now try booting the DSPs:
    proc = subprocess.Popen(dspbootcmd)
    time.sleep(60)

    dspboot_completed = False
    
    if proc.poll() == None:
        # still not done? Terminate
        proc.kill()
    else:
        if proc.returncode == 0:
            dspboot_completed = True
    
    return dspboot_completed



fid = file("linktest.log", 'w')
iter = 0

tgtdevices = range(8, 24)

while True:
    print "booting iter ", iter
    manual_boot_dsp.manual_boot_dsp(dspbitfile, devices)
    dls = dlstatlib.DeviceLinkStatus(somaip)
    
    ls1 = dls.getLinkStatus(4)
    lcc1 = dls.getLinkCycleCount(4)
    lt1 =  dls.getDLTiming()
    
    fp = dspboard.fpgaping.FPGAPing(somaip, tgtdevices)
##     pingtries_pre = []
##     pingN = 1
##     for i in range(pingN):
##         pingsuc, pingfail = fp.ping()
##         pingtries_pre.append((pingsuc, pingfail))
##         time.sleep(1)
##     fp.stop()

    dsp_success = boot_dsp()

    ls2 = dls.getLinkStatus(4)
    lcc2 = dls.getLinkCycleCount(4)
    lt2 =  dls.getDLTiming()
    
    
##     pingtries_post = []
##     pingN = 1
##     for i in range(pingN):
##         pingsuc, pingfail = fp.ping()
##         pingtries_post.append((pingsuc, pingfail))
##         time.sleep(1)

    
    fid.write("%s\n" % [ls1, lcc1, lt1, # pingtries_pre,
                        dsp_success, ls2, lcc2, lt2
                        #pingtries_post
                        ])
    fid.flush()
    dls.stop()
    
    iter += 1
    
