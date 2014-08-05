use 5.010001;
use strict;
use warnings;
use Test::More;
use Test::Fatal;

use lib 'lib';
use Term::Choose;

my $new = Term::Choose->new();
my $exception;

$exception = exception { $new->config() };
ok( ! defined $exception, '$new->config()' );

$exception = exception { $new->config( {} ) };
ok( ! defined $exception, '$new->config( {} )' );

$exception = exception { $new->config( {}, {} ) };
ok( $exception =~ /config:/, "\$new->config( {}, {} ) => $exception" );

$exception = exception { $new->config( 'a' ) };
ok( $exception =~ /config:/, "\$new->config( 'a' ) => $exception" );

done_testing();
