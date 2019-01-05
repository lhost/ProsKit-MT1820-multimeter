
package Device::MT1820;

use strict;
use warnings;

our $VERSION = '0.01';

our @ISA = qw(Exporter);
our @EXPORT_OK = qw( parse_data );

use vars qw( $DEBUG );

$DEBUG = 0;

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
my $unit_map	= {
	0x0020	=> {
		unit	=> 'resistance',
		symbol	=> 'Ohm',
		factor	=> 1,
	},
	0x2020	=> {
		unit	=> 'resistance',
		symbol	=> 'kOhm',
		factor	=> 1E3,
	},
	0x1020	=> {
		unit	=> 'resistance',
		symbol	=> 'MOhm',
		factor	=> 1E6,
	},
	0x0002	=> {
		unit	=> 'temperature',
		symbol	=> '˚C',
		factor	=> 1,
	},
	0x0001	=> {
		unit	=> 'temperature',
		symbol	=> '˚F',
		factor	=> 1,
	},
	0x4080	=> {
		unit	=> 'voltage',
		symbol	=> 'mV',
		factor	=> 1E-3,
	},
	0x0080	=> {
		unit	=> 'voltage',
		symbol	=> 'V',
		factor	=> 1,
	},
	0x8040	=> {
		unit	=> 'current',
		symbol	=> 'μA',
		factor	=> 1E-6,
	},
	0x4040	=> {
		unit	=> 'current',
		symbol	=> 'mA',
		factor	=> 1E-3,
	},
	0x0040	=> {
		unit	=> 'current',
		symbol	=> 'A',
		factor	=> 1,
	},
	0x0480	=> {
		unit	=> 'diode-test',
		symbol	=> 'V',
		factor	=> 1,
	},
	0x0820	=> {
		unit	=> 'continuity-test',
		symbol	=> 'Ohm',
		factor	=> 1,
	},
	0x0008	=> {
		unit	=> 'frequency',
		symbol	=> 'Hz',
		factor	=> 1,
	},
	0x2008	=> {
		unit	=> 'frequency',
		symbol	=> 'kHz',
		factor	=> 1E3,
	},
	0x1008	=> { # TODO: test frequency measurement for MHz signal
		unit	=> 'frequency',
		symbol	=> 'MHz',
		factor	=> 1E6,
	},
	0x0004	=> {
		unit	=> 'capacitance',
		symbol	=> 'nF',
		factor	=> 1E-9,
	},
	0x8004	=> {
		unit	=> 'capacitance',
		symbol	=> 'μF',
		factor	=> 1E-6,
	},
};

