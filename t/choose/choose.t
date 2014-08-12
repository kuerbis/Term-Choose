use 5.010000;
use warnings;
use strict;
use Test::More;
use Encode;
use FindBin               qw( $RealBin );
use File::Spec::Functions qw( catfile );

BEGIN {
    if ( $^O eq 'MSWin32' ) {
        plan skip_all => "MSWin32: no escape sequences.";
    }
}

if( Test::Builder->VERSION < 2 ) {
    for my $method ( qw( output failure_output todo_output ) ) {
        binmode Test::More->builder->$method(), ':encoding(UTF-8)';
    }
}

eval "use Expect";
if ( $@ ) {
    plan skip_all => "Expect required for $0.";
}

use lib $RealBin;
use Data_Test_Choose;


my $command    = $^X;
my $script     = catfile $RealBin, 'key_test.pl';
my @parameters = ( $script );


eval {
    my $exp = Expect->new();
    $exp->raw_pty( 1 );
    $exp->log_stdout( 0 );
    $exp->slave->set_winsize( 24, 80, undef, undef );
    -r $script or die "$script is NOT readable";
    $exp->spawn( $command, @parameters ) or die "Spawn '$command @parameters' NOT ok $!";
    $exp->send( "\r" );
    my $ret = $exp->expect( 1, [ qr/^.?/ ] );
    $exp->hard_close();
    1;
}
or plan skip_all => '$@';


my $data = Data_Test_Choose::key_move_results();
my %ok = ();

my $exp = Expect->new();
$exp->raw_pty( 1 );
$exp->log_stdout( 0 );
$exp->slave->set_winsize( 24, 80, undef, undef );
$exp->spawn( $command, @parameters ) or die "Spawn '$command @parameters' NOT ok $!";

for my $key ( sort keys %$data ) {
    my $expected   = $data->{$key}[0];
    my $escape_seq = $data->{$key}[1];

    $exp->send( $escape_seq );
    my $ret = $exp->expect( 2, [ qr/<[\ 0-9]+>/ ] );

    if ( $ret ) {
        my $result = $exp->match();
        if ( $expected eq $result ) {
            $ok{$key}++;
        }
        else {
            diag( "$key: $expected - $result" );
        }
    }
    else {
        diag( "$key: no match" );
    }
}
$exp->hard_close();


my $key = Data_Test_Choose::keys();

$key->{BTAB_Z}    //= $key->{CONTROL_H};
$key->{BTAB_OZ}   //= $key->{CONTROL_H};

$key->{UP}        //= $key->{Key_k};
$key->{UP_O}      //= $key->{Key_k};

$key->{DOWN}      //= $key->{Key_j};
$key->{DOWN_O}    //= $key->{Key_j};

$key->{RIGHT}     //= $key->{Key_l};
$key->{RIGHT_O}   //= $key->{Key_l};

$key->{LEFT}      //= $key->{Key_h};
$key->{LEFT_O}    //= $key->{Key_h};

$key->{PAGE_UP}   //= $key->{CONTROL_B};
$key->{PAGE_DOWN} //= $key->{CONTROL_F};

$key->{HOME}      //= $key->{CONTROL_A};
$key->{END}       //= $key->{CONTROL_E};


my $a_ref       = Data_Test_Choose::test_options();
$script      = catfile $RealBin, 'choose.pl';
eval { -r $script or die "$script is NOT readable"; 1 } or plan skip_all => $@;



my $pressed_keys = Data_Test_Choose::pressed_keys();
@parameters = ( $script, 'long' );

my $exp1 = Expect->new();
$exp1->raw_pty( 1 );
$exp1->log_stdout( 0 );
$exp1->slave->set_winsize( 24, 80, undef, undef );
$exp1->spawn( $command, @parameters ) or die "Spawn '$command @parameters' NOT ok $!";

for my $ref ( @$a_ref ) {
    $exp1->send( @{$key}{@$pressed_keys} );
    my $ret = $exp1->expect( 2, [ qr/<.+>/ ] );

    my $expected = $ref->{long};
    my $result   = $exp1->match() // '';

    ok( $ret, 'matched something' );
    ok( $result eq $expected, "expected: '$expected', got: '$result'" );
}
$exp1->hard_close();



$pressed_keys = Data_Test_Choose::pressed_keys_short();
@parameters = ( $script, 'short' );

my $exp2 = Expect->new();
$exp2->raw_pty( 1 );
$exp2->log_stdout( 0 );
$exp2->slave->set_winsize( 24, 80, undef, undef );
$exp2->spawn( $command, @parameters ) or die "Spawn '$command @parameters' NOT ok $!";

for my $ref ( @$a_ref ) {
    $exp2->send( @{$key}{@$pressed_keys} );
    my $ret = $exp2->expect( 2, [ qr/<.+>/ ] );

    my $expected = $ref->{short};
    my $result   = $exp2->match() // '';

    ok( $ret, 'matched something' );
    ok( $result eq $expected, "expected: '$expected', got: '$result'" );
}
$exp2->hard_close();



$pressed_keys = Data_Test_Choose::pressed_keys();
@parameters = ( $script, 'unicode' );

my $exp3 = Expect->new();
$exp3->raw_pty( 1 );
$exp3->log_stdout( 0 );
$exp3->slave->set_winsize( 24, 80, undef, undef );
$exp3->spawn( $command, @parameters ) or die "Spawn '$command @parameters' NOT ok $!";

for my $ref ( @$a_ref ) {
    $exp3->send( @{$key}{@$pressed_keys} );
    my $ret = $exp3->expect( 2, [ qr/<.+>/ ] );

    my $expected = $ref->{unicode};
    my $result = decode( 'utf8', $exp3->match() // '' );

    ok( $ret, 'matched something' );
    ok( $result eq $expected, "expected: '$expected', got: '$result'" );
}
$exp3->hard_close();



done_testing();
