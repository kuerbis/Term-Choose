use 5.010000;
use warnings;
use strict;
use Test::More;
use FindBin               qw( $RealBin );
use File::Spec::Functions qw( catfile );

eval "use Expect";
if ( $@ ) {
    plan skip_all => "Expect required for $0.";
}

use lib $RealBin;
use Data_Test_Choose;

my $type = 'simple';

my $exp;
eval {
    $exp = Expect->new();
    $exp->raw_pty( 1 );
    $exp->log_stdout( 0 );
    $exp->slave->clone_winsize_from( \*STDIN );

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

my $ret = $exp->expect( 2, [ qr/Your choice: .*/ ] );
my $expected = $ref->{expected};
$exp->send( "\r" );
$ret = $exp->expect( 2, [ qr/<.+>/ ] );
ok( $ret, 'matched something' );

my $result = $exp->match() // '';
ok( $result eq $expected, qq[expected: "$expected", got: "$result"] );

$exp->hard_close();

done_testing();
