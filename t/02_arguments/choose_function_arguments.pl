#!/usr/bin/env perl
use 5.010000;
use warnings;
use strict;
use utf8;

use lib '../../lib';
use Term::Choose qw( choose );

use lib 't/';
use Term_Choose_Testdata;


choose( [] );
choose( [], {} );

my $valid_values = Term_Choose_Testdata::valid_values();
for my $opt ( sort keys %$valid_values ) {
    for my $val ( @{$valid_values->{$opt}}, undef ) {
        choose( [], { $opt => $val } );
    }
}

my $mixed_options_1 = Term_Choose_Testdata::mixed_options_1();
choose( [], $mixed_options_1 );

my $mixed_options_2 = Term_Choose_Testdata::mixed_options_2();
choose( [], $mixed_options_1 );


say "<End_func_chse_arg_test>";
