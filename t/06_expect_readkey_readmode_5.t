use 5.010001;
use warnings;
use strict;
use Test::More;

eval "use Expect";
if ( $@ ) {
    plan skip_all => "Expect required for $0.";
}

my $exp = Expect->new();
$exp->raw_pty( 1 );
$exp->log_stdout( 0 );
$exp->slave->set_winsize( 80, 24, undef, undef );

my $command     = $^X;
my $script      = 't/expect_readkey_readmode_5.pl';
my @parameters  = ( $script );

ok( -r $script, "$script is readable" );
ok( -x $script, "$script is executable" );
ok( $exp->spawn( $command, @parameters ), "Spawn '$command @parameters' OK" );

my $expected = 'choice:';
my $ret = $exp->expect( 2, $expected );
ok( $ret, 'matched something' );

my $result = $exp->match() // '';

ok( $result eq $expected, "expected: '$expected', got: '$result'" );

$exp->soft_close();

done_testing();
