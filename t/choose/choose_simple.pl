#!/usr/bin/env perl
use warnings;
use strict;
use 5.010000;
use Term::Choose qw( choose );

my $choice = choose(
    [ 2 ],
    { prompt => 'Your choice: ', order => 0, layout => 0, hide_cursor => 0 }
);
say '<' . $choice . '>';
