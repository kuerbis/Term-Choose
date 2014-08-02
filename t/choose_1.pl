#!/usr/bin/env perl
use warnings;
use strict;
use 5.010001;

use Term::Choose qw( choose );

my $choice = choose(
    [ 1 ],
    { prompt => 'Choose: ', layout => 0, mouse => 0, clear_screen => 0, hide_cursor => 0 }
);

say "choice: $choice";
