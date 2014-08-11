package # hide
Data_Test_Choose;

use 5.010000;
use warnings;
use strict;

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

##############################################################################################################


sub keys {
    return {

        CONTROL_at    => "\x{00}",
        CONTROL_Space => "\x{00}",

        CONTROL_C     => "\x{03}",
        CONTROL_D     => "\x{04}",

        CONTROL_H     => "\x{08}",
        BTAB          => "\x{08}",
        BSPACE        => "\x{7f}",
        BTAB_Z        => "\e[Z",
        BTAB_OZ       => "\eOZ",

        CONTROL_I     => "\x{09}",
        TAB           => "\x{09}",

        CONTROL_M     => "\x{0d}",
        ENTER         => "\x{0d}",

        SPACE         => "\x{20}",
        Key_q         => "\x{71}",

        Key_k         => "\x{6b}",
        UP            => "\e[A",
        UP_O          => "\eOA",

        Key_j         => "\x{6a}",
        DOWN          => "\e[B",
        DOWN_O        => "\eOB",

        Key_l         => "\x{6c}",
        RIGHT         => "\e[C",
        RIGHT_O       => "\eOC",

        Key_h         => "\x{68}",
        LEFT          => "\e[D",
        LEFT_O        => "\eOD",

        CONTROL_B     => "\x{02}",
        PAGE_UP       => "\e[5~",

        CONTROL_F     => "\x{06}",
        PAGE_DOWN     => "\e[6~",

        CONTROL_A     => "\x{01}",
        HOME          => "\e[H",

        CONTROL_E     => "\x{05}",
        END           => "\e[F",
    }
}


sub pressed_keys {
    return [ qw(
        SPACE
        END
        SPACE
        HOME
        SPACE
        CONTROL_E
        PAGE_UP
        SPACE
        CONTROL_B CONTROL_B CONTROL_B CONTROL_B CONTROL_B CONTROL_B
        SPACE
        TAB TAB TAB TAB TAB TAB TAB TAB TAB TAB
        DOWN DOWN DOWN
        SPACE
        RIGHT
        DOWN_O DOWN_O
        Key_j
        SPACE
        LEFT_O LEFT_O
        Key_h Key_h
        SPACE
        PAGE_DOWN
        CONTROL_F CONTROL_F
        SPACE
        BSPACE BSPACE BSPACE BSPACE BSPACE BSPACE BSPACE BSPACE BSPACE BSPACE
        CONTROL_H CONTROL_H CONTROL_H CONTROL_H CONTROL_H
        BTAB BTAB
        BTAB_Z
        BTAB_OZ
        SPACE
        UP UP UP
        UP_O UP_O UP_O
        Key_k Key_k Key_k
        SPACE
        RIGHT_O
        CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I
        CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I
        SPACE
        PAGE_DOWN PAGE_DOWN PAGE_DOWN
        PAGE_UP PAGE_UP PAGE_UP PAGE_UP PAGE_UP PAGE_UP
        SPACE
        END
        LEFT
        ENTER
    ) ];
}


sub pressed_keys_short {
    return [ qw(
        SPACE
        END
        SPACE
        HOME
        SPACE
        CONTROL_E
        PAGE_UP
        SPACE
        SPACE
        TAB TAB TAB TAB TAB TAB TAB TAB TAB TAB
        SPACE
        RIGHT
        SPACE
        LEFT_O LEFT_O
        Key_h Key_h
        SPACE
        PAGE_DOWN
        SPACE
        BSPACE BSPACE BSPACE BSPACE BSPACE BSPACE BSPACE BSPACE BSPACE BSPACE
        CONTROL_H CONTROL_H CONTROL_H CONTROL_H CONTROL_H
        BTAB BTAB
        BTAB_Z
        BTAB_OZ
        SPACE
        UP UP
        UP_O UP_O
        Key_k Key_k
        SPACE
        DOWN
        DOWN_O
        Key_j
        SPACE
        RIGHT_O
        CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I
        CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I
        SPACE
        END
        LEFT
        ENTER
    ) ];
}


