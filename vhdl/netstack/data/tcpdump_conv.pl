#!/usr/bin/perl -w

# converts the output of TCPdump into 
# a nice linear set of bytes for our testbench. 


# standard format to run is
#  /usr/sbin/tcpdump  -x -e -v -s 2000 icmp and dst host cortical


while(<STDIN>) {
 
    
    if (/(ip|arp) (\d+)/) {
	my $bstr = (unpack("B16", pack("n", $2)))[0];
	print "$bstr\n" ;

	#there is other stuff to look for
	/ ([a-f0-9\:]+) ([a-f0-9\:]+) (\w+)/;

	my @src_mac =  split /:/, $1; 
	my @dst_mac =  split /:/, $2; 
	my $proto = $3; 

	$bstr = (unpack("B*", pack("H*", $src_mac[0] . $src_mac[1])))[0];
	print "$bstr\n" ;
	$bstr = (unpack("B*", pack("H*", $src_mac[2] . $src_mac[3])))[0];
	print "$bstr\n" ;
	$bstr = (unpack("B*", pack("H*", $src_mac[4] . $src_mac[5])))[0];
	print "$bstr\n" ;

	$bstr = (unpack("B*", pack("H*", $dst_mac[0] . $dst_mac[1])))[0];
	print "$bstr\n" ;
	$bstr = (unpack("B*", pack("H*", $dst_mac[2] . $dst_mac[3])))[0];
	print "$bstr\n" ;
	$bstr = (unpack("B*", pack("H*", $dst_mac[4] . $dst_mac[5])))[0];
	print "$bstr\n" ;
	if ($proto eq "ip") { print "0000100000000000\n";}
	if ($proto eq "arp") { print "0000100000000110\n";}





	

	

    }
    
    if (/^\W+(.*)/) {
	my @details=split / /, $1;
	foreach (@details) {

	    my $bstr = (unpack("B*", pack("H*", $_)))[0];
	    print "$bstr\n" ;
	}
	
    }

}
