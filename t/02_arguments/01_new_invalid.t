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

use lib '../../lib';
use Term::Choose;

use lib 't/';
use Term_Choose_Testdata;

my $exception;

$exception = exception { my $new = Term::Choose->new( {}, {} ) };
ok( $exception =~ /new:/, "\$new = Term::Choose->new( {}, {} ) => $exception" );

$exception = exception { my $new = Term::Choose->new( 'a' ) };
ok( $exception =~ /new:/, "\$new = Term::Choose->new( 'a' ) => $exception" );



my %new;
my $n = 1; # ?

my $invalid_values = Term_Choose_Testdata::invalid_values();

for my $opt ( sort keys %$invalid_values ) {
    for my $val ( @{$invalid_values->{$opt}} ) {
        my $exception = exception { $new{$n++} = Term::Choose->new( { $opt => $val }  ) };
        ok( $exception =~ /new:/, "\$new = Term::Choose->new( { $opt => $val } ) => $exception" );
    }
}


my $mixed_invalid_1 = Term_Choose_Testdata::mixed_invalid_1();
$exception = exception { $new{$n++} = Term::Choose->new( $mixed_invalid_1  ) };
ok( $exception =~ /new:/, "\$new = Term::Choose->new( { >>> } ) => $exception" );


my $mixed_invalid_2 = Term_Choose_Testdata::mixed_invalid_2();
$exception = exception { $new{$n++} = Term::Choose->new( $mixed_invalid_2 ) };
ok( $exception =~ /new:/, "\$new = Term::Choose->new( { <<< } ) => $exception" );



done_testing();
