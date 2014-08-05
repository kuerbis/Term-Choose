use 5.010001;
use warnings;
use strict;
use ExtUtils::MakeMaker;


my %prereqs_os_specific;
if ( $^O eq 'MSWin32' ) {
    %prereqs_os_specific = (
        'Win32::Console'       => 0,
    );
}
else {
    %prereqs_os_specific = (
        'Term::ReadKey'        => 0,
    );
}


WriteMakefile(
    PL_FILES         => {},
    MIN_PERL_VERSION => '5.010001',
    LICENSE          => 'perl',
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources   => {
            repository => {
              type => 'git',
              web  => 'https://github.com/kuerbis/Term-Choose',
              url  => 'https://github.com/kuerbis/Term-Choose.git',
            },
        },
    },
    AUTHOR           => 'Matthaeus Kiem <cuer2s@gmail.com>',
    NAME             => 'Term::Choose',
    ABSTRACT_FROM    => 'lib/Term/Choose.pm',
    VERSION_FROM     => 'lib/Term/Choose.pm',
    EXE_FILES        => [],
    BUILD_REQUIRES   => {
        'Test::More'        => 0,
        'Test::Fatal'       => 0, ###
        'Expect'            => 0, ###
        'Text::LineFold'    => 0, ###
        'Unicode::GCString' => 0, ###
        'Term::ReadKey'     => 0, ###
    },
    PREREQ_PM => {
        'strict'            => 0,
        'warnings'          => 0,
        'Carp'              => 0,
        'Exporter'          => 0,
        'Text::LineFold'    => 0,
        'Unicode::GCString' => 0,
        %prereqs_os_specific,
    },
    dist  => {
        COMPRESS => 'gzip',
        SUFFIX   => '.gz',
        TARFLAGS => '--format=gnu -cvf',
    },
    clean => {
        FILES => 'Term-Choose-*',
    },
);
