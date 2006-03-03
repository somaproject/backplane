
from scipy import *

def calcZ(w, s, t, h, epsilon=4.6) :
    Z0 = 60. / sqrt(0.457*epsilon +0.67)*log(4*h/(0.67*(0.8*w + t)))

    Zdiff = 2*Z0 * (1- 0.48*exp(-0.96*(s/h)))
    

    return (Z0, Zdiff)

w = 11 # trace width 
s = 14 # trace separation 
t = 1.4 # trace thickness 
h = 7.5 # height above ground plane

print calcZ(w, s, t, h)

lw = w*2+s+1.5*s
print "Lane width = ", lw, " mil" 

print "total width = " ,  lw*12
