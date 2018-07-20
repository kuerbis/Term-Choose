package Term::Choose;

use warnings;
use strict;
use 5.008003;

our $VERSION = '1.608';
use Exporter 'import';
our @EXPORT_OK = qw( choose );

use Carp qw( croak carp );

use Term::Choose::Constants qw( :choose );
use Term::Choose::LineFold  qw( line_fold print_columns cut_to_printwidth );

no warnings 'utf8';

my $Plugin_Package;

BEGIN {
    if ( $^O eq 'MSWin32' ) {
        require Term::Choose::Win32;
        $Plugin_Package = 'Term::Choose::Win32';
    }
    else {
        require Term::Choose::Linux;
        $Plugin_Package = 'Term::Choose::Linux';
    }
}


sub new {
    my $class = shift;
    my ( $opt ) = @_;
    croak "new: called with " . @_ . " arguments - 0 or 1 arguments expected" if @_ > 1;
    my $self = bless {}, $class;
    if ( defined $opt ) {
        croak "new: the (optional) argument must be a HASH reference" if ref $opt ne 'HASH';
        $self->__validate_and_add_options( $opt );
    }
    $self->{backup_opt} = { defined $opt ? %$opt : () };
    $self->{plugin} = $Plugin_Package->new();
    return $self;
}


sub DESTROY {
    my ( $self ) = @_;
    $self->__reset_term();
}


sub __defaults {        #hae
    my ( $self ) = @_;
    my $prompt = defined $self->{wantarray} ? 'Your choice:' : 'Close with ENTER';
    return {
        prompt              => $prompt,
        info                => '',
        beep                => 0,
        clear_screen        => 0,
        #default            => undef,
        empty               => '<empty>',
        hide_cursor         => 1,
        include_highlighted => 0,
        index               => 0,
        justify             => 0,
        keep                => 5,
        layout              => 1,
        #lf                 => undef,
        #ll                 => undef,
        #mark               => undef,
        #max_height         => undef,
        #max_width          => undef,
        mouse               => 0,
        #no_spacebar        => undef,
        #meta_items         => undef,
        order               => 1,
        pad                 => 2,
        page                => 1,
        undef               => '<undef>',
    };
}


sub __undef_to_defaults {
    my ( $self ) = @_;
    my $defaults = $self->__defaults();
    for my $option ( keys %$defaults ) {
        $self->{$option} = $defaults->{$option} if ! defined $self->{$option};
    }
}


sub __valid_options {       #hae
    return {
        beep                => '[ 0 1 ]',
        clear_screen        => '[ 0 1 ]',
        hide_cursor         => '[ 0 1 ]',
        index               => '[ 0 1 ]',
        order               => '[ 0 1 ]',
        page                => '[ 0 1 ]',
        include_highlighted => '[ 0 1 2 ]',
        justify             => '[ 0 1 2 ]',
        layout              => '[ 0 1 2 3 ]',
        mouse               => '[ 0 1 2 3 4 ]',
        keep                => '[ 1-9 ][ 0-9 ]*',
        ll                  => '[ 1-9 ][ 0-9 ]*',
        max_height          => '[ 1-9 ][ 0-9 ]*',
        max_width           => '[ 1-9 ][ 0-9 ]*',
        default             => '[ 0-9 ]+',
        pad                 => '[ 0-9 ]+',
        lf                  => 'ARRAY',
        mark                => 'ARRAY',
        no_spacebar         => 'ARRAY',
        meta_items          => 'ARRAY',
        empty               => 'Str',
        info                => 'Str',
        prompt              => 'Str',
        undef               => 'Str',
    };
};


sub __validate_and_add_options {
    my ( $self, $opt ) = @_;
    return if ! defined $opt;
    my $valid = $self->__valid_options();
    my $sub =  ( caller( 1 ) )[3];
    $sub =~ s/^.+::(?:__)?([^:]+)\z/$1/;
    $sub .= ':';
    for my $key ( keys %$opt ) {
        if ( ! exists $valid->{$key} ) {
            croak "$sub '$key' is not a valid option name";
        }
        next if ! defined $opt->{$key};
        if ( $valid->{$key} eq 'ARRAY' ) {
            croak "$sub $key => the passed value has to be an ARRAY reference." if ref $opt->{$key} ne 'ARRAY';
            {
                no warnings 'uninitialized';
                for ( @{$opt->{$key}} ) {
                    /^[0-9]+\z/ or croak "$sub $key => $_ is an invalid array element";
                }
            }
            if ( $key eq 'lf' ) {
                croak "$sub $key => too many array elements." if @{$opt->{$key}} > 2;
            }
        }
        elsif ( $valid->{$key} eq 'Str' ) {
            croak "$sub $key => references are not valid values." if ref $opt->{$key} ne '';
        }
        elsif ( $opt->{$key} !~ m/^$valid->{$key}\z/x ) {
            croak "$sub $key => '$opt->{$key}' is not a valid value.";
        }
        $self->{$key} = $opt->{$key};
    }
}


sub __init_term {
    my ( $self ) = @_;
    $self->{mouse} = $self->{plugin}->__set_mode( $self->{mouse}, $self->{hide_cursor} );
}


sub __reset_term {
    my ( $self, $from_choose ) = @_;
    if ( $from_choose ) {
        print CR;
        my $up = $self->{i_row} + $self->{nr_prompt_lines};
        $self->{plugin}->__up( $up ) if $up;
        $self->{plugin}->__clear_to_end_of_screen();
    }
    if ( defined $self->{plugin} ) {
        $self->{plugin}->__reset_mode( $self->{mouse}, $self->{hide_cursor} );
    }
    if ( exists $self->{backup_opt} ) {
        my $backup_opt = $self->{backup_opt};
        for my $key ( keys %$self ) {
            if ( $key eq 'plugin' || $key eq 'backup_opt' ) {
                next;
            }
            elsif ( exists $backup_opt->{$key} ) {
                $self->{$key} = $backup_opt->{$key};
            }
            else {
                delete $self->{$key};
            }
        }
    }
}


sub __get_key {
    my ( $self ) = @_;
    my $key = $self->{plugin}->__get_key_OS( $self->{mouse} );
    return $key if ref $key ne 'ARRAY';
    return $self->__mouse_info_to_key( @$key );
}


sub choose {      #hae
    if ( ref $_[0] ne 'Term::Choose' ) {
        #return Term::Choose->new()->__choose( @_ );
        return __choose( bless( { plugin => $Plugin_Package->new() }, 'Term::Choose' ), @_ );
    }
    my $self = shift;
    return $self->__choose( @_ ); # 1 backup_self
}

