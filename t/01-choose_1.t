use 5.010001;
use warnings;
use strict;
use Test::More;
use Term::Choose qw( choose );

eval "use Expect";
if ( $@ ) {
    plan skip_all => "Expect required for choose_1.t test.";
}


my $expect = Expect->new();

my $command     = 'perl';
my @parameters  = qw( t/choose_1.pl );


$expect->raw_pty( 1 );
$expect->log_stdout( 0 );
$expect->slave->set_winsize( 24, 80, undef, undef );

ok( $expect->spawn( $command, @parameters ), "Spawn '$command @parameters' OK" );

$expect->send( "\e[C" x 10, "\e[B" x 3, "\x{0d}" );

my $ret = $expect->expect( 3, 'choice: 70' );

ok( $ret, 'matched something' );

ok( $expect->match() eq 'choice: 70', "expected: 'choice: 70', got: '" . $expect->match() . "'" );

done_testing();
