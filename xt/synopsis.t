use 5.10.1;
use strict;
use warnings;
use Test::Synopsis;


$SIG{__WARN__} = sub { die @_ };


use lib 'lib';

use Term::Choose;

all_synopsis_ok();
