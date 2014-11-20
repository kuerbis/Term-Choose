use 5.008000;
use warnings;
use strict;
use Test::More;
use FindBin               qw( $RealBin );
use File::Spec::Functions qw( catfile );

BEGIN {
    if ( $^O eq 'MSWin32' ) {
        plan skip_all => "MSWin32: Expect not available.";
    }
    #if ( ! $ENV{TESTS_USING_EXPECT_OK} ) {
    #    plan skip_all => "Environment variable 'TESTS_USING_EXPECT_OK' not enabled.";
    #}
}

eval "use Expect";
if ( $@ ) {
    plan skip_all => "Expect required for $0.";
}

use lib $RealBin;
use Data_Test_Choose;

my $type = 'hide_cursor';

my $exp;
eval {
    $exp = Expect->new();
    $exp->raw_pty( 1 );
    $exp->log_stdout( 0 );
    $exp->slave->set_winsize( 24, 80, undef, undef );

    my $command     = $^X;
    my $script      = catfile $RealBin, 'choose.pl';
    my @parameters  = ( $script, $type );

    -r $script or die "$script is NOT readable";
    $exp->spawn( $command, @parameters ) or die "Spawn '$command @parameters' NOT ok $!";
    1;
}
or plan skip_all => $@;



my $a_ref = Data_Test_Choose::return_test_data( $type );
my $ref = shift @$a_ref;

my $expected = $ref->{expected};
my $ret = $exp->expect( 2,
    [ 'Your choice: ' => sub {
            $exp->send( "\r" );
            'exp_continue';
        }
    ],
    [ $expected => sub {} ],
);

ok( $ret, 'matched something' );
my $result = $exp->match();
$result = '' if ! defined $result;
ok( $result eq $expected, "expected: '$expected', got: '$result'" );

$exp->hard_close();

done_testing();
