#!/usr/bin/env perl
use warnings;
use strict;
use 5.10.1;

use Term::Choose qw( choose );

use FindBin qw( $RealBin );
use lib $RealBin;
use Z_Data_Test_Choose;


my $type = shift;
my $a_ref = Z_Data_Test_Choose::return_test_data( $type );

for my $ref ( @$a_ref ) {
    my $opt  = $ref->{options};
    my $list = $ref->{list};
    my @choice = choose(
        $list,
        $opt
    );
   print "<@choice>\n";
}
