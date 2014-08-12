#!/usr/bin/env perl
use warnings;
use strict;
use 5.010000;
use utf8;
binmode STDOUT, ':encoding(UTF-8)';

use Term::Choose qw( choose );

use FindBin qw( $RealBin );
use lib $RealBin;
use Data_Test_Choose;

my $a_ref = Data_Test_Choose::test_options();
my $b_ref = Data_Test_Choose::test_list();

my $type = shift;
my $list = $b_ref->{$type};



for my $ref ( @$a_ref ) {
    my $opt = $ref->{options};
    my @choice = choose(
        $list,
        $opt
    );
   say "<@choice>";
}