sub test_list {
    return {
        long    => [ 0 .. 1999 ],
        short   => [ 0 .. 99 ],
        unicode => [ (
            "\x{043a}\x{043e}\x{043d}\x{044c}",
            "\x{9f8d}",
            "\x{9f99}",
            "\x{263a}8\x{263b}c",
            "\x{b8e1}\x{002f}\x{c6a9}",
            "\x{bbf8}\x{b974}",
            "\x{05d0}\x{05e8}\x{05d5}\x{05d7}\x{05ea}\x{0020}\x{05d1}\x{05d5}\x{05e7}\x{05e8}",
            'aa' .. 'az',
            "\x{7adc}",
            "\x{308a}\x{3085}\x{3046}",
            "\x{305f}\x{3064}",
            "\x{06f2}\x{06f0}\x{06f1}\x{06f4}",
            'hello',
            "\x{0639}\x{0633}\x{0644}",
            "\x{842c}\x{91cc}\x{9577}\x{57ce}",
            0 .. 9,
            "\x{0be8}\x{0be6}\x{0be7}\x{0bea}",
            "\x{0628}\x{064a}\x{062a}",
            "\x{03b8}\x{03ac}\x{03bb}\x{03b1}\x{03c3}\x{03c3}\x{03b1}",
            'world',
            "\x{5fa1}\x{8336}",
            "\x{94c1}\x{8def}",
            "\x{7267}\x{573a}",
            'A' .. 'Z',
            "\x{05d4}\x{05e9}\x{05de}\x{05e9}",
            "\x{0627}\x{0644}\x{0639}\x{064a}\x{0646}",
        ) x 10 ],
    }
}


