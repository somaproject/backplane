#!/usr/bin/perl -w
use strict;
use Socket;


use constant SIMPLE_UDP_PORT => 7000;

use constant REMOTE_HOST => 'cortical';

my $trans_serv = getprotobyname( 'udp' );

my $remote_host = gethostbyname( REMOTE_HOST );

my $remote_port = SIMPLE_UDP_PORT;

my $destination = sockaddr_in( $remote_port, $remote_host );

socket( UDP_SOCK, PF_INET, SOCK_DGRAM, $trans_serv );

my $data = "This is a simple UDP message";

send( UDP_SOCK, $data, 0, $destination );

close UDP_SOCK;
