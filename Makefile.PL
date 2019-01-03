use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
	AUTHOR       => 'Lubomir Host <lubomir.host@gmail.com>',
	NAME         => 'Device::MT1820',
	VERSION_FROM => 'lib/Device/MT1820.pm',
	test         => { TESTS => 't/*.t t/*/*.t' },
	EXE_FILES  => [ 'bin/multimeter-read.pl', ],
	PREREQ_PM	=> {
		# 'Win32::SerialPort'	=> '0', # if ($OSNAME eq 'MSWin32');
		# 'Device::SerialPort'	=> '0', # if ($OSNAME eq 'linux');
	},
);

sub MY::postamble {
    return <<Makefile
include Rules.mk
Makefile
}
