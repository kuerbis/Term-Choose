use 5.010000;
use strict;
use warnings;
use Test::More tests => 1;

BEGIN {
    use lib '../../lib';
    use_ok( 'Term::Choose' ) || print "Bail out!\n";
}

diag( "Testing Term::Choose $Term::Choose::VERSION, Perl $], $^X" );
