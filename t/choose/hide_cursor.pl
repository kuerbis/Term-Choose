#!/usr/bin/env perl
use warnings;
use strict;
use 5.010000;

use lib '../../lib';
use Term::Choose qw( choose );

my $choice = choose(
    [ 1 .. 199 ],
    { prompt => 'Your choice: ', order => 0, layout => 0, hide_cursor => 1, clear_screen => 0  }
);

say "choice: $choice";
