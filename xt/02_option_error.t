use 5.010001;
use warnings;
use strict;
use utf8;
use Test::More;

use Term::Choose qw( choose );

use Test::Warnings qw( :all );


no warnings 'redefine';
sub Term::Choose::__get_key { sleep 0.01; return 0x0d };

close STDIN or plan skip_all => "Close STDIN $!";
my $stdin = "eingabe\n";
open STDIN, "<", \$stdin or plan skip_all => "STDIN $!";

close STDOUT or plan skip_all => "Close STDOUT $!";
close STDERR or plan skip_all => "Close STDERR $!";
my ( $tmp_stdout, $tmp_stderr );
open STDOUT, '>', \$tmp_stdout or plan skip_all => "STDOUT $!";
open STDERR, '>', \$tmp_stderr or plan skip_all => "STDERR $!";


my $choices = [ '', 0, undef, 1, 2, 3, 'aa' .. 'zz', '☻☮☺', "\x{263a}\x{263b}", '한글', 'æða' ];

my $d;

my $int = {
    beep         => '[ 0 1 ]',
    clear_screen => '[ 0 1 ]',
    hide_cursor  => '[ 0 1 ]',
    index        => '[ 0 1 ]',
    justify      => '[ 0 1 2 ]',
    layout       => '[ 0 1 2 3 ]',
    mouse        => '[ 0 1 2 3 4 ]',
    order        => '[ 0 1 ]',
    page         => '[ 0 1 ]',
    keep         => '[ 1-9 ][ 0-9 ]*',
    ll           => '[ 1-9 ][ 0-9 ]*',
    limit        => '[ 1-9 ][ 0-9 ]*',
    max_height   => '[ 1-9 ][ 0-9 ]*',
    max_width    => '[ 1-9 ][ 0-9 ]*',
    default      => '[ 0-9 ]+',
    pad          => '[ 0-9 ]+',
    pad_one_row  => '[ 0-9 ]+',
};


my @wrong = ( -1, 2, 2 .. 10, 999999, '01', '', 'a', { 1, 1 }, [ 1 ], {}, [], [ 2 ] );


for my $opt ( sort keys %$int ) {
    for my $val ( grep { ! /^$int->{$opt}\z/x } @wrong ) {
        like( warning { $d = choose( $choices, { $opt => $val } ) || 1 }, qr/choose/, "Test for 'option $opt: $val invalid value' warning" );
    }
}


my $string = {
    empty  => '',
    prompt => '',
    undef  => '',
};

for my $opt ( sort keys %$string ) {
    for my $val ( grep { ref } @wrong ) {
        like( warning { $d = choose( $choices, { $opt => $val } ) || 1 }, qr/choose|ARRAY/, "Test for 'option $opt: $val invalid value' warning" ); # ARRAY ?
    }
}


my $lf = {
    lf => 'ARRAY',
};
my @val_lf = ( -2, -1, 0, 1, '', 'a', { 1, 1 }, {}  );

for my $opt ( sort keys %$lf ) {
    for my $val ( @val_lf ) {
        like( warning { $d = choose( $choices, { $opt => $val } ) || 1 }, qr/choose/, "Test for 'option $opt: $val invalid value' warning" );
    }
}


my $no_spacebar = {
    no_spacebar => 'ARRAY',
};
my @val_no_spacebar = ( -2, -1, 0, 1, '', 'a', { 1, 1 }, {}  );

for my $opt ( sort keys %$no_spacebar ) {
    for my $val ( @val_no_spacebar ) {
        like( warning { $d = choose( $choices, { $opt => $val } ) || 1 }, qr/choose/, "Test for 'option $opt: $val invalid value' warning" );
    }
}


like( warning { $d = choose( $choices, {
    beep  => -1, clear_screen => 2, hide_cursor => 3, index => 4, justify => '@', layout => 5, mouse => {},
    order => 1, page => 0, keep => -1, ll => -1, limit => 0, max_height => 0, max_width => 0, default => [],
    pad => 'a', pad_one_row => 'b', empty => [], prompt => {}, undef => [], lf => 4, no_spacebar => 4 } ) || 1 },
qr/choose|ARRAY/, "Test for 'option: invalid value' warning" ); # ARRAY ?


like( warning { $d = choose( [ 'aaa' .. 'zzz' ], {
    no_spacebar => 'a', lf => 'b', undef => [], prompt => {}, empty => {}, pad_one_row => 'c', pad => 'd',
    default => 'e', max_width => -1, max_height => -2,  limit => -3, ll => -4, keep => -5, page => -6, order => -7,
    mouse => 'k', layout => 'e', justify => [], index => {}, hide_cursor => -1,  clear_screen => [], beep  => 10 } ) || 1 },
qr/choose|ARRAY/, "Test for 'option: invalid value' warning" ); # ARRAY ?



done_testing();

__DATA__
