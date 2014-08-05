use 5.010001;
use warnings;
use strict;
use utf8;
use Test::More;
use Test::Fatal;

if( Test::Builder->VERSION < 2 ) {
    for my $method ( qw( output failure_output todo_output ) ) {
        binmode Test::More->builder->$method(), ':encoding(UTF-8)';
    }
}

use lib 'lib';
use Term::Choose;

my $new  = Term::Choose->new( { order => 1, layout => 2, mouse => 3 } );
my %hash;
my $n = 1; # ?


my $int = {
    beep         => [ 0, 1 ],
    clear_screen => [ 0, 1 ],
    hide_cursor  => [ 0, 1 ],
    index        => [ 0, 1 ],
    justify      => [ 0, 1, 2 ],
    layout       => [ 0, 1, 2, 3 ],
    mouse        => [ 0, 1, 2, 3, 4 ],
    order        => [ 0, 1 ],
    page         => [ 0, 1 ],
};

for my $opt ( sort keys %$int ) {
    for my $val ( @{$int->{$opt}}, undef ) {
        my $exception = exception { $hash{$n} = Term::Choose->new( { $opt => $val } ) };
        ok( ! defined $exception, "\$new = Term::Choose->new( { $opt => " . ( $val // 'undef' ) . " } )" );
        $n++;
    }
}

for my $opt ( sort keys %$int ) {
    for my $val ( @{$int->{$opt}}, undef ) {
        my $exception = exception { $new->config( { $opt => $val } ) };
        ok( ! defined $exception, "\$new->config( { $opt => " . ( $val // 'undef' ) . " } )"  );
    }
}



my $one_or_greater = {
    keep       => '[ 1-9 ][ 0-9 ]*',
    ll         => '[ 1-9 ][ 0-9 ]*',
    limit      => '[ 1-9 ][ 0-9 ]*',
    max_height => '[ 1-9 ][ 0-9 ]*',
    max_width  => '[ 1-9 ][ 0-9 ]*',
};
my @val_one_or_greater = ( 1, 2, 100, 999999, undef );

for my $opt ( sort keys %$one_or_greater ) {
    for my $val ( @val_one_or_greater ) {
        my $exception = exception { $hash{$n} = Term::Choose->new( { $opt => $val } ) };
        ok( ! defined $exception, "\$new = Term::Choose->new( { $opt => " . ( $val // 'undef' ) . " } )" );
        $n++;
    }
}

for my $opt ( sort keys %$one_or_greater ) {
    for my $val ( @val_one_or_greater ) {
        my $exception = exception { $new->config( { $opt => $val } ) };
        ok( ! defined $exception, "\$new->config( { $opt => " . ( $val // 'undef' ) . " } )"  );
    }
}



my $zero_or_greater = {
    default     => '[ 0-9 ]+',
    pad         => '[ 0-9 ]+',
    pad_one_row => '[ 0-9 ]+',
};
my @val_zero_or_greater = ( 0, 1, 2, 100, 999999, undef );

for my $opt ( sort keys %$zero_or_greater ) {
    for my $val ( @val_zero_or_greater ) {
        my $exception = exception { $hash{$n} = Term::Choose->new( { $opt => $val } ) };
        ok( ! defined $exception, "\$new = Term::Choose->new( { $opt => " . ( $val // 'undef' ) . " } )" );
        $n++;
    }
}

for my $opt ( sort keys %$zero_or_greater ) {
    for my $val ( @val_zero_or_greater ) {
        my $exception = exception { $new->config( { $opt => $val } ) };
        ok( ! defined $exception, "\$new->config( { $opt => " . ( $val // 'undef' ) . " } )"  );
    }
}



my $string = {
    empty  => '',
    prompt => '',
    undef  => '',
};
my @val_string = ( 0, 'Hello' x 50, '', ' ', '☻☮☺', "\x{263a}\x{263b}", '한글', undef, 'æða' );

for my $opt ( sort keys %$string ) {
    for my $val ( @val_string ) {
        my $exception = exception { $hash{$n} = Term::Choose->new( { $opt => $val } ) };
        ok( ! defined $exception, "\$new = Term::Choose->new( { $opt => " . ( $val // 'undef' ) . " } )" );
        $n++;
    }
}

for my $opt ( sort keys %$string ) {
    for my $val ( @val_string ) {
        my $exception = exception { $new->config( { $opt => $val } ) };
        ok( ! defined $exception, "\$new->config( { $opt => " . ( $val // 'undef' ) . " } )"  );
    }
}



my $lf = { lf => 'ARRAY' };
my @val_lf = ( [ 2, 4 ], [ 8 ], [], undef );

for my $opt ( sort keys %$lf ) {
    for my $val ( @val_lf ) {
        my $exception = exception { $hash{$n} = Term::Choose->new( { $opt => $val } ) };
        ok( ! defined $exception, "\$new = Term::Choose->new( { $opt => " . ( $val // 'undef' ) . " } )" );
        $n++;
    }
}

for my $opt ( sort keys %$lf ) {
    for my $val ( @val_lf ) {
        my $exception = exception { $new->config( { $opt => $val } ) };
        ok( ! defined $exception, "\$new->config( { $opt => " . ( $val // 'undef' ) . " } )"  );
    }
}



my $no_spacebar = { no_spacebar => 'ARRAY' };
my @val_no_spacebar = ( [ 0, 1, 2, 100, 999999 ], [ 1 ], undef );

for my $opt ( sort keys %$no_spacebar ) {
    for my $val ( @val_no_spacebar ) {
        my $exception = exception { $hash{$n} = Term::Choose->new( { $opt => $val } ) };
        ok( ! defined $exception, "\$new = Term::Choose->new( { $opt => " . ( $val // 'undef' ) . " } )" );
        $n++;
    }
}

for my $opt ( sort keys %$no_spacebar ) {
    for my $val ( @val_no_spacebar ) {
        my $exception = exception { $new->config( { $opt => $val } ) };
        ok( ! defined $exception, "\$new->config( { $opt => " . ( $val // 'undef' ) . " } )"  );
    }
}



my $exception = exception { $hash{$n} = Term::Choose->new( {
    beep  => 0, clear_screen => undef, hide_cursor => 1, index => 0, justify => 0, layout => 0, mouse => 0,
    order => 1, page => 0, keep => 1, ll => 1, limit => 9, max_height => 19, max_width => 19, default => 9,
    pad => 3, pad_one_row => 2, empty => '', prompt => '', undef => '', lf => [ 1 ], no_spacebar => [ 0 ] } ) };
ok( ! defined $exception, "\$new = Term::Choose->new( { >>> } )" );
$n++;

$exception = exception { $new->config( {
    beep  => 0, clear_screen => undef, hide_cursor => 1, index => 0, justify => 0, layout => 0, mouse => 0,
    order => 1, page => 0, keep => 1, ll => 1, limit => 9, max_height => 19, max_width => 19, default => 9,
    pad => 3, pad_one_row => 2, empty => '', prompt => '', undef => '', lf => [ 1 ], no_spacebar => [ 0 ] } ) };
ok( ! defined $exception, "\$new->config( { >>> } )"  );



$exception = exception { $hash{$n} = Term::Choose->new( {
    no_spacebar => [ 11, 0, 8 ], lf => [ 1, 1 ], undef => '', prompt => 'prompt_line', empty => '', pad_one_row => 2, pad => 3,
    default => 9, max_width => 19, max_height => 119,  limit => 999999, ll => 15, keep => 1, page => 1, order => 1,
    mouse => 0, layout => 3, justify => 0, index => 0, hide_cursor => 1,  clear_screen => undef, beep  => 0 } ) };
ok( ! defined $exception, "\$new = Term::Choose->new( { <<< } )" );

$exception = exception { $new->config( {
    no_spacebar => [ 11, 0, 8 ], lf => [ 1, 1 ], undef => '', prompt => 'prompt_line', empty => '', pad_one_row => 2, pad => 3,
    default => 9, max_width => 19, max_height => 119,  limit => 999999, ll => 15, keep => 1, page => 1, order => 1,
    mouse => 0, layout => 3, justify => 0, index => 0, hide_cursor => 1,  clear_screen => undef, beep  => 0 } ) };
ok( ! defined $exception, "\$new->config( { <<< } )" );



done_testing();
