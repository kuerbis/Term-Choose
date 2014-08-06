package # hide
ValidValues;
use 5.010001;
use warnings;
use strict;
use utf8;



sub valid_values {
    return {
        beep         => [ 0, 1 ],
        clear_screen => [ 0, 1 ],
        hide_cursor  => [ 0, 1 ],
        index        => [ 0, 1 ],
        justify      => [ 0, 1, 2 ],
        layout       => [ 0, 1, 2, 3 ],
        mouse        => [ 0, 1, 2, 3, 4 ],
        order        => [ 0, 1 ],
        page         => [ 0, 1 ],

        # '[ 1-9 ][ 0-9 ]*'
        keep       => [ 1, 2, 100, 999999, undef ],
        ll         => [ 1, 2, 100, 999999, undef ],
        limit      => [ 1, 2, 100, 999999, undef ],
        max_height => [ 1, 2, 100, 999999, undef ],
        max_width  => [ 1, 2, 100, 999999, undef ],

        # '[ 0-9 ]+'
        default     => [ 0, 1, 2, 100, 999999, undef ],
        pad         => [ 0, 1, 2, 100, 999999, undef ],
        pad_one_row => [ 0, 1, 2, 100, 999999, undef ],

        # ''
        empty  => [ 0, 'Hello' x 50, '', ' ', '☻☮☺', "\x{263a}\x{263b}", '한글', undef, 'æða' ],
        prompt => [ 0, 'Hello' x 50, '', ' ', '☻☮☺', "\x{263a}\x{263b}", '한글', undef, 'æða' ],
        undef  => [ 0, 'Hello' x 50, '', ' ', '☻☮☺', "\x{263a}\x{263b}", '한글', undef, 'æða' ],

        # ARRAY max 2 int
        lf => [ [ 2, 4 ], [ 8 ], [], undef ],

        # ARRAY int
        no_spacebar => [ [ 0, 1, 2, 100, 999999 ], [ 1 ], undef ],
    };
}


sub mixed_options_1 {
    return {
        beep  => 0, clear_screen => undef, hide_cursor => 1, index => 0, justify => 0, layout => 0, mouse => 0,
        order => 1, page => 0, keep => 1, ll => 1, limit => 9, max_height => 19, max_width => 19, default => 9,
        pad => 3, pad_one_row => 2, empty => '', prompt => '', undef => '', lf => [ 1 ], no_spacebar => [ 0 ]
    };
}


sub mixed_options_2 {
    return {
        no_spacebar => [ 11, 0, 8 ], lf => [ 1, 1 ], undef => '', prompt => 'prompt_line', empty => '', pad_one_row => 2, pad => 3,
        default => 9, max_width => 19, max_height => 119,  limit => 999999, ll => 15, keep => 1, page => 1, order => 1,
        mouse => 0, layout => 3, justify => 0, index => 0, hide_cursor => 1,  clear_screen => undef, beep  => 0
    };
}



1;

__END__
