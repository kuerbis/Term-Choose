#!/usr/bin/env perl
use 5.010000;
use warnings;
use strict;

use Term::Choose qw( choose );

use FindBin qw( $RealBin );
use lib $RealBin;
use Data_Test_Arguments;


choose( [] );
choose( [], {} );

my $valid_values = Data_Test_Arguments::valid_values();
for my $opt ( sort keys %$valid_values ) {
    for my $val ( @{$valid_values->{$opt}}, undef ) {
        choose( [], { $opt => $val } );
    }
}

my $mixed_options_1 = Data_Test_Arguments::mixed_options_1();
choose( [], $mixed_options_1 );

my $mixed_options_2 = Data_Test_Arguments::mixed_options_2();
choose( [], $mixed_options_1 );


say "<End_fc_va>";
