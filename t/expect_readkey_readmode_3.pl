#!/usr/bin/env perl
use warnings;
use strict;
use 5.010001;

use Term::ReadKey;

ReadMode 'cbreak';

END{ ReadMode 'normal' }


print "choice:";
