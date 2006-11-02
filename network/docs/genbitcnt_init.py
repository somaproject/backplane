#!/usr/bin/python

"""
Generates the INIT declarations for our bitcnt

we loop through all 2**12 values, count the number of bits in that value, and use that as our word.

We then properly format the resulting list


"""

N = 12

def bitcnt(x):
    sum = 0 
    for i in range(N):
        sum += ((x >> i) & 0x1)

    return sum

bitlist = []
for i in range(2**N):
    bitlist.append(bitcnt(i))

# generate the inits
print bitlist
linenum = 0

while len(bitlist) > 0:
    ostr = ""

    for i in range(64):
        ostr = ("%X" % bitlist.pop(0)) + ostr
    print 'INIT_%2.2X => X"%s",' % ( linenum, ostr)
        
    linenum +=1
