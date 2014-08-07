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

my $exp = Expect->new();
$exp->raw_pty( 1 );
$exp->log_stdout( 0 );
$exp->slave->set_winsize( 24, 80, undef, undef );

my $command     = $^X;
my $script      = catfile $RealBin, 'choose_method_arguments.pl';
my @parameters  = ( $script );

ok( -r $script, "$script is readable" );
ok( -x $script, "$script is executable" );
ok( $exp->spawn( $command, @parameters ), "Spawn '$command @parameters' OK" );

my $expected = '<End method choose argument test>';
my $ret = $exp->expect( 2, [ qr/.....+/ ] );

ok( $ret, 'matched something' );
my $result = $exp->match() // '';
ok( $result eq $expected, "expected: '$expected', got: '$result'" );

$exp->soft_close();

done_testing();
