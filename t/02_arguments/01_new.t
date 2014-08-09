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


my $new1;
my $exception = exception { $new1 = Term::Choose->new() };
ok( ! defined $exception, '$new = Term::Choose->new()' );
ok( $new1, '$new = Term::Choose->new()' );

my $new;
$exception = exception { $new = Term::Choose->new( {} ) };
ok( ! defined $exception, '$new = Term::Choose->new( {} )' );


my %new;
my $n = 1; # ?

my $valid_values = Term_Choose_Testdata::valid_values();

for my $opt ( sort keys %$valid_values ) {
    for my $val ( @{$valid_values->{$opt}}, undef ) {
        my $exception = exception { $new{$n++} = Term::Choose->new( { $opt => $val } ) };
        ok( ! defined $exception, "\$new = Term::Choose->new( { $opt => " . ( $val // 'undef' ) . " } )" );
    }
}


my $mixed_options_1 = Term_Choose_Testdata::mixed_options_1();
$exception = exception { $new{$n++} = Term::Choose->new( $mixed_options_1 ) };
ok( ! defined $exception, "\$new = Term::Choose->new( { >>> } )"  );


my $mixed_options_2 = Term_Choose_Testdata::mixed_options_2();
$exception = exception { $new{$n++} = Term::Choose->new( $mixed_options_2 ) };
ok( ! defined $exception, "\$new = Term::Choose->new( { <<< } )" );



done_testing();
