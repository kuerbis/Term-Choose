use 5.010001;
use warnings;
use strict;
use Test::More;
use Test::Fatal;
use POSIX     qw();
use Term::Cap qw();

if ( $^O eq 'MSWin32' ) {
    plan skip_all => "MSWin32: no escape sequences.";
}

my $termios = POSIX::Termios->new();
$termios->getattr;

my $terminal = Term::Cap->Tgetent( { TERM => undef, OSPEED => $termios->getospeed } );


my %seq = (
    kb => "\x{7f}",
    kd => "\eOB",
    kh => "\eOH",
    kl => "\eOD",
    kr => "\eOC",
    ku => "\eOA",
    kI => "\e[2~",
    kD => "\e[3~",
    kN => "\e[6~",
    kP => "\e[5~",
);

diag( $ENV{TERM} );

for my $cap ( sort keys %seq ) {
    my $exception = exception { $terminal->Trequire( $cap ) };
    ok( ! defined $exception, "Trequire( '$cap' ) OK" ) or delete $seq{$cap};
}

for my $cap ( sort keys %seq ) {
    next if $seq{$cap} eq '';
    my $d = $terminal->Tputs( $cap );
    my $ok = ok( $d eq $seq{$cap}, $cap );
    if ( ! $ok ) {
        $d =~ s/\e/\\e/g;
        $seq{$cap} =~ s/\e/\\e/g;
        diag( qq{> '$cap': "$seq{$cap}" - "$d"} );
    }
}

done_testing;
