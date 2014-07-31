#!/usr/bin/env perl
use warnings;
use strict;
use 5.010001;

use Term::Choose qw( choose );

my $choice = choose(
    [ 1 ]
);

say "choice: $choice";
