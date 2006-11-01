#!/usr/bin/python

import numpy as n

N = 96

for i in range(N+1):
    a = n.zeros(N, int)

    for j in range(i):
        a[j] = 1
    for q in range(10):
        
        ap = n.random.permutation(a)

        for b in ap:
            print b,

        print i
    
        
    
    
