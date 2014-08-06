#!/usr/bin/env perl
use warnings;
use strict;
use 5.010001;

use lib '../../lib';
use Term::Choose qw( choose );

my $choice = choose(
    [ 0 .. 199 ],
    { prompt => 'Your choice: ', layout => 0, order => 0, hide_cursor => 0, clear_screen => 0  }
);

say "choice: $choice";
