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

use FindBin qw( $RealBin );
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
            diag( "$key: $expected-$result" );
        }
    }
    else {
        diag( "$key: no match" );
    }
}

for my $l ( qw( h j k l ) ) { # q
    ok( $ok{"Key_$l"}, "Key '$l' OK" );
}

ok( $ok{SPACE}, "'Space' OK" );

for my $l ( qw( A B E F H I M @ Space ) ) { # C D
    ok( $ok{"CONTROL_$l"}, "'Ctrl+$l' OK" );
}


done_testing();