sub test_options {
    return [
        {
            long    => "<83 92 951 1017 1410 1558 1567 1624 1846 1867 1977 1999>",
            short   => "<80 94>",
            unicode => "<aj Z ab ah R R av hello ag ap F \x{0627}\x{0644}\x{0639}\x{064a}\x{0646}>",
            options => { max_height => undef, max_width => undef, layout => 0 },
        },
        {
            long    => "<69 78 943 1003 1402 1550 1559 1610 1846 1859 1979 1999>",
            short   => "<80 94>",
            unicode => "<ab L \x{05d0}\x{05e8}\x{05d5}\x{05d7}\x{05ea}\x{0020}\x{05d1}\x{05d5}\x{05e7}\x{05e8} an D J av aw \x{0627}\x{0644}\x{0639}\x{064a}\x{0646} ab H \x{0627}\x{0644}\x{0639}\x{064a}\x{0646}>",
            options => { max_height => 20,    max_width => undef, layout => 0 }
        },
        {
            long    => "<83 92 951 1017 1410 1558 1567 1624 1846 1867 1977 1999>",
            short   => "<7 10 12 67 93 99>",
            unicode => "<aj Z ab ah R R av hello ag ap F \x{0627}\x{0644}\x{0639}\x{064a}\x{0646}>",
            options => { max_height => undef, max_width => undef, layout => 1 }
        },
        {
            long    => "<1859 1869 1872 1907 1916 1929 1935 1979 1999>",
            short   => "<64 67 70 89 99>",
            unicode => "<aw \x{842c}\x{91cc}\x{9577}\x{57ce} 2 U \x{9f8d} ah an H \x{0627}\x{0644}\x{0639}\x{064a}\x{0646}>",
            options => { max_height => 20,    max_width => undef, layout => 3 }
        },
        {
            long    => "<1052 1118 1307 1316 1799 1843 1845 1849 1852 1909 1977 1999>",
            short   => "<35 38 41 69 85 99>",
            unicode => "<aq \x{b8e1}\x{002f}\x{c6a9} T \x{043a}\x{043e}\x{043d}\x{044c} \x{0627}\x{0644}\x{0639}\x{064a}\x{0646} ah ai an aq X F \x{0627}\x{0644}\x{0639}\x{064a}\x{0646}>",
            options => { max_height => undef, max_width => 61,    layout => 2 }
        },
        {
            long    => "<1066 1126 1315 1324 1799 1857 1859 1863 1866 1917 1979 1999>",
            short   => "<7 10 12 67 93 99>",
            unicode => "<hello af \x{0627}\x{0644}\x{0639}\x{064a}\x{0646} ab \x{0627}\x{0644}\x{0639}\x{064a}\x{0646} av aw \x{308a}\x{3085}\x{3046} hello \x{263a}8\x{263b}c H \x{0627}\x{0644}\x{0639}\x{064a}\x{0646}>",
            options => { max_height => 20,    max_width => 60,    layout => 0 }
        },
        {
            long    => "<1066 1126 1315 1324 1799 1857 1859 1863 1866 1917 1979 1999>",
            short   => "<41 44 47 50 91 99>",
            unicode => "<hello af \x{0627}\x{0644}\x{0639}\x{064a}\x{0646} ab \x{0627}\x{0644}\x{0639}\x{064a}\x{0646} av aw \x{308a}\x{3085}\x{3046} hello \x{263a}8\x{263b}c H \x{0627}\x{0644}\x{0639}\x{064a}\x{0646}>",
            options => { max_height => 20,    max_width => 60,    layout => 1 }
        },
        {
            long    => "<1066 1126 1315 1324 1799 1857 1859 1863 1866 1917 1979 1999>",
            short   => "<35 38 41 69 85 99>",
            unicode => "<hello af \x{0627}\x{0644}\x{0639}\x{064a}\x{0646} ab \x{0627}\x{0644}\x{0639}\x{064a}\x{0646} av aw \x{308a}\x{3085}\x{3046} hello \x{263a}8\x{263b}c H \x{0627}\x{0644}\x{0639}\x{064a}\x{0646}>",
            options => { max_height => 20,    max_width => 60,    layout => 2 }
        },
        {
            long    => "<1859 1869 1872 1907 1916 1929 1935 1979 1999>",
            short   => "<64 67 70 89 99>",
            unicode => "<aw \x{842c}\x{91cc}\x{9577}\x{57ce} 2 U \x{9f8d} ah an H \x{0627}\x{0644}\x{0639}\x{064a}\x{0646}>",
            options => { max_height => 20,    max_width => 60,    layout => 3 }
        },
        {
            long    => "<86 89 149 312 748 808 1777 1859 1915 1924 1979 1999>",
            short   => "<61 64 67 89 96 99>",
            unicode => "<P X 7 \x{94c1}\x{8def} \x{305f}\x{3064} \x{0627}\x{0644}\x{0639}\x{064a}\x{0646} ab Y 2 aw H \x{0627}\x{0644}\x{0639}\x{064a}\x{0646}>",
            options => { max_height => 20,    max_width => 60,    layout => 1, prompt => 'Your choice: ', page => 0, pad => 3,
                        order => 1, justify => 2, keep => 8, clear_screen => 1 }
        },
        {
            long    => "<170 173 197 396 832 856 1777 1943 1963 1972 1991 1999>",
            short   => "<41 44 47 50 91 99>",
            unicode => "<O W ad al \x{308a}\x{3085}\x{3046} 7 \x{7267}\x{573a} X 2 av T \x{0627}\x{0644}\x{0639}\x{064a}\x{0646}>",
            options => { max_height => 20,    max_width => 60,    layout => 1, prompt => 'Your choice: ' x 100, page => 0,
                        pad => 3, order => 1, justify => 2, keep => 8, clear_screen => 1, pad_one_row => 4 }
        },
        {
            long    => "<0 10 57 66 481 529 709 780 789 828 923 936 984 1000>",
            short   => "<0 7 67 93 99>",
            unicode => "<\x{043a}\x{043e}\x{043d}\x{044c} ad \x{06f2}\x{06f0}\x{06f1}\x{06f4} \x{0627}\x{0644}\x{0639}\x{064a}\x{0646} av \x{308a}\x{3085}\x{3046} T ac av A ai ar L \x{0627}\x{0644}\x{0639}\x{064a}\x{0646}>",
            options => { prompt => 'Hello world' x 50, default => 10, empty =>' ', undef => '--', limit => 1001, beep => 1,
                        no_spacebar => [ 11 .. 14 ], lf => [ 0, 4 ], keep => 16 }
        },
        {
            long    => "<0 9>",
            short   => "<9>",
            unicode => "<\x{043a}\x{043e}\x{043d}\x{044c} ac>",
            options => { prompt => 'Hello world' x 50, default => 10, empty =>' ', undef => '--', limit => 11, pad_one_row => 4,
                        no_spacebar => [ 1 .. 14 ], lf => [ 3, 2 ], keep => 7 }
        },

    ];
    # ll
}







1;

__END__
