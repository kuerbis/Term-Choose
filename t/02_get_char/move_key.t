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

my $exp = Expect->new();
$exp->raw_pty( 1 );
$exp->log_stdout( 0 );
$exp->slave->set_winsize( 24, 80, undef, undef );

my $command     = $^X;
my $script      = catfile $RealBin, 'choose.pl';
my @parameters  = ( $script );
$exp->spawn( $command, @parameters ) or die $!;

# CONTROL_C
# KEY_q CONTROL_D

my %hash = (
    ENTER       => [ '<0>',     ( "\r" )                                      ],
    CONTROL_M   => [ '<0>',     ( "\cM" )                                     ],

    RIGHT       => [ '<3>',     ( "\e[C" x 3 )                     . ( "\r" ) ],
    RIGHT_O     => [ '<3>',     ( "\eOC" x 3 )                     . ( "\r" ) ],
    Key_l       => [ '<3>',     ( "l" x 3 )                        . ( "\r" ) ],

    LEFT        => [ '<2>',     ( "\e[C" x 4 ) . ( "\e[D" x 2 )    . ( "\r" ) ],
    LEFT_O      => [ '<2>',     ( "\eOC" x 4 ) . ( "\eOD" x 2 )    . ( "\r" ) ],
    Key_h       => [ '<2>',     ( "l" x 4 )    . ( "h" x 2 )       . ( "\r" ) ],

    DOWN        => [ '<40>',    ( "\e[C" x 1 ) . ( "\e[B" x 3 )    . ( "\r" ) ],
    DOWN_O      => [ '<40>',    ( "\eOC" x 1 ) . ( "\eOB" x 3 )    . ( "\r" ) ],
    Key_j       => [ '<40>',    ( "l" x 1 )    . ( "j" x 3 )       . ( "\r" ) ],

    UP          => [ '<39>',    ( "\e[B" x 6 ) . ( "\e[A" x 3 )    . ( "\r" ) ],
    UP_O        => [ '<39>',    ( "\eOB" x 6 ) . ( "\eOA" x 3 )    . ( "\r" ) ],
    Key_k       => [ '<39>',    ( "j" x 6 )    . ( "k" x 3 )       . ( "\r" ) ],

    TAB         => [ '<16>',    ( "\t" x 16 )                      . ( "\r" ) ],
    CONTROL_I   => [ '<16>',    ( "\cI" x 16 )                     . ( "\r" ) ],

    BSPACE      => [ '<68>',    ( "\e[B" x 6 ) . ( "\x{7f}" x 10 ) . ( "\r" ) ],
    CONTROL_H   => [ '<68>',    ( "\e[B" x 6 ) . ( "\cH" x 10 )    . ( "\r" ) ],
    BTAB        => [ '<68>',    ( "\e[B" x 6 ) . ( "\x{08}" x 10 ) . ( "\r" ) ],
    BTAB_Z      => [ '<68>',    ( "\e[B" x 6 ) . ( "\e[Z" x 10 )   . ( "\r" ) ],
    BTAB_OZ     => [ '<68>',    ( "\eOB" x 6 ) . ( "\eOZ" x 10 )   . ( "\r" ) ],

    HOME        => [ '<0>',     ( "\e[H" )                         . ( "\r" ) ],
    CONTROL_A   => [ '<0>',     ( "\cA" )                          . ( "\r" ) ],

    END         => [ '<1999>',  ( "\e[F" )                         . ( "\r" ) ],
    CONTROL_E   => [ '<1999>',  ( "\cE" )                          . ( "\r" ) ],

    PAGE_DOWN   => [ '<286>',   ( "\e[6~" )                        . ( "\r" ) ],
    CONTROL_F   => [ '<286>',   ( "\cF" )                          . ( "\r" ) ],

    PAGE_UP     => [ '<572>',   ( "\e[6~" x 3 ) . ( "\e[5~" )      . ( "\r" ) ],
    CONTROL_B   => [ '<572>',   ( "\cF" x 3 ) . ( "\cB" )          . ( "\r" ) ],

    SPACE       => [ '<0 1>',   ( "\x{20}" ) . ( "\e[C" )          . ( "\r" ) ],

    CONTROL_SPACE => [ '<0 1>',   ( "\x{20}" ) . ( "\e[C" ) . ( "\c\x{20}" x 2 ) . ( "\r" ) ],
    'CONTROL_@'   => [ '<0 1>',   ( "\x{20}" ) . ( "\e[C" ) . ( "\c@ " x 2 )     . ( "\r" ) ],
);

my %ok = ();
for my $key ( sort keys %hash ) {
    my $expected   = $hash{$key}[0];
    my $escape_seq = $hash{$key}[1];
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

$ok{UP}    //= $ok{UP_O};
$ok{DOWN}  //= $ok{DOWN_O};
$ok{LEFT}  //= $ok{LEFT_O};
$ok{RIGHT} //= $ok{RIGHT_O};
$ok{BTAB}  //= $ok{BTAB_Z} // $ok{BTAB_OZ};

ok( $ok{ENTER} || $ok{CONTROL_M},                                           'Return OK' );
ok( $ok{UP}    || $ok{Key_k} || $ok{BSPACE} || $ok{CONTROL_H} || $ok{BTAB}, 'Up OK'     );
ok( $ok{LEFT}  || $ok{Key_h} || $ok{BSPACE} || $ok{CONTROL_H} || $ok{BTAB}, 'Left OK'   );
ok( $ok{DOWN}  || $ok{Key_j} || $ok{TAB}    || $ok{CONTROL_I},              'Down OK'   );
ok( $ok{RIGHT} || $ok{Key_l} || $ok{TAB}    || $ok{CONTROL_I},              'Right OK'  );
ok( $ok{SPACE},                                                             'Space OK'  );

done_testing();
