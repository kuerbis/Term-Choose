#!/usr/bin/env perl
use 5.010000;
use warnings;
use strict;
use utf8;

use lib '../../lib';
use Term::Choose;

use FindBin qw( $RealBin );
use lib $RealBin;
use ValidValues;


my $new = Term::Choose->new();

$new->choose( [] );
$new->choose( [], {} );

my $valid_values = ValidValues::valid_values();
for my $opt ( sort keys %$valid_values ) {
    for my $val ( @{$valid_values->{$opt}}, undef ) {
        $new->choose( [], { $opt => $val } );
    }
}

my $mixed_options_1 = ValidValues::mixed_options_1();
$new->choose( [], $mixed_options_1 );

my $mixed_options_2 = ValidValues::mixed_options_2();
$new->choose( [], $mixed_options_1 );


say "<End method choose argument test>";
