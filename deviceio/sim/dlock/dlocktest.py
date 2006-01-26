#!/usr/bin/python
import random


def extractbits(datasrc, dataen):

    data = []

    for i in range(len(datasrc)):
        if dataen[i] == 1:
            data.append(datasrc[i])

    return data

def checkcomma(data, comma):
    pos = []
    for i in range(len(data) - len(comma)):
        if data[i:(i+len(comma))] == comma:
                pos.append(i)
    return pos

def removecomma(datasrc, comma):
    
    pos = 0

    while pos < len(datasrc):
        if pos < 0:
            pos  += 1
        else:
            if datasrc[pos:(pos + len(comma))] == comma:
                if datasrc[pos+len(comma)/2] == 1:
                    datasrc[pos+len(comma)/2] = 0
                else:
                    datasrc[pos+len(comma)/2] = 1
                pos -= len(comma)
            else:

                pos += 1
    

commasym = [0, 0, 1, 1, 1, 1, 1, 0, 1, 0]

wordlen = 10
enrate = 0.97
bits = 1000000

datasrc = []
dataen = []
    
for i in range(bits):
    if random.random() > 0.5:
        datasrc.append(1)
    else:
        datasrc.append(0)



# remove commas from raw byte string

removecomma(datasrc, commasym)

com = checkcomma(datasrc, commasym) 
print "The source random data has ", len(com), " comma symbols"

# now we add our comma characters
numcoms = 600
commaspace = 400
posc = 0
for i in range(numcoms):
    
    p = random.randint(1, 100)
    # before we add the col here we check to make sure we're not causing
    # any extra commas
    startpos = posc + p
    
    tmpdata = list(datasrc[startpos-50:startpos+50])
    tmpdata[50:50+len(commasym)] = commasym
    
    if len(checkcomma(tmpdata, commasym)) > 1:
        print "oops, generated too many commas" 
    
    datasrc[startpos:(startpos  + len(commasym))] = commasym
    posc += commaspace + 100
    
com = checkcomma(datasrc, commasym) 
print "The partitioned  data has ", len(com), " comma symbols"

# add en positions
data = []
dataen = []

fid = file("output.dat", 'w')

# get results
for i in range(len(datasrc)):
    if datasrc[i : (i + len(commasym))] == commasym:
        #print "writing comma at ", i
        word = []
        
        for j in range(commaspace):
            word.append(datasrc[i + j])
            
            if (j+1) % len(commasym) == 0:
                for k in range(len(commasym)):
                    fid.write("%d" % word[9-k])
                fid.write(" ")
                word = []
                
        fid.write("\n")


fidin = file("input.dat", 'w')

for b in datasrc:
    fidin.write ("%d 1\n" % b)
    if random.random() > enrate:
        fidin.write("0 0\n")

