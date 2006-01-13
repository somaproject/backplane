
from scipy import *
epsilon = 4.6
w = 9 # trace width 
s = 9 # trace separation 
t = 1.4 # trace thickness 
h = 7.5 # height above ground plane

Z0 = 60. / sqrt(0.457*epsilon +0.67)*log(4*h/(0.67*(0.8*w + t)))

Zdiff = 2*Z0 * (1- 0.48*exp(-0.96*(s/h)))

print "Z0 = ", Z0
print "Zdiff = ", Zdiff
