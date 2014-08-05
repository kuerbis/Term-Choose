#!/usr/bin/env perl
use warnings;
use strict;
use 5.10.0;
use open qw( :std :utf8 );



use lib 'lib';

use Term::Choose;


my $new;

$new = Term::Choose->new();


$new = Term::Choose->new( {} );

