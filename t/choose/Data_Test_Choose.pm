package # hide
Data_Test_Choose;

use 5.008000;
use warnings;
use strict;


sub key_seq {
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



my $simple = [
    {
       list      => [ 2 ],
       used_keys => [ qw( ENTER ) ],
       expected  => "<2>",
       options   => { prompt => 'Your choice: ', order => 0, layout => 0, hide_cursor => 0 },
   },
];

my $hide_cursor = [
    {
       list      => [ 1 .. 199 ],
       used_keys => [ qw( ENTER ) ],
       expected  => "<1>",
       options   => { prompt => 'Your choice: ', order => 0, layout => 0, hide_cursor => 1, clear_screen => 0  }
   },
];


# CONTROL_C
# KEY_q CONTROL_D
my $k_list    = [ 0 .. 1999 ];
my $k_options = { default => 1007, order => 0, layout => 0, hide_cursor => 0 };
my $seq_test = [
    #{ list => $k_list, used_keys => [ qw( ENTER ) ],        expected => "<1007>",     options => $k_options, },
    #{ list => $k_list, used_keys => [ qw( CONTROL_M ) ],    expected => "<1007>",     options => $k_options, },
    { list => $k_list, used_keys => [ qw( RIGHT ) ],        expected => "<1008>",     options => $k_options, },
    { list => $k_list, used_keys => [ qw( RIGHT_O ) ],      expected => "<1008>",     options => $k_options, },
    { list => $k_list, used_keys => [ qw( Key_l ) ],        expected => "<1008>",     options => $k_options, },
    { list => $k_list, used_keys => [ qw( LEFT ) ],         expected => "<1006>",     options => $k_options, },
    { list => $k_list, used_keys => [ qw( LEFT_O ) ],       expected => "<1006>",     options => $k_options, },
    { list => $k_list, used_keys => [ qw( Key_h ) ],        expected => "<1006>",     options => $k_options, },
    { list => $k_list, used_keys => [ qw( DOWN ) ],         expected => "<1020>",     options => $k_options, },
    { list => $k_list, used_keys => [ qw( DOWN_O ) ],       expected => "<1020>",     options => $k_options, },
    { list => $k_list, used_keys => [ qw( Key_j ) ],        expected => "<1020>",     options => $k_options, },
    { list => $k_list, used_keys => [ qw( UP ) ],           expected => "<994>",      options => $k_options, },
    { list => $k_list, used_keys => [ qw( UP_O ) ],         expected => "<994>",      options => $k_options, },
    { list => $k_list, used_keys => [ qw( Key_k ) ],        expected => "<994>",      options => $k_options, },
    { list => $k_list, used_keys => [ qw( TAB ) ],          expected => "<1008>",     options => $k_options, },
    { list => $k_list, used_keys => [ qw( CONTROL_I ) ],    expected => "<1008>",     options => $k_options, },
    { list => $k_list, used_keys => [ qw( BSPACE ) ],       expected => "<1006>",     options => $k_options, },
    { list => $k_list, used_keys => [ qw( CONTROL_H ) ],    expected => "<1006>",     options => $k_options, },
    { list => $k_list, used_keys => [ qw( BTAB ) ],         expected => "<1006>",     options => $k_options, },
    { list => $k_list, used_keys => [ qw( BTAB_Z ) ],       expected => "<1006>",     options => $k_options, },
    { list => $k_list, used_keys => [ qw( BTAB_OZ ) ],      expected => "<1006>",     options => $k_options, },
    { list => $k_list, used_keys => [ qw( HOME ) ],         expected => "<0>",        options => $k_options, },
    { list => $k_list, used_keys => [ qw( CONTROL_A ) ],    expected => "<0>",        options => $k_options, },
    { list => $k_list, used_keys => [ qw( END ) ],          expected => "<1999>",     options => $k_options, },
    { list => $k_list, used_keys => [ qw( CONTROL_E ) ],    expected => "<1999>",     options => $k_options, },
    { list => $k_list, used_keys => [ qw( PAGE_DOWN ) ],    expected => "<1293>",     options => $k_options, },
    { list => $k_list, used_keys => [ qw( CONTROL_F ) ],    expected => "<1293>",     options => $k_options, },
    { list => $k_list, used_keys => [ qw( PAGE_UP ) ],      expected => "<721>",      options => $k_options, },
    { list => $k_list, used_keys => [ qw( CONTROL_B ) ],    expected => "<721>",      options => $k_options, },
    { list => $k_list, used_keys => [ qw( SPACE ) ],        expected => "<1007>",     options => $k_options, },
    { list => $k_list, used_keys => [ qw( CONTROL_Space ) ],expected => "<@$k_list>", options => $k_options, },
    { list => $k_list, used_keys => [ qw( CONTROL_at ) ],    expected => "<@$k_list>", options => $k_options, },
];

##############################################################################################################



my $keys = {
    long => [ qw(
        SPACE
            END
        SPACE
            HOME
        SPACE
            CONTROL_E PAGE_UP
        SPACE
            CONTROL_B CONTROL_B CONTROL_B CONTROL_B CONTROL_B CONTROL_B
        SPACE
            TAB TAB TAB TAB TAB TAB TAB TAB TAB TAB DOWN DOWN DOWN
        SPACE
            RIGHT DOWN_O DOWN_O Key_j
        SPACE
            LEFT_O LEFT_O Key_h Key_h
        SPACE
            PAGE_DOWN CONTROL_F CONTROL_F
        SPACE
            BSPACE BSPACE BSPACE BSPACE BSPACE BSPACE BSPACE BSPACE BSPACE BSPACE
            CONTROL_H CONTROL_H CONTROL_H CONTROL_H CONTROL_H
            BTAB BTAB BTAB_Z BTAB_OZ
        SPACE
            UP UP UP UP_O UP_O UP_O Key_k Key_k Key_k
        SPACE
            RIGHT_O
            CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I
            CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I
        SPACE
            PAGE_DOWN PAGE_DOWN PAGE_DOWN PAGE_UP PAGE_UP PAGE_UP PAGE_UP PAGE_UP PAGE_UP
        SPACE
            END LEFT
        ENTER
    ) ],
    short => [ qw(
        SPACE
            END
        SPACE
            HOME
        SPACE
            CONTROL_E PAGE_UP
        SPACE
        SPACE
            TAB TAB TAB TAB TAB TAB TAB TAB TAB TAB
        SPACE
            RIGHT
        SPACE
            LEFT_O LEFT_O Key_h Key_h
        SPACE
            PAGE_DOWN
        SPACE
            BSPACE BSPACE BSPACE BSPACE BSPACE BSPACE BSPACE BSPACE BSPACE BSPACE
            CONTROL_H CONTROL_H CONTROL_H CONTROL_H CONTROL_H
            BTAB BTAB BTAB_Z BTAB_OZ
        SPACE
            UP UP UP_O UP_O Key_k Key_k
        SPACE
            DOWN DOWN_O Key_j
        SPACE
            RIGHT_O
            CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I
            CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I CONTROL_I
        SPACE
            END LEFT
        ENTER
    ) ],
};


my $list = {
    long    => [ 0 .. 1999 ],
    short   => [ 0 .. 99 ],
    ll      => [ (
            "In"            . '.' x 7,
            "scalar"        . '.' x 3,
            "context"       . '.' x 4,
            "returns"       . '.' x 2,
            "the"           . '.' x 6,
            "number"        . '.' x 3,
            "of"            . '.' x 7,
            "elements"      . '.' x 1,
            "so"            . '.' x 7,
            "generated"              ,
            "hello"         . '.' x 4,
            "world"         . '.' x 4,
            "12345678"      . '.' x 1,
            "The"           . '.' x 6,
            "black"         . '.' x 4,
            "cat"           . '.' x 6,
            "jumped"        . '.' x 3,
            "from"          . '.' x 5,
            "the"           . '.' x 6,
            "green"         . '.' x 4,
            "tree"          . '.' x 5,
            "abcdefghi"              ,

        ) x 2 ],
};


my $options = [
    { max_height => undef, max_width => undef, layout => 0 },
    { max_height => 20, max_width => undef, layout => 0 },
    { max_height => undef, max_width => undef, layout => 1 },
    { max_height => 20, max_width => undef, layout => 3 },
    { max_height => undef, max_width => 61, layout => 2 },
    { max_height => 20, max_width => 60, layout => 0 },
    { max_height => 20, max_width => 60, layout => 1 },
    { max_height => 20, max_width => 60, layout => 2 },
    { max_height => 20, max_width => 60, layout => 3 },
    { max_height => 20, max_width => 60, layout => 1, prompt => 'Your choice: ', page => 0, pad => 3, order => 1,
      justify => 2, keep => 8, clear_screen => 1 },
    { max_height => 20, max_width => 60, layout => 1, prompt => 'Your choice: ' x 100, page => 0, pad => 3, order => 1,
      justify => 2, keep => 8, clear_screen => 1, pad_one_row => 4 },
    { prompt => 'abc 12345678 def' x 50, default => 10, empty =>' ', undef => '--', beep => 1,
      no_spacebar => [ 11 .. 2000 ], lf => [ 0, 4 ], keep => 16 },
];



my $c_opt;
$c_opt = 0;
my $long = [
    {   list      => $list->{long},
        used_keys => $keys->{long},
        expected  => "<83 92 951 1017 1410 1558 1567 1624 1846 1867 1977 1999>",
        options   => $options->[$c_opt++],
    },
    {   list      => $list->{long},
        used_keys => $keys->{long},
        expected  => "<69 78 943 1003 1402 1550 1559 1610 1846 1859 1979 1999>",
        options   => $options->[$c_opt++],
    },
    {   list      => $list->{long},
        used_keys => $keys->{long},
        expected  => "<83 92 951 1017 1410 1558 1567 1624 1846 1867 1977 1999>",
        options   => $options->[$c_opt++],
    },
    {   list      => $list->{long},
        used_keys => $keys->{long},
        expected  => "<1859 1869 1872 1907 1916 1929 1935 1979 1999>",
        options   => $options->[$c_opt++],
    },
    {   list      => $list->{long},
        used_keys => $keys->{long},
        expected  => "<1052 1118 1307 1316 1799 1843 1845 1849 1852 1909 1977 1999>",
        options   => $options->[$c_opt++],
    },
    {   list      => $list->{long},
        used_keys => $keys->{long},
        expected  => "<1066 1126 1315 1324 1799 1857 1859 1863 1866 1917 1979 1999>",
        options   => $options->[$c_opt++],
    },
    {   list      => $list->{long},
        used_keys => $keys->{long},
        expected  => "<1066 1126 1315 1324 1799 1857 1859 1863 1866 1917 1979 1999>",
        options   => $options->[$c_opt++],
    },
    {   list      => $list->{long},
        used_keys => $keys->{long},
        expected  => "<1066 1126 1315 1324 1799 1857 1859 1863 1866 1917 1979 1999>",
        options   => $options->[$c_opt++],
    },
    {   list      => $list->{long},
        used_keys => $keys->{long},
        expected  => "<1859 1869 1872 1907 1916 1929 1935 1979 1999>",
        options   => $options->[$c_opt++],
    },
    {   list      => $list->{long},
        used_keys => $keys->{long},
        expected  => "<86 89 149 312 748 808 1777 1859 1915 1924 1979 1999>",
        options   => $options->[$c_opt++],
    },
    {   list      => $list->{long},
        used_keys => $keys->{long},
        expected  => "<170 173 197 396 832 856 1777 1943 1963 1972 1991 1999>",
        options   => $options->[$c_opt++],
    },
    {   list      => $list->{long},
        used_keys => $keys->{long},
        expected  => "<0 10 1846>",
        options   => $options->[$c_opt++],
    },
];

$c_opt = 0;
my $short = [
    {   list      => $list->{short},
        used_keys => $keys->{short},
        expected  => "<80 94>",
        options   => $options->[$c_opt++],
    },
    {   list      => $list->{short},
        used_keys => $keys->{short},
        expected  => "<80 94>",
        options   => $options->[$c_opt++],
    },
    {   list      => $list->{short},
        used_keys => $keys->{short},
        expected  => "<7 10 12 67 93 99>",
        options   => $options->[$c_opt++],
    },
    {   list      => $list->{short},
        used_keys => $keys->{short},
        expected  => "<64 67 70 89 99>",
        options   => $options->[$c_opt++],
    },
    {   list      => $list->{short},
        used_keys => $keys->{short},
        expected  => "<35 38 41 69 85 99>",
        options   => $options->[$c_opt++],
    },
    {   list      => $list->{short},
        used_keys => $keys->{short},
        expected  => "<7 10 12 67 93 99>",
        options   => $options->[$c_opt++],
    },
    {   list      => $list->{short},
        used_keys => $keys->{short},
        expected  => "<41 44 47 50 91 99>",
        options   => $options->[$c_opt++],
    },
    {   list      => $list->{short},
        used_keys => $keys->{short},
        expected  => "<35 38 41 69 85 99>",
        options   => $options->[$c_opt++],
    },
    {   list      => $list->{short},
        used_keys => $keys->{short},
        expected  => "<64 67 70 89 99>",
        options   => $options->[$c_opt++],
    },
    {   list      => $list->{short},
        used_keys => $keys->{short},
        expected  => "<61 64 67 89 96 99>",
        options   => $options->[$c_opt++],
    },
    {   list      => $list->{short},
        used_keys => $keys->{short},
        expected  => "<41 44 47 50 91 99>",
        options   => $options->[$c_opt++],
    },
    {   list      => $list->{short},
        used_keys => $keys->{short},
        expected  => "<0 7 93>",
        expected_w81 => "<0 10 93>",
        options   => $options->[$c_opt++],
    },
];

my $option_ll = [
    {
        list      => $list->{ll},
        used_keys => [ ( 'DOWN' ) x 3, 'SPACE', ( 'RIGHT' ) x 3, 'SPACE', 'HOME', 'ENTER'  ],
        expected  => "<In....... returns.. so.......>",
        options   => { ll => 9, layout => 1 }
    },
    {
        list      => $list->{ll},
        used_keys => [  'END', 'SPACE', 'PAGE_UP', 'SPACE', ( 'UP' ) x 12, 'LEFT', 'ENTER'  ],
        expected  => "<generated abcdefghi abcdefghi>",
        options   => { ll => 9, layout => 3 }
    },
];

my $pad_one_row = [
    {
        list      => [ qw( 1 The black cat this_is_a_long_word climbed the green tree ) ],
        used_keys => [ qw( END LEFT SPACE LEFT LEFT LEFT ENTER ) ],
        expected  => "<this_is_a_long_word green>",
        options   => { prompt => 'one_row', default => 3, pad_one_row => 3 }
    },
];

sub return_test_data {
    my $type = shift;
       if ( $type eq 'simple'        ) { return $simple; }
    elsif ( $type eq 'hide_cursor'   ) { return $hide_cursor; }
    elsif ( $type eq 'seq_test'      ) { return $seq_test; }
    elsif ( $type eq 'long'          ) { return $long; }
    elsif ( $type eq 'short'         ) { return $short; }
    elsif ( $type eq 'option_ll'     ) { return $option_ll; }
    elsif ( $type eq 'pad_one_row'   ) { return $pad_one_row; }

}




1;

__END__
