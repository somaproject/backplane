
env = createEnvironment()
env.createVariable("CountVal")
env.createVariable("total0")
env.createVariable("total1")
env.createVariable("echoCnt")

#############################################################################
#First code
#######################################################################
proc = env.createProc("enableEventProc")
proc.nop()
proc.nop()
# send the first event
y = proc.createVariable("y")
cmd = proc.createVariable("cmd")
proc.load(cmd, 0x05);
dest = proc.createVariable("dest")
proc.load(dest, 0x7);
proc.output(0x87, dest)
proc.output(0x80, cmd)
# send the second event
proc.load(y, 0xAABB)
proc.output(0x81, y)
proc.load(y, 0xCCDD)
proc.output(0x82, y)
proc.load(y, 0xEEFF)
proc.output(0x83, y)
proc.load(dest, 0x08)
proc.load(cmd, 0x06)
proc.output(0x80, cmd)

## enable the cycle-dependent ops

proc.load(y, 1)
proc.output(0x89, y)
proc.label("foreverWaitLoop")
proc.jump("foreverWaitLoop")

# Now the ecycle Proc
ecp = env.createECycleProc()
y = ecp.createVariable("y")
ecp.load(y, 0xABCD)
ecp.output(0x00, y)
ecp.output(0x01, env.CountVal)
ecp.output(0x02, env.total0)
ecp.output(0x03, env.total1)
ecp.output(0x04, env.echoCnt)
ecp.label("ecycwaitloop")
ecp.jump("ecycwaitloop")

# and the event dispatches
cvp = env.createEProc((0, 0), (0, 0))
cvp.move(env.CountVal, ereg.edata[0])

t0p = env.createEProc((16, 31), (30, 39))
t0py = env.createVariable("t0py")
t0p.move(t0py, ereg.edata[0])
t0p.output(0x04, t0py)
t0p.add(env.total0, t0py)
t0p.output(0x04, env.total0)

# the echo process
echop = env.createEProc((128, 128), (60, 60))
# load up the echo
echocmd = echop.createVariable("echocmd")
echop.move(echocmd, ereg.cmd)
echosrc = echop.createVariable("echosrc")
echop.move(echosrc, ereg.src)
echoData0 = echop.createVariable("echoData0")
echop.move(echoData0, ereg.edata[0])
# write it out
echop.output(0x81, echoData0)
echop.output(0x87, echosrc)
echop.output(0x80, echocmd)
echop.output(0x10, echocmd)


