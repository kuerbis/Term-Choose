#!/usr/bin/env perl
use warnings;
use strict;
use 5.010001;
use Term::Choose qw( choose );

my $choice = choose(
    [ 0 .. 99 ],
    { prompt => 'Your choice: ', layout => 0, order => 0,  }
);

say "choice: $choice";
