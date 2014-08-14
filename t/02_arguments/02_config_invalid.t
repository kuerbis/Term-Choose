use 5.010000;
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

use Term::Choose;

use FindBin qw( $RealBin );
use lib $RealBin;
use Data_Test_Arguments;

my $exception;
my $new = Term::Choose->new();



$exception = exception { $new->config( {}, {} ) };
ok( $exception =~ /config:/, "\$new->config( {}, {} ) => $exception" );

$exception = exception { $new->config( 'a' ) };
ok( $exception =~ /config:/, "\$new->config( 'a' ) => $exception" );

$exception = exception { $new->config( { hello => 1, world => 2 } ) };
ok( $exception =~ /config:/, "\$new->config( { hello => 1, world => 2 } ) => $exception" );


my $invalid_values = Data_Test_Arguments::invalid_values();

for my $opt ( sort keys %$invalid_values ) {
    for my $val ( @{$invalid_values->{$opt}} ) {
        my $exception = exception { $new->config( { $opt => $val }  ) };
        ok( $exception =~ /config:/, "\$new->config( { $opt => $val } ) => $exception" );
    }
}


my $mixed_invalid_1 = Data_Test_Arguments::mixed_invalid_1();
$exception = exception { $new->config( $mixed_invalid_1  ) };
ok( $exception =~ /config:/, "\$new->config( { >>> } ) => $exception" );


my $mixed_invalid_2 = Data_Test_Arguments::mixed_invalid_2();
$exception = exception { $new->config( $mixed_invalid_2 ) };
ok( $exception =~ /config:/, "\$new->config( { <<< } ) => $exception" );



done_testing();
