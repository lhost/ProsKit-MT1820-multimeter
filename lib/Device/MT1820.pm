
package Device::MT1820;

use strict;
use warnings;

our $VERSION = '0.01';

our @ISA = qw(Exporter);
our @EXPORT_OK = qw( parse_data );

my $DEBUG = 0;

#use Data::Dumper;
#$Data::Dumper::Useqq = 1;

use constant UNIT_hFE => 0x0010;
use constant UNIT_mV => 0x4080;
use constant UNIT_V => 0x0080;
use constant UNIT_Ohm => 0x0020;
use constant UNIT_kOhm => 0x2020;
use constant UNIT_MOhm => 0x1020;
use constant UNIT_DIODE_V => 0x0480;
use constant UNIT_F => 0x0004;
use constant UNIT_Hz => 0x0008;
use constant UNIT_DUTY_Hz => 0x0200;
use constant UNIT_C => 0x0002;
use constant UNIT_uA => 0x8040;
use constant UNIT_mA => 0x4040;
use constant UNIT_A => 0x0040;

# with help from https://github.com/drahoslavzan/ProsKit-MT1820-Probe/blob/master/proskit.cc#L28
my $value_map	= {
	0x0020	=> {
		par	=> 'resistance',
		desc	=> 'Ohm',
		factor	=> 1E0,
	},
	0x2020	=> {
		par	=> 'resistance',
		desc	=> 'kOhm',
		factor	=> 1E3,
	},
	0x1020	=> {
		par	=> 'resistance',
		desc	=> 'MOhm',
		factor	=> 1E6,
	},
};

=head1 parse_data

	decode binary data to readable format

	Test::Doctest
	>>> parse_data("\x{2b}\x{3f}\x{30}\x{3a}\x{3f}\x{20}\x{34}\x{21}\x{00}\x{00}\x{20}\x{3d}");
	"undefined data '+?0:?'"
	>>> parse_data("+0096 4!\0\0 \0");
	'resistance 9.6 9.6 Ohm 0% [ 8448 ]'
	>>> parse_data("\x{2b}\x{30}\x{31}\x{30}\x{32}\x{20}\x{34}\x{21}\x{00}\x{00}\x{20}\x{01}");
	'resistance 10.2 10.2 Ohm 1% [ 8448 ]'
	>>> parse_data("+5363 4!\0\0 5");
	'resistance 536.3 536.3 Ohm 53% [ 8448 ]'
	>>> parse_data("\x{2b}\x{31}\x{30}\x{32}\x{35}\x{20}\x{31}\x{21}\x{00}\x{20}\x{20}\x{0a}");
	'resistance 1025 1.025 kOhm 10% [ 8448 ]'
	>>> parse_data("\x{2b}\x{31}\x{33}\x{34}\x{39}\x{20}\x{32}\x{21}\x{00}\x{20}\x{20}\x{0d}");
	'resistance 13490 13.49 kOhm 13% [ 8448 ]'
	>>> parse_data("\x{2b}\x{35}\x{38}\x{33}\x{37}\x{20}\x{32}\x{21}\x{00}\x{20}\x{20}\x{3a}");
	'resistance 58370 58.37 kOhm 58% [ 8448 ]'
	>>> parse_data("\x{2b}\x{30}\x{36}\x{34}\x{31}\x{20}\x{34}\x{21}\x{00}\x{20}\x{20}\x{06}");
	'resistance 64100 64.1 kOhm 6% [ 8448 ]'
	>>> parse_data("\x{2b}\x{30}\x{39}\x{39}\x{39}\x{20}\x{34}\x{21}\x{00}\x{20}\x{20}\x{0a}");
	'resistance 99900 99.9 kOhm 10% [ 8448 ]'
	>>> parse_data("\x{2b}\x{31}\x{30}\x{30}\x{33}\x{20}\x{34}\x{21}\x{00}\x{20}\x{20}\x{0a}");
	'resistance 100300 100.3 kOhm 10% [ 8448 ]'
	>>> parse_data("\x{2b}\x{30}\x{36}\x{35}\x{33}\x{20}\x{32}\x{21}\x{00}\x{10}\x{20}\x{06}");
	'resistance 6530000 6.53 MOhm 6% [ 8448 ]'
	>>> parse_data("\x{2b}\x{30}\x{39}\x{32}\x{34}\x{20}\x{32}\x{21}\x{00}\x{10}\x{20}\x{09}");
	'resistance 9240000 9.24 MOhm 9% [ 8448 ]'
	>>> parse_data("\x{2b}\x{32}\x{31}\x{31}\x{31}\x{20}\x{32}\x{21}\x{00}\x{10}\x{20}\x{15}");
	'resistance 21110000 21.11 MOhm 21% [ 8448 ]'
	>>> parse_data("\x{2b}\x{35}\x{39}\x{33}\x{37}\x{20}\x{32}\x{21}\x{00}\x{10}\x{20}\x{3b}");
	'resistance 59370000 59.37 MOhm 59% [ 8448 ]'

=cut

sub parse_data {
	my ($data) = @_;

# 	BYTE:
# 		00       Sign +-
# 		01 - 04  Value, ie. 4 digits from left to right as in display
# 		05       ?
# 		06       Decimal point
# 		07 - 08  Flags 08 only in Farrad maybe belong to unit
# 		09 - 10  Unit, byte is 09 scale factor (u,m,M) of unit on byte 10
# 		11       Meter at bottom of display, signed value
	if ($DEBUG) {
		#print Dumper( $data );
		print STDERR "\t>>> parse_data(\"",
		( map { "\\x{" . unpack("H*") . "}" } split( //, $data ) ),
		"\");\n";
	}

	my ( $string_value, $_space, $decimal_point, $flags, $unit, $meter )
	= unpack( 'A5 A1 A1 n n c', $data );

#	print Dumper([
#			$string_value, $_space, $decimal_point, $flags, $unit, $meter, $_unknown,
#		]);
#	print Dumper( [ $unit, $value_map, $value_map->{$unit} ] );
	if ( substr( $data, 0, 2 ) eq '+?' ) {
		return "undefined data '$string_value'";
	}
	else {
		if ($decimal_point == 4
				and ( substr( $data, 0, 2 ) eq '+0'
					or ( 0.0 + $string_value > 1000.0 ) )
		) {
			$decimal_point = 3;
		}
		# add decimal point and convert to float number
		my $value = 0.0 + (
			substr( $string_value, 0, 1 )    # sign '+' or '-'
				. ( substr( $string_value, 1, $decimal_point ) || 0 ) . '.'
				. substr( $string_value, $decimal_point + 1 )
		);
		my $vm = $value_map->{$unit};
		return "$vm->{par} "
			. $value * $vm->{factor}
			. " $value $vm->{desc} $meter% [ $flags ]";
	}
}

1;