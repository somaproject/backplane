import numpy as np
from matplotlib import pyplot
import sys
filename = sys.argv[1]
fid = file(filename, 'r')
d = []
for l in fid.readlines():
    d.append(eval(l))

N = len(d)
K = 4
# extract out the offsets
offsets = np.zeros((K, N))
lengths = np.zeros((K, N))
state = np.zeros((K, N), dtype=np.bool)
upcnts_pre = np.zeros((K, N))
upcnts_post = np.zeros((K, N))

for n in range(N):
    states = d[n][0]
    vals = d[n][2]
    upcnt_pre = d[n][1]
    upcnt_post = d[n][5]
    for k in range(K):
        offsets[k, n] = vals[k][1]
        lengths[k, n] = vals[k][0]
        if not states[k]:
            print "a link was down", k, n
        state[k, n] = states[k]
        upcnts_pre[k, n] = upcnt_pre[k]
        upcnts_post[k, n] = upcnt_post[k]

errors = upcnts_post - upcnts_pre
jitter = 0.3

for i in range(K):
    pyplot.subplot(2, 2, i+1)
    pyplot.scatter(offsets[i] + np.random.normal(0, jitter, N),
                   lengths[i] + np.random.normal(0, jitter, N), s=30,
                   c = (errors[i] > 0)*255)
    pyplot.xlabel("offset")
    pyplot.ylabel("length")
    pyplot.axis([0, 26, 0, 26])
    pyplot.title("Device pos = %d" % i)
pyplot.figure()
pyplot.plot(upcnts_post.T - upcnts_pre.T)

pyplot.show()
