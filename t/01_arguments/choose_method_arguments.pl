#!/usr/bin/env perl
use 5.008003;
use warnings;
use strict;

use Term::Choose;

use FindBin qw( $RealBin );
use lib $RealBin;
use Data_Test_Arguments;


my $new = Term::Choose->new();

$new->choose( [] );
$new->choose( [], {} );

my $valid_values = Data_Test_Arguments::valid_values();
for my $opt ( sort keys %$valid_values ) {
    for my $val ( @{$valid_values->{$opt}}, undef ) {
        $new->choose( [], { $opt => $val } );
    }
}

my $mixed_options_1 = Data_Test_Arguments::mixed_options_1();
$new->choose( [], $mixed_options_1 );

my $mixed_options_2 = Data_Test_Arguments::mixed_options_2();
$new->choose( [], $mixed_options_1 );


print "<End_mc_va>\n";
