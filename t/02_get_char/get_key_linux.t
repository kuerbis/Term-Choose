use 5.010000;
use warnings;
use strict;
use Test::More;
use FindBin               qw( $RealBin );
use File::Spec::Functions qw( catfile );

BEGIN {
    if ( $^O eq 'MSWin32' ) {
        plan skip_all => "MSWin32: no escape sequences.";
    }
}

eval "use Expect";
if ( $@ ) {
    plan skip_all => "Expect required for $0.";
}

use lib '../../lib';
use Term::Choose::Constants qw( :linux );


my $script     = catfile $RealBin, 'get_key_linux.pl';
ok( -r $script, "$script is readable" );
ok( -x $script, "$script is executable" );

for my $char ( qw( h j k l q ), ' ', "\t" ) {
    my $exp = Expect->new();
    $exp->raw_pty( 1 );
    $exp->slave->set_winsize( 24, 80, undef, undef );
    ok( $exp->spawn( $script ), "Spawn '$script' OK" );
    $exp->send( $char );
    my $expected = '<' . ord( $char ) . '>';
    my $ret = $exp->expect( 3, , $expected );
    ok( $ret, 'matched something' );
    my $result = $exp->match() // '';
    ok( $result eq $expected, "expected: '$expected', got: '$result'" );
    $exp->soft_close();
}

for my $char ( "\cA", "\cB", "\cC", "\cD", "\cE", "\cF", "\cH", "\cI", "\c@" ) {
    say $char;
    my $exp = Expect->new();
    $exp->raw_pty( 1 );
    $exp->slave->set_winsize( 24, 80, undef, undef );
    ok( $exp->spawn( $script ), "Spawn '$script' OK" );
    $exp->send( $char );
    my $expected = '<' . ord( $char ) . '>';
    my $ret = $exp->expect( 3, , $expected );
    ok( $ret, 'matched something' );
    my $result = $exp->match() // '';
    ok( $result eq $expected, "expected: '$expected', got: '$result'" );
    $exp->soft_close();
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
        my $exp = Expect->new();
        $exp->raw_pty( 1 );
        $exp->slave->set_winsize( 24, 80, undef, undef );
        ok( $exp->spawn( $script ), "Spawn '$script' OK" );
        $exp->send( $seq );
        my $expected = '<' . $elem->[1] . '>';
        my $ret = $exp->expect( 3, , $expected );
        ok( $ret, 'matched something' );
        my $result = $exp->match() // '';
        ok( $result eq $expected, "expected: '$expected', got: '$result'" );
        $exp->soft_close();
    }
}

done_testing();
