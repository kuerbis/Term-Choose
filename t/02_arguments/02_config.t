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


my $new = Term::Choose->new();
my $exception;

$exception = exception { $new->config() };
ok( ! defined $exception, '$new->config()' );

$exception = exception { $new->config( {} ) };
ok( ! defined $exception, '$new->config( {} )' );


my $valid_values = Term_Choose_Testdata::valid_values();
my $new1  = Term::Choose->new( { order => 1, layout => 2, mouse => 3 } ); # ?

for my $opt ( sort keys %$valid_values ) {
    for my $val ( @{$valid_values->{$opt}}, undef ) {
        my $exception = exception { $new1->config( { $opt => $val } ) };
        ok( ! defined $exception, "\$new->config( { $opt => " . ( $val // 'undef' ) . " } )"  );
    }
}


my $mixed_options_1 = Term_Choose_Testdata::mixed_options_1();
$exception = exception { $new1->config( $mixed_options_1 ) };
ok( ! defined $exception, "\$new->config( { >>> } )"  );


my $mixed_options_2 = Term_Choose_Testdata::mixed_options_2();
$exception = exception { $new1->config( $mixed_options_2 ) };
ok( ! defined $exception, "\$new->config( { <<< } )" );



done_testing();
