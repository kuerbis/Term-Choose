use 5.010001;
use warnings;
use strict;
use Test::More;

BEGIN {
    if ( $^O eq 'MSWin32' ) {
        plan skip_all => "MSWin32: no escape sequences.";
    }
}

eval "use Expect";
if ( $@ ) {
    plan skip_all => "Expect required for $0.";
}

use lib 'lib';
use Term::Choose::Constants qw( :linux );

no warnings 'once';

$Expect::Debug        = 0;
$Expect::Exp_Internal = 0;
$Expect::Log_Stdout   = 0;

my $script     = 't/get_key_linux.pl';
ok( -r $script, "$script is readable" );
ok( -x $script, "$script is executable" );

for my $char ( qw( h j k l q ), ' ', "\t" ) {
    my $e = Expect->new();
    $e->raw_pty( 1 );
    $e->slave->set_winsize( 80, 24, undef, undef );
    ok( $e->spawn( $script ), "Spawn '$script' OK" );
    $e->send( $char );
    my $expected = '<' . ord( $char ) . '>';
    my $ret = $e->expect( 3, , $expected );
    ok( $ret, 'matched something' );
    ok( $e->match() eq $expected, "expected: '$expected', got: '" . $e->match() . "'" );
    $e->soft_close();
}

for my $char ( "\cA", "\cB", "\cC", "\cD", "\cE", "\cF", "\cH", "\cI", "\c@" ) {
    say $char;
    my $e = Expect->new();
    $e->raw_pty( 1 );
    $e->slave->set_winsize( 80, 24, undef, undef );
    ok( $e->spawn( $script ), "Spawn '$script' OK" );
    $e->send( $char );
    my $expected = '<' . ord( $char ) . '>';
    my $ret = $e->expect( 3, , $expected );
    ok( $ret, 'matched something' );
    ok( $e->match() eq $expected, "expected: '$expected', got: '" . $e->match() . "'" );
    $e->soft_close();
}

my $array = [
    [ [ "\e[A", "\eOA" ],   VK_UP ],
    [ [ "\e[B", "\eOB" ],   VK_DOWN ],
    [ [ "\e[C", "\eOC" ],   VK_RIGHT ],
    [ [ "\e[D", "\eOD" ],   VK_LEFT ],
    [ [ "\e[F", "\eOF" ],   VK_END ],
    [ [ "\e[H", "\eOH" ],   VK_HOME ],
    [ [ "\e[Z", "\eOZ" ],   KEY_BTAB ],
    [ [ "\e" ],             KEY_ESC ],
    [ [ "\e[2~" ],          VK_INSERT ],
    [ [ "\e[3~" ],          VK_DELETE ],
    [ [ "\e[5~" ],          VK_PAGE_UP ],
    [ [ "\e[6~" ],          VK_PAGE_DOWN ],
];

for my $elem ( @$array ) {
    for my $seq ( @{$elem->[0]} ) {
        my $e = Expect->new();
        $e->raw_pty( 1 );
        $e->slave->set_winsize( 80, 24, undef, undef );
        ok( $e->spawn( $script ), "Spawn '$script' OK" );
        $e->send( $seq );
        my $expected = '<' . $elem->[1] . '>';
        my $ret = $e->expect( 3, , $expected );
        ok( $ret, 'matched something' );
        ok( $e->match() eq $expected, "expected: '$expected', got: '" . $e->match() . "'" );
            $e->soft_close();
        }
}

done_testing();
