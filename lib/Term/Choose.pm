package Term::Choose;

use warnings;
use strict;
use 5.010001;

our $VERSION = '1.110';
use Exporter 'import';
our @EXPORT_OK = qw( choose );

use Carp qw( croak carp );
use Text::LineFold;
use Unicode::GCString;

use Term::Choose::Constants qw( :choose );

no warnings 'utf8';
#use warnings FATAL => qw( all );
#use Log::Log4perl qw( get_logger );
#my $log = get_logger( 'Term::Choose' );

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
        $self->__validate_options( $opt );
    }
    $self->{plugin} = $Plugin_Package->new();
    return $self;
}


sub DESTROY {
    my ( $self ) = @_;
    $self->__reset_term();
}


sub __set_defaults {
    my ( $self ) = @_;
    my $prompt = defined $self->{wantarray} ? 'Your choice:' : 'Close with ENTER';
    $self->{prompt}           //= $prompt;
    $self->{beep}             //= 0;
    $self->{clear_screen}     //= 0;
    #$self->{default}         //= undef;
    $self->{empty}            //= '<empty>';
    $self->{hide_cursor}      //= 1;
    $self->{index}            //= 0;
    $self->{justify}          //= 0;
    $self->{keep}             //= 5;
    $self->{layout}           //= 1;
    #$self->{lf}              //= undef;
    #$self->{ll}              //= undef;
    #$self->{limit}           //= undef;
    #$self->{max_height}      //= undef;
    #$self->{max_width}       //= undef;
    $self->{mouse}            //= 0;
    #$self->{no_spacebar}     //= undef;
    $self->{order}            //= 1;
    $self->{pad}              //= 2;
    $self->{pad_one_row}      //= $self->{pad};
    $self->{page}             //= 1;
    $self->{undef}            //= '<undef>';
}


sub __validate_options {
    my ( $self, $opt ) = @_;
    return if ! defined $opt;
    my $valid = {
        beep            => '[ 0 1 ]',
        clear_screen    => '[ 0 1 ]',
        default         => '[ 0-9 ]+',
        empty           => '',
        hide_cursor     => '[ 0 1 ]',
        index           => '[ 0 1 ]',
        justify         => '[ 0 1 2 ]',
        keep            => '[ 1-9 ][ 0-9 ]*',
        layout          => '[ 0 1 2 3 ]',
        lf              => 'ARRAY',
        ll              => '[ 1-9 ][ 0-9 ]*',
        limit           => '[ 1-9 ][ 0-9 ]*',
        max_height      => '[ 1-9 ][ 0-9 ]*',
        max_width       => '[ 1-9 ][ 0-9 ]*',
        mouse           => '[ 0 1 2 3 4 ]',
        no_spacebar     => 'ARRAY',
        order           => '[ 0 1 ]',
        pad             => '[ 0-9 ]+',
        pad_one_row     => '[ 0-9 ]+',
        page            => '[ 0 1 ]',
        prompt          => '',
        undef           => '',
    };
    my @warn = ();
    for my $key ( keys %$opt ) {
        if ( ! exists $valid->{$key} ) {
            push @warn, "'$key' is not a valid option name";
            next;
        }
        next if ! defined $opt->{$key};
        if ( $valid->{$key} eq '' && ! ref $opt->{$key} ) {
            $self->{$key} = $opt->{$key};
        }
        elsif ( $key eq 'lf' ) {
            my $err;
            if ( ref $opt->{$key} eq 'ARRAY' && @{$opt->{$key}} <= 2 ) {
                no warnings 'uninitialized';
                /^[0-9]+\z/ || ++$err && last for @{$opt->{$key}};
            }
            else {
                ++$err;
            }
            if ( $err ) {
                push @warn, "option '$key' : the passed value is not a valid value. Falling back to the default value";
            }
            else {
                $self->{$key} = $opt->{$key};
            }
        }
        elsif ( $key eq 'no_spacebar' ) {
            my $err;
            if ( ref $opt->{$key} eq 'ARRAY' ) {
                no warnings 'uninitialized';
                /^[0-9]+\z/ || ++$err && last for @{$opt->{$key}};
            }
            else {
                ++$err;
            }
            if ( $err ) {
                push @warn, "option '$key' : the passed value is not a valid value. Falling back to the default value";
            }
            else {
                $self->{$key} = $opt->{$key};
            }
        }
        elsif ( $opt->{$key} =~ m/^$valid->{$key}\z/x ) {
            $self->{$key} = $opt->{$key};
        }
        else {
            push @warn, "option '$key' : '$opt->{$key}' is not a valid value. Falling back to the default value";
        }
    }
    if ( @warn ) {
        for my $w ( @warn ) {
            carp "choose: " . $w;
        }
        print "Press a key to continue";
        my $dummy = <STDIN>;
    }
}


sub __init_term {
    my ( $self ) = @_;
    $self->{old_handle} = select $self->{handle_out};
    $self->{backup_flush} = $|;
    $| = 1;
    $self->{mouse} = $self->{plugin}->__set_mode( $self->{mouse} );
    print HIDE_CURSOR if $self->{hide_cursor};
}


sub __reset_term {
    my ( $self, $from_choose ) = @_;
    if ( $from_choose ) {
        print CR, UP x ( $self->{i_row} + $self->{nr_prompt_lines} );
        print CLEAR_TO_END_OF_SCREEN;
    }
    print RESET;
    if ( defined $self->{plugin} ) {
        $self->{plugin}->__reset_mode( $self->{mouse} );
    }
    if ( $self->{hide_cursor} ) {
        print SHOW_CURSOR;
    }
    if ( defined $self->{backup_flush} ) {
        $| = $self->{backup_flush};
        delete $self->{backup_flush};
    }
    if ( defined $self->{old_handle} ) {
        select $self->{old_handle};
        delete $self->{old_handle};
    }
    if ( defined $self->{backup_opt} ) {
        my $backup_opt = delete $self->{backup_opt};
        for my $key ( keys %$backup_opt ) {
            $self->{$key} = $backup_opt->{$key};
        }
    }
}


sub __get_key {
    my ( $self ) = @_;
    my $key = $self->{plugin}->__get_key_OS( $self->{mouse} );
    return $key if ref $key ne 'ARRAY';
    return $self->__mouse_info_to_key( @$key );
}


sub config {
    my $self = shift;
    my ( $opt ) = @_;
    croak "config: called with " . @_ . " arguments - 0 or 1 arguments expected" if @_ > 1;
    if ( defined $opt ) {
        croak "config: the argument must be a HASH reference" if ref $opt ne 'HASH';
        $self->__validate_options( $opt );
    }
}


