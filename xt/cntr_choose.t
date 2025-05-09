use 5.10.1;
use strict;
use warnings;
use File::Basename qw( basename );
use Test::More;


for my $file ( qw(
lib/Term/Choose.pm
lib/Term/Choose/Constants.pm
lib/Term/Choose/LineFold.pm
lib/Term/Choose/LineFold/PP.pm
lib/Term/Choose/LineFold/PP/CharWidthAmbiguousWide.pm
lib/Term/Choose/LineFold/PP/CharWidthDefault.pm
lib/Term/Choose/Linux.pm
lib/Term/Choose/Opt/Mouse.pm
lib/Term/Choose/Opt/Search.pm
lib/Term/Choose/Opt/SkipItems.pm
lib/Term/Choose/Screen.pm
lib/Term/Choose/ValidateOptions.pm
lib/Term/Choose/Win32.pm
) ) {

    my $data_dumper   = 0;
    my $warnings      = 0;
    my $use_lib       = 0;
    my $warn_to_fatal = 0;

    open my $fh, '<', $file or die $!;
    while ( my $line = <$fh> ) {
        if ( $line =~ /^\s*use\s+Data::Dumper/s ) {
            $data_dumper++;
        }
        if ( $line =~ /^\s*use\s+warnings\s+FATAL/s ) {
            $warnings++;
        }
        if ( $line =~ /^\s*use\s+lib\s/s ) {
            $use_lib++;
        }
        if ( $line =~ /__WARN__.+die/s ) {
            $warn_to_fatal++;
        }
    }
    close $fh;

    is( $data_dumper,   0, 'OK - Data::Dumper in "'         . basename( $file ) . '" disabled.' );
    is( $warnings,      0, 'OK - warnings FATAL in "'       . basename( $file ) . '" disabled.' );
    is( $use_lib,       0, 'OK - no "use lib" in "'         . basename( $file ) . '"' );
    is( $warn_to_fatal, 0, 'OK - no "warn to fatal" in "'   . basename( $file ) . '"' );
}


done_testing();
