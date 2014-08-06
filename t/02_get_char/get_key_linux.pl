#!/usr/bin/env perl
use warnings;
use strict;
use 5.010001;
use Term::ReadKey;

use lib '../../lib';
use Term::Choose::Constants qw( :linux );
use Term::Choose::Linux;

ReadMode 'ultra-raw';
END{ ReadMode 'normal' }

my $linux = Term::Choose::Linux->new();

my $key = $linux->__get_key_OS( 0 );

say "<$key>";
