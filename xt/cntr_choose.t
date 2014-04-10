use 5.010001;
use strict;
use warnings;
use Test::More tests => 2;


my $file = 'lib/Term/Choose.pm';


my $test_env = 0;

open my $fh1, '<', $file or die $!;
while ( my $line = <$fh1> ) {
    if ( $line =~ /^\s*use\s+warnings\s+FATAL/s ) {
        $test_env++;
    }
	if ( $line =~ /(?:^\s*|\s+)use\s+Log::Log4perl/ ) {
		$test_env++;
	}
}
close $fh1;

is( $test_env, 0, "OK - test environment in $file disabled." );



my $pad_before_pad_one_row = 0;
my $c = 0;

open my $fh2, '<', $file or die $!;
while ( my $line = <$fh2> ) {
    if ( $line =~ /^sub __set_defaults/ .. $line =~ /^\}/ ) {
        $c++ if $line =~ /^\s*\$self->{pad}/;
        if ( $line =~ /^\s*\$self->{pad_one_row}/ ) {
            $pad_before_pad_one_row = 1 if $c;
            last;
        }
    }
}
close $fh2;

is( $pad_before_pad_one_row, 1, "OK - option \"pad\" is set before option \"pad_one_row\"." );
