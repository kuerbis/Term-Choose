#!/usr/bin/env perl
use 5.010001;
use warnings;
use strict;
use utf8;

use lib '../../lib';
use Term::Choose qw( choose );

use FindBin qw( $RealBin );
use lib $RealBin;
use ValidValues;


choose( [] );
choose( [], {} );

my $valid_values = ValidValues::valid_values();
for my $opt ( sort keys %$valid_values ) {
    for my $val ( @{$valid_values->{$opt}}, undef ) {
        choose( [], { $opt => $val } );
    }
}

my $mixed_options_1 = ValidValues::mixed_options_1();
choose( [], $mixed_options_1 );

my $mixed_options_2 = ValidValues::mixed_options_2();
choose( [], $mixed_options_1 );


say "<End function choose argument test>";
