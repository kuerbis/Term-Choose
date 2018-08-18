package Term::Choose::Win32;

use warnings;
use strict;
use 5.008003;

our $VERSION = '1.625_02';


use Encode qw( decode );

use Encode::Locale qw();
use Win32::Console qw( STD_INPUT_HANDLE ENABLE_MOUSE_INPUT ENABLE_PROCESSED_INPUT STD_OUTPUT_HANDLE
                       RIGHT_ALT_PRESSED LEFT_ALT_PRESSED RIGHT_CTRL_PRESSED LEFT_CTRL_PRESSED SHIFT_PRESSED
                       FOREGROUND_INTENSITY BACKGROUND_INTENSITY );

use Term::Choose::Constants      qw( :win32 );
#use Term::Choose::Win32::Console qw();

sub SHIFTED_MASK () {
      RIGHT_ALT_PRESSED
    | LEFT_ALT_PRESSED
    | RIGHT_CTRL_PRESSED
    | LEFT_CTRL_PRESSED
    | SHIFT_PRESSED
}


sub new {
    return bless {}, $_[0];
}


sub __get_key_OS {
    my ( $self, $mouse ) = @_;
    my @event = $self->{input}->Input;
    my $event_type = shift @event;
    return NEXT_get_key if ! defined $event_type;
    if ( $event_type == 1 ) {
        my ( $key_down, $repeat_count, $v_key_code, $v_scan_code, $char, $ctrl_key_state ) = @event;
        return NEXT_get_key if ! $key_down;
        if ( $char ) {
            if ( $char == 32 && $ctrl_key_state & ( RIGHT_CTRL_PRESSED | LEFT_CTRL_PRESSED ) ) {
                return CONTROL_SPACE;
            }
            else {
                #return $char;
                return ord decode( 'console_in', chr( $char & 0xff ) ); #
            }
        }
        else{
            if ( $ctrl_key_state & SHIFTED_MASK ) {
                return NEXT_get_key;
            }
            elsif ( $v_key_code == VK_CODE_PAGE_UP )   { return VK_PAGE_UP }
            elsif ( $v_key_code == VK_CODE_PAGE_DOWN ) { return VK_PAGE_DOWN }
            elsif ( $v_key_code == VK_CODE_END )       { return VK_END }
            elsif ( $v_key_code == VK_CODE_HOME )      { return VK_HOME }
            elsif ( $v_key_code == VK_CODE_LEFT )      { return VK_LEFT }
            elsif ( $v_key_code == VK_CODE_UP )        { return VK_UP }
            elsif ( $v_key_code == VK_CODE_RIGHT )     { return VK_RIGHT }
            elsif ( $v_key_code == VK_CODE_DOWN )      { return VK_DOWN }
            elsif ( $v_key_code == VK_CODE_INSERT )    { return VK_INSERT }
            elsif ( $v_key_code == VK_CODE_DELETE )    { return VK_DELETE }
            else                                       { return NEXT_get_key }
        }
    }
    elsif ( $mouse && $event_type == 2 ) {
        my( $x, $y, $button_state, $control_key, $event_flags ) = @event;
        my $button;
        if ( ! $event_flags ) {
            if ( $button_state & LEFTMOST_BUTTON_PRESSED ) {
                $button = 1;
            }
            elsif ( $button_state & RIGHTMOST_BUTTON_PRESSED ) {
                $button = 3;
            }
            elsif ( $button_state & FROM_LEFT_2ND_BUTTON_PRESSED ) {
                $button = 2;
            }
            else {
                return NEXT_get_key;
            }
        }
        elsif ( $event_flags & MOUSE_WHEELED ) {
            $button = $button_state >> 24 ? 5 : 4;
        }
        else {
            return NEXT_get_key;
        }
        return [ $self->{abs_cursor_y}, $button, $x, $y ];
    }
    else {
        return NEXT_get_key;
    }
}


sub __set_mode_raw {
    my ( $self, $mouse, $hide_cursor ) = @_;
    if ( defined $self->{input}{handle} ) {
        delete $self->{input}{handle};
    }
    $self->{input} = Win32::Console->new( STD_INPUT_HANDLE );
    #$self->{input} = Term::Choose::Win32::Console->new( STD_INPUT_HANDLE );
    $self->{old_in_mode} = $self->{input}->Mode();
    $self->{input}->Mode( !ENABLE_PROCESSED_INPUT )                    if ! $mouse;
    $self->{input}->Mode( !ENABLE_PROCESSED_INPUT|ENABLE_MOUSE_INPUT ) if   $mouse;
    if ( defined $self->{output}{handle} ) {
        delete $self->{output}{handle};
    }
    $self->{output} = Win32::Console->new( STD_OUTPUT_HANDLE );
    #$self->{output} = Term::Choose::Win32::Console->new( STD_OUTPUT_HANDLE );
    $self->{curr_attr} = $self->{output}->Attr();
    $self->{fg_color}  = $self->{curr_attr} & 0x7;
    $self->{bg_color}  = $self->{curr_attr} & 0x70;
    $self->{fill_attr} = $self->{bg_color} | $self->{bg_color};
    $self->{inverse}   = ( $self->{bg_color} >> 4 ) | ( $self->{fg_color} << 4 );
    $self->__hide_cursor() if $hide_cursor;
    return $mouse;
}


