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


my $exp;
eval {
    $exp = Expect->new();
    $exp->raw_pty( 1 );
    $exp->log_stdout( 0 );
    $exp->slave->set_winsize( 24, 80, undef, undef );

    my $command     = $^X;
    my $script      = catfile $RealBin, 'key_test.pl';
    my @parameters  = ( $script );

    -r $script or die "$script is NOT readable";
    $exp->spawn( $command, @parameters ) or die "Spawn '$command @parameters' NOT ok $!";
    1;
}
or plan skip_all => $@;

my $data = Data_Test_Choose::key_move_results();
my %ok = ();
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


my $a_ref = Data_Test_Choose::test_options();



eval {
    $exp = Expect->new();
    $exp->raw_pty( 1 );
    $exp->log_stdout( 0 );
    $exp->slave->set_winsize( 24, 80, undef, undef );

    my $command     = $^X;
    my $script      = catfile $RealBin, 'choose.pl';
    my @parameters  = ( $script, 'long' );

    -r $script or die "$script is NOT readable";
    $exp->spawn( $command, @parameters ) or die "Spawn '$command @parameters' NOT ok $!";
    1;
}
or plan skip_all => $@;

my $pressed_keys = Data_Test_Choose::pressed_keys();
for my $ref ( @$a_ref ) {
    my $expected = $ref->{long};
    $exp->send( @{$key}{@$pressed_keys} );
    my $ret = $exp->expect( 2, [ qr/<.+>/ ] );
    ok( $ret, 'matched something' );
    my $result = $exp->match() // '';
    ok( $result eq $expected, "expected: '$expected', got: '$result'" );
}

$exp->soft_close();



eval {
    $exp = Expect->new();
    $exp->raw_pty( 1 );
    $exp->log_stdout( 0 );
    $exp->slave->set_winsize( 24, 80, undef, undef );

    my $command     = $^X;
    my $script      = catfile $RealBin, 'choose.pl';
    my @parameters  = ( $script, 'short' );

    -r $script or die "$script is NOT readable";
    $exp->spawn( $command, @parameters ) or die "Spawn '$command @parameters' NOT ok $!";
    1;
}
or plan skip_all => $@;

$pressed_keys = Data_Test_Choose::pressed_keys_short();
for my $ref ( @$a_ref ) {
    my $expected = $ref->{short};
    $exp->send( @{$key}{@$pressed_keys} );
    my $ret = $exp->expect( 2, [ qr/<.+>/ ] );
    ok( $ret, 'matched something' );
    my $result = $exp->match() // '';
    ok( $result eq $expected, "expected: '$expected', got: '$result'" );
}

$exp->soft_close();



eval {
    $exp = Expect->new();
    $exp->raw_pty( 1 );
    $exp->log_stdout( 0 );
    $exp->slave->set_winsize( 24, 80, undef, undef );

    my $command     = $^X;
    my $script      = catfile $RealBin, 'choose.pl';
    my @parameters  = ( $script, 'unicode' );

    -r $script or die "$script is NOT readable";
    $exp->spawn( $command, @parameters ) or die "Spawn '$command @parameters' NOT ok $!";
    1;
}
or plan skip_all => $@;

$pressed_keys = Data_Test_Choose::pressed_keys();
for my $ref ( @$a_ref ) {
    my $expected = $ref->{unicode};
    $exp->send( @{$key}{@$pressed_keys} );
    my $ret = $exp->expect( 2, [ qr/<.+>/ ] );
    ok( $ret, 'matched something' );
    my $result = decode( 'utf8', $exp->match() // '' );
    ok( $result eq $expected, "expected: '$expected', got: '$result'" );
}

$exp->soft_close();



done_testing();
