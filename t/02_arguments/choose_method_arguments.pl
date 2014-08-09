#!/usr/bin/env perl
use 5.010000;
use warnings;
use strict;
use utf8;

use lib '../../lib';
use Term::Choose;

use lib 't/';
use Term_Choose_Testdata;


my $new = Term::Choose->new();

$new->choose( [] );
$new->choose( [], {} );

my $valid_values = Term_Choose_Testdata::valid_values();
for my $opt ( sort keys %$valid_values ) {
    for my $val ( @{$valid_values->{$opt}}, undef ) {
        $new->choose( [], { $opt => $val } );
    }
}

my $mixed_options_1 = Term_Choose_Testdata::mixed_options_1();
$new->choose( [], $mixed_options_1 );

my $mixed_options_2 = Term_Choose_Testdata::mixed_options_2();
$new->choose( [], $mixed_options_1 );


say "<End_meth_chse_arg_test>";