sub __reset_mode {
    my ( $self, $mouse, $hide_cursor ) = @_;  # no use for $mouse on win32
    if ( defined $self->{input} ) {
        if ( defined $self->{old_in_mode} ) {
            $self->{input}->Mode( $self->{old_in_mode} );
            delete $self->{old_in_mode};
        }
        $self->{input}->Flush;
        # workaround Bug #33513:
        delete $self->{input}{handle};
    }
    if ( defined $self->{output} ) {
        $self->__reset;
        $self->__show_cursor() if $hide_cursor;
        #$self->{output}->Free();
        delete $self->{output}{handle};
    }
}


sub __get_term_size {
    my ( $self ) = @_;
    my ( $term_width, $term_height ) = Win32::Console->new()->Size();
    #my ( $term_width, $term_height ) = Term::Choose::Win32::Console->new()->Size();
    return $term_width - 1, $term_height - 1;
}


sub __get_cursor_position {
    my ( $self ) = @_;
    ( $self->{abs_cursor_x}, $self->{abs_cursor_y} ) = $self->{output}->Cursor();
}


sub __set_cursor_position {
    my ( $self, $col, $row ) = @_;
    $self->{output}->Cursor( $col, $row );
}


sub __hide_cursor {
    my ( $self ) = @_;
    if ( ! exists $self->{output}{handle} || ! defined $self->{output}{handle} ) {
        $self->{output} = Win32::Console->new( STD_OUTPUT_HANDLE );
        #$self->{output} = Term::Choose::Win32::Console->new( STD_OUTPUT_HANDLE );
        $self->{output}->Cursor( -1, -1, -1, 0 );
        delete $self->{output}{handle};
    }
    else {
        $self->{output}->Cursor( -1, -1, -1, 0 );
    }
}


sub __show_cursor {
    my ( $self ) = @_;
    if ( ! exists $self->{output}{handle} || ! defined $self->{output}{handle} ) {
        $self->{output} = Win32::Console->new( STD_OUTPUT_HANDLE );
        #$self->{output} = Term::Choose::Win32::Console->new( STD_OUTPUT_HANDLE );
        $self->{output}->Cursor( -1, -1, -1, 1 );
        delete $self->{output}{handle};
    }
    else {
        $self->{output}->Cursor( -1, -1, -1, 1 );
    }
}


sub __clear_screen {
    my ( $self ) = @_;
    if ( ! exists $self->{output}{handle} || ! defined $self->{output}{handle} ) {
        $self->{output} = Win32::Console->new( STD_OUTPUT_HANDLE );
        #$self->{output} = Term::Choose::Win32::Console->new( STD_OUTPUT_HANDLE );
        $self->{curr_attr} = $self->{output}->Attr();
        $self->{output}->Cls( $self->{curr_attr} );
        delete $self->{output}{handle};
    }
    else {
        $self->{output}->Cls( $self->{curr_attr} );
    }
}


sub __clear_to_end_of_screen {
    my ( $self ) = @_;
    my ( $width, $height ) = $self->{output}->Size();
    $self->__get_cursor_position();
    $self->{output}->FillAttr(
            $self->{fill_attr},
            $width * $height,
            $self->{abs_cursor_x}, $self->{abs_cursor_y} );
}


sub __clear_line {
    my ( $self ) = @_;
    my ( $width, $height ) = $self->{output}->Size(); #
    $self->__get_cursor_position();
    $self->__set_cursor_position( 0, $self->{abs_cursor_y} );
    $self->{output}->FillAttr(
            $self->{fill_attr},
            $width,
            0, $self->{abs_cursor_y} );
}


sub __bold_underline {
    my ( $self ) = @_;
    $self->{output}->Attr( $self->{curr_attr} | FOREGROUND_INTENSITY | BACKGROUND_INTENSITY  );
}


sub __reverse {
    my ( $self ) = @_;
    $self->{output}->Attr( $self->{inverse} );
}


sub __reset {
    my ( $self ) = @_;
    $self->{output}->Attr( $self->{curr_attr} );
}


sub __up {
    #my ( $self, $rows_up ) = @_;
    my ( $col, $row ) = $_[0]->__get_cursor_position;
    $_[0]->__set_cursor_position( $col, $row - $_[1] );
}


sub __down {
    #my ( $self, $rows_down ) = @_;
    my ( $col, $row ) = $_[0]->__get_cursor_position;
    $_[0]->__set_cursor_position( $col, $row + $_[1]  );
}


sub __left {
    #my ( $self, $cols_left ) = @_;
    my ( $col, $row ) = $_[0]->__get_cursor_position;
    $_[0]->__set_cursor_position( $col - $_[1], $row );
}

sub __right {
    #my ( $self, $cols_right ) = @_;
    my ( $col, $row ) = $_[0]->__get_cursor_position;
    $_[0]->__set_cursor_position( $col + $_[1], $row );
}


sub __beep {
    my ( $self, $beep ) = @_;
    if ( $beep ) {
    }
}




1;

__END__
