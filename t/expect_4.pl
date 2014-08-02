#!/usr/bin/env perl
use warnings;
use strict;
use 5.010001;

use Term::Choose qw( choose );

print "Enter: ";
my $choice = <STDIN>;
chomp $choice;

say "<$choice>";
