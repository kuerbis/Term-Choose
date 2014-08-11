#!/usr/bin/env perl
use warnings;
use strict;
use 5.010000;

use lib '../../lib';
use Term::Choose qw( choose );

for my $count ( 1 .. 32 ) {
    my @choice = choose(
        [ 0 .. 1999 ],
        { order => 0, layout => 0, hide_cursor => 0 }
    );
    say "<@choice>";
}
