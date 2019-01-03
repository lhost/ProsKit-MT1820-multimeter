#!/usr/bin/env perl

use strict;
use warnings;

use English;
use Time::HiRes qw( time usleep);
use FindBin;
use lib "$FindBin::Bin/../lib";

use Device::MT1820 qw( parse_data );

my $DEBUG = 0;

use constant PROTOCOL_LENGTH => 14;
use constant PROTOCOL_SEPARATOR => "\r\n";
use constant SEPARATOR_LENGTH => 2;

my ($device, $port);

if ($OSNAME eq 'MSWin32') {
	$device = $ARGV[0] || 'COM1';
	require Win32::SerialPort;
	$port = Win32::SerialPort->new($device);
}
elsif ($OSNAME eq 'linux') {
	$device = $ARGV[0] || '/dev/ttyUSB0';
	require Device::SerialPort;
	$port = Device::SerialPort->new($device);
}

unless ($port) {
	die "Can't open device '$device': $!";
}

$port->baudrate(2400); # Configure this to match your device
$port->databits(8);
$port->parity("none");
$port->stopbits(1);
$port->debug(1);

sub timestr {    # {{{
	my $sec  = Time::HiRes::time();
	my @cas  = localtime($sec);
	my $text = sprintf(
		"%04d-%02d-%02d %02d:%02d:%02d.%03d",
		$cas[5] + 1900,
		$cas[4] + 1,
		$cas[3], $cas[2], $cas[1], $cas[0], ( 1000 * $sec % 1000 )
	);
	return $text;
}    # }}}

my $buffer = '';

# skip first incomplete data
while (1) {
	my ($count_in, $string_in) = $port->read(PROTOCOL_LENGTH);
	die "Read error: $!" unless defined ($string_in);
	$buffer .= $string_in;
	my $skip = index($buffer, PROTOCOL_SEPARATOR);
	if (length($buffer) >= PROTOCOL_LENGTH and $skip > 0) {
		$skip += SEPARATOR_LENGTH; # remove "\r\n" sequence too
		print "# $skip bytes ignored\n";
		$buffer = substr($buffer, $skip);
		last;
	}
}

while (1) {
	  my ($count_in, $string_in) = $port->read(PROTOCOL_LENGTH);
	  die "Read error: $!" unless defined ($string_in);
	  $buffer .= $string_in;
	  if (length($buffer) >= PROTOCOL_LENGTH) {
		  my $time = timestr();
		  my $data = substr($buffer, 0, PROTOCOL_LENGTH - SEPARATOR_LENGTH);
		  $buffer = substr($buffer, PROTOCOL_LENGTH);
		  my $parsed_data = parse_data($data);
		  print STDERR "\t'$parsed_data'\n" if ($DEBUG);
		  print "$time $parsed_data\n";

	  }
	  else {
		  usleep(1000000);
	  }
}

