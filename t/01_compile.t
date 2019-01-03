use strict;
use warnings;
use Test::Most tests => 1;

use lib (qw( lib ));

bail_on_fail;

use_ok 'Device::MT1820';
