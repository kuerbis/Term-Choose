#!/usr/bin/env perl
use warnings;
use strict;
use 5.010000;

use lib '../../lib';
use Term::Choose qw( choose );

use lib 't/';
use Term_Choose_Testdata;

my $a_ref = Term_Choose_Testdata::test_options();

for my $ref ( @$a_ref ) {
    my $opt = $ref->[1];
    my @choice = choose(
        [ 0 .. 1999 ],
        $opt
    );
    say "<@choice>";
}
