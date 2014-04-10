use 5.010001;
use strict;
use warnings;
use Test::More;


my $build = 'Build.PL';
my %build;

open my $fh_build, '<:encoding(UTF-8)', $build or die $!;
while ( my $line = <$fh_build> ) {
    chomp $line;
    $build{one}    = $line if $. == 1 and $line =~ /^use/;
    $build{two}    = $line if $. == 2 and $line eq 'use warnings';
    $build{three}  = $line if $. == 3 and $line eq 'use strict;';
    $build{module_name}        = $1 if $line =~ /^\s* module_name       \s*=>\s*'([^']+)'/x;
    $build{license}            = $1 if $line =~ /^\s* license           \s*=>\s*'([^']+)'/x;
    $build{dist_author}        = $1 if $line =~ /^\s* dist_author       \s*=>\s*'([^']+)'/x;
    $build{dist_version_from}  = $1 if $line =~ /^\s* dist_version_from \s*=>\s*'([^']+)'/x;
    $build{Term_Size_Win32}    = $1 if $line =~ /^\s* 'Term::Size::Win32'   \s*=>\s*([^\s,]+)/x;
    $build{Win32_Console}      = $1 if $line =~ /^\s* 'Win32::Console'      \s*=>\s*([^\s,]+)/x;
    $build{Win32_Console_ANSI} = $1 if $line =~ /^\s* 'Win32::Console::ANSI'\s*=>\s*([^\s,]+)/x;
    $build{Term_ReadKey}       = $1 if $line =~ /^\s* 'Term::ReadKey'       \s*=>\s*([^\s,]+)/x;
    $build{Test_More}          = $1 if $line =~ /^\s* 'Test::More'          \s*=>\s*([^\s,]+)/x;
    $build{constant}           = $1 if $line =~ /^\s* 'constant'            \s*=>\s*([^\s,]+)/x;
    $build{if}                 = $1 if $line =~ /^\s* 'if'                  \s*=>\s*([^\s,]+)/x;
    $build{strict}             = $1 if $line =~ /^\s* 'strict'              \s*=>\s*([^\s,]+)/x;
    $build{warnings}           = $1 if $line =~ /^\s* 'warnings'            \s*=>\s*([^\s,]+)/x;
    $build{perl}               = $1 if $line =~ /^\s* 'perl'                \s*=>\s*([^\s,]+)/x;
    $build{Carp}               = $1 if $line =~ /^\s* 'Carp'                \s*=>\s*([^\s,]+)/x;
    $build{Exporter}           = $1 if $line =~ /^\s* 'Exporter'            \s*=>\s*([^\s,]+)/x;
    $build{Text_LineFold}      = $1 if $line =~ /^\s* 'Text::LineFold'      \s*=>\s*([^\s,]+)/x;
    $build{Scalar_Util}        = $1 if $line =~ /^\s* 'Scalar::Util'        \s*=>\s*([^\s,]+)/x;
    $build{Unicode_GCString}   = $1 if $line =~ /^\s*'Unicode::GCString'    \s*=>\s*([^\s,]+)/x;
}
close $fh_build;



my $make = 'Makefile.PL';
my %make;

open my $fh_make, '<:encoding(UTF-8)', $make or die $!;
while ( my $line = <$fh_make> ) {
    chomp $line;
    $make{one}    = $line if $. == 1 and $line =~ /^use/;
    $make{two}    = $line if $. == 2 and $line eq 'use warnings';
    $make{three}  = $line if $. == 3 and $line eq 'use strict;';
    $make{module_name}        = $1 if $line =~ /^\s* NAME           \s*=>\s*'([^']+)'/x;
    $make{license}            = $1 if $line =~ /^\s* LICENSE        \s*=>\s*'([^']+)'/x;
    $make{dist_author}        = $1 if $line =~ /^\s* AUTHOR         \s*=>\s*'([^']+)'/x;
    $make{dist_version_from}  = $1 if $line =~ /^\s* VERSION_FROM   \s*=>\s*'([^']+)'/x;
    $make{Term_Size_Win32}    = $1 if $line =~ /^\s* 'Term::Size::Win32'   \s*=>\s*([^\s,]+)/x;
    $make{Win32_Console}      = $1 if $line =~ /^\s* 'Win32::Console'      \s*=>\s*([^\s,]+)/x;
    $make{Win32_Console_ANSI} = $1 if $line =~ /^\s* 'Win32::Console::ANSI'\s*=>\s*([^\s,]+)/x;
    $make{Term_ReadKey}       = $1 if $line =~ /^\s* 'Term::ReadKey'       \s*=>\s*([^\s,]+)/x;
    $make{Test_More}          = $1 if $line =~ /^\s* 'Test::More'          \s*=>\s*([^\s,]+)/x;
    $make{constant}           = $1 if $line =~ /^\s* 'constant'            \s*=>\s*([^\s,]+)/x;
    $make{if}                 = $1 if $line =~ /^\s* 'if'                  \s*=>\s*([^\s,]+)/x;
    $make{strict}             = $1 if $line =~ /^\s* 'strict'              \s*=>\s*([^\s,]+)/x;
    $make{warnings}           = $1 if $line =~ /^\s* 'warnings'            \s*=>\s*([^\s,]+)/x;
    $make{perl}               = $1 if $line =~ /^\s* MIN_PERL_VERSION      \s*=>\s*([^\s,]+)/x;
    $make{Carp}               = $1 if $line =~ /^\s* 'Carp'                \s*=>\s*([^\s,]+)/x;
    $make{Exporter}           = $1 if $line =~ /^\s* 'Exporter'            \s*=>\s*([^\s,]+)/x;
    $make{Text_LineFold}      = $1 if $line =~ /^\s* 'Text::LineFold'      \s*=>\s*([^\s,]+)/x;
    $make{Scalar_Util}        = $1 if $line =~ /^\s* 'Scalar::Util'        \s*=>\s*([^\s,]+)/x;
    $make{Unicode_GCString}   = $1 if $line =~ /^\s* 'Unicode::GCString'   \s*=>\s*([^\s,]+)/x;
}
close $fh_make;



my %keys;
for my $key ( keys %build ) {
    $keys{$key}++;
}
for my $key ( keys %make ) {
    $keys{$key}++;
}


plan tests => scalar keys %keys;



for my $key ( sort keys %keys ) {
    ok( $build{$key} eq $make{$key}, "Key: $key" );
}
