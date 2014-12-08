use 5.008003;
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
    plan skip_all => "'Expect' with suitable 'IO::Pty' version required for $0.";
}

use lib $RealBin;
use Data_Test_Choose;


my $command = $^X;
my $timeout = 5;
my $choose_pl = catfile $RealBin, 'choose.pl';
my $key = Data_Test_Choose::key_seq();

{
    my $type = 'seq_test';
    my $rows = 24;
    my $cols = 80;
    my @parameters = ( $choose_pl, $type );

    my $exp;
    eval {
        $exp = Expect->new();
        $exp->raw_pty( 1 );
        $exp->log_stdout( 0 );
        $exp->slave->set_winsize( $rows, $cols, undef, undef );
        $exp->spawn( $command, @parameters ) or die "Spawn '$command @parameters' NOT ok $!";
        1;
    }
    or plan skip_all => $@;

    subtest 'seq_test', sub {
        my $a_ref = Data_Test_Choose::return_test_data( $type );

        for my $ref ( @$a_ref ) {
            my $pressed_keys = $ref->{used_keys};
            my $expected     = $ref->{expected};

            $exp->send( @{$key}{@$pressed_keys}, $key->{ENTER} );
            my $ret = $exp->expect( $timeout, [ qr/<.+>/ ] );
            my $result = $exp->match();
            $result = '' if ! defined $result;

            ok( $expected eq $result, "'@{$ref->{used_keys}}' OK: " . sprintf( "%10.10s - %10.10s", $expected, $result ) );
        }
        $exp->hard_close();

        done_testing();
    }
}

my @types = ( qw( long short option_ll pad_one_row ) );
my $rows = 24;
my $cols = 80;


for my $type ( @types ) {
    my $a_ref = Data_Test_Choose::return_test_data( $type );
    my @parameters = ( $choose_pl, $type );

    subtest 'choose ' . $type, sub {
        my $exp = Expect->new();
        $exp->raw_pty( 1 );
        $exp->log_stdout( 0 );
        $exp->slave->set_winsize( $rows, $cols, undef, undef );
        $exp->spawn( $command, @parameters ) or die "Spawn '$command @parameters' NOT ok $!";

        for my $ref ( @$a_ref ) {
            my $pressed_keys = $ref->{used_keys};
            my $expected     = $ref->{expected};

            $exp->send( @{$key}{@$pressed_keys} );
            my $ret = $exp->expect( $timeout, [ qr/<.+>/ ] );
            my $result = $exp->match();
            $result = '' if ! defined $result;

            ok( $ret, 'matched something' );
            ok( $result eq $expected, "expected: '$expected', got: '$result'" );

        }
        $exp->hard_close();

        done_testing();
    };
}


$rows = 24;
$cols = 81;


for my $type ( @types ) {
    my $a_ref = Data_Test_Choose::return_test_data( $type );
    my @parameters = ( $choose_pl, $type );

    subtest 'choose ' . $type, sub {
        my $exp = Expect->new();
        $exp->raw_pty( 1 );
        $exp->log_stdout( 0 );
        $exp->slave->set_winsize( $rows, $cols, undef, undef );
        $exp->spawn( $command, @parameters ) or die "Spawn '$command @parameters' NOT ok $!";

        for my $ref ( @$a_ref ) {
            my $pressed_keys = $ref->{used_keys};
            my $expected     = defined $ref->{expected_w81} ? $ref->{expected_w81} : $ref->{expected};

            $exp->send( @{$key}{@$pressed_keys} );
            my $ret = $exp->expect( $timeout, [ qr/<.+>/ ] );
            my $result = $exp->match();
            $result = '' if ! defined $result;

            ok( $ret, 'matched something' );
            ok( $result eq $expected, "expected: '$expected', got: '$result'" );

        }
        $exp->hard_close();

        done_testing();
    };
}



done_testing();
