package # hide from PAUSE
Term::Choose::Win32;

use warnings;
use strict;
use 5.010001;

our $VERSION = '1.109';

use Win32::Console       qw( STD_INPUT_HANDLE ENABLE_MOUSE_INPUT ENABLE_PROCESSED_INPUT
                             RIGHT_ALT_PRESSED LEFT_ALT_PRESSED RIGHT_CTRL_PRESSED LEFT_CTRL_PRESSED SHIFT_PRESSED );
use Win32::Console::ANSI qw( :func );

use Term::Choose::Constants qw( :win32 );


sub SHIFTED_MASK () {
      RIGHT_ALT_PRESSED
    | LEFT_ALT_PRESSED
    | RIGHT_CTRL_PRESSED
    | LEFT_CTRL_PRESSED
    | SHIFT_PRESSED
}


INIT {
    # ordinary   print "\e(U";
    # causes the 00-load test to fail
    # workaround: INIT { print "\e(U" }
    print "\e(U";
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
                return $char;
            }
        }
        else{
            if ( $ctrl_key_state & SHIFTED_MASK ) {
                return NEXT_get_key;
            }
            elsif ( $v_key_code == VK_PAGE_UP )   { return VK_PAGE_UP }
            elsif ( $v_key_code == VK_PAGE_DOWN ) { return VK_PAGE_DOWN }
            elsif ( $v_key_code == VK_END )       { return VK_END }
            elsif ( $v_key_code == VK_HOME )      { return VK_HOME }
            elsif ( $v_key_code == VK_LEFT )      { return VK_LEFT }
            elsif ( $v_key_code == VK_UP )        { return VK_UP }
            elsif ( $v_key_code == VK_RIGHT )     { return VK_RIGHT }
            elsif ( $v_key_code == VK_DOWN )      { return VK_DOWN }
            elsif ( $v_key_code == VK_INSERT )    { return VK_INSERT } # unused
            elsif ( $v_key_code == VK_DELETE )    { return VK_DELETE } # unused
            else                                  { return NEXT_get_key }
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


sub __set_mode {
    my ( $self, $mouse ) = @_;
    $self->{input} = Win32::Console->new( STD_INPUT_HANDLE );
    $self->{old_in_mode} = $self->{input}->Mode();
    $self->{input}->Mode( !ENABLE_PROCESSED_INPUT )                    if ! $mouse;
    $self->{input}->Mode( !ENABLE_PROCESSED_INPUT|ENABLE_MOUSE_INPUT ) if   $mouse;
    return $mouse;
}


sub __reset_mode {
    my ( $self, $mouse ) = @_;  # no use for $mouse on win32
    if ( defined $self->{input} ) {
        if ( defined $self->{old_in_mode} ) {
            $self->{input}->Mode( $self->{old_in_mode} );
            delete $self->{old_in_mode};
        }
        $self->{input}->Flush;
        # workaround Bug #33513:
        delete $self->{input}{handle};
        #$self->{input}{handle} = undef;
        #
    }
}


sub __get_term_size {
    my ( $self, $handle_out ) = @_;  # no use for $handle_out on win32
    my ( $term_width, $term_height ) = Win32::Console->new()->Size();
    return $term_width - 1, $term_height;
}


sub __term_cursor_position {
    my ( $self ) = @_;
    ( $self->{abs_cursor_x}, $self->{abs_cursor_y} ) = Cursor();
    #$self->{abs_cursor_x}--; # unused
    $self->{abs_cursor_y}--;
}





1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Term::Choose::Win32 - Plugin for Term::Choose.

=head1 VERSION

Version 1.109

=head1 DESCRIPTION

This module is not expected to be directly used by any module other than L<Term::Choose>.

=head1 SEE ALSO

L<Term::Choose>

=head1 AUTHORS

Matthäus Kiem <cuer2s@gmail.com>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2012-2014 Matthäus Kiem.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl 5.10.0. For
details, see the full text of the licenses in the file LICENSE.

=cut
