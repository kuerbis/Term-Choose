package # hide
Term_Choose_Testdata;

use 5.010000;
use warnings;
use strict;
use utf8;

# CONTROL_C
# KEY_q CONTROL_D

sub key_move_results {
# 24 x 80
#for my $count ( 1 .. 32 ) {
#    my @choice = choose(
#        [ 0 .. 1999 ],
#        { order => 0, layout => 0, hide_cursor => 0 }
#    );
#    say "<@choice>";
#}
    return {
        ENTER       => [ '<0>',     ( "\r" )                                      ],
        CONTROL_M   => [ '<0>',     ( "\cM" )                                     ],

        RIGHT       => [ '<3>',     ( "\e[C" x 3 )                     . ( "\r" ) ],
        RIGHT_O     => [ '<3>',     ( "\eOC" x 3 )                     . ( "\r" ) ],
        Key_l       => [ '<3>',     ( "l" x 3 )                        . ( "\r" ) ],

        LEFT        => [ '<2>',     ( "\e[C" x 4 ) . ( "\e[D" x 2 )    . ( "\r" ) ],
        LEFT_O      => [ '<2>',     ( "\eOC" x 4 ) . ( "\eOD" x 2 )    . ( "\r" ) ],
        Key_h       => [ '<2>',     ( "l" x 4 )    . ( "h" x 2 )       . ( "\r" ) ],

        DOWN        => [ '<40>',    ( "\e[C" x 1 ) . ( "\e[B" x 3 )    . ( "\r" ) ],
        DOWN_O      => [ '<40>',    ( "\eOC" x 1 ) . ( "\eOB" x 3 )    . ( "\r" ) ],
        Key_j       => [ '<40>',    ( "l" x 1 )    . ( "j" x 3 )       . ( "\r" ) ],

        UP          => [ '<39>',    ( "\e[B" x 6 ) . ( "\e[A" x 3 )    . ( "\r" ) ],
        UP_O        => [ '<39>',    ( "\eOB" x 6 ) . ( "\eOA" x 3 )    . ( "\r" ) ],
        Key_k       => [ '<39>',    ( "j" x 6 )    . ( "k" x 3 )       . ( "\r" ) ],

        TAB         => [ '<16>',    ( "\t" x 16 )                      . ( "\r" ) ],
        CONTROL_I   => [ '<16>',    ( "\cI" x 16 )                     . ( "\r" ) ],

        BSPACE      => [ '<68>',    ( "\e[B" x 6 ) . ( "\x{7f}" x 10 ) . ( "\r" ) ],
        CONTROL_H   => [ '<68>',    ( "\e[B" x 6 ) . ( "\cH" x 10 )    . ( "\r" ) ],
        BTAB        => [ '<68>',    ( "\e[B" x 6 ) . ( "\x{08}" x 10 ) . ( "\r" ) ],
        BTAB_Z      => [ '<68>',    ( "\e[B" x 6 ) . ( "\e[Z" x 10 )   . ( "\r" ) ],
        BTAB_OZ     => [ '<68>',    ( "\eOB" x 6 ) . ( "\eOZ" x 10 )   . ( "\r" ) ],

        HOME        => [ '<0>',     ( "\e[H" )                         . ( "\r" ) ],
        CONTROL_A   => [ '<0>',     ( "\cA" )                          . ( "\r" ) ],

        END         => [ '<1999>',  ( "\e[F" )                         . ( "\r" ) ],
        CONTROL_E   => [ '<1999>',  ( "\cE" )                          . ( "\r" ) ],

        PAGE_DOWN   => [ '<286>',   ( "\e[6~" )                        . ( "\r" ) ],
        CONTROL_F   => [ '<286>',   ( "\cF" )                          . ( "\r" ) ],

        PAGE_UP     => [ '<572>',   ( "\e[6~" x 3 ) . ( "\e[5~" )      . ( "\r" ) ],
        CONTROL_B   => [ '<572>',   ( "\cF" x 3 ) . ( "\cB" )          . ( "\r" ) ],

        SPACE       => [ '<0 1>',   ( "\x{20}" ) . ( "\e[C" )          . ( "\r" ) ],

        CONTROL_Space => [ '<0 1>',   ( "\x{20}" ) . ( "\e[C" ) . ( "\c\x{20}" x 2 ) . ( "\r" ) ],
        'CONTROL_@'   => [ '<0 1>',   ( "\x{20}" ) . ( "\e[C" ) . ( "\c@ " x 2 )     . ( "\r" ) ],
    };
}

#################################################################################################

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



##################################################################################################

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


##############################################################################################################

sub test_options {
    return [
        [ 1999, { max_height => undef, max_width => undef, layout => 0 } ],
        [ 1999, { max_height => 20,    max_width => undef, layout => 0 } ],
        [ 1999, { max_height => undef, max_width => undef, layout => 1 } ],
        [ 1999, { max_height => 20,    max_width => undef, layout => 3 } ],
        [ 1999, { max_height => undef, max_width => 61,    layout => 2 } ],
        [ 1999, { max_height => 20,    max_width => 60,    layout => 0 } ],
        [ 1999, { max_height => 20,    max_width => 60,    layout => 1 } ],
        [ 1999, { max_height => 20,    max_width => 60,    layout => 2 } ],
        [ 1999, { max_height => 20,    max_width => 60,    layout => 3 } ],
        [ 1999, { max_height => 20,    max_width => 60,    layout => 1,
            prompt => 'Your choice: ', page => 0, pad => 3,
            order => 1, justify => 2, keep => 8, clear_screen => 1 } ],
        [ 1999, { max_height => 20,    max_width => 60,    layout => 1,
            prompt => 'Your choice: ' x 100, page => 0, pad => 3,
            order => 1, justify => 2, keep => 8, clear_screen => 1, pad_one_row => 4 } ],
        [ 1000, { prompt => 'Hello world' x 50, default => 10, empty =>' ', undef => '--', limit => 1001,
            beep => 1, no_spacebar => [ 1 ..14 ], lf => [ 0, 4 ], keep => 16 } ],
        [ 10, { prompt => 'Hello world' x 50, default => 10, empty =>' ', undef => '--', limit => 11,
            pad_one_row => 4, no_spacebar => [ 1 ..14 ], lf => [ 3, 2 ], keep => 7 } ],
    ];
    # ll
}













1;

__END__
