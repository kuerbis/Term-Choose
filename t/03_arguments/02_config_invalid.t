use 5.010001;
use warnings;
use strict;
use utf8;
use Test::More;
use Test::Fatal;

if( Test::Builder->VERSION < 2 ) {
    for my $method ( qw( output failure_output todo_output ) ) {
        binmode Test::More->builder->$method(), ':encoding(UTF-8)';
    }
}

use lib '../../lib';
use Term::Choose;

use FindBin qw( $RealBin );
use lib $RealBin;
use InvalidValues;

my $exception;
my $new = Term::Choose->new();



$exception = exception { $new->config( {}, {} ) };
ok( $exception =~ /config:/, "\$new->config( {}, {} ) => $exception" );

$exception = exception { $new->config( 'a' ) };
ok( $exception =~ /config:/, "\$new->config( 'a' ) => $exception" );


my $invalid_values = InvalidValues::invalid_values();

for my $opt ( sort keys %$invalid_values ) {
    for my $val ( @{$invalid_values->{$opt}} ) {
        my $exception = exception { $new->config( { $opt => $val }  ) };
        ok( $exception =~ /config:/, "\$new->config( { $opt => $val } ) => $exception" );
    }
}


my $mixed_invalid_1 = InvalidValues::mixed_invalid_1();
$exception = exception { $new->config( $mixed_invalid_1  ) };
ok( $exception =~ /config:/, "\$new->config( { >>> } ) => $exception" );


my $mixed_invalid_2 = InvalidValues::mixed_invalid_2();
$exception = exception { $new->config( $mixed_invalid_2 ) };
ok( $exception =~ /config:/, "\$new->config( { <<< } ) => $exception" );



done_testing();
