# Simple code to generate IPtx frames

import re


def getbyte(val, n):
    return (0xFF & (val >> (8*n)))

def str2ip(ip):
    # turns a "18.238.0.1" IP into a 32-bit long
    
    ipre = re.compile("(\d+)\.(\d+)\.(\d+)\.(\d+)")
    result = ipre.search(ip).groups()
    
    return int(result[0])*(2**24) + int(result[1])*(2**16) + \
           int(result[2])*(2**8) + int(result[3])

def str2mac(mac):
    print mac
    macre = re.compile("([\dabcdef]+):([\dabcdef]+):([\dabcdef]+):([\dabcdef]+):([\dabcdef]+):([\dabcdef]+)", re.IGNORECASE)
    result = macre.search(mac).groups()
    return int(result[5], 16)*(2**40) + \
    int(result[4], 16)*(2**32) + \
    int(result[3], 16)*(2**24) + \
    int(result[2], 16)*(2**16) + \
    int(result[1], 16)*(2**8) + \
    int(result[0], 16)

class ARPreq:
    def __init__(self, srcip, srcmac, destip):
        if isinstance(srcip, str) :
            self.srcip = str2ip(srcip)
        else: 
            self.srcip = srcip


        if isinstance(srcmac, str):
            self.srcmac = str2mac(srcmac)
        else:
            self.srcmac = srcmac


        if isinstance(destip, str) :
            self.destip = str2ip(destip)
        else: 
            self.destip = destip

    def generate(self):
        # returns a string for writing into the output

        outstr = "0020 FFFF FFFF FFFF "
        outstr += "%02X%02X %02X%02X %02X%02X "  % (getbyte(self.srcmac, 1),
                                                    getbyte(self.srcmac, 0),
                                                    getbyte(self.srcmac, 3),
                                                    getbyte(self.srcmac, 2),
                                                    getbyte(self.srcmac, 5),
                                                    getbyte(self.srcmac, 4))
        outstr += "0608 0100 0008 0406 0100 " 
        outstr += "%02X%02X %02X%02X %02X%02X " % (getbyte(self.srcmac, 1),
                                                   getbyte(self.srcmac, 0),
                                                   getbyte(self.srcmac, 3),
                                                   getbyte(self.srcmac, 2),
                                                   getbyte(self.srcmac, 5),
                                                    getbyte(self.srcmac, 4))
        outstr += "%02X%02X %02X%02X " % (getbyte(self.srcip, 3),
                                          getbyte(self.srcip, 2),
                                          getbyte(self.srcip, 1),
                                          getbyte(self.srcip, 0))
        outstr += "0000 0000 0000 "
        outstr += "%02X%02X %02X%02X " % (getbyte(self.destip, 3),
                                          getbyte(self.destip, 2),
                                          getbyte(self.destip, 1),
                                          getbyte(self.destip, 0))        

        outstr += "0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 \n"
        return outstr


class IP:
    def __init__(self, srcip, destip, srcmac, destmac, proto):
        # creates a packet of total length lbytes.
        self.header = range(20)


        if isinstance(srcip, str) :
            self.srcip = str2ip(srcip)
        else: 
            self.srcip = srcip


        if isinstance(srcmac, str):
            self.srcmac = str2mac(srcmac)
        else:
            self.srcmac = srcmac


        if isinstance(destip, str) :
            self.destip = str2ip(destip)
        else: 
            self.destip = destip

        if isinstance(destmac, str):
            self.destmac = str2mac(destmac)
        else:
            self.destmac = destmac

        self.proto = proto


    def generate(self, length):
        self.header[0] = 0x45
        self.header[1] = 0x00
        self.header[2] = length >> 8
        self.header[3] = length & 0xFF
        self.header[4] = 0
        self.header[5] = 0
        self.header[6] = 0x40
        self.header[7] = 0x00
        self.header[8] = 0x40  # ttl
        self.header[9] = self.proto
        self.header[10] = 0
        self.header[11] = 0

        # src ip:
        self.header[12] = getbyte(self.srcip, 3)
        self.header[13] = getbyte(self.srcip, 2)
        self.header[14] = getbyte(self.srcip, 1)
        self.header[15] = getbyte(self.srcip, 0)

        #dest ip
        self.header[16] = getbyte(self.destip, 3)
        self.header[17] = getbyte(self.destip, 2)
        self.header[18] = getbyte(self.destip, 1)
        self.header[19] = getbyte(self.destip, 0)


        # compute, set header hceksum
        hsum = ~self.hchecksum()
        print "%X, %02X %02X" % (hsum, (hsum % 256) % 256, (hsum >> 8) % 256)
        self.header[11] = (hsum % 256) % 256
        self.header[10] = (hsum >> 8) % 256

        
        outstr = "%04X " % (length + 14)
        outstr += "%02X%02X %02X%02X %02X%02X "  % (getbyte(self.destmac, 1),
                                                    getbyte(self.destmac, 0),
                                                    getbyte(self.destmac, 3),
                                                    getbyte(self.destmac, 2),
                                                    getbyte(self.destmac, 5),
                                                    getbyte(self.destmac, 4))
        
        outstr += "%02X%02X %02X%02X %02X%02X "  % (getbyte(self.srcmac, 1),
                                                    getbyte(self.srcmac, 0),
                                                    getbyte(self.srcmac, 3),
                                                    getbyte(self.srcmac, 2),
                                                    getbyte(self.srcmac, 5),
                                                    getbyte(self.srcmac, 4))
        outstr += "0008 "

        for i in range(10):
            outstr += "%02X%02X " % (self.header[2*i +1], self.header[2*i])

        # now, the data writing
        for i in range((length-20+1)/2) :
            outstr += "%02X%02X " % (i >> 8, i & 0xFF)
            
        
        outstr += "\n"
        return outstr
    
    def hchecksum(self):
        # compute the header checksum:
        sum = 0
        for i in range(10):
            sum += (self.header[i*2] * 256 + self.header[i*2+1])
            print "%08X %d " % (sum, sum)
        return (sum % 2**16) + (sum >> 16)
    
            
        

