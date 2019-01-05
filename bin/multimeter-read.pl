#!/usr/bin/env perl

use strict;
use warnings;

use English;
use Getopt::Long qw(:config no_auto_abbrev no_ignore_case );
use Pod::Usage;
use Time::HiRes qw( time usleep);
use Data::Dumper;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Device::MT1820 qw( parse_data );

use constant PROTOCOL_LENGTH    => 14;
use constant PROTOCOL_SEPARATOR => "\r\n";
use constant SEPARATOR_LENGTH   => 2;

use vars qw(
	$VERSION
	$DEBUG
	$device $port
	$help $man $verbose
	$stat
);

$VERSION = 0.1;
$DEBUG   = 0;
$help    = $verbose = '';

my $rv = GetOptions(
	'd|debug'    => \$DEBUG,
	'D|device=s' => \$device,
	'help'       => \$help,
	'man'        => \$man,
	'verbose'    => \$verbose,
	's|stat'     => \$stat,
) or pod2usage( { q(-verbose) => 1, q(-message) => 'ERROR: Invalid parameter' } );

pod2usage( -exitval => 0, -verbose => 1 ) if ($help);
pod2usage( -exitval => 0, -verbose => 2 ) if ($man);

$Device::MT1820::DEBUG = $DEBUG;

$device ||= $ARGV[0] || ( $OSNAME eq 'MSWin32' ? 'COM1' : '/dev/ttyUSB0' );

if ( $OSNAME eq 'MSWin32' ) {
	require Win32::SerialPort;
	$port = Win32::SerialPort->new($device);
}
elsif ( $OSNAME eq 'linux' ) {
	require Device::SerialPort;
	$port = Device::SerialPort->new($device);
}

unless ($port) {
	die "Can't open device '$device': $!";
}

$port->baudrate(2400);    # Configure this to match your device
$port->databits(8);
$port->parity("none");
$port->stopbits(1);
$port->debug($DEBUG) if ($DEBUG);

sub timestr {             # {{{
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

if ($stat) {
	$Data::Dumper::Sortkeys = 1;
	$stat                   = {};    # change from scalar to hash. Ugly hack
}

my $buffer = '';

# skip first incomplete data
while (1) {
	my ( $count_in, $string_in ) = $port->read(PROTOCOL_LENGTH);
	die "Read error: $!" unless defined($string_in);
	$buffer .= $string_in;
	my $skip = index( $buffer, PROTOCOL_SEPARATOR );
	if ( length($buffer) >= PROTOCOL_LENGTH and $skip > 0 ) {
		$skip += SEPARATOR_LENGTH;    # remove "\r\n" sequence too
		print "# $skip bytes ignored\n" if ($DEBUG);
		$buffer = substr( $buffer, $skip );
		last;
	}
}

while (1) {
	my ( $count_in, $string_in ) = $port->read(PROTOCOL_LENGTH);
	die "Read error: $!" unless defined($string_in);
	$buffer .= $string_in;
	if ( length($buffer) >= PROTOCOL_LENGTH ) {
		my $data = substr( $buffer, 0, PROTOCOL_LENGTH - SEPARATOR_LENGTH );
		$buffer = substr( $buffer, PROTOCOL_LENGTH );

		if ($stat) {
			my ( $parsed_data, $encoded_data ) = parse_data($data);
			$stat->{$encoded_data} ||= { count => 0, output => $parsed_data };
			$stat->{$encoded_data}->{count} += 1;
			print Dumper($stat);
		}
		else {
			my $parsed_data = parse_data($data);
			my $time        = timestr();
			print STDERR "'$parsed_data'\n" if ($DEBUG);
			print "$time $parsed_data\n";
		}

	}
	else {
		usleep(1000000);
	}
}

__END__

=pod

=head1 NAME

multimeter-read.pl

=head1 SYNOPSIS

	multimeter-read.pl [--device /dev/ttyUSB0]

or

	multimeter-read.pl --debug --device /dev/ttyUSB1
	multimeter-read.pl --debug --device /dev/serial/by-id/usb-Silicon_Labs_CP2102_USB_to_UART_Bridge_Controller_0001-if00-port0

or

	multimeter-read.pl --help
	multimeter-read.pl --man

=head1 DESCRIPTION

This script is used to read data from Multimeter https://www.prokits.com.tw/Product/MT-1820/ or similiar

=head1 OPTIONS

=over 4

=item B<--help>

Print a brief help message and exits.

=item B<--man>

Prints the manual page and exists.

=item B<--debug>

Turn on debugging. Raw binary data are dumped to the STDERR and parsing can be checked

=item B<--device>

Change device for serial connection. Default value is B</dev/ttyUSB0> on Linux and B<COM1> on Windows.

=item B<--stat>

Run in statistics mode. Used with debug mode to capture all measured data and count number of unique values.

=back

=head1 BUGS

Please report any issue on https://github.com/lhost/ProsKit-MT1820-multimeter/issues
Thank you!

=head1 SEE ALSO

	minicom(1)

=head1 AUTHOR

Lubomir Host E<lt>lubomir.host@gmail.comE<gt>

=head1 COPYRIGHT

Copyright (c) 2019 by Lubomir Host. All rights reserved.
This program is covered by the open source GNU GPLv2 license.

=cut

