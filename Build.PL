use 5.010001;
use warnings;
use strict;
use Module::Build;


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


my $builder = Module::Build->new(
    module_name         => 'Term::Choose',
    license             => 'perl',
    meta_merge => {
        resources => {
            repository => 'https://github.com/kuerbis/Term-Choose',
        }
    },
    dist_author         => 'Matthaeus Kiem <cuer2s@gmail.com>',
    dist_version_from   => 'lib/Term/Choose.pm',
    configure_requires => {
        'Module::Build'     => 0,
    },
    build_requires => {
        'Test::More'        => 0,
        'Test::Fatal'       => 0, ###
    },
    requires => {
        'perl'              => '5.010001',
        'strict'            => 0,
        'warnings'          => 0,
        'Carp'              => 0,
        'Exporter'          => 0,
        'Text::LineFold'    => 0,
        'Unicode::GCString' => 0,
        %prereqs_os_specific,
    },
    add_to_cleanup      => [ 'Term-Choose-*' ],
    #create_makefile_pl => 'traditional',
);

$builder->create_build_script();
