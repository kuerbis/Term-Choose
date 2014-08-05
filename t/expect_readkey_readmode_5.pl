#!/usr/bin/env perl
use warnings;
use strict;
use 5.010001;

use Term::ReadKey qw( GetTerminalSize ReadKey ReadMode );

ReadMode 'ultra-raw';

END{ ReadMode 'normal' }


print "choice:";