my $flags_map = {
	0x2900	=> {
		desc	=> 'AC', # alternating current
	},
	0x3100	=> {
		desc	=> 'DC', # direct current
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

	>>> parse_data("\x{2b}\x{30}\x{32}\x{35}\x{33}\x{20}\x{34}\x{20}\x{00}\x{00}\x{02}\x{00}");
	'temperature 25.3 25.3 ˚C 0% [ 8192 ]'
	>>> parse_data("\x{2b}\x{30}\x{39}\x{38}\x{34}\x{20}\x{34}\x{20}\x{00}\x{00}\x{01}\x{00}");
	'temperature 98.4 98.4 ˚F 0% [ 8192 ]'

	>>> parse_data("\x{2b}\x{34}\x{32}\x{35}\x{39}\x{20}\x{34}\x{31}\x{00}\x{40}\x{80}\x{2a}");
	'voltage-DC 0.4259 425.9 mV 42% [ DC ]'
	>>> parse_data("\x{2b}\x{34}\x{35}\x{30}\x{31}\x{20}\x{31}\x{31}\x{00}\x{00}\x{80}\x{2d}");
	'voltage-DC 4.501 4.501 V 45% [ DC ]'

	>>> parse_data("\x{2b}\x{30}\x{30}\x{30}\x{30}\x{20}\x{31}\x{29}\x{00}\x{00}\x{80}\x{00}");
	'voltage-AC 0 0 V 0% [ AC ]'
	>>> parse_data("\x{2b}\x{32}\x{32}\x{32}\x{30}\x{20}\x{31}\x{29}\x{00}\x{00}\x{80}\x{0b}");
	'voltage-AC 2.22 2.22 V 11% [ AC ]'
	>>> parse_data("\x{2b}\x{30}\x{30}\x{36}\x{34}\x{20}\x{31}\x{29}\x{00}\x{00}\x{80}\x{00}");
	'voltage-AC 0.064 0.064 V 0% [ AC ]'
	>>> parse_data("\x{2b}\x{32}\x{32}\x{35}\x{35}\x{20}\x{34}\x{29}\x{00}\x{00}\x{80}\x{00}");
	'voltage-AC 225.5 225.5 V 0% [ AC ]'

	>>> parse_data("\x{2b}\x{30}\x{30}\x{30}\x{30}\x{20}\x{34}\x{31}\x{00}\x{80}\x{40}\x{00}");
	'current-DC 0 0 μA 0% [ DC ]'
	>>> parse_data("\x{2b}\x{30}\x{30}\x{35}\x{36}\x{20}\x{34}\x{31}\x{00}\x{80}\x{40}\x{00}");
	'current-DC 5.6e-06 5.6 μA 0% [ DC ]'
	>>> parse_data("\x{2b}\x{30}\x{32}\x{38}\x{39}\x{20}\x{34}\x{31}\x{00}\x{80}\x{40}\x{02}");
	'current-DC 2.89e-05 28.9 μA 2% [ DC ]'
	>>> parse_data("\x{2d}\x{34}\x{38}\x{39}\x{37}\x{20}\x{34}\x{31}\x{00}\x{80}\x{40}\x{b0}");
	'current-DC -0.0004897 -489.7 μA -80% [ DC ]'
	>>> parse_data("\x{2d}\x{35}\x{31}\x{36}\x{30}\x{20}\x{34}\x{31}\x{00}\x{80}\x{40}\x{b3}");
	'current-DC -0.000516 -516 μA -77% [ DC ]'

	>>> parse_data("\x{2b}\x{30}\x{30}\x{30}\x{30}\x{20}\x{32}\x{31}\x{00}\x{40}\x{40}\x{00}");
	'current-DC 0 0 mA 0% [ DC ]'
	>>> parse_data("\x{2b}\x{30}\x{30}\x{30}\x{30}\x{20}\x{32}\x{31}\x{00}\x{40}\x{40}\x{80}");
	'current-DC 0 0 mA -128% [ DC ]'
	>>> parse_data("\x{2b}\x{30}\x{36}\x{31}\x{33}\x{20}\x{34}\x{31}\x{00}\x{40}\x{40}\x{06}");
	'current-DC 0.0613 61.3 mA 6% [ DC ]'
	>>> parse_data("\x{2d}\x{35}\x{30}\x{36}\x{39}\x{20}\x{32}\x{31}\x{00}\x{40}\x{40}\x{b2}");
	'current-DC -0.05069 -50.69 mA -78% [ DC ]'

	>>> parse_data("\x{2b}\x{30}\x{30}\x{30}\x{30}\x{20}\x{31}\x{31}\x{00}\x{00}\x{40}\x{00}");
	'current-DC 0 0 A 0% [ DC ]'
	>>> parse_data("\x{2b}\x{33}\x{30}\x{33}\x{33}\x{20}\x{31}\x{31}\x{00}\x{00}\x{40}\x{1e}");
	'current-DC 3.033 3.033 A 30% [ DC ]'
	>>> parse_data("\x{2b}\x{32}\x{39}\x{32}\x{32}\x{20}\x{31}\x{31}\x{00}\x{00}\x{40}\x{1d}");
	'current-DC 2.922 2.922 A 29% [ DC ]'

	>>> parse_data("\x{2b}\x{30}\x{30}\x{30}\x{31}\x{20}\x{32}\x{29}\x{00}\x{40}\x{40}\x{00}");
	'current-AC 1e-05 0.01 mA 0% [ AC ]'
	>>> parse_data("\x{2b}\x{30}\x{30}\x{30}\x{32}\x{20}\x{32}\x{29}\x{00}\x{40}\x{40}\x{00}");
	'current-AC 2e-05 0.02 mA 0% [ AC ]'
	>>> parse_data("\x{2b}\x{30}\x{34}\x{30}\x{35}\x{20}\x{32}\x{29}\x{00}\x{40}\x{40}\x{00}");
	'current-AC 0.00405 4.05 mA 0% [ AC ]'
	>>> parse_data("\x{2b}\x{32}\x{33}\x{32}\x{30}\x{20}\x{32}\x{29}\x{00}\x{40}\x{40}\x{0f}");
	'current-AC 0.0232 23.2 mA 15% [ AC ]'

	>>> parse_data("\x{2b}\x{30}\x{30}\x{30}\x{30}\x{20}\x{31}\x{29}\x{00}\x{00}\x{40}\x{00}");
	'current-AC 0 0 A 0% [ AC ]'
	>>> parse_data("\x{2b}\x{30}\x{30}\x{30}\x{31}\x{20}\x{31}\x{29}\x{00}\x{00}\x{40}\x{00}");
	'current-AC 0.001 0.001 A 0% [ AC ]'
	>>> parse_data("\x{2b}\x{30}\x{30}\x{32}\x{38}\x{20}\x{31}\x{29}\x{00}\x{00}\x{40}\x{0a}");
	'current-AC 0.028 0.028 A 10% [ AC ]'
	>>> parse_data("\x{2b}\x{31}\x{32}\x{35}\x{36}\x{20}\x{31}\x{29}\x{00}\x{00}\x{40}\x{14}");
	'current-AC 1.256 1.256 A 20% [ AC ]'

	>>> parse_data("\x{2b}\x{30}\x{30}\x{30}\x{31}\x{20}\x{34}\x{01}\x{00}\x{08}\x{20}\x{00}");
	'continuity-test 0.1 0.1 Ohm 0% [ 256 ]'
	>>> parse_data("\x{2b}\x{30}\x{30}\x{30}\x{32}\x{20}\x{34}\x{01}\x{00}\x{08}\x{20}\x{00}");
	'continuity-test 0.2 0.2 Ohm 0% [ 256 ]'
	>>> parse_data("\x{2b}\x{30}\x{32}\x{33}\x{36}\x{20}\x{34}\x{01}\x{00}\x{08}\x{20}\x{02}");
	'continuity-test 23.6 23.6 Ohm 2% [ 256 ]'
	>>> parse_data("\x{2b}\x{30}\x{36}\x{31}\x{39}\x{20}\x{34}\x{01}\x{00}\x{08}\x{20}\x{06}");
	'continuity-test 61.9 61.9 Ohm 6% [ 256 ]'
	>>> parse_data("\x{2b}\x{30}\x{38}\x{33}\x{39}\x{20}\x{34}\x{01}\x{00}\x{08}\x{20}\x{08}");
	'continuity-test 83.9 83.9 Ohm 8% [ 256 ]'

	>>> parse_data("\x{2b}\x{30}\x{30}\x{30}\x{30}\x{20}\x{31}\x{00}\x{00}\x{04}\x{80}\x{00}");
	'diode-test 0 0 V 0% [ 0 ]'
	>>> parse_data("\x{2b}\x{31}\x{38}\x{34}\x{32}\x{20}\x{31}\x{00}\x{00}\x{04}\x{80}\x{00}");
	'diode-test 1.842 1.842 V 0% [ 0 ]'

	>>> parse_data("\x{2b}\x{30}\x{30}\x{30}\x{30}\x{20}\x{31}\x{20}\x{00}\x{00}\x{08}\x{3d}");
	'frequency 0 0 Hz 61% [ 8192 ]'
	>>> parse_data("\x{2b}\x{30}\x{35}\x{36}\x{38}\x{20}\x{31}\x{20}\x{00}\x{00}\x{08}\x{3d}");
	'frequency 0.568 0.568 Hz 61% [ 8192 ]'
	>>> parse_data("\x{2b}\x{33}\x{36}\x{33}\x{36}\x{20}\x{31}\x{20}\x{00}\x{00}\x{08}\x{3d}");
	'frequency 3.636 3.636 Hz 61% [ 8192 ]'
	>>> parse_data("\x{2b}\x{31}\x{33}\x{30}\x{39}\x{20}\x{34}\x{20}\x{00}\x{00}\x{08}\x{3d}");
	'frequency 130.9 130.9 Hz 61% [ 8192 ]'
	>>> parse_data("\x{2b}\x{39}\x{38}\x{34}\x{31}\x{20}\x{34}\x{20}\x{00}\x{00}\x{08}\x{3d}");
	'frequency 984.1 984.1 Hz 61% [ 8192 ]'
	>>> parse_data("\x{2b}\x{31}\x{30}\x{34}\x{35}\x{20}\x{31}\x{20}\x{00}\x{20}\x{08}\x{3d}");
	'frequency 1045 1.045 kHz 61% [ 8192 ]'
	>>> parse_data("\x{2b}\x{37}\x{34}\x{39}\x{37}\x{20}\x{31}\x{20}\x{00}\x{20}\x{08}\x{3d}");
	'frequency 7497 7.497 kHz 61% [ 8192 ]'
	>>> parse_data("\x{2b}\x{31}\x{33}\x{32}\x{39}\x{20}\x{32}\x{20}\x{00}\x{20}\x{08}\x{3d}");
	'frequency 13290 13.29 kHz 61% [ 8192 ]'
	>>> parse_data("\x{2b}\x{31}\x{36}\x{39}\x{34}\x{20}\x{34}\x{20}\x{00}\x{20}\x{08}\x{3d}");
	'frequency 169400 169.4 kHz 61% [ 8192 ]'

	>>> parse_data("\x{2b}\x{30}\x{30}\x{32}\x{35}\x{20}\x{32}\x{20}\x{02}\x{00}\x{04}\x{00}");
	'capacitance 2.5e-10 0.25 nF 0% [ 8194 ]'
	>>> parse_data("\x{2b}\x{30}\x{30}\x{34}\x{37}\x{20}\x{32}\x{20}\x{02}\x{00}\x{04}\x{00}");
	'capacitance 4.7e-10 0.47 nF 0% [ 8194 ]'
	>>> parse_data("\x{2b}\x{30}\x{33}\x{30}\x{39}\x{20}\x{32}\x{20}\x{02}\x{00}\x{04}\x{00}");
	'capacitance 3.09e-09 3.09 nF 0% [ 8194 ]'
	>>> parse_data("\x{2b}\x{30}\x{39}\x{31}\x{39}\x{20}\x{34}\x{20}\x{02}\x{00}\x{04}\x{00}");
	'capacitance 9.19e-08 91.9 nF 0% [ 8194 ]'
	>>> parse_data("\x{2b}\x{32}\x{34}\x{38}\x{31}\x{20}\x{34}\x{20}\x{00}\x{80}\x{04}\x{00}");
	'capacitance 0.0002481 248.1 μF 0% [ 8192 ]'
	>>> parse_data("\x{2b}\x{30}\x{34}\x{37}\x{37}\x{20}\x{30}\x{20}\x{00}\x{80}\x{04}\x{3d}");
	'capacitance 0.000477 477 μF 61% [ 8192 ]'

=cut

sub parse_data {
	my ($data) = @_;
	my $doctest;

# 	BYTE:
# 		00       Sign +-
# 		01 - 04  Value, ie. 4 digits from left to right as in display
# 		05       ?
# 		06       Decimal point
# 		07 - 08  Flags 08 only in Farrad maybe belong to unit -  AC / DC indicator
# 		09 - 10  Unit, byte is 09 scale factor (u,m,M) of unit on byte 10
# 		11       Meter at bottom of display, signed value
	$doctest = join('', ">>> parse_data(\"",
		( map { "\\x{" . unpack("H*") . "}" } split( //, $data ) ),
		"\");"
	);
	if ($DEBUG) {
		print STDERR "$doctest\n";
	}

	my ( $string_value, $_space, $decimal_point, $flags, $unit, $meter )
	= unpack( 'A5 A1 A1 n n c', $data );

#	use Data::Dumper;
#	$Data::Dumper::Useqq = 1;
#	print Dumper([
#			$string_value, $_space, $decimal_point, $flags, $unit, $meter,
#		]);
#	print Dumper( [ $unit,  $unit_map->{$unit} ] );
	if ( substr( $data, 0, 2 ) eq '+?' ) {
		my $rv = "undefined data '$string_value'";
		return wantarray ? ($rv, $doctest) : $rv;
	}
	else {
		if ($decimal_point == 4
				and ( substr( $data, 0, 2 ) eq '+0'
					or substr( $data, 0, 2 ) eq '-0'
					or 0.0 + $string_value > 1000.0
					or 0.0 + $string_value < -1000.0
				)
		) {
			$decimal_point = 3;
		}

		if ($unit == 0x8004) { # This condition is only for sure
			# capacitance measurement: in Faraday mode with μF units
			# $decimal_point returned by multimeter is zero. Needs to be fixed.
			$decimal_point ||= 4;
		}

		# add decimal point and convert to float number
		my $value = 0.0 + (
			substr( $string_value, 0, 1 )    # sign '+' or '-'
				. ( substr( $string_value, 1, $decimal_point ) || 0 ) . '.'
				. substr( $string_value, $decimal_point + 1 )
		);
		my $vm = $unit_map->{$unit};
		my $fm = $flags_map->{$flags};

		unless ($vm) {
			my $rv = "undefined measurement '$string_value', unit = $unit";
			return wantarray ? ($rv, $doctest) : $rv;
		}
		my $rv = $vm->{unit} . (
			$fm ? "-$fm->{desc} " : ' '
			)
			. $value * $vm->{factor}
			. " $value $vm->{symbol} $meter% [ "
				. ($fm->{desc} || $flags)
			. " ]";
		return wantarray ? ($rv, $doctest) : $rv;
	}
}

1;
