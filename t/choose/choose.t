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

use lib 't/';
use Term_Choose_Testdata;

my $exp;
eval {
    $exp = Expect->new();
    $exp->raw_pty( 1 );
    $exp->log_stdout( 0 );
    $exp->slave->set_winsize( 24, 80, undef, undef );

    my $command     = $^X;
    my $script      = catfile $RealBin, 'choose.pl';
    my @parameters  = ( $script );

    -r $script or die "$script is NOT readable";
    $exp->spawn( $command, @parameters ) or die "Spawn '$command @parameters' NOT ok $!";
    1;
}
or plan skip_all => $@;

my $data = Term_Choose_Testdata::key_move_results();
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

my $CONTROL_at    = "\x{00}";
my $CONTROL_Space = "\x{00}";

my $CONTROL_C     = "\x{03}";
my $CONTROL_D     = "\x{04}";

my $CONTROL_H     = "\x{08}";
my $BTAB          = "\x{08}";
my $BSPACE        = "\x{7f}";
my $BTAB_Z        = $ok{BTAB_Z}    ? "\e[Z"  : $CONTROL_H;
my $BTAB_OZ       = $ok{BTAB_OZ}   ? "\eOZ"  : $CONTROL_H;

my $CONTROL_I     = "\x{09}";
my $TAB           = "\x{09}";

my $CONTROL_M     = "\x{0d}";
my $ENTER         = "\x{0d}";

my $SPACE         = "\x{20}";
my $KEY_q         = "\x{71}";

my $KEY_k         = "\x{6b}";
my $UP            = $ok{UP}        ? "\e[A"  : $KEY_k;
my $UP_O          = $ok{UP_O}      ? "\eOA"  : $KEY_k;

my $KEY_j         = "\x{6a}";
my $DOWN          = $ok{DOWN}      ? "\e[B"  : $KEY_j;
my $DOWN_O        = $ok{DOWN_O}    ? "\eOB"  : $KEY_j;

my $KEY_l         = "\x{6c}";
my $RIGHT         = $ok{RIGHT}     ? "\e[C"  : $KEY_l;
my $RIGHT_O       = $ok{RIGHT_O}   ? "\eOC"  : $KEY_l;

my $KEY_h         = "\x{68}";
my $LEFT          = $ok{LEFT}      ? "\e[D"  : $KEY_h;
my $LEFT_O        = $ok{LEFT_O}    ? "\eOD"  : $KEY_h;

my $CONTROL_B     = "\x{02}";
my $PAGE_UP       = $ok{PAGE_UP}   ? "\e[5~" : $CONTROL_B;

my $CONTROL_F     = "\x{06}";
my $PAGE_DOWN     = $ok{PAGE_DOWN} ? "\e[6~" : $CONTROL_F;

my $CONTROL_A     = "\x{01}";
my $HOME          = $ok{HOME}      ? "\e[H"  : $CONTROL_A;

my $CONTROL_E     = "\x{05}";
my $END           = $ok{END}       ? "\e[F"  : $CONTROL_E;


my $a_ref = Term_Choose_Testdata::test_options();

eval {
    $exp = Expect->new();
    $exp->raw_pty( 1 );
    $exp->log_stdout( 0 );
    $exp->slave->set_winsize( 24, 80, undef, undef );

    my $command     = $^X;
    my $script      = catfile $RealBin, 'choose_test.pl';
    my @parameters  = ( $script );

    -r $script or die "$script is NOT readable";
    $exp->spawn( $command, @parameters ) or die "Spawn '$command @parameters' NOT ok $!";
    1;
}
or plan skip_all => $@;

for my $ref ( @$a_ref ) {
    my $expected = "<$ref->[0]>";
    $exp->send( $CONTROL_E );
    $exp->send( $ENTER );
    my $ret = $exp->expect( 2, [ qr/<.+>/ ] );
    ok( $ret, 'matched something' );
    my $result = $exp->match() // '';
    ok( $result eq $expected, "expected: '$expected', got: '$result'" );
}

$exp->soft_close();

done_testing();