sub __choose {
    my $self = shift;
    my ( $orig_list_ref, $opt ) = @_;
    croak "choose: called with " . @_ . " arguments - 1 or 2 arguments expected" if @_ < 1 || @_ > 2;
    croak "choose: the first argument must be an ARRAY reference" if ref $orig_list_ref ne 'ARRAY';
    if ( defined $opt ) {
        croak "choose: the (optional) second argument must be a HASH reference" if ref $opt ne 'HASH';
        $self->__validate_and_add_options( $opt );
    }
    if ( ! @$orig_list_ref ) {
        return;
    }

    local $\ = undef;
    local $, = undef;
    local $| = 1;
    $self->{wantarray} = wantarray;
    $self->__undef_to_defaults();
    $self->__copy_orig_list( $orig_list_ref );
    $self->__length_longest(); #
    $self->{col_width} = $self->{length_longest} + $self->{pad};
    local $SIG{'INT'} = sub {
        # my $signame = shift;
        exit 1;
    };
    $self->__init_term();
    $self->__write_first_screen();

    GET_KEY: while ( 1 ) {
        my $key = $self->__get_key();
        if ( ! defined $key ) {
            $self->__reset_term( 1 );
            carp "EOT: $!";
            return;
        }
        my ( $new_width, $new_height ) = $self->{plugin}->__get_term_size();
        if ( $new_width != $self->{term_width} || $new_height != $self->{term_height} ) {
            if ( $self->{ll} ) {
                return -1;
            }
            $self->__copy_orig_list( $orig_list_ref );
            $self->{default} = $self->{rc2idx}[$self->{pos}[ROW]][$self->{pos}[COL]];
            if ( $self->{wantarray} && @{$self->{marked}} ) {
                $self->{mark} = $self->__marked_rc2idx();
            }
            print CR;
            my $up = $self->{i_row} + $self->{nr_prompt_lines};
            $self->{plugin}->__up( $up ) if $up;
            $self->{plugin}->__clear_to_end_of_screen();
            $self->__write_first_screen();
            next GET_KEY;
        }
        next GET_KEY if $key == NEXT_get_key;
        next GET_KEY if $key == KEY_Tilde;
        if ( exists $ENV{TC_RESET_AUTO_UP} ) {
            $ENV{TC_RESET_AUTO_UP} = 1 if $key != KEY_ENTER;
        }

        # $self->{rc2idx} holds the new list (AoA) formatted in "__size_and_layout" appropriate to the chosen layout.
        # $self->{rc2idx} does not hold the values directly but the respective list indexes from the original list.
        # If the original list would be ( 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h' ) and the new formatted list should be
        #     a d g
        #     b e h
        #     c f
        # then the $self->{rc2idx} would look like this
        #     0 3 6
        #     1 4 7
        #     2 5
        # So e.g. the second value in the second row of the new list would be $self->{list}[ $self->{rc2idx}[1][1] ].
        # On the other hand the index of the last row of the new list would be $#{$self->{rc2idx}}
        # or the index of the last column in the first row would be $#{$self->{rc2idx}[0]}.

        if ( $key == KEY_j || $key == VK_DOWN ) {
            if (     ! $self->{rc2idx}[$self->{pos}[ROW]+1]
                  || ! $self->{rc2idx}[$self->{pos}[ROW]+1][$self->{pos}[COL]]
            ) {
                $self->{plugin}->__beep();
            }
            else {
                $self->{pos}[ROW]++;
                if ( $self->{pos}[ROW] <= $self->{p_end} ) {
                    $self->__wr_cell( $self->{pos}[ROW] - 1, $self->{pos}[COL] );
                    $self->__wr_cell( $self->{pos}[ROW],     $self->{pos}[COL] );
                }
                else {
                    $self->{p_begin} = $self->{p_end} + 1;
                    $self->{p_end}   = $self->{p_end} + $self->{avail_height};
                    $self->{p_end}   = $#{$self->{rc2idx}} if $self->{p_end} > $#{$self->{rc2idx}};
                    $self->__wr_screen();
                }
            }
        }
        elsif ( $key == KEY_k || $key == VK_UP ) {
            if ( $self->{pos}[ROW] == 0 ) {
                $self->{plugin}->__beep();
            }
            else {
                $self->{pos}[ROW]--;
                if ( $self->{pos}[ROW] >= $self->{p_begin} ) {
                    $self->__wr_cell( $self->{pos}[ROW] + 1, $self->{pos}[COL] );
                    $self->__wr_cell( $self->{pos}[ROW],     $self->{pos}[COL] );
                }
                else {
                    $self->{p_end}   = $self->{p_begin} - 1;
                    $self->{p_begin} = $self->{p_begin} - $self->{avail_height};
                    $self->{p_begin} = 0 if $self->{p_begin} < 0;
                    $self->__wr_screen();
                }
            }
        }
        elsif ( $key == KEY_TAB || $key == CONTROL_I ) {
            if (    $self->{pos}[ROW] == $#{$self->{rc2idx}}
                 && $self->{pos}[COL] == $#{$self->{rc2idx}[$self->{pos}[ROW]]}
            ) {
                $self->{plugin}->__beep();
            }
            else {
                if ( $self->{pos}[COL] < $#{$self->{rc2idx}[$self->{pos}[ROW]]} ) {
                    $self->{pos}[COL]++;
                    $self->__wr_cell( $self->{pos}[ROW], $self->{pos}[COL] - 1 );
                    $self->__wr_cell( $self->{pos}[ROW], $self->{pos}[COL] );
                }
                else {
                    $self->{pos}[ROW]++;
                    if ( $self->{pos}[ROW] <= $self->{p_end} ) {
                        $self->{pos}[COL] = 0;
                        $self->__wr_cell( $self->{pos}[ROW] - 1, $#{$self->{rc2idx}[$self->{pos}[ROW] - 1]} );
                        $self->__wr_cell( $self->{pos}[ROW],     $self->{pos}[COL] );
                    }
                    else {
                        $self->{p_begin} = $self->{p_end} + 1;
                        $self->{p_end}   = $self->{p_end} + $self->{avail_height};
                        $self->{p_end}   = $#{$self->{rc2idx}} if $self->{p_end} > $#{$self->{rc2idx}};
                        $self->{pos}[COL] = 0;
                        $self->__wr_screen();
                    }
                }
            }
        }
        elsif ( $key == KEY_BSPACE || $key == CONTROL_H || $key == KEY_BTAB ) {
            if ( $self->{pos}[COL] == 0 && $self->{pos}[ROW] == 0 ) {
                $self->{plugin}->__beep();
            }
            else {
                if ( $self->{pos}[COL] > 0 ) {
                    $self->{pos}[COL]--;
                    $self->__wr_cell( $self->{pos}[ROW], $self->{pos}[COL] + 1 );
                    $self->__wr_cell( $self->{pos}[ROW], $self->{pos}[COL] );
                }
                else {
                    $self->{pos}[ROW]--;
                    if ( $self->{pos}[ROW] >= $self->{p_begin} ) {
                        $self->{pos}[COL] = $#{$self->{rc2idx}[$self->{pos}[ROW]]};
                        $self->__wr_cell( $self->{pos}[ROW] + 1, 0 );
                        $self->__wr_cell( $self->{pos}[ROW],     $self->{pos}[COL] );
                    }
                    else {
                        $self->{p_end}   = $self->{p_begin} - 1;
                        $self->{p_begin} = $self->{p_begin} - $self->{avail_height};
                        $self->{p_begin} = 0 if $self->{p_begin} < 0;
                        $self->{pos}[COL] = $#{$self->{rc2idx}[$self->{pos}[ROW]]};
                        $self->__wr_screen();
                    }
                }
            }
        }
        elsif ( $key == KEY_l || $key == VK_RIGHT ) {
            if ( $self->{pos}[COL] == $#{$self->{rc2idx}[$self->{pos}[ROW]]} ) {
                $self->{plugin}->__beep();
            }
            else {
                $self->{pos}[COL]++;
                $self->__wr_cell( $self->{pos}[ROW], $self->{pos}[COL] - 1 );
                $self->__wr_cell( $self->{pos}[ROW], $self->{pos}[COL] );
            }
        }
        elsif ( $key == KEY_h || $key == VK_LEFT ) {
            if ( $self->{pos}[COL] == 0 ) {
                $self->{plugin}->__beep();
            }
            else {
                $self->{pos}[COL]--;
                $self->__wr_cell( $self->{pos}[ROW], $self->{pos}[COL] + 1 );
                $self->__wr_cell( $self->{pos}[ROW], $self->{pos}[COL] );
            }
        }
        elsif ( $key == CONTROL_B || $key == VK_PAGE_UP ) {
            if ( $self->{p_begin} <= 0 ) {
                $self->{plugin}->__beep();
            }
            else {
                $self->{p_begin} = $self->{avail_height} * ( int( $self->{pos}[ROW] / $self->{avail_height} ) - 1 );;
                $self->{p_end}   = $self->{p_begin} + $self->{avail_height} - 1;
                $self->{pos}[ROW] -= $self->{avail_height};
                $self->__wr_screen();
            }
        }
        elsif ( $key == CONTROL_F || $key == VK_PAGE_DOWN ) {
            if ( $self->{p_end} >= $#{$self->{rc2idx}} ) {
                $self->{plugin}->__beep();
            }
            else {
                $self->{p_begin} = $self->{avail_height} * ( int( $self->{pos}[ROW] / $self->{avail_height} ) + 1 );
                $self->{p_end}   = $self->{p_begin} + $self->{avail_height} - 1;
                $self->{p_end}   = $#{$self->{rc2idx}} if $self->{p_end} > $#{$self->{rc2idx}};
                $self->{pos}[ROW] += $self->{avail_height};
                if ( $self->{pos}[ROW] >= $#{$self->{rc2idx}} ) {
                    if ( $#{$self->{rc2idx}} == $self->{p_begin} || ! $self->{rest} || $self->{pos}[COL] <= $self->{rest} - 1 ) {
                        if ( $self->{pos}[ROW] != $#{$self->{rc2idx}} ) {
                            $self->{pos}[ROW] = $#{$self->{rc2idx}};
                        }
                        if ( $self->{rest} && $self->{pos}[COL] > $self->{rest} - 1 ) {
                            $self->{pos}[COL] = $#{$self->{rc2idx}[$self->{pos}[ROW]]};
                        }
                    }
                    else {
                        $self->{pos}[ROW] = $#{$self->{rc2idx}} - 1;
                    }
                }
                $self->__wr_screen();
            }
        }
        elsif ( $key == CONTROL_A || $key == VK_HOME ) {
            if ( $self->{pos}[COL] == 0 && $self->{pos}[ROW] == 0 ) {
                $self->{plugin}->__beep();
            }
            else {
                $self->{pos}[ROW] = 0;
                $self->{pos}[COL] = 0;
                $self->{p_begin} = 0;
                $self->{p_end}   = $self->{p_begin} + $self->{avail_height} - 1;
                $self->{p_end}   = $#{$self->{rc2idx}} if $self->{p_end} > $#{$self->{rc2idx}};
                $self->__wr_screen();
            }
        }
        elsif ( $key == CONTROL_E || $key == VK_END ) {
            if ( $self->{order} == 1 && $self->{rest} ) {
                if (    $self->{pos}[ROW] == $#{$self->{rc2idx}} - 1
                     && $self->{pos}[COL] == $#{$self->{rc2idx}[$self->{pos}[ROW]]}
                ) {
                    $self->{plugin}->__beep();
                }
                else {
                    $self->{p_begin} = @{$self->{rc2idx}} - ( @{$self->{rc2idx}} % $self->{avail_height} || $self->{avail_height} );
                    $self->{pos}[ROW] = $#{$self->{rc2idx}} - 1;
                    $self->{pos}[COL] = $#{$self->{rc2idx}[$self->{pos}[ROW]]};
                    if ( $self->{p_begin} == $#{$self->{rc2idx}} ) {
                        $self->{p_begin} = $self->{p_begin} - $self->{avail_height};
                        $self->{p_end}   = $self->{p_begin} + $self->{avail_height} - 1;
                    }
                    else {
                        $self->{p_end}   = $#{$self->{rc2idx}};
                    }
                    $self->__wr_screen();
                }
            }
            else {
                if (    $self->{pos}[ROW] == $#{$self->{rc2idx}}
                     && $self->{pos}[COL] == $#{$self->{rc2idx}[$self->{pos}[ROW]]}
                ) {
                    $self->{plugin}->__beep();
                }
                else {
                    $self->{p_begin} = @{$self->{rc2idx}} - ( @{$self->{rc2idx}} % $self->{avail_height} || $self->{avail_height} );
                    $self->{p_end}   = $#{$self->{rc2idx}};
                    $self->{pos}[ROW] = $#{$self->{rc2idx}};
                    $self->{pos}[COL] = $#{$self->{rc2idx}[$self->{pos}[ROW]]};
                    $self->__wr_screen();
                }
            }
        }
        elsif ( $key == KEY_q || $key == CONTROL_D ) {
            $self->__reset_term( 1 );
            return;
        }
        elsif ( $key == CONTROL_C ) {
            $self->__reset_term( 1 );
            print STDERR "^C\n";
            exit 1;
        }
        elsif ( $key == KEY_ENTER ) {
            my $index = $self->{index} || $self->{ll};
            if ( ! defined $self->{wantarray} ) {
                $self->__reset_term( 1 );
                return;
            }
            elsif ( $self->{wantarray} ) {
                if ( $self->{include_highlighted} == 1 ) {
                    $self->{marked}[$self->{pos}[ROW]][$self->{pos}[COL]] = 1;
                }
                elsif ( $self->{include_highlighted} == 2 ) {
                    my $chosen = $self->__marked_rc2idx();
                    if ( ! @$chosen ) {
                        $self->{marked}[$self->{pos}[ROW]][$self->{pos}[COL]] = 1;
                    }
                }
                elsif ( defined $self->{meta_items} ) {
                    for my $meta_item ( @{$self->{meta_items}} ) {
                        if ( $meta_item == $self->{rc2idx}[$self->{pos}[ROW]][$self->{pos}[COL]] ) {
                            $self->{marked}[$self->{pos}[ROW]][$self->{pos}[COL]] = 1;
                            last;
                        }
                    }
                }
                my $chosen = $self->__marked_rc2idx();
                $self->__reset_term( 1 );
                return $index ? @$chosen : @{$orig_list_ref}[@$chosen];
            }
            else {
                my $i = $self->{rc2idx}[$self->{pos}[ROW]][$self->{pos}[COL]];
                my $chosen = $index ? $i : $orig_list_ref->[$i];
                $self->__reset_term( 1 );
                return $chosen;
            }
        }
        elsif ( $key == KEY_SPACE ) {
            if ( $self->{wantarray} ) {
                my $locked = 0;
                if ( defined $self->{no_spacebar} || defined $self->{meta_items} ) {
                    for my $no_spacebar ( @{$self->{no_spacebar}||[]}, @{$self->{meta_items}||[]} ) {
                        if ( $self->{rc2idx}[$self->{pos}[ROW]][$self->{pos}[COL]] == $no_spacebar ) {
                            ++$locked;
                            last;
                        }
                    }
                }
                if ( $locked ) {
                    $self->{plugin}->__beep();
                }
                else {
                    $self->{marked}[$self->{pos}[ROW]][$self->{pos}[COL]] = ! $self->{marked}[$self->{pos}[ROW]][$self->{pos}[COL]];
                    $self->__wr_cell( $self->{pos}[ROW], $self->{pos}[COL] );
                }
            }
        }
        elsif ( $key == CONTROL_SPACE ) {
            if ( $self->{wantarray} ) {
                for my $i ( 0 .. $#{$self->{rc2idx}} ) {
                    for my $j ( 0 .. $#{$self->{rc2idx}[$i]} ) {
                        $self->{marked}[$i][$j] = ! $self->{marked}[$i][$j];
                    }
                }
                if ( defined $self->{no_spacebar} ) {
                    $self->__marked_idx2rc( $self->{no_spacebar}, 0 );
                }
                $self->__wr_screen();
            }
            else {
                $self->{plugin}->__beep();
            }
        }
        else {
            $self->{plugin}->__beep();
        }
    }
}


sub __marked_idx2rc {
    my ( $self, $list_of_indexes, $boolean ) = @_;
    my $last_list_idx = $#{$self->{list}};
    if ( $self->{current_layout} == 3 ) {
        for my $idx ( @$list_of_indexes ) {
            next if $idx > $last_list_idx;
            $self->{marked}[$idx][0] = $boolean;
        }
        return;
    }
    my ( $row, $col );
    my $cols_per_row = @{$self->{rc2idx}[0]};
    if ( $self->{order} == 0 ) {
        for my $idx ( @$list_of_indexes ) {
            next if $idx > $last_list_idx;
            $row = int( $idx / $cols_per_row );
            $col = $idx % $cols_per_row;
            $self->{marked}[$row][$col] = $boolean;
        }
    }
    elsif ( $self->{order} == 1 ) {
        my $rows_per_col = @{$self->{rc2idx}};
        my $end_last_full_col = $rows_per_col * ( $self->{rest} || $cols_per_row );
        for my $idx ( @$list_of_indexes ) {
            next if $idx > $last_list_idx;
            if ( $idx <= $end_last_full_col ) {
                $row = $idx % $rows_per_col;
                $col = int( $idx / $rows_per_col );
            }
            else {
                my $rows_per_col_short = $rows_per_col - 1;
                $row = ( $idx - $end_last_full_col ) % $rows_per_col_short;
                $col = int( ( $idx - $self->{rest} ) / $rows_per_col_short );
            }
            $self->{marked}[$row][$col] = $boolean;
        }
    }
}


sub __marked_rc2idx {
    my ( $self ) = @_;
    my $idx = [];
    if ( $self->{order} == 1 ) {
        for my $col ( 0 .. $#{$self->{rc2idx}[0]} ) {
            for my $row ( 0 .. $#{$self->{rc2idx}} ) {
                if ( $self->{marked}[$row][$col] ) {
                    push @$idx, $self->{rc2idx}[$row][$col];
                }
            }
        }
    }
    else {
        for my $row ( 0 .. $#{$self->{rc2idx}} ) {
            for my $col ( 0 .. $#{$self->{rc2idx}[$row]} ) {
                if ( $self->{marked}[$row][$col] ) {
                    push @$idx, $self->{rc2idx}[$row][$col];
                }
            }
        }
    }
    return $idx;
}


sub __copy_orig_list {      #hae
    my ( $self, $orig_list_ref ) = @_;
    $self->{list} = [ @$orig_list_ref ];
    if ( $self->{ll} ) {
        for ( @{$self->{list}} ) {
            $_ = $self->{undef} if ! defined $_;
        }
    }
    else {
        for ( @{$self->{list}} ) {
            if ( ! $_ ) {
                $_ = $self->{undef} if ! defined $_;
                $_ = $self->{empty} if $_ eq '';
            }
            if ( ref ) {
                $_ = sprintf "%s(0x%x)", ref $_, $_;
            }
            s/\p{Space}/ /g;  # replace, but don't squash sequences of spaces
            s/\p{C}//g;
        }
    }
}


sub __length_longest {
    my ( $self ) = @_;
    my $list = $self->{list};
    if ( $self->{ll} ) {
        $self->{length_longest} = $self->{ll};
        $self->{length} = [ ( $self->{length_longest} ) x @$list ];
    }
    else {
        my $len = [];
        my $longest = 0;
        for my $i ( 0 .. $#$list ) {
            $len->[$i] = $self->__print_columns( $list->[$i] );
            $longest = $len->[$i] if $len->[$i] > $longest;
        }
        $self->{length_longest} = $longest;
        $self->{length} = $len;
    }
}


sub __write_first_screen {
    my ( $self ) = @_;
    ( $self->{term_width}, $self->{term_height} ) = $self->{plugin}->__get_term_size();
    ( $self->{avail_width}, $self->{avail_height} ) = ( $self->{term_width}, $self->{term_height} );
    if ( $self->{length_longest} > $self->{avail_width} && $^O ne 'MSWin32' && $^O ne 'cygwin' ) {
        $self->{avail_width} += WIDTH_CURSOR;
        # + WIDTH_CURSOR: use also the last terminal column if there is only one print-column;
        #                 with only one print-column the output doesn't get messed up if an item
        #                 reaches the right edge of the terminal on a non-MSWin32-OS
    }
    if ( $self->{max_width} && $self->{avail_width} > $self->{max_width} ) {
        $self->{avail_width} = $self->{max_width};
    }
    if ( $self->{mouse} == 2 ) {
        $self->{avail_width}  = MAX_COL_MOUSE_1003 if $self->{avail_width}  > MAX_COL_MOUSE_1003;
        $self->{avail_height} = MAX_ROW_MOUSE_1003 if $self->{avail_height} > MAX_ROW_MOUSE_1003;
    }
    if ( $self->{avail_width} < 1 ) {
        $self->{avail_width} = 1;
    }
    $self->__prepare_promptline();
    $self->{pp_row} = $self->{page} ? 1 : 0;
    $self->{avail_height} -= $self->{nr_prompt_lines} + $self->{pp_row};
    if ( $self->{avail_height} < $self->{keep} ) {
        $self->{avail_height} = $self->{term_height} >= $self->{keep} ? $self->{keep} : $self->{term_height};
    }
    if ( $self->{max_height} && $self->{max_height} < $self->{avail_height} ) {
        $self->{avail_height} = $self->{max_height};
    }
    $self->__size_and_layout();
    if ( $self->{page} ) {
        $self->__prepare_page_number();
    }
    $self->{avail_height_idx} = $self->{avail_height} - 1;
    $self->{p_begin}    = 0;
    $self->{p_end}      = $self->{avail_height_idx} > $#{$self->{rc2idx}} ? $#{$self->{rc2idx}} : $self->{avail_height_idx};
    $self->{i_row}      = 0;
    $self->{i_col}      = 0;
    $self->{pos}        = [ 0, 0 ];
    $self->{marked}     = [];
    if ( $self->{wantarray} && defined $self->{mark} ) {
        $self->__marked_idx2rc( $self->{mark}, 1 );
    }
    if ( defined $self->{default} && $self->{default} <= $#{$self->{list}} ) {
        $self->__set_default_cell();
    }
    if ( $self->{clear_screen} ) {
        $self->{plugin}->__clear_screen();
    }
    if ( $self->{prompt_copy} ne '' ) {
        print $self->{prompt_copy};
    }
    $self->__wr_screen();
    if ( $self->{mouse} ) {
        $self->{plugin}->__get_cursor_position();
    }
    $self->{cursor_row} = $self->{i_row};
}


sub __prepare_promptline {
    my ( $self ) = @_;
    my $prompt = '';
    if ( length $self->{info} ) {
        $prompt .= $self->{info};
        $prompt .= "\n" if length $self->{prompt};
    }
    $prompt .= $self->{prompt};
    if ( $prompt eq '' ) {
        $self->{prompt_copy} = '';
        $self->{nr_prompt_lines} = 0;
        return;
    }
    my $init   = $self->{lf}[0] ? $self->{lf}[0] : 0;
    my $subseq = $self->{lf}[1] ? $self->{lf}[1] : 0;
    $self->{prompt_copy} = line_fold( $prompt, $self->{avail_width}, ' ' x $init, ' ' x $subseq );
    $self->{prompt_copy} .= "\n\r";
    $self->{nr_prompt_lines} = $self->{prompt_copy} =~ s/\n/\n\r/g;
}


sub __size_and_layout {
    my ( $self ) = @_;
    my $layout = $self->{layout};
    $self->{rc2idx} = [];
    if ( $self->{length_longest} > $self->{avail_width} ) {
        $self->{avail_col_width} = $self->{avail_width};
        $layout = 3;
    }
    else {
        $self->{avail_col_width} = $self->{length_longest};
    }
    $self->{current_layout} = $layout;
    my $all_in_first_row = '';
    if ( $layout == 0 || $layout == 1 ) {
        for my $idx ( 0 .. $#{$self->{list}} ) {
            $all_in_first_row .= $self->{list}[$idx];
            $all_in_first_row .= ' ' x $self->{pad} if $idx < $#{$self->{list}};
            if ( $self->__print_columns( $all_in_first_row ) > $self->{avail_width} ) {
                $all_in_first_row = '';
                last;
            }
        }
    }
    if ( $all_in_first_row ) {
        $self->{rc2idx}[0] = [ 0 .. $#{$self->{list}} ];
    }
    elsif ( $layout == 3 ) {
        for my $idx ( 0 .. $#{$self->{list}} ) {
            $self->{rc2idx}[$idx][0] = $idx;
        }
    }
    else {
        my $tmp_avail_width = $self->{avail_width} + $self->{pad};
        # auto_format
        if ( $layout == 1 || $layout == 2 ) {
            my $tmc = int( @{$self->{list}} / $self->{avail_height} );
            $tmc++ if @{$self->{list}} % $self->{avail_height};
            $tmc *= $self->{col_width};
            if ( $tmc < $tmp_avail_width ) {
                $tmc = int( $tmc + ( ( $tmp_avail_width - $tmc ) / 1.5 ) ) if $layout == 1;
                $tmc = int( $tmc + ( ( $tmp_avail_width - $tmc ) / 4 ) )   if $layout == 2;
                $tmp_avail_width = $tmc;
            }
        }
        # order
        my $cols_per_row = int( $tmp_avail_width / $self->{col_width} );
        $cols_per_row = 1 if $cols_per_row < 1;
        $self->{rest} = @{$self->{list}} % $cols_per_row;
        if ( $self->{order} == 1 ) {
            my $rows = int( ( @{$self->{list}} - 1 + $cols_per_row ) / $cols_per_row );
            my @rearranged_idx;
            my $begin = 0;
            my $end = $rows - 1;
            for my $c ( 0 .. $cols_per_row - 1 ) {
                --$end if $self->{rest} && $c >= $self->{rest};
                $rearranged_idx[$c] = [ $begin .. $end ];
                $begin = $end + 1;
                $end = $begin + $rows - 1;
            }
            for my $r ( 0 .. $rows - 1 ) {
                my @temp_idx;
                for my $c ( 0 .. $cols_per_row - 1 ) {
                    next if $r == $rows - 1 && $self->{rest} && $c >= $self->{rest};
                    push @temp_idx, $rearranged_idx[$c][$r];
                }
                push @{$self->{rc2idx}}, \@temp_idx;
            }
        }
        else {
            my $begin = 0;
            my $end = $cols_per_row - 1;
            $end = $#{$self->{list}} if $end > $#{$self->{list}};
            push @{$self->{rc2idx}}, [ $begin .. $end ];
            while ( $end < $#{$self->{list}} ) {
                $begin += $cols_per_row;
                $end   += $cols_per_row;
                $end    = $#{$self->{list}} if $end > $#{$self->{list}};
                push @{$self->{rc2idx}}, [ $begin .. $end ];
            }
        }
    }
}


sub __set_default_cell {
    my ( $self ) = @_;
    LOOP: for my $i ( 0 .. $#{$self->{rc2idx}} ) {
        for my $j ( 0 .. $#{$self->{rc2idx}[$i]} ) {
            if ( $self->{default} == $self->{rc2idx}[$i][$j] ) {
                $self->{pos} = [ $i, $j ];
                last LOOP;
            }
        }
    }
    $self->{p_begin} = $self->{avail_height} * int( $self->{pos}[ROW] / $self->{avail_height} );
    $self->{p_end} = $self->{p_begin} + $self->{avail_height} - 1;
    $self->{p_end} = $#{$self->{rc2idx}} if $self->{p_end} > $#{$self->{rc2idx}};
}


sub __goto {
    my ( $self, $newrow, $newcol ) = @_;
    if ( $newrow > $self->{i_row} ) {
        print CR, LF x ( $newrow - $self->{i_row} );
        $self->{i_row} += ( $newrow - $self->{i_row} );
        $self->{i_col} = 0;
    }
    elsif ( $newrow < $self->{i_row} ) {
        $self->{plugin}->__up( $self->{i_row} - $newrow );
        $self->{i_row} -= ( $self->{i_row} - $newrow );
    }
    if ( $newcol > $self->{i_col} ) {
        $self->{plugin}->__right( $newcol - $self->{i_col} );
        $self->{i_col} += ( $newcol - $self->{i_col} );
    }
    elsif ( $newcol < $self->{i_col} ) {
        $self->{plugin}->__left( $self->{i_col} - $newcol );
        $self->{i_col} -= ( $self->{i_col} - $newcol );
    }
}


sub __prepare_page_number {
    my ( $self ) = @_;
    if ( $#{$self->{rc2idx}} / ( $self->{avail_height} + $self->{pp_row} ) > 1 ) {
        my $total_pp = int( $#{$self->{rc2idx}} / $self->{avail_height} ) + 1;
        my $total_pp_w = length $total_pp;
        $self->{footer_fmt} = '--- Page %0' . $total_pp_w . 'd/' . $total_pp . ' ---';
        if ( length( sprintf $self->{footer_fmt}, $total_pp ) > $self->{avail_width} ) {
            $self->{footer_fmt} = '%0' . $total_pp_w . 'd/' . $total_pp;
            if ( length( sprintf $self->{footer_fmt}, $total_pp ) > $self->{avail_width} ) {
                $total_pp_w = $self->{avail_width} if $total_pp_w > $self->{avail_width};
                $self->{footer_fmt} = '%0' . $total_pp_w . '.' . $total_pp_w . 's';
            }
        }
    }
    else {
        $self->{avail_height} += $self->{pp_row};
        $self->{pp_row} = 0;
    }
}


sub __wr_screen {
    my ( $self ) = @_;
    $self->__goto( 0, 0 );
    $self->{plugin}->__clear_to_end_of_screen();
    if ( $self->{pp_row} ) {
        $self->__goto( $self->{avail_height_idx} + $self->{pp_row}, 0 );
        my $pp_line = sprintf $self->{footer_fmt}, int( $self->{p_begin} / $self->{avail_height} ) + 1;
        print $pp_line;
        $self->{i_col} += length $pp_line;
     }
    for my $row ( $self->{p_begin} .. $self->{p_end} ) {
        for my $col ( 0 .. $#{$self->{rc2idx}[$row]} ) {
            $self->__wr_cell( $row, $col );
        }
    }
    $self->__wr_cell( $self->{pos}[ROW], $self->{pos}[COL] );
}


sub __wr_cell {     # hae
    my( $self, $row, $col ) = @_;
    my $is_current_pos = $row == $self->{pos}[ROW] && $col == $self->{pos}[COL];
    my $idx = $self->{rc2idx}[$row][$col];
    if ( $#{$self->{rc2idx}} == 0 && $#{$self->{rc2idx}[0]} > 0 ) {
        my $lngth = 0;
        if ( $col > 0 ) {
            for my $cl ( 0 .. $col - 1 ) {
                my $i = $self->{rc2idx}[$row][$cl];
                $lngth += $self->__print_columns( $self->{list}[$i] );
                $lngth += $self->{pad};
            }
        }
        $self->__goto( $row - $self->{p_begin}, $lngth );
        $self->{plugin}->__bold_underline() if $self->{marked}[$row][$col];
        $self->{plugin}->__reverse()        if $is_current_pos;
        print $self->{list}[$idx];
        $self->{i_col} += $self->__print_columns( $self->{list}[$idx] );
    }
    else {
        $self->__goto( $row - $self->{p_begin}, $col * $self->{col_width} );
        $self->{plugin}->__bold_underline() if $self->{marked}[$row][$col];
        $self->{plugin}->__reverse()        if $is_current_pos;
        print $self->__unicode_sprintf( $idx );
        $self->{i_col} += $self->{avail_col_width};
    }
    $self->{plugin}->__reset() if $self->{marked}[$row][$col] || $is_current_pos;
}


# Term::Choose_HAE overwrites __valid_options, __defaults, choose,
# __copy_orig_list, __wr_cell, __print_columns, __unicode_trim


sub __print_columns {       #hae
    #my $self = $_[0];
    print_columns( $_[1] );
}

sub __unicode_trim {        #hae
    #my $self = $_[0];
    cut_to_printwidth( $_[1], $_[2] ); # , 0
}

sub __unicode_sprintf {
    my ( $self, $idx ) = @_;
    my $unicode;
    my $str_length = $self->{length}[$idx];
    if ( $str_length > $self->{avail_col_width} ) {
        if ( $self->{avail_col_width} > 3 ) {
            $unicode = $self->__unicode_trim( $self->{list}[$idx], $self->{avail_col_width} - 3 ) . '...';
        }
        else {
            $unicode = $self->__unicode_trim( $self->{list}[$idx], $self->{avail_col_width} );
        }
    }
    elsif ( $str_length < $self->{avail_col_width} ) {
        if ( $self->{justify} == 0 ) {
            $unicode = $self->{list}[$idx] . " " x ( $self->{avail_col_width} - $str_length );
        }
        elsif ( $self->{justify} == 1 ) {
            $unicode = " " x ( $self->{avail_col_width} - $str_length ) . $self->{list}[$idx];
        }
        elsif ( $self->{justify} == 2 ) {
            my $all = $self->{avail_col_width} - $str_length;
            my $half = int( $all / 2 );
            $unicode = " " x $half . $self->{list}[$idx] . " " x ( $all - $half );
        }
    }
    else {
        $unicode = $self->{list}[$idx];
    }
    return $unicode;
}


sub __mouse_info_to_key {
    my ( $self, $abs_cursor_y, $button, $abs_mouse_x, $abs_mouse_y ) = @_;
    if ( $button == 4 ) {
        return VK_PAGE_UP;
    }
    elsif ( $button == 5 ) {
        return VK_PAGE_DOWN;
    }
    my $abs_y_top_row = $abs_cursor_y - $self->{cursor_row};
    if ( $abs_mouse_y < $abs_y_top_row ) {
        return NEXT_get_key;
    }
    my $mouse_row = $abs_mouse_y - $abs_y_top_row;
    my $mouse_col = $abs_mouse_x;
    if ( $mouse_row > $#{$self->{rc2idx}} ) {
        return NEXT_get_key;
    }
    my $matched_col;
    my $end_last_col = 0;
    my $row = $mouse_row + $self->{p_begin};

    COL: for my $col ( 0 .. $#{$self->{rc2idx}[$row]} ) {
        my $end_this_col;
        if ( $#{$self->{rc2idx}} == 0 ) {
            my $idx = $self->{rc2idx}[$row][$col];
            $end_this_col = $end_last_col + $self->__print_columns( $self->{list}[$idx] ) + $self->{pad};
        }
        else { #
            $end_this_col = $end_last_col + $self->{col_width};
        }
        if ( $col == 0 ) {
            $end_this_col -= int( $self->{pad} / 2 );
        }
        if ( $col == $#{$self->{rc2idx}[$row]} && $end_this_col > $self->{avail_width} ) {
            $end_this_col = $self->{avail_width};
        }
        if ( $end_last_col < $mouse_col && $end_this_col >= $mouse_col ) {
            $matched_col = $col;
            last COL;
        }
        $end_last_col = $end_this_col;
    }
    if ( ! defined $matched_col ) {
        return NEXT_get_key;
    }
    my $return_char = '';
    if ( $button == 1 ) {
        $return_char = KEY_ENTER;
    }
    elsif ( $button == 3 ) {
        $return_char = KEY_SPACE;
    }
    else {
        return NEXT_get_key;
    }
    if ( $row != $self->{pos}[ROW] || $matched_col != $self->{pos}[COL] ) {
        my $not_pos = $self->{pos};
        $self->{pos} = [ $row, $matched_col ];
        $self->__wr_cell( $not_pos->[0], $not_pos->[1] );
        $self->__wr_cell( $self->{pos}[ROW], $self->{pos}[COL] );
    }
    return $return_char;
}



1;


__END__

=pod

=encoding UTF-8

=head1 NAME

Term::Choose - Choose items from a list interactively.

=head1 VERSION

Version 1.608

=cut

=head1 SYNOPSIS

Functional interface:

    use Term::Choose qw( choose );

    my $array_ref = [ qw( one two three four five ) ];

    my $choice = choose( $array_ref );                            # single choice
    print "$choice\n";

    my @choices = choose( [ 1 .. 100 ], { justify => 1 } );       # multiple choice
    print "@choices\n";

    choose( [ 'Press ENTER to continue' ], { prompt => '' } );    # no choice

Object-oriented interface:

    use Term::Choose;

    my $array_ref = [ qw( one two three four five ) ];

    my $new = Term::Choose->new();

    my $choice = $new->choose( $array_ref );                       # single choice
    print "$choice\n";

    my @choices = $new->choose( [ 1 .. 100 ] );                    # multiple choice
    print "@choices\n";

    my $stopp = Term::Choose->new( { prompt => '' } );
    $stopp->choose( [ 'Press ENTER to continue' ] );               # no choice

=head1 DESCRIPTION

Choose interactively from a list of items.

C<Term::Choose> provides a functional interface (L</SUBROUTINES>) and an object-oriented interface (L</METHODS>).

=head1 EXPORT

Nothing by default.

    use Term::Choose qw( choose );

=head1 METHODS

=head2 new

    $new = Term::Choose->new( [ \%options] );

This constructor returns a new C<Term::Choose> object.

To set the different options it can be passed a reference to a hash as an optional argument.

For detailed information about the options see L</OPTIONS>.

=head2 choose

The method C<choose> allows the user to choose from a list.

The first argument is an array reference which holds the list of the available choices.

As a second and optional argument it can be passed a reference to a hash where the keys are the option names and the
values the option values.

Options set with C<choose> overwrite options set with C<new>. Before leaving C<choose> restores the
overwritten options.

    $choice = $new->choose( $array_ref [, \%options] );

    @choices= $new->choose( $array_ref [, \%options] );

              $new->choose( $array_ref [, \%options] );

When in the documentation is mentioned "array" or "list" or "elements" or "items" (of the array/list) than these
refer to this array passed as a reference as the first argument.

For more information how to use C<choose> and its return values see L<USAGE AND RETURN VALUES>.

=head1 SUBROUTINES

=head2 choose

The function C<choose> allows the user to choose from a list. It takes the same arguments as the method L</choose>.

    $choice = choose( $array_ref [, \%options] );

    @choices= choose( $array_ref [, \%options] );

              choose( $array_ref [, \%options] );

See the L</OPTIONS> section for more details about the different options and how to set them.

See also the following section L<USAGE AND RETURN VALUES>.

=head1 USAGE AND RETURN VALUES

=over

=item *

If C<choose> is called in a I<scalar context>, the user can choose an item by using the L</Keys to move around> and
confirming with C<Return>.

C<choose> then returns the chosen item.

=item *

If C<choose> is called in an I<list context>, the user can also mark an item with the C<SpaceBar>.

C<choose> then returns - when C<Return> is pressed - the list of marked items (including the highlighted item if the
option I<include_highlighted> is set to C<1>).

In I<list context> C<Ctrl-SpaceBar> (or C<Ctrl-@>) inverts the choices: marked items are unmarked and unmarked items are
marked.

=item *

If C<choose> is called in an I<void context>, the user can move around but mark nothing; the output shown by C<choose>
can be closed with C<Return>.

Called in void context C<choose> returns nothing.

If the first argument refers to an empty array, C<choose> returns nothing.

=back

If the items of the list don't fit on the screen, the user can scroll to the next (previous) page(s).

If the window size is changed, then as soon as the user enters a keystroke C<choose> rewrites the screen.

C<choose> returns C<undef> or an empty list in list context if the C<q> key (or C<Ctrl-D>) is pressed.

With a I<mouse> mode enabled (and if supported by the terminal) the item can be chosen with the left mouse key, in list
context the right mouse key can be used instead the C<SpaceBar> key.

=head2 Keys to move around

=over

=item *

the C<Arrow> keys (or the C<h,j,k,l> keys) to move up and down or to move to the right and to the left,

=item *

the C<Tab> key (or C<Ctrl-I>) to move forward, the C<BackSpace> key (or C<Ctrl-H> or C<Shift-Tab>) to move backward,

=item *

the C<PageUp> key (or C<Ctrl-B>) to go back one page, the C<PageDown> key (or C<Ctrl-F>) to go forward one page,

=item *

the C<Home> key (or C<Ctrl-A>) to jump to the beginning of the list, the C<End> key (or C<Ctrl-E>) to jump to the end of
the list.

=back

=head2 Modifications for the output

For the output on the screen the array elements are modified.

All the modifications are made on a copy of the original array so C<choose> returns the chosen elements as they were
passed to the function without modifications.

Modifications:

=over

=item *

If an element is not defined the value from the option I<undef> is assigned to the element.

=item *

If an element holds an empty string the value from the option I<empty> is assigned to the element.

=item *

White-spaces in elements are replaced with simple spaces.

    $element =~ s/\p{Space}/ /g;

=item *

If the length of an element is greater than the width of the screen the element is cut and at the end of the string are
added three dots.

=back

The following should be without meaning if you comply with the requirements.

=over

=item *

Characters which match the Unicode character property C<Other> are removed.

    $element =~ s/\p{C}//g;

C<ESC> characters are removed by this substitution so it is not possible to color the output with ANSI escape sequences.
For colored output see L<Term::Choose_HAE>.

=item *

If an element is a reference it will be replaced with a string: the reference type followed with the hexadecimal value
of the reference enclosed in parentheses.

    if ( ref $element ) {
        $element = sprintf "%s(0x%x)", ref $element, $element;
    }

=item *

The category of C<utf8> C<warnings> is disabled.

    no warnings 'utf8';

=back

=head1 OPTIONS

Options which expect a number as their value expect integers.

=head3 beep

0 - off (default)

1 - on

=head3 clear_screen

0 - off (default)

1 - clears the screen before printing the choices

=head3 default

With the option I<default> it can be selected an element, which will be highlighted as the default instead of the first
element.

I<default> expects a zero indexed value, so e.g. to highlight the third element the value would be I<2>.

If the passed value is greater than the index of the last array element the first element is highlighted.

Allowed values: 0 or greater

(default: undefined)

=head3 empty

Sets the string displayed on the screen instead an empty string.

(default: "<empty>")

=head3 hide_cursor

0 - keep the terminals highlighting of the cursor position

1 - hide the terminals highlighting of the cursor position (default)

=head3 info

Expects as its value a string. The string is printed above the prompt string.

(default: not set)

=head3 index

0 - off (default)

1 - return the index of the chosen element instead of the chosen element respective the indices of the chosen elements
instead of the chosen elements.

=head3 justify

0 - elements ordered in columns are left justified (default)

1 - elements ordered in columns are right justified

2 - elements ordered in columns are centered

=head3 keep

I<keep> prevents that all the terminal rows are used by the prompt lines.

Setting I<keep> ensures that at least I<keep> terminal rows are available for printing list rows.

If the terminal height is less than I<keep> I<keep> is set to the terminal height.

Allowed values: 1 or greater

(default: 5)

=head3 layout

From broad to narrow: 0 > 1 > 2 > 3

=over

=item *

0 - layout off

 .----------------------.   .----------------------.   .----------------------.   .----------------------.
 | .. .. .. .. .. .. .. |   | .. .. .. .. .. .. .. |   | .. .. .. .. .. .. .. |   | .. .. .. .. .. .. .. |
 |                      |   | .. .. .. .. .. .. .. |   | .. .. .. .. .. .. .. |   | .. .. .. .. .. .. .. |
 |                      |   |                      |   | .. .. .. .. ..       |   | .. .. .. .. .. .. .. |
 |                      |   |                      |   |                      |   | .. .. .. .. .. .. .. |
 |                      |   |                      |   |                      |   | .. .. .. .. .. .. .. |
 |                      |   |                      |   |                      |   | .. .. .. .. .. .. .. |
 '----------------------'   '----------------------'   '----------------------'   '----------------------'

=item *

1 - layout "H" (default)

 .----------------------.   .----------------------.   .----------------------.   .----------------------.
 | .. .. .. .. .. .. .. |   | .. .. .. .. ..       |   | .. .. .. .. .. ..    |   | .. .. .. .. .. .. .. |
 |                      |   | .. .. .. .. ..       |   | .. .. .. .. .. ..    |   | .. .. .. .. .. .. .. |
 |                      |   | .. ..                |   | .. .. .. .. .. ..    |   | .. .. .. .. .. .. .. |
 |                      |   |                      |   | .. .. .. .. .. ..    |   | .. .. .. .. .. .. .. |
 |                      |   |                      |   | .. .. ..             |   | .. .. .. .. .. .. .. |
 |                      |   |                      |   |                      |   | .. .. .. .. .. .. .. |
 '----------------------'   '----------------------'   '----------------------'   '----------------------'

=item *

2 - layout "V"

 .----------------------.   .----------------------.   .----------------------.   .----------------------.
 | .. ..                |   | .. .. ..             |   | .. .. .. ..          |   | .. .. .. .. .. .. .. |
 | .. ..                |   | .. .. ..             |   | .. .. .. ..          |   | .. .. .. .. .. .. .. |
 | ..                   |   | .. .. ..             |   | .. .. .. ..          |   | .. .. .. .. .. .. .. |
 |                      |   | .. ..                |   | .. .. ..             |   | .. .. .. .. .. .. .. |
 |                      |   |                      |   | .. .. ..             |   | .. .. .. .. .. .. .. |
 |                      |   |                      |   |                      |   | .. .. .. .. .. .. .. |
 '----------------------'   '----------------------'   '----------------------'   '----------------------'

=item *

3 - all in a single column

 .----------------------.   .----------------------.   .----------------------.   .----------------------.
 | ..                   |   | ..                   |   | ..                   |   | ..                   |
 | ..                   |   | ..                   |   | ..                   |   | ..                   |
 | ..                   |   | ..                   |   | ..                   |   | ..                   |
 |                      |   | ..                   |   | ..                   |   | ..                   |
 |                      |   |                      |   | ..                   |   | ..                   |
 |                      |   |                      |   |                      |   | ..                   |
 '----------------------'   '----------------------'   '----------------------'   '----------------------'

=back

=head3 lf

If I<prompt> lines are folded the option I<lf> allows one to insert spaces at beginning of the folded lines.

The option I<lf> expects a reference to an array with one or two elements:

- the first element (C<INITIAL_TAB>) sets the number of spaces inserted at beginning of paragraphs

- a second element (C<SUBSEQUENT_TAB>) sets the number of spaces inserted at the beginning of all broken lines apart
from the beginning of paragraphs

Allowed values for the two elements are: 0 or greater.

See C<INITIAL_TAB> and C<SUBSEQUENT_TAB> in L<Text::LineFold>.

(default: undefined)

=head3 ll

If all elements have the same length, the length can be passed with this option.

If I<ll> is set, then C<choose> doesn't calculate the length of the longest element itself but uses the value passed
with this option.

I<length> refers here to the number of print columns the element will use on the terminal.

The length of undefined elements depends on the value of the option I<undef>.

If the option I<ll> is set, only undefined values are replaced. The replacements described in L</Modifications for the
output> are not applied. If elements contain unsupported characters the output might break if the width (number of print
columns) of the replacement character does not correspond to the width of the replaced character - for example when a
unsupported non-spacing character is replaced by a replacement character with a normal width.

If I<ll> is set to a value less than the length of the elements, the output could break.

If the value of I<ll> is greater than the screen width, the elements will be trimmed to fit into the screen.

If I<ll> is set, C<choose> returns (in list or scalar context) always the indexes of the chosen items regardless of how
I<index> is set.

If I<ll> is set and the window size has changed, choose returns immediately C<-1>.

Allowed values: 1 or greater

(default: undefined)

=head3 max_height

If defined sets the maximal number of rows used for printing list items.

If the available height is less than I<max_height> I<max_height> is set to the available height.

Height in this context means print rows.

I<max_height> overwrites I<keep> if I<max_height> is set to a value less than I<keep>.

Allowed values: 1 or greater

(default: undefined)

=head3 max_width

If defined, sets the maximal output width to I<max_width> if the terminal width is greater than I<max_width>.

To prevent the "auto-format" to use a width less than I<max_width> set I<layout> to 0.

Width refers here to the number of print columns.

Allowed values: 1 or greater

(default: undefined)

=head3 mouse

For MSWin32 see also the end of this section.

0 - no mouse mode (default)

1 - mouse mode 1003 enabled

2 - mouse mode 1003 enabled; the output width is limited to 223 print-columns and the height to 223 rows (mouse mode
1003 doesn't work above 223)

3 - extended mouse mode (1005) - uses utf8

4 - extended SGR mouse mode (1006)

If a mouse mode is enabled layers for C<STDIN> are changed. Then before leaving C<choose> as a cleanup C<STDIN> is
marked as C<UTF-8> with C<:encoding(UTF-8)>. This doesn't apply if the OS is MSWin32.

If the OS is MSWin32 there is no difference between the mouse modes 1, 3, and 4 - the all enable the mouse with the help
of L<Win32::Console>.

=head3 order

If the output has more than one row and more than one column:

0 - elements are ordered horizontally

1 - elements are ordered vertically (default)

Default may change in a future release.

=head3 pad

Sets the number of whitespaces between columns. (default: 2)

Allowed values: 0 or greater

=head3 page

0 - off

1 - print the page number on the bottom of the screen if there is more then one page. (default)

=head3 prompt

If I<prompt> is undefined a default prompt-string will be shown.

If the I<prompt> value is an empty string ("") no prompt-line will be shown.

default in list and scalar context: C<Your choice:>

default in void context: C<Close with ENTER>

=head3 undef

Sets the string displayed on the screen instead an undefined element.

default: "<undef>"

=head2 Options List Context

=head3 include_highlighted

In list context when C<Return> is pressed

0 - C<choose> returns the items marked with the C<SpaceBar>. (default)

1 - C<choose> returns the items marked with the C<SpaceBar> plus the highlighted item.

2 - C<choose> returns the items marked with the C<SpaceBar>. If no items are marked with the C<SpaceBar>, the
highlighted item is returned.

=head3 mark

I<mark> expects as its value a reference to an array. The elements of the array are list indexes. C<choose> preselects
the list-elements correlating to these indexes.

Elements greater than the last index of the list are ignored.

This option has only meaning in list context.

(default: undefined)

=head3 meta_items

I<meta_items> expects as its value a reference to an array. The elements of the array are list indexes. These elements
can not be marked with the C<SpaceBar> or with the right mouse key but if one of these elements is the highlighted item
it is added to the chosen items when C<Return> is pressed.

Elements greater than the last index of the list are ignored.

This option has only meaning in list context.

(default: undefined)

=head3 no_spacebar

I<no_spacebar> expects as its value a reference to an array. The elements of the array are indexes of the list which
should not be markable with the C<SpaceBar> or with the right mouse key.

If an element is preselected with the option I<mark> and also marked as not selectable with the option I<no_spacebar>,
the user can not remove the preselection of this element.

I<no_spacebar> elements greater than the last index of the list are ignored.

This option has only meaning in list context.

(default: undefined)

=head1 ERROR HANDLING

=head2 croak

C<new|choose> dies if passed invalid arguments.

=head2 carp

If pressing a key results in an undefined value C<choose> warns with C<EOT: $!> and returns I<undef> or an empty list in
list context.

=head1 REQUIREMENTS

=head2 Perl version

Requires Perl version 5.8.3 or greater.

=head2 Optional modules

=head3 Term::ReadKey

If L<Term::ReadKey> is available it is used C<ReadKey> to read the user input and C<GetTerminalSize> to get the
terminal size. Without C<Term::ReadKey> C<getc> is used to read the input and C<stty size> to get the terminal size.

If the OS is MSWin32 it is always used L<Win32::Console> to read the user input and to get the terminal size.

=head2 Decoded strings

C<choose> expects decoded strings as array elements.

=head2 Encoding layer for STDOUT

For a correct output it is required an appropriate encoding layer for STDOUT matching the terminal's character set.

=head2 Monospaced font

It is required a terminal that uses a monospaced font which supports the printed characters.

=head2 Escape sequences

It is required a terminal that supports ANSI escape sequences.

If the option "hide_cursor" is enabled, it is also required the support for the following escape sequences:

    "\e[?25l"   Hide Cursor

    "\e[?25h"   Show Cursor

If a I<mouse> mode is enabled

    "\e[?1003h", "\e[?1005h", "\e[?1006h"   Enable Mouse Tracking

    "\e[?1003l", "\e[?1005l", "\e[?1006l"   Disable Mouse Tracking

are used to enable/disable the different I<mouse> modes.

If the OS is MSWin32 L<Win32::Console> is used, to emulate the behavior of the escape sequences.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Term::Choose

=head1 AUTHOR

Matthäus Kiem <cuer2s@gmail.com>

=head1 CREDITS

Based on the C<choose> function from the L<Term::Clui> module.

Thanks to the L<Perl-Community.de|http://www.perl-community.de> and the people form
L<stackoverflow|http://stackoverflow.com> for the help.

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2012-2018 Matthäus Kiem.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl 5.10.0. For
details, see the full text of the licenses in the file LICENSE.

=cut
