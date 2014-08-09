#!/usr/bin/env perl
use 5.010000;
use warnings;
use strict;
use utf8;

use lib '../../lib';
use Term::Choose qw( choose );

use lib 't/';
use Term_Choose_Testdata;


eval { choose(           ); 1 } and die 'choose();';

eval { choose( undef     ); 1 } and die 'choose( undef );';

eval { choose( {}        ); 1 } and die 'choose( {} );';

eval { choose( undef, {} ); 1 } and die 'choose( undef, {} );';

eval { choose( 'a'       ); 1 } and die 'choose( "a" );';

eval { choose( 1, {}     ); 1 } and die 'choose( 1, {} );';

eval { choose( [], []    ); 1 } and die 'choose( [], [] );';

eval { choose( [], 'b'   ); 1 } and die 'choose( [], "b" );';


my $valid_values = Term_Choose_Testdata::invalid_values();
for my $opt ( sort keys %$valid_values ) {
    for my $val ( @{$valid_values->{$opt}} ) {
        eval { choose( [], { $opt => $val } ); 1 } and die "choose( { $opt => $val } );";
    }
}

my $mixed_options_1 = Term_Choose_Testdata::mixed_invalid_1();
eval { choose( [], $mixed_options_1 ); 1 } and die 'choose( >>> );';

my $mixed_options_2 = Term_Choose_Testdata::mixed_invalid_2();
eval { choose( [], $mixed_options_1 ); 1 } and die 'choose( <<< );';


say "<End_func_chse_invalid_arg_test>";
