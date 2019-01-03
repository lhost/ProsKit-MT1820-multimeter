#!/usr/bin/env perl

use strict;
use warnings;

use Test::Doctest;

use lib qw( lib );

open my $files,
'find lib -type f -name "*.pm" | xargs grep -l Test::Doctest | xargs grep -h -E "^package " |'
	or die "Can't get list of modules: $!";

runtests( sort map /^package\s+(\S+?)\s*;/, <$files> );

