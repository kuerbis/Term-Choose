use 5.010001;
use warnings;
use strict;
use Test::More;
use Test::Fatal;
use Devel::Peek;
use POSIX     qw();
use Term::Cap qw();

if ( $^O eq 'MSWin32' ) {
    plan skip_all => "MSWin32: no escape sequences.";
}

my $termios = POSIX::Termios->new();
$termios->getattr;

my $terminal = Term::Cap->Tgetent( { TERM => undef, OSPEED => $termios->getospeed } );

my %hash = (
    cl => "\e[H\e[2J",
    cd => "\e[J",
    cm => "\e[%i%d;%dH",
    le => "\e[D",
    nd => "\e[C",
    up => "\e[A",
    sc => "\e[s",
    rc => "\e[u",

    kh => '',
    kd => '',
    kl => '',
    kr => '',
    ku => '',
    kN => '',
    kP => '',
    kI => '',

    me => "\e[0m",
    md => "\e[1m",
    mr => "\e[7m",
    ms => "\e[4m",

    ve => "\e[?25h",
    vi => "\e[?25l",
);

for my $cap ( sort( keys %hash ) ) {
    my $exception = Test::Fatal::exception { $terminal->Trequire( $cap ) };
    ok( ! defined $exception, "cap $cap OK " );
}

for my $cap ( sort keys %hash ) {
    next if $hash{$cap} eq '';
    my $d = $terminal->Tputs( $cap );
    ok( $d eq $hash{$cap}, $cap ) or diag( Dump $d );
}
