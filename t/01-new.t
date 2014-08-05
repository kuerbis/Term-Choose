use 5.010001;
use strict;
use warnings;
use Test::More;
use Test::Fatal;

use lib 'lib';
use Term::Choose;

my $new1; # ?
my $exception;

my $ex = exception { $new1 = Term::Choose->new() };
ok( ! defined $exception, '$new = Term::Choose->new()' );

ok( $new1, '$new = Term::Choose->new()' );

my $new;
$exception = exception { $new = Term::Choose->new( {} ) };
ok( ! defined $exception, '$new = Term::Choose->new( {} )' );

$exception = exception { $new = Term::Choose->new( {}, {} ) };
ok( $exception =~ /new:/, "\$new = Term::Choose->new( {}, {} ) => $exception" );

$exception = exception { $new = Term::Choose->new( 'a' ) };
ok( $exception =~ /new:/, "\$new = Term::Choose->new( 'a' ) => $exception" );

done_testing();
