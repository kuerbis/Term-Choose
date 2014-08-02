use 5.010001;
use warnings;
use strict;
use Test::More;

if ( $^O eq 'MSWin32' ) {
    plan skip_all => "MSWin32: no escape sequences.";
}

BEGIN {
  eval "use Test::Fatal qw( exception ); 1"
    or plan skip_all => "Test::Fatal required: $@";
};

use POSIX     qw();
use Term::Cap qw();


my $termios = POSIX::Termios->new();
$termios->getattr;

my $terminal = Term::Cap->Tgetent( { TERM => undef, OSPEED => $termios->getospeed } );

for my $cap ( qw( cd cm do le nd up sc rc kh kd kl kr ku kN kP kI ) ) {
    my $exception = Test::Fatal::exception { $terminal->Trequire( $cap ) };
    ok( ! defined $exception, "cap $cap OK " );
}


my $d = $terminal->Tputs( 'cd' );
ok( $d eq "\e[J" || $d eq "\e[0J", '\e[J : clear to the end of screen' );

$d = $terminal->Tputs( 'up' );
ok( $d eq "\e[A" || $d eq "\e[1A", '\e[A : move up' );

$d = $terminal->Tputs( 'nd' );
ok( $d eq "\e[C" || $d eq "\e[1C", '\e[C : move forward' );

done_testing();
