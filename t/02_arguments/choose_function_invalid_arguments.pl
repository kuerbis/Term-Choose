#!/usr/bin/env perl
use 5.008000;
use warnings;
use strict;

use Term::Choose qw( choose );

use FindBin qw( $RealBin );
use lib $RealBin;
use Data_Test_Arguments;


eval { choose(           ); 1 } and die 'choose();';

eval { choose( undef     ); 1 } and die 'choose( undef );';

eval { choose( {}        ); 1 } and die 'choose( {} );';

eval { choose( undef, {} ); 1 } and die 'choose( undef, {} );';

eval { choose( 'a'       ); 1 } and die 'choose( "a" );';

eval { choose( 1, {}     ); 1 } and die 'choose( 1, {} );';

eval { choose( [], []    ); 1 } and die 'choose( [], [] );';

eval { choose( [], 'b'   ); 1 } and die 'choose( [], "b" );';

eval { choose( [], { hello => 1, world => 2 } ); 1 } and die 'choose( [], { hello => 1, world => 2 } );';


my $valid_values = Data_Test_Arguments::invalid_values();
for my $opt ( sort keys %$valid_values ) {
    for my $val ( @{$valid_values->{$opt}} ) {
        eval { choose( [], { $opt => $val } ); 1 } and die "choose( { $opt => $val } );";
    }
}

my $mixed_options_1 = Data_Test_Arguments::mixed_invalid_1();
eval { choose( [], $mixed_options_1 ); 1 } and die 'choose( >>> );';

my $mixed_options_2 = Data_Test_Arguments::mixed_invalid_2();
eval { choose( [], $mixed_options_1 ); 1 } and die 'choose( <<< );';


print "<End_fc_ia>\n";
