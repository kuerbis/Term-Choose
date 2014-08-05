#!/usr/bin/env perl
use warnings;
use strict;
use 5.010001;

use lib 'lib';
use Term::Choose qw( choose );


my $choice = choose( [ 1 ], { prompt => 'Your choice: ', hide_cursor => 0, clear_screen => 0 } );

print "choice: $choice";
