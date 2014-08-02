use 5.010001;
use warnings;
use strict;
use Test::More;

eval "use Expect";
if ( $@ ) {
    plan skip_all => "Expect required for choose_1.t test.";
}

my $exp = Expect->new();
$exp->raw_pty( 1 );
$exp->log_stdout( 0 );
$exp->slave->set_winsize( 80, 24, undef, undef );

my $command     = 'perl';
my $script      = 't/choose_2.pl';
my @parameters  = ( $script );

ok( -r $script, "$script is readable" );

ok( -x $script, "$script is executable" );

ok( $exp->spawn( $command, @parameters ), "Spawn '$command @parameters' OK" );

$exp->send( "\r" );

my $expected = 'choice: 1';

my $ret = $exp->expect( 2, $expected );

ok( $ret, 'matched something' );

ok( $exp->match() eq $expected, "expected: '$expected', got: '" . $exp->match() . "'" );

done_testing();