class IPTX:
    def __init__(self):
        self.cfid = file("control.dat", 'w')
        self.dfid =  file("data.dat", 'w')
        
    def newpkt(self, length, latency, subnet, netmask, srcip, destip,
               arphit, macresponse, srcmac, proto, arppending = False):
        # netmask is in standard 255.255.0.0 notation
        # subnet, srcip, destip are all 18.238.0.1 notation as well
        # arphit is boolean, macresponse is a string MAC address CO:FF:EE
        # and arppending is a boolean

        # LENGTH is the total length of the packet
        self.netmask = str2ip(netmask)
        self.subnet = str2ip(subnet)
        self.srcip = str2ip(srcip)
        self.destip = str2ip(destip)
        self.arphit = arphit
        self.mac = str2mac(macresponse)
        self.srcmac = str2mac(srcmac)
        self.proto = proto
        if arppending:
            outstr = "1 "
        else:
            outstr = "0 "

            
        outstr += "%d " % length
        outstr += "%d " % proto
        outstr += "%d " % latency
        if arphit:
            outstr += "1 "
        else:
            outstr += "0 "

            
        outstr += "%02X%02X%02X%02X%02X%02X " % (getbyte(self.mac, 5),
                                                 getbyte(self.mac, 4),
                                                 getbyte(self.mac, 3),
                                                 getbyte(self.mac, 2),
                                                 getbyte(self.mac, 1),
                                                 getbyte(self.mac, 0))
        
        outstr += "%02X%02X%02X%02X%02X%02X " % (getbyte(self.srcmac, 5),
                                                 getbyte(self.srcmac, 4),
                                                 getbyte(self.srcmac, 3),
                                                 getbyte(self.srcmac, 2),
                                                 getbyte(self.srcmac, 1),
                                                 getbyte(self.srcmac, 0))

        
        outstr += "%02X%02X%02X%02X " % (getbyte(self.subnet, 3),
                                         getbyte(self.subnet, 2),
                                         getbyte(self.subnet, 1),
                                         getbyte(self.subnet, 0))        
        

        
        outstr += "%02X%02X%02X%02X " % (getbyte(self.srcip, 3),
                                         getbyte(self.srcip, 2),
                                         getbyte(self.srcip, 1),
                                         getbyte(self.srcip, 0))        

        outstr += "%02X%02X%02X%02X " % (getbyte(self.destip, 3),
                                         getbyte(self.destip, 2),
                                         getbyte(self.destip, 1),
                                         getbyte(self.destip, 0))        
        
        



        self.cfid.write(outstr + "\n")

        if arphit :
            ip = IP(srcip, destip, self.srcmac, self.mac, self.proto)
            self.dfid.write(ip.generate(length))
        else:
            arp = ARPreq(self.srcip, self.srcmac, self.destip)
            self.dfid.write(arp.generate())
            
            

def main():
    
    iptx = IPTX()
    iptx.newpkt(100, 4, "18.238.0.0", "255.255.0.0", "18.238.0.1",
                "18.238.1.97", False, "C0:FF:EE:11:22:33", "01:02:03:04:05:06",
                136)

    iptx.newpkt(100, 4, "18.238.0.0", "255.255.0.0", "18.238.0.1",
                "18.238.1.97", True, "C0:FF:EE:11:22:33", "01:02:03:04:05:06",
                136)

    iptx.newpkt(300, 4, "18.238.0.0", "255.255.0.0", "18.238.0.5",
                "18.238.1.23", True, "C0:FF:EE:11:22:33", "01:02:03:04:05:06",
                72)

    iptx.newpkt(1500, 4, "18.238.0.0", "255.255.0.0", "18.238.0.5",
                "18.238.1.23", True, "C0:FF:EE:11:22:33", "01:02:03:04:05:06",
                72)

    iptx.newpkt(100, 4, "18.238.0.0", "255.255.0.0", "18.238.0.5",
                "18.238.1.23", True, "C0:FF:EE:11:22:33", "01:02:03:04:05:06",
                72)

    iptx.newpkt(101, 4, "18.238.0.0", "255.255.0.0", "18.238.0.5",
                "18.238.1.23", True, "C0:FF:EE:11:22:33", "01:02:03:04:05:06",
                72)


    # next stage of latency queries
    iptx.newpkt(100, 1, "18.238.0.0", "255.255.0.0", "18.238.0.5",
                "18.238.1.23", True, "C0:FF:EE:11:22:33", "01:02:03:04:05:06",
                72)
    
    # next stage of latency queries
    iptx.newpkt(800, 7, "18.238.0.0", "255.255.0.0", "18.238.0.5",
                "18.238.1.23", True, "C0:FF:EE:11:22:33", "01:02:03:04:05:06",
                72)
    
    

if __name__ == "__main__":
    main()
