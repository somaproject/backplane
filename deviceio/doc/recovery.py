from scipy import *

from matplotlib.pylab import *
import random

random.seed(0)

fs = 1e12
dr = 240e6
sr = dr * 32/31. * 4. 

bitlen = 30
bits =[ 1, 0, 1, 1, 0, 1, 1, 1, 0, 1,
        0, 0, 1, 0, 1, 1, 0, 1, 0, 0,
        1, 0, 0, 0, 1, 0, 1, 0, 1, 1]
#for i in range(bitlen):
#    if random.random() > 0.5:
#        bits.append(1)
#    else:
#        bits.append(0)
        


bitsize = int(fs/dr)
samplepos = int(fs/sr)
data = zeros((bitsize*len(bits),), Int8)


for p, b in enumerate(bits):
    offset = 0 # int(bitsize*0.4)
    jamount = 0 #int(bitsize * 0.01 / 2.)
    j1 = 0# random.randrange(-jamount, jamount)
    j2 = 0
    data[(p*bitsize+offset+j1):((p+1)*bitsize+offset+j2)] = b


pos = 0
recdata = []
recpos = []
while pos <= len(bits)*bitsize :
    recpos.append(pos)
    recdata.append(data[pos])
    pos += samplepos

phaseA = [recpos[::4], recdata[::4]]
phaseB = [recpos[1::4], recdata[1::4]]
phaseC = [recpos[2::4], recdata[2::4]]
phaseD = [recpos[3::4], recdata[3::4]]
    
plot(data)
print len(phaseA[0])
print len(phaseA[1])
circsize = 10
scatter(phaseA[0], phaseA[1], circsize, 'r',  faceted=False)
scatter(phaseB[0], phaseB[1], circsize,  'b', faceted=False)
scatter(phaseC[0], phaseC[1], circsize, 'g', faceted=False)
scatter(phaseD[0], phaseD[1], circsize, 'y', faceted=False)

# now we generate the points
print "we have ", bitlen, "bits but we recorded", len(phaseA[0])

tuples = []

for i in range(len(phaseA[0])):
    try:
        tuples.append((phaseA[1][i], phaseB[1][i],
                       phaseC[1][i], phaseD[1][i]))
    except:
        pass
    

# now, recover the data stream:
spos = 2
lastt = (0, 0, 0, 0)
result = []
dpos = 0
lspos = spos

for t in tuples:

    result.append(t[(spos + 1) % 4])
    print t, "spos =", spos, "t= ", t[(spos+1) % 4],

    if t[0] != lastt[3]:
        spos = 0
    elif t[1] != t[0]:
        spos = 1
    elif t[2] != t[1]:
        spos = 2
    elif t[3] != t[2]:
        spos = 3

    if dpos < len(bits):
        if lspos != spos and spos ==3:
            print
        else:
            print bits[dpos]
            dpos += 1
        
    lspos = spos
        
    lastt = t

print "we recovered", len(result)
#show()

