#!/usr/bin/env perl
use warnings;
use strict;
use 5.010001;

use Term::ReadKey;
use Unicode::GCString;
use Text::LineFold;

ReadMode 'ultra-raw';

END{ ReadMode 'normal' }


print "choice:";
