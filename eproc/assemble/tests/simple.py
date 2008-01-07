
env = createEnvironment()
env.createVariable("x")
proc = env.createProc("testproc")
proc.nop()
proc.nop()
y = proc.createVariable("y")
z = proc.createVariable("z")
w = proc.createVariable("w")

proc.load(env.x, 0x12)
proc.load(y, 0x34)
proc.load(z, 0x5678)
proc.move(w, z)
proc.output(0x80, w)
proc.move(w, ereg.cmd)
proc.move(w, ereg.src)
proc.move(w, ereg.edata[0])

