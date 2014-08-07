package # hide
InvalidValues;

use 5.010000;
use warnings;
use strict;
use utf8;


sub invalid_values {
    my @invalid = ( -1, 2, 2 .. 10, 999999, '01', '', 'a', { 1, 1 }, [ 1 ], [ 2 ] );
    return{
        beep         => [ grep { ! /^[ 0 1 ]\z/x }         @invalid ],
        clear_screen => [ grep { ! /^[ 0 1 ]\z/x }         @invalid ],
        hide_cursor  => [ grep { ! /^[ 0 1 ]\z/x }         @invalid ],
        index        => [ grep { ! /^[ 0 1 ]\z/x }         @invalid ],
        justify      => [ grep { ! /^[ 0 1 2 ]\z/x }       @invalid ],
        layout       => [ grep { ! /^[ 0 1 2 3 ]\z/x }     @invalid ],
        mouse        => [ grep { ! /^[ 0 1 2 3 4 ]\z/x }   @invalid ],
        order        => [ grep { ! /^[ 0 1 ]\z/x }         @invalid ],
        page         => [ grep { ! /^[ 0 1 ]\z/x }         @invalid ],
        keep         => [ grep { ! /^[ 1-9 ][ 0-9 ]*\z/x } @invalid ],
        ll           => [ grep { ! /^[ 1-9 ][ 0-9 ]*\z/x } @invalid ],
        limit        => [ grep { ! /^[ 1-9 ][ 0-9 ]*\z/x } @invalid ],
        max_height   => [ grep { ! /^[ 1-9 ][ 0-9 ]*\z/x } @invalid ],
        max_width    => [ grep { ! /^[ 1-9 ][ 0-9 ]*\z/x } @invalid ],
        default      => [ grep { ! /^[ 0-9 ]+\z/x }        @invalid ],
        pad          => [ grep { ! /^[ 0-9 ]+\z/x }        @invalid ],
        pad_one_row  => [ grep { ! /^[ 0-9 ]+\z/x }        @invalid ],

        # ''
        empty  => [ { 1, 1 }, [ 1 ], {}, [], [ 2 ] ],
        prompt => [ { 1, 1 }, [ 1 ], {}, [], [ 2 ] ],
        undef  => [ { 1, 1 }, [ 1 ], {}, [], [ 2 ] ],

        # ARRAY max 2 int
        lf => [ -2, -1, 0, 1, '', 'a', { 1, 1 }, {}, [ 1, 2, 3, ], [ 'a', 'b' ], [ -3, -4 ] ],

        # ARRAY int
        no_spacebar => [ -2, -1, 0, 1, '', 'a', { 1, 1 }, {}, [ 'a', 'b' ], [ -3, -4 ] ],
    };
}


sub mixed_invalid_1 {
    return {
        beep  => -1, clear_screen => 2, hide_cursor => 3, index => 4, justify => '@', layout => 5, mouse => {},
        order => 1, page => 0, keep => -1, ll => -1, limit => 0, max_height => 0, max_width => 0, default => [],
        pad => 'a', pad_one_row => 'b', empty => [], prompt => {}, undef => [], lf => 4, no_spacebar => 4
    };
}


sub mixed_invalid_2 {
    return {
        no_spacebar => 'a', lf => 'b', undef => [], prompt => {}, empty => {}, pad_one_row => 'c', pad => 'd',
        default => 'e', max_width => -1, max_height => -2,  limit => -3, ll => -4, keep => -5, page => -6, order => -7,
        mouse => 'k', layout => 'e', justify => [], index => {}, hide_cursor => -1,  clear_screen => [], beep  => 10
    };
}



1;

__END__
