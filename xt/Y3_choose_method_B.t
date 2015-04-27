use 5.008003;
use warnings;
use strict;
use Test::More;
use Term::Choose;
use FindBin qw( $RealBin );
use lib $RealBin;
use Y_Data_Test_Arguments;

my $new = Term::Choose->new();
my @error;

if (
    eval {
        $new->choose( [] );
        $new->choose( [], {} );
        my $valid_values = Y_Data_Test_Arguments::valid_values();
        for my $opt ( sort keys %$valid_values ) {
            for my $val ( @{$valid_values->{$opt}}, undef ) {
                $new->choose( [], { $opt => $val } );
            }
        }
        $new->choose( [], Y_Data_Test_Arguments::mixed_options_1() );
        $new->choose( [], Y_Data_Test_Arguments::mixed_options_2() );
        1;
    }
) {
    @error = ();
}
else {
    @error = $@;
}

ok( ! @error, "method 'choose' valid arguments: " . ( @error ? "@error" : "ok." ) );

done_testing();