sub choose {
    if ( ref $_[0] ne 'Term::Choose' ) {
        return Term::Choose->new( $_[1] )->choose( $_[0] );
    }
    my $self = shift;
    my ( $orig_list_ref, $opt ) = @_;
    croak "choose: called with " . @_ . " arguments - 0 or 1 arguments expected" if @_ < 1 || @_ > 2;
    croak "choose: the first argument must be an ARRAY reference" if ref $orig_list_ref ne 'ARRAY';
    if ( ! @$orig_list_ref ) {
        carp "choose: The first argument refers to an empty list";
        return;
    }
    if ( defined $opt ) {
        croak "choose: the (optional) second argument must be a HASH reference" if ref $opt ne 'HASH';
        $self->{backup_opt} = { map{ $_ => $self->{$_} } keys %$opt };
        $self->__validate_options( $opt );
    }
    local $\ = undef;
    local $, = undef;
    $self->{wantarray}  = wantarray;
    $self->{handle_out} = -t \*STDOUT ? \*STDOUT : \*STDERR;
    $self->__set_defaults();
    if ( $self->{limit} && @$orig_list_ref > $self->{limit} ) {
        $self->{list_to_long} = 1;
    }
    $self->{orig_list} = $orig_list_ref;
    $self->__copy_orig_list();
    $self->__length_longest();
    $self->{col_width} = $self->{length_longest} + $self->{pad};
    local $SIG{'INT'} = sub {
        # my $signame = shift;
        exit 1;
    };
    $self->__init_term();
    $self->__write_first_screen();

    while ( 1 ) {
        my $key = $self->__get_key();
        if ( ! defined $key ) {
            $self->__reset_term( 1 );
            carp "EOT: $!";
            return;
        }
        my ( $new_width, $new_height ) = $self->{plugin}->__get_term_size();
        if ( $new_width != $self->{term_width} || $new_height != $self->{term_height} ) {
            $self->{list} = $self->__copy_orig_list();
            print CR, UP x ( $self->{i_row} + $self->{nr_prompt_lines} );
            print CLEAR_TO_END_OF_SCREEN;
            $self->__write_first_screen();
            next;
        }
        next if $key == NEXT_get_key;
        next if $key == KEY_Tilde;

        # $self->{rc2idx} holds the new list (AoA) formated in "__size_and_layout" appropirate to the chosen layout.
        # $self->{rc2idx} does not hold the values dircetly but the respective list indexes from the original list.
        # If the original list would be ( 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h' ) and the new formated list should be
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
            if ( $#{$self->{rc2idx}} == 0 || ! (    $self->{rc2idx}[$self->{pos}[ROW]+1]
                                                 && $self->{rc2idx}[$self->{pos}[ROW]+1][$self->{pos}[COL]] )
            ) {
                $self->__beep();
            }
            else {
                $self->{pos}[ROW]++;
                if ( $self->{pos}[ROW] <= $self->{p_end} ) {
                    $self->__wr_cell( $self->{pos}[ROW] - 1, $self->{pos}[COL] );
                    $self->__wr_cell( $self->{pos}[ROW],     $self->{pos}[COL] );
                }
                else {
                    $self->{row_on_top} = $self->{pos}[ROW];
                    $self->{p_begin} = $self->{p_end} + 1;
                    $self->{p_end}   = $self->{p_end} + $self->{avail_height};
                    $self->{p_end}   = $#{$self->{rc2idx}} if $self->{p_end} > $#{$self->{rc2idx}};
                    $self->__wr_screen();
                }
            }
        }
        elsif ( $key == KEY_k || $key == VK_UP ) {
            if ( $self->{pos}[ROW] == 0 ) {
                $self->__beep();
            }
            else {
                $self->{pos}[ROW]--;
                if ( $self->{pos}[ROW] >= $self->{p_begin} ) {
                    $self->__wr_cell( $self->{pos}[ROW] + 1, $self->{pos}[COL] );
                    $self->__wr_cell( $self->{pos}[ROW],     $self->{pos}[COL] );
                }
                else {
                    $self->{row_on_top} = $self->{pos}[ROW] - ( $self->{avail_height} - 1 );
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
                $self->__beep();
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
                        $self->{row_on_top} = $self->{pos}[ROW];
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
                $self->__beep();
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
                        $self->{row_on_top} = $self->{pos}[ROW] - ( $self->{avail_height} - 1 );
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
                $self->__beep();
            }
            else {
                $self->{pos}[COL]++;
                $self->__wr_cell( $self->{pos}[ROW], $self->{pos}[COL] - 1 );
                $self->__wr_cell( $self->{pos}[ROW], $self->{pos}[COL] );
            }
        }
        elsif ( $key == KEY_h || $key == VK_LEFT ) {
            if ( $self->{pos}[COL] == 0 ) {
                $self->__beep();
            }
            else {
                $self->{pos}[COL]--;
                $self->__wr_cell( $self->{pos}[ROW], $self->{pos}[COL] + 1 );
                $self->__wr_cell( $self->{pos}[ROW], $self->{pos}[COL] );
            }
        }
        elsif ( $key == CONTROL_B || $key == VK_PAGE_UP ) {
            if ( $self->{p_begin} <= 0 ) {
                $self->__beep();
            }
            else {
                $self->{row_on_top} = $self->{avail_height} * ( int( $self->{pos}[ROW] / $self->{avail_height} ) - 1 );
                $self->{pos}[ROW] -= $self->{avail_height};
                $self->{p_begin} = $self->{row_on_top};
                $self->{p_end}   = $self->{p_begin} + $self->{avail_height} - 1;
                $self->__wr_screen();
            }
        }
        elsif ( $key == CONTROL_F || $key == VK_PAGE_DOWN ) {
            if ( $self->{p_end} >= $#{$self->{rc2idx}} ) {
                $self->__beep();
            }
            else {
                $self->{row_on_top} = $self->{avail_height} * ( int( $self->{pos}[ROW] / $self->{avail_height} ) + 1 );
                $self->{pos}[ROW] += $self->{avail_height};
                if ( $self->{pos}[ROW] >= $#{$self->{rc2idx}} ) {
                    if ( $#{$self->{rc2idx}} == $self->{row_on_top} || ! $self->{rest} || $self->{pos}[COL] <= $self->{rest} - 1 ) {
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
                $self->{p_begin} = $self->{row_on_top};
                $self->{p_end}   = $self->{p_begin} + $self->{avail_height} - 1;
                $self->{p_end}   = $#{$self->{rc2idx}} if $self->{p_end} > $#{$self->{rc2idx}};
                $self->__wr_screen();
            }
        }
        elsif ( $key == CONTROL_A || $key == VK_HOME ) {
            if ( $self->{pos}[COL] == 0 && $self->{pos}[ROW] == 0 ) {
                $self->__beep();
            }
            else {
                $self->{row_on_top} = 0;
                $self->{pos}[ROW] = $self->{row_on_top};
                $self->{pos}[COL] = 0;
                $self->{p_begin} = $self->{row_on_top};
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
                    $self->__beep();
                }
                else {
                    $self->{row_on_top} = @{$self->{rc2idx}} - ( @{$self->{rc2idx}} % $self->{avail_height} || $self->{avail_height} );
                    $self->{pos}[ROW] = $#{$self->{rc2idx}} - 1;
                    $self->{pos}[COL] = $#{$self->{rc2idx}[$self->{pos}[ROW]]};
                    if ( $self->{row_on_top} == $#{$self->{rc2idx}} ) {
                        $self->{row_on_top} = $self->{row_on_top} - $self->{avail_height};
                        $self->{p_begin} = $self->{row_on_top};
                        $self->{p_end}   = $self->{p_begin} + $self->{avail_height} - 1;
                    }
                    else {
                        $self->{p_begin} = $self->{row_on_top};
                        $self->{p_end}   = $#{$self->{rc2idx}};
                    }
                    $self->__wr_screen();
                }
            }
            else {
                if (    $self->{pos}[ROW] == $#{$self->{rc2idx}}
                     && $self->{pos}[COL] == $#{$self->{rc2idx}[$self->{pos}[ROW]]}
                ) {
                    $self->__beep();
                }
                else {
                    $self->{row_on_top} = @{$self->{rc2idx}} - ( @{$self->{rc2idx}} % $self->{avail_height} || $self->{avail_height} );
                    $self->{pos}[ROW] = $#{$self->{rc2idx}};
                    $self->{pos}[COL] = $#{$self->{rc2idx}[$self->{pos}[ROW]]};
                    $self->{p_begin} = $self->{row_on_top};
                    $self->{p_end}   = $#{$self->{rc2idx}};
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
            my @chosen;
            if ( ! defined $self->{wantarray} ) {
                $self->__reset_term( 1 );
                return;
            }
            elsif ( $self->{wantarray} ) {
                if ( $self->{order} == 1 ) {
                    for my $col ( 0 .. $#{$self->{rc2idx}[0]} ) {
                        for my $row ( 0 .. $#{$self->{rc2idx}} ) {
                            if ( $self->{marked}[$row][$col] || $row == $self->{pos}[ROW] && $col == $self->{pos}[COL] ) {
                                my $i = $self->{rc2idx}[$row][$col];
                                push @chosen, $self->{index} ? $i : $self->{orig_list}[$i];
                            }
                        }
                    }
                }
                else {
                    for my $row ( 0 .. $#{$self->{rc2idx}} ) {
                        for my $col ( 0 .. $#{$self->{rc2idx}[$row]} ) {
                            if ( $self->{marked}[$row][$col] || $row == $self->{pos}[ROW] && $col == $self->{pos}[COL] ) {
                                my $i = $self->{rc2idx}[$row][$col];
                                push @chosen, $self->{index} ? $i : $self->{orig_list}[$i];
                            }
                        }
                    }
                }
                $self->__reset_term( 1 );
                return @chosen;
            }
            else {
                my $i = $self->{rc2idx}[$self->{pos}[ROW]][$self->{pos}[COL]];
                my $chosen = $self->{index} ? $i : $self->{orig_list}[$i];
                $self->__reset_term( 1 );
                return $chosen;
            }
        }
        elsif ( $key == KEY_SPACE ) {
            if ( $self->{wantarray} ) {
                my $locked = 0;
                if ( $self->{no_spacebar} ) {
                    for my $no_spacebar ( @{$self->{no_spacebar}} ) {
                        if ( $self->{rc2idx}[$self->{pos}[ROW]][$self->{pos}[COL]] == $no_spacebar ) {
                            ++$locked;
                            last;
                        }
                    }
                }
                if ( $locked ) {
                    $self->__beep();
                }
                else {
                    if ( ! $self->{marked}[$self->{pos}[ROW]][$self->{pos}[COL]] ) {
                        $self->{marked}[$self->{pos}[ROW]][$self->{pos}[COL]] = 1;
                    }
                    else {
                        $self->{marked}[$self->{pos}[ROW]][$self->{pos}[COL]] = 0;
                    }
                    $self->__wr_cell( $self->{pos}[ROW], $self->{pos}[COL] );
                }
            }
        }
        elsif ( $key == CONTROL_SPACE ) {
            if ( $self->{wantarray} ) {
                for my $i ( 0 .. $#{$self->{rc2idx}} ) {
                    for my $j ( 0 .. $#{$self->{rc2idx}[$i]} ) {
                        $self->{marked}[$i][$j] = $self->{marked}[$i][$j] ? 0 : 1;
                    }
                }
                $self->__unmark_no_spacebar() if $self->{no_spacebar};
                $self->__wr_screen();
            }
        }
        else {
            $self->__beep();
        }
    }
}


sub __unmark_no_spacebar {
    my ( $self ) = @_;
    if ( $self->{layout} == 3 ) {
        for my $idx ( @{$self->{no_spacebar}} ) {
            $self->{marked}[$idx][0] = 0;
        }
        return;
    }
    my ( $row, $col );
    my $cols_per_row = $#{$self->{rc2idx}[0]};
    if ( $self->{order} == 0 ) {
        for my $idx ( @{$self->{no_spacebar}} ) {
            $row = int( $idx / $cols_per_row );
            $col = $idx % $cols_per_row;
            $self->{marked}[$row][$col] = 0;
        }
    }
    elsif ( $self->{order} == 1 ) {
        my $rows_per_col = @{$self->{rc2idx}};
        my $full = $rows_per_col * ( $self->{rest} || $cols_per_row );
        for my $idx ( @{$self->{no_spacebar}} ) {
            if ( $idx <= $full ) {
                $row = $idx % $rows_per_col;
                $col = int( $idx / $rows_per_col );
            }
            else {
                my $rows_per_col_short = $rows_per_col - 1;
                $row = ( $idx - $full ) % $rows_per_col_short;
                $col = int( ( $idx - $self->{rest} ) / $rows_per_col_short );
            }
            $self->{marked}[$row][$col] = 0;
        }
    }
}


sub __beep {
    my ( $self ) = @_;
    print BEEP if $self->{beep};
}


sub __copy_orig_list {
    my ( $self ) = @_;
    if ( $self->{ll} ) {
        if ( $self->{list_to_long} ) {
            $self->{list} = [ map {
                my $copy = $_;
                if ( ! $copy ) {
                    $copy = $self->{undef} if ! defined $copy;
                    $copy = $self->{empty} if $copy eq '';
                }
                $copy;
            } @{$self->{orig_list}}[ 0 .. $self->{limit} - 1 ] ];
        }
        else {
            $self->{list} = [ map {
                my $copy = $_;
                if ( ! $copy ) {
                    $copy = $self->{undef} if ! defined $copy;
                    $copy = $self->{empty} if $copy eq '';
                }
                $copy;
            } @{$self->{orig_list}} ];
        }
    }
    else {
        if ( $self->{list_to_long} ) {
            $self->{list} = [ map {
                my $copy = $_;
                if ( ! $copy ) {
                    $copy = $self->{undef} if ! defined $copy;
                    $copy = $self->{empty} if $copy eq '';
                }
                if ( ref $copy ) {
                    $copy = sprintf "%s(0x%x)", ref $copy, $copy;
                }
                $copy =~ s/\p{Space}/ /g;  # replace, but don't squash sequences of spaces
                $copy =~ s/\p{C}//g;
                $copy;
            } @{$self->{orig_list}}[ 0 .. $self->{limit} - 1 ] ];
        }
        else {
            $self->{list} = [ map {
                my $copy = $_;
                if ( ! $copy ) {
                    $copy = $self->{undef} if ! defined $copy;
                    $copy = $self->{empty} if $copy eq '';
                }
                if ( ref $copy ) {
                    $copy = sprintf "%s(0x%x)", ref $copy, $copy;
                }
                $copy =~ s/\p{Space}/ /g;
                $copy =~ s/\p{C}//g;
                $copy;
            } @{$self->{orig_list}} ];
        }
    }
}


sub __length_longest {
    my ( $self ) = @_;
    if ( $self->{ll} ) {
        $self->{length_longest} = $self->{ll};
        $self->{length} = [];
    }
    else {
        my $list = $self->{list};
        my $len = [];
        my $longest = 0;
        for my $i ( 0 .. $#$list ) {
            my $gcs = Unicode::GCString->new( $list->[$i] );
            $len->[$i] = $gcs->columns();
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
    $self->{max_width} += WIDTH_CURSOR if defined $self->{max_width};
    if ( $self->{max_width} && $self->{avail_width} > $self->{max_width} ) {
        $self->{avail_width} = $self->{max_width};
    }
    if ( $self->{mouse} == 2 ) {
        $self->{avail_width}  = MAX_COL_MOUSE_1003 if $self->{avail_width}  > MAX_COL_MOUSE_1003;
        $self->{avail_height} = MAX_ROW_MOUSE_1003 if $self->{avail_height} > MAX_ROW_MOUSE_1003;
    }
    $self->{avail_width} = 1 if $self->{avail_width} < 1;
    $self->__prepare_promptline();
    $self->{tail} = $self->{page} ? 1 : 0;
    $self->{avail_height} -= $self->{nr_prompt_lines} + $self->{tail};
    if ( $self->{avail_height} < $self->{keep} ) {
        my $height = ( $self->{plugin}->__get_term_size() )[1];
        $self->{avail_height} = $height >= $self->{keep} ? $self->{keep} : $height;
        $self->{avail_height} = 1 if $self->{avail_height} < 1;
    }
    if ( $self->{max_height} && $self->{max_height} < $self->{avail_height} ) {
        $self->{avail_height} = $self->{max_height};
    }
    $self->__size_and_layout();
    $self->__prepare_page_number() if $self->{page};
    $self->{avail_height_idx} = $self->{avail_height} - 1;
    $self->{p_begin}    = 0;
    $self->{p_end}      = $self->{avail_height_idx} > $#{$self->{rc2idx}} ? $#{$self->{rc2idx}} : $self->{avail_height_idx};
    $self->{marked}     = [];
    $self->{row_on_top} = 0;
    $self->{i_row}      = 0;
    $self->{i_col}      = 0;
    $self->{pos}        = [ 0, 0 ];
    $self->__set_default_cell() if defined $self->{default} && $self->{default} <= $#{$self->{list}};
    print CLEAR_SCREEN if $self->{clear_screen};
    print $self->{prompt_copy} if $self->{prompt} ne '';
    $self->__wr_screen();
    $self->{plugin}->__term_cursor_position() if $self->{mouse};
    $self->{cursor_row} = $self->{i_row};
}


sub __prepare_promptline {
    my ( $self ) = @_;
    if ( $self->{prompt} eq '' ) {
        $self->{nr_prompt_lines} = 0;
        return;
    }
    $self->{prompt} =~ s/[^\n\P{Space}]/ /g;
    $self->{prompt} =~ s/[^\n\P{C}]//g;
    my $gcs_prompt = Unicode::GCString->new( $self->{prompt} );
    if ( $self->{prompt} !~ /\n/ && $gcs_prompt->columns() <= $self->{avail_width} ) {
        $self->{nr_prompt_lines} = 1;
        $self->{prompt_copy} = $self->{prompt} . "\n\r";
    }
    else {
        my $line_fold = Text::LineFold->new(
            Charset=> 'utf-8',
            ColMax => $self->{avail_width},
            OutputCharset => '_UNICODE_',
            Urgent => 'FORCE'
        );
        if ( defined $self->{lf} ) {
            $self->{prompt_copy} = $line_fold->fold( ' ' x $self->{lf}[0], ' ' x $self->{lf}[1], $self->{prompt} );
        }
        else {
            $self->{prompt_copy} = $line_fold->fold( $self->{prompt}, 'PLAIN' );
        }
        $self->{nr_prompt_lines} = $self->{prompt_copy} =~ s/\n/\n\r/g;
    }
}


sub __size_and_layout {
    my ( $self ) = @_;
    $self->{rc2idx} = [];
    if ( $self->{length_longest} > $self->{avail_width} ) {
        $self->{avail_col_width} = $self->{avail_width};
        $self->{layout} = 3;
    }
    else {
        $self->{avail_col_width} = $self->{length_longest};
    }
    my $all_in_first_row;
    if ( $self->{layout} == 0 || $self->{layout} == 1 ) {
        for my $idx ( 0 .. $#{$self->{list}} ) {
            $all_in_first_row .= $self->{list}[$idx];
            $all_in_first_row .= ' ' x $self->{pad_one_row} if $idx < $#{$self->{list}};
            my $gcs_first_row = Unicode::GCString->new( $all_in_first_row );
            if ( $gcs_first_row->columns() > $self->{avail_width} ) {
                $all_in_first_row = '';
                last;
            }
        }
    }
    if ( $all_in_first_row ) {
        $self->{rc2idx}[0] = [ 0 .. $#{$self->{list}} ];
    }
    elsif ( $self->{layout} == 3 ) {
        if ( $self->{length_longest} <= $self->{avail_width} ) {
            for my $idx ( 0 .. $#{$self->{list}} ) {
                $self->{rc2idx}[$idx][0] = $idx;
            }
        }
        else {
            for my $idx ( 0 .. $#{$self->{list}} ) {
                my $gcs_element = Unicode::GCString->new( $self->{list}[$idx] );
                if ( $gcs_element->columns > $self->{avail_width} ) {
                    $self->{list}[$idx] = $self->__unicode_trim( $gcs_element, $self->{avail_width} - 3 ) . '...';
                }
                $self->{rc2idx}[$idx][0] = $idx;
            }
        }
    }
    else {
        my $tmp_avail_width = $self->{avail_width} + $self->{pad} - WIDTH_CURSOR;
        # auto_format
        if ( $self->{layout} == 1 || $self->{layout} == 2 ) {
            my $tmc = int( @{$self->{list}} / $self->{avail_height} );
            $tmc++ if @{$self->{list}} % $self->{avail_height};
            $tmc *= $self->{col_width};
            if ( $tmc < $tmp_avail_width ) {
                $tmc = int( $tmc + ( ( $tmp_avail_width - $tmc ) / 1.5 ) ) if $self->{layout} == 1;
                $tmc = int( $tmc + ( ( $tmp_avail_width - $tmc ) / 4 ) )   if $self->{layout} == 2;
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


sub __unicode_trim {
    my ( $self, $gcs, $len ) = @_;
    return '' if $len <= 0; #
    my $pos = $gcs->pos;
    $gcs->pos( 0 );
    my $cols = 0;
    my $gc;
    while ( defined( $gc = $gcs->next ) ) {
        if ( $len < ( $cols += $gc->columns ) ) {
            my $ret = $gcs->substr( 0, $gcs->pos - 1 );
            $gcs->pos( $pos );
            return $ret->as_string;
        }
    }
    $gcs->pos( $pos );
    return $gcs->as_string;
}


sub __prepare_page_number {
    my ( $self ) = @_;
    $self->{pp} = int( $#{$self->{rc2idx}} / ( $self->{avail_height} + $self->{tail} ) ) + 1;
    if ( $self->{pp} > 1 ) {
        $self->{pp} = int( $#{$self->{rc2idx}} / $self->{avail_height} ) + 1;
        $self->{width_pp} = length $self->{pp};
        $self->{pp_printf_fmt} = "--- Page %0*d/%d ---";
        $self->{pp_printf_type} = 0;
        if ( length sprintf( $self->{pp_printf_fmt}, $self->{width_pp}, $self->{pp}, $self->{pp} ) > $self->{avail_width} ) {
            $self->{pp_printf_fmt} = "%0*d/%d";
            if ( length sprintf( $self->{pp_printf_fmt}, $self->{width_pp}, $self->{pp}, $self->{pp} ) > $self->{avail_width} ) {
                $self->{width_pp} = $self->{avail_width} if $self->{width_pp} > $self->{avail_width};
                $self->{pp_printf_fmt} = "%0*.*s";
                $self->{pp_printf_type} = 1;
            }
        }
    }
    else {
        $self->{avail_height} += $self->{tail};
        $self->{tail} = 0;
    }
}


sub __set_default_cell {
    my ( $self ) = @_;
    $self->{tmp_pos} = [ 0, 0 ];
    LOOP: for my $i ( 0 .. $#{$self->{rc2idx}} ) {
        # if ( $self->{default} ~~ @{$self->{rc2idx}[$i]} ) {
            for my $j ( 0 .. $#{$self->{rc2idx}[$i]} ) {
                if ( $self->{default} == $self->{rc2idx}[$i][$j] ) {
                    $self->{tmp_pos} = [ $i, $j ];
                    last LOOP;
                }
            }
        # }
    }
    while ( $self->{tmp_pos}[ROW] > $self->{p_end} ) {
        $self->{row_on_top} = $self->{avail_height} * ( int( $self->{pos}[ROW] / $self->{avail_height} ) + 1 );
        $self->{pos}[ROW] = $self->{row_on_top};
        $self->{p_begin} = $self->{row_on_top};
        $self->{p_end} = $self->{p_begin} + $self->{avail_height} - 1;
        $self->{p_end} = $#{$self->{rc2idx}} if $self->{p_end} > $#{$self->{rc2idx}};
    }
    $self->{pos} = $self->{tmp_pos};
}


sub __goto {
    my ( $self, $newrow, $newcol ) = @_;
    if ( $newrow > $self->{i_row} ) {
        print CR, LF x ( $newrow - $self->{i_row} );
        $self->{i_row} += ( $newrow - $self->{i_row} );
        $self->{i_col} = 0;
    }
    elsif ( $newrow < $self->{i_row} ) {
        print UP x ( $self->{i_row} - $newrow );
        $self->{i_row} -= ( $self->{i_row} - $newrow );
    }
    if ( $newcol > $self->{i_col} ) {
        print RIGHT x ( $newcol - $self->{i_col} );
        $self->{i_col} += ( $newcol - $self->{i_col} );
    }
    elsif ( $newcol < $self->{i_col} ) {
        print LEFT x ( $self->{i_col} - $newcol );
        $self->{i_col} -= ( $self->{i_col} - $newcol );
    }
}


sub __wr_screen {
    my ( $self ) = @_;
    $self->__goto( 0, 0 );
    print CLEAR_TO_END_OF_SCREEN;
    if ( $self->{page} && $self->{pp} > 1 ) {
        $self->__goto( $self->{avail_height_idx} + $self->{tail}, 0 );
        if ( $self->{pp_printf_type} == 0 ) {
            printf $self->{pp_printf_fmt}, $self->{width_pp}, int( $self->{row_on_top} / $self->{avail_height} ) + 1, $self->{pp};
            $self->{i_col} += length sprintf $self->{pp_printf_fmt}, $self->{width_pp}, int( $self->{row_on_top} / $self->{avail_height} ) + 1, $self->{pp};
        }
        elsif ( $self->{pp_printf_type} == 1 ) {
            printf $self->{pp_printf_fmt}, $self->{width_pp}, $self->{width_pp}, int( $self->{row_on_top} / $self->{avail_height} ) + 1;
            $self->{i_col} += length sprintf $self->{pp_printf_fmt}, $self->{width_pp}, $self->{width_pp}, int( $self->{row_on_top} / $self->{avail_height} ) + 1;
        }
     }
    for my $row ( $self->{p_begin} .. $self->{p_end} ) {
        for my $col ( 0 .. $#{$self->{rc2idx}[$row]} ) {
            $self->__wr_cell( $row, $col );
        }
    }
    $self->__wr_cell( $self->{pos}[ROW], $self->{pos}[COL] );
}


sub __wr_cell {
    my( $self, $row, $col ) = @_;
    if ( $#{$self->{rc2idx}} == 0 ) {
        my $lngth = 0;
        if ( $col > 0 ) {
            for my $cl ( 0 .. $col - 1 ) {
                my $gcs_element = Unicode::GCString->new( $self->{list}[$self->{rc2idx}[$row][$cl]] );
                $lngth += $gcs_element->columns();
                $lngth += $self->{pad_one_row};
            }
        }
        $self->__goto( $row - $self->{row_on_top}, $lngth );
        print BOLD, UNDERLINE if $self->{marked}[$row][$col];
        print REVERSE         if $row == $self->{pos}[ROW] && $col == $self->{pos}[COL];
        print $self->{list}[$self->{rc2idx}[$row][$col]];
        my $gcs_element = Unicode::GCString->new( $self->{list}[$self->{rc2idx}[$row][$col]] );
        $self->{i_col} += $gcs_element->columns();
    }
    else {
        $self->__goto( $row - $self->{row_on_top}, $col * $self->{col_width} );
        print BOLD, UNDERLINE if $self->{marked}[$row][$col];
        print REVERSE         if $row == $self->{pos}[ROW] && $col == $self->{pos}[COL];
        print $self->__unicode_sprintf( $self->{rc2idx}[$row][$col] );
        $self->{i_col} += $self->{length_longest};
    }
    print RESET if $self->{marked}[$row][$col] || $row == $self->{pos}[ROW] && $col == $self->{pos}[COL];
}


sub __unicode_sprintf {
    my ( $self, $idx ) = @_;
    my $unicode;
    my $str_length = $self->{length}[$idx] // $self->{length_longest};
    if ( $str_length > $self->{avail_col_width} ) {
        my $gcs = Unicode::GCString->new( $self->{list}[$idx] );
        $unicode = $self->__unicode_trim( $gcs, $self->{avail_col_width} );
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
    return NEXT_get_key if $abs_mouse_y < $abs_y_top_row;
    my $mouse_row = $abs_mouse_y - $abs_y_top_row;
    my $mouse_col = $abs_mouse_x;
    my( $found_row, $found_col );
    my $found = 0;
    if ( $#{$self->{rc2idx}} == 0 ) {
        my $row = 0;
        if ( $row == $mouse_row ) {
            my $end_last_col = 0;
            COL: for my $col ( 0 .. $#{$self->{rc2idx}[$row]} ) {
                my $gcs_element = Unicode::GCString->new( $self->{list}[$self->{rc2idx}[$row][$col]] );
                my $end_this_col = $end_last_col + $gcs_element->columns() + $self->{pad_one_row};
                if ( $col == 0 ) {
                    $end_this_col -= int( $self->{pad_one_row} / 2 );
                }
                if ( $col == $#{$self->{rc2idx}[$row]} ) {
                    $end_this_col = $self->{avail_width} if $end_this_col > $self->{avail_width};
                }
                if ( $end_last_col < $mouse_col && $end_this_col >= $mouse_col ) {
                    $found = 1;
                    $found_row = $row + $self->{row_on_top};
                    $found_col = $col;
                    last;
                }
                $end_last_col = $end_this_col;
            }
        }
    }
    else {
        ROW: for my $row ( 0 .. $#{$self->{rc2idx}} ) {
            if ( $row == $mouse_row ) {
                my $end_last_col = 0;
                COL: for my $col ( 0 .. $#{$self->{rc2idx}[$row]} ) {
                    my $end_this_col = $end_last_col + $self->{col_width};
                    if ( $col == 0 ) {
                        $end_this_col -= int( $self->{pad} / 2 );
                    }
                    if ( $col == $#{$self->{rc2idx}[$row]} ) {
                        $end_this_col = $self->{avail_width} if $end_this_col > $self->{avail_width};
                    }
                    if ( $end_last_col < $mouse_col && $end_this_col >= $mouse_col ) {
                        $found = 1;
                        $found_row = $row + $self->{row_on_top};
                        $found_col = $col;
                        last ROW;
                    }
                    $end_last_col = $end_this_col;
                }
            }
        }
    }
    return NEXT_get_key if ! $found;
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
    if ( $found_row != $self->{pos}[ROW] || $found_col != $self->{pos}[COL] ) {
        my $tmp = $self->{pos};
        $self->{pos} = [ $found_row, $found_col ];
        $self->__wr_cell( $tmp->[0], $tmp->[1] );
        $self->__wr_cell( $self->{pos}[ROW], $self->{pos}[COL] );
    }
    return $return_char;
}



1;


__END__

=pod

=encoding UTF-8

=head1 NAME

Term::Choose - Choose items from a list.

=head1 VERSION

Version 1.110

=cut

=head1 SYNOPSIS

    use 5.10.1;
    use Term::Choose qw( choose );

    my $array_ref = [ qw( one two three four five ) ];

    my $choice = choose( $array_ref );                            # single choice
    say $choice;

    my @choices = choose( [ 1 .. 100 ], { justify => 1 } );       # multiple choice
    say "@choices";

    choose( [ 'Press ENTER to continue' ], { prompt => '' } );    # no choice


    # or OO-interface:


    use 5.10.1;
    use Term::Choose;

    my $array_ref = [ qw( one two three four five ) ];

    my $new = Term::Choose->new();

    my $choice = $new->choose( $array_ref );                       # single choice
    say $choice;

    $new->config( { justify => 1 } )
    my @choices = $new->choose( [ 1 .. 100 ] );                    # multiple choice
    say "@choices";

    my $stopp = Term::Choose->new( { prompt => '' } )
    $stopp->choose( [ 'Press ENTER to continue' ] );               # no choice

=head1 DESCRIPTION

Choose from a list of items.

Based on the C<choose> function from the L<Term::Clui> module.

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

=head2 config

    $new->config( \%options );

The C<config> method is meant to set the different options. The options are passed as a hash reference.

Options set with C<config> overwrite options set with the C<new> method.

For detailed information about the different options, their allowed and default values see L</OPTIONS>.

=head2 choose

The method C<choose> allows the user to choose from a list.

The first argument is an array reference which holds the list of the available choices.

As a second and optional argument it can be passed a reference to a hash where the keys are the option names and the
values the option values.

Options set with C<choose> overwrite options set with C<new> or C<config>. Before leaving C<choose> restores the
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

=item

If C<choose> is called in a I<scalar context>, the user can choose an item by using the L</Keys to move around> and
confirming with C<Return>.

C<choose> then returns the chosen item.

=item

If C<choose> is called in an I<list context>, the user can also mark an item with the C<SpaceBar>.

C<choose> then returns - when C<Return> is pressed - the list of marked items including the highlighted item.

In I<list context> C<Ctrl-SpaceBar> (or C<Ctrl-@>) inverts the choices: marked items are unmarked and unmarked items are marked.

=item

If C<choose> is called in an I<void context>, the user can move around but mark nothing; the output shown by C<choose>
can be closed with C<Return>.

Called in void context C<choose> returns nothing.

=back

If the items of the list don't fit on the screen, the user can scroll to the next (previous) page(s).

If the window size is changed, then as soon as the user enters a keystroke C<choose> rewrites the screen. In list
context marked items are reset.

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

If the length of an element is greater than the width of the screen the element is cut.

    $element = substr( $element, 0, $allowed_length - 3 ) . '...';*

* C<Term::Choose> uses its own function to cut strings which uses C<columns> from L<Unicode::GCString> to determine the
string length.

=back

The following should be without meaning if you comply with the requirements.

=over

=item *

Characters which match the Unicode character property C<Other> are removed.

    $element =~ s/\p{C}//g;

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

=head2 beep

0 - off (default)

1 - on

=head2 clear_screen

0 - off (default)

1 - clears the screen before printing the choices

=head2 default

With the option I<default> it can be selected an element, which will be highlighted as the default instead of the first
element.

I<default> expects a zero indexed value, so e.g. to highlight the third element the value would be I<2>.

If the passed value is greater than the index of the last array element the first element is highlighted.

Allowed values: 0 or greater

(default: undefined)

=head2 empty

Sets the string displayed on the screen instead an empty string.

default: "<empty>"

=head2 hide_cursor

0 - keep the terminals highlighting of the cursor position

1 - hide the terminals highlighting of the cursor position (default)

=head2 index

0 - off (default)

1 - return the index of the chosen element instead of the chosen element respective the indices of the chosen elements
instead of the chosen elements.

=head2 justify

0 - elements ordered in columns are left justified (default)

1 - elements ordered in columns are right justified

2 - elements ordered in columns are centered

=head2 keep

I<keep> prevents that all the terminal rows are used by the prompt lines.

Setting I<keep> ensures that at least I<keep> terminal rows are available for printing list rows.

If the terminal height is less than I<keep> I<keep> is set to the terminal height.

Allowed values: 1 or greater

(default: 5)

=head2 layout

From broad to narrow: 0 > 1 > 2 > 3

=over

=item

0 - layout off

 .----------------------.   .----------------------.   .----------------------.   .----------------------.
 | .. .. .. .. .. .. .. |   | .. .. .. .. .. .. .. |   | .. .. .. .. .. .. .. |   | .. .. .. .. .. .. .. |
 |                      |   | .. .. .. .. .. .. .. |   | .. .. .. .. .. .. .. |   | .. .. .. .. .. .. .. |
 |                      |   |                      |   | .. .. .. .. ..       |   | .. .. .. .. .. .. .. |
 |                      |   |                      |   |                      |   | .. .. .. .. .. .. .. |
 |                      |   |                      |   |                      |   | .. .. .. .. .. .. .. |
 |                      |   |                      |   |                      |   | .. .. .. .. .. .. .. |
 '----------------------'   '----------------------'   '----------------------'   '----------------------'

=item

1 - layout "H" (default)

 .----------------------.   .----------------------.   .----------------------.   .----------------------.
 | .. .. .. .. .. .. .. |   | .. .. .. .. ..       |   | .. .. .. .. .. ..    |   | .. .. .. .. .. .. .. |
 |                      |   | .. .. .. .. ..       |   | .. .. .. .. .. ..    |   | .. .. .. .. .. .. .. |
 |                      |   | .. ..                |   | .. .. .. .. .. ..    |   | .. .. .. .. .. .. .. |
 |                      |   |                      |   | .. .. .. .. .. ..    |   | .. .. .. .. .. .. .. |
 |                      |   |                      |   | .. .. ..             |   | .. .. .. .. .. .. .. |
 |                      |   |                      |   |                      |   | .. .. .. .. .. .. .. |
 '----------------------'   '----------------------'   '----------------------'   '----------------------'

=item

2 - layout "V"

 .----------------------.   .----------------------.   .----------------------.   .----------------------.
 | .. ..                |   | .. .. ..             |   | .. .. .. ..          |   | .. .. .. .. .. .. .. |
 | .. ..                |   | .. .. ..             |   | .. .. .. ..          |   | .. .. .. .. .. .. .. |
 | ..                   |   | .. .. ..             |   | .. .. .. ..          |   | .. .. .. .. .. .. .. |
 |                      |   | .. ..                |   | .. .. ..             |   | .. .. .. .. .. .. .. |
 |                      |   |                      |   | .. .. ..             |   | .. .. .. .. .. .. .. |
 |                      |   |                      |   |                      |   | .. .. .. .. .. .. .. |
 '----------------------'   '----------------------'   '----------------------'   '----------------------'

=item

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

=head2 lf

If I<prompt> lines are folded the option I<lf> allows to insert spaces at beginning of the folded lines.

The option I<lf> expects a reference to an array with one or two elements:

- the first element (C<INITIAL_TAB>) sets the number of spaces inserted at beginning of paragraphs

- a second element (C<SUBSEQUENT_TAB>) sets the number of spaces inserted at the beginning of all broken lines apart from the
beginning of paragraphs

Allowed values for the two elements are: 0 or greater.

See C<INITIAL_TAB> and C<SUBSEQUENT_TAB> in L<Text::LineFold>.

(default: undefined)

=head2 limit

Sets the maximal allowed length of the array. (default: undefined)

If the array referred by the first argument has more than I<limit> elements choose uses only the first I<limit> array
elements.

Allowed values: 1 or greater

=head2 ll

If all elements have the same length and this length is known before calling C<choose> the length can be passed with
this option.

If I<ll> is set, then C<choose> doesn't calculate the length of the longest element itself but uses the value passed
with this option.

I<length> refers here to the number of print columns the element will use on the terminal.

A way to determine the number of print columns is the use of C<columns> from L<Unicode::GCString>.

The length of undefined elements and elements with an empty string depends on the value of the option I<undef>
respective on the value of the option I<empty>.

If the option I<ll> is set the replacements described in L</Modifications for the output> are not applied.

If elements contain unsupported characters the output might break if the width (number of print columns) of the
replacement character does not correspond to the width of the replaced character - for example when a unsupported
non-spacing character is replaced by a replacement character with a normal width.

If I<ll> is set to a value less than the length of the elements the output could break.

If the value of I<ll> is greater than the screen width the elements will be trimmed to fit into the screen.

Allowed values: 1 or greater

(default: undefined)

=head2 max_height

If defined sets the maximal number of rows used for printing list items.

If the available height is less than I<max_height> I<max_height> is set to the available height.

Height in this context means print rows.

I<max_height> overwrites I<keep> if I<max_height> is set and less than I<keep>.

Allowed values: 1 or greater

(default: undefined)

=head2 max_width

If defined, sets the maximal output width to I<max_width> if the terminal width is greater than I<max_width>.

To prevent the "auto-format" to use a width less than I<max_width> set I<layout> to 0.

Width refers here to the number of print columns.

Allowed values: 1 or greater

(default: undefined)

=head2 mouse

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

=head2 no_spacebar

I<no_spacebar> expects as its value a reference to an array. The elements of the array are indexes of choices which
should not be markable with the C<SpaceBar> or with the right mouse key.

(default: undefined)

=head2 order

If the output has more than one row and more than one column:

0 - elements are ordered horizontally

1 - elements are ordered vertically (default)

Default may change in a future release.

=head2 pad

Sets the number of whitespaces between columns. (default: 2)

Allowed values: 0 or greater

=head2 pad_one_row

Sets the number of whitespaces between elements if we have only one row. (default: value of the option I<pad>)

Allowed values: 0 or greater

=head2 page

0 - off

1 - print the page number on the bottom of the screen if there is more then one page. (default)

=head2 prompt

If I<prompt> is undefined a default prompt-string will be shown.

If the I<prompt> value is an empty string ("") no prompt-line will be shown.

default in list and scalar context: C<Your choice:>

default in void context: C<Close with ENTER>

=head2 undef

Sets the string displayed on the screen instead an undefined element.

default: "<undef>"

=head1 ERROR HANDLING

=head2 croak

=over

=item * If passed an invalid number of arguments C<new|config|choose> dies.

=item * If passed an invalid argument C<new|config|choose> dies.

=back

=head2 carp

=over

=item * If the array referred by the first argument is empty C<choose> warns and returns C<undef> respective an empty list.

=item * If an option does not exist C<new|config|choose> warns.

=item * If an option value is not valid C<new|config|choose> warns and uses the default value instead.

=item * If after pressing a key L<Term::ReadKey>::ReadKey returns C<undef> C<choose> warns with C<EOT: $!> and returns
I<undef> or an empty list in list context.

=back

=head1 REQUIREMENTS

=head2 Perl version

Requires Perl version 5.10.1 or greater.

=head2 Modules

Used modules not provided as core modules:

=over

=item

L<Text::LineFold>

=item

L<Unicode::GCString>

=back

Additionally, if the OS is MSWin32

=over

=item

L<Term::Size::Win32>

=item

L<Win32::Console>

=item

L<Win32::Console::ANSI>

=back

are required. Else

=over

=item

L<Term::ReadKey>

=back

is additionally required.

=head2 Decoded strings

C<choose> expects decoded strings as array elements.

If the operating system is MSWin32 C<Term::Choose> disables the automatic conversion done by C<Win32::Console::ANSI>
globally - see C<"\e(U"> in L<Win32::Console::ANSI|Win32::Console::ANSI/Escape sequences for Select Character Set>.

=head2 Encoding layer for STDOUT

For a correct output it is required to set an encoding layer for C<STDOUT> matching the terminal's character set.

=head2 Monospaced font

It is required a terminal that uses a monospaced font which supports the printed characters.

=head2 Escape sequences

The following ANSI escape sequences are used:

    "\e[A"      Cursor Up

    "\e[C"      Cursor Forward

    "\e[D"      Cursor Back

    "\e[0J"     Clear to End of Screen (Erase Data)

    "\e[0m"     Normal/Reset

    "\e[1m"     Bold

    "\e[4m"     Underline

    "\e[7m"     Inverse

If the option "hide_cursor" is enabled:

    "\e[?25l"   Hide Cursor

    "\e[?25h"   Show Cursor

If the option "clear_screen" is enabled:

    "\e[2J"     Clear Screen (Erase Data)

    "\e[1;1H"   Go to Top Left (Cursor Position)

If the OS is MSWin32 the L<Win32::Console::ANSI> module is used to understand these escape sequences.

If a I<mouse> mode is enabled

    "\e[6n"    Get Cursor Position (Device Status Report)

    "\e[?1003h", "\e[?1005h", "\e[?1006h"   Enable Mouse Tracking

    "\e[?1003l", "\e[?1005l", "\e[?1006l"   Disable Mouse Tracking

are used to enable/disable the different I<mouse> modes.

To read key and mouse events with an MSWin32 OS L<Win32::Console> is used instead.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Term::Choose

=head1 AUTHOR

Matthäus Kiem <cuer2s@gmail.com>

=head1 CREDITS

Based on and inspired by the C<choose> function from the L<Term::Clui> module.

Thanks to the L<Perl-Community.de|http://www.perl-community.de> and the people form
L<stackoverflow|http://stackoverflow.com> for the help.

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2012-2014 Matthäus Kiem.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl 5.10.0. For
details, see the full text of the licenses in the file LICENSE.

=cut
