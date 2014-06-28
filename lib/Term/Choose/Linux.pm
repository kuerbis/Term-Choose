package # hide from PAUSE
Term::Choose::Linux;

use warnings;
use strict;
use 5.010001;

our $VERSION = '1.110';

use Term::ReadKey qw( GetTerminalSize ReadKey ReadMode );

use Term::Choose::Constants qw( :linux );



sub new {
    return bless {}, $_[0];
}


sub __get_key_OS {
    my ( $self, $mouse ) = @_;
    my $c1 = ReadKey( 0 );
    return if ! defined $c1;
    if ( $c1 eq "\e" ) {
        my $c2 = ReadKey( 0.10 );
        if ( ! defined $c2 ) { return KEY_ESC; } # unused
        elsif ( $c2 eq '[' ) {
            my $c3 = ReadKey( 0 );
               if ( $c3 eq 'A' ) { return VK_UP; }
            elsif ( $c3 eq 'B' ) { return VK_DOWN; }
            elsif ( $c3 eq 'C' ) { return VK_RIGHT; }
            elsif ( $c3 eq 'D' ) { return VK_LEFT; }
            elsif ( $c3 eq 'F' ) { return VK_END; }
            elsif ( $c3 eq 'H' ) { return VK_HOME; }
            elsif ( $c3 eq 'Z' ) { return KEY_BTAB; }
            elsif ( $c3 =~ /^[0-9]$/ ) {
                my $c4 = ReadKey( 0 );
                if ( $c4 eq '~' ) {
                       if ( $c3 eq '2' ) { return VK_INSERT; } # unused
                    elsif ( $c3 eq '3' ) { return VK_DELETE; } # unused
                    elsif ( $c3 eq '5' ) { return VK_PAGE_UP; }
                    elsif ( $c3 eq '6' ) { return VK_PAGE_DOWN; }
                    else {
                        return NEXT_get_key;
                    }
                }
                elsif ( $c4 =~ /^[;0-9]$/ ) { # response to "\e[6n"
                    my $abs_curs_y = $c3;
                    my $ry = $c4;
                    while ( $ry =~ m/^[0-9]$/ ) {
                        $abs_curs_y .= $ry;
                        $ry = ReadKey( 0 );
                    }
                    return NEXT_get_key if $ry ne ';';
                    my $abs_curs_x = '';
                    my $rx = ReadKey( 0 );
                    while ( $rx =~ m/^[0-9]$/ ) {
                        $abs_curs_x .= $rx;
                        $rx = ReadKey( 0 );
                    }
                    if ( $rx eq 'R' ) {
                        #$self->{abs_cursor_x} = $abs_curs_x; # unused
                        $self->{abs_cursor_y} = $abs_curs_y;
                    }
                    return NEXT_get_key;
                }
                else {
                    return NEXT_get_key;
                }
            }
            # http://invisible-island.net/xterm/ctlseqs/ctlseqs.html
            elsif ( $c3 eq 'M' && $mouse ) {
                my $event_type = ord( ReadKey( 0 ) ) - 32;
                my $x          = ord( ReadKey( 0 ) ) - 32;
                my $y          = ord( ReadKey( 0 ) ) - 32;
                my $button = $self->__mouse_event_to_button( $event_type );
                return NEXT_get_key if $button == NEXT_get_key;
                return [ $self->{abs_cursor_y}, $button, $x, $y ];
            }
            elsif ( $c3 eq '<' && $mouse ) {  # SGR 1006
                my $event_type = '';
                my $m1;
                while ( ( $m1 = ReadKey( 0 ) ) =~ m/^[0-9]$/ ) {
                    $event_type .= $m1;
                }
                return NEXT_get_key if $m1 ne ';';
                my $x = '';
                my $m2;
                while ( ( $m2 = ReadKey( 0 ) ) =~ m/^[0-9]$/ ) {
                    $x .= $m2;
                }
                return NEXT_get_key if $m2 ne ';';
                my $y = '';
                my $m3;
                while ( ( $m3 = ReadKey( 0 ) ) =~ m/^[0-9]$/ ) {
                    $y .= $m3;
                }
                return NEXT_get_key if $m3 !~ /^[mM]$/;
                my $button_released = $m3 eq 'm' ? 1 : 0;
                return NEXT_get_key if $button_released;
                my $button = $self->__mouse_event_to_button( $event_type );
                return NEXT_get_key if $button == NEXT_get_key;
                return [ $self->{abs_cursor_y}, $button, $x, $y ];
            }
            else {
                return NEXT_get_key;
            }
        }
        else {
            return NEXT_get_key;
        }
    }
    else {
        return ord $c1;
    }
};


sub __mouse_event_to_button {
    my ( $self, $event_type ) = @_;
    my $button_drag = ( $event_type & 0x20 ) >> 5;
    return NEXT_get_key if $button_drag;
    my $button;
    my $low_2_bits = $event_type & 0x03;
    if ( $low_2_bits == 3 ) {
        $button = 0;
    }
    else {
        if ( $event_type & 0x40 ) {
            $button = $low_2_bits + 4; # 4,5
        }
        else {
            $button = $low_2_bits + 1; # 1,2,3
        }
    }
    return $button;
}


sub __set_mode {
    my ( $self, $mouse ) = @_;
    if ( $mouse ) {
        if ( $mouse == 3 ) {
            my $return = binmode STDIN, ':utf8';
            if ( $return ) {
                print SET_ANY_EVENT_MOUSE_1003;
                print SET_EXT_MODE_MOUSE_1005;
            }
            else {
                $mouse = 0;
                warn "binmode STDIN, :utf8: $!\n";
                warn "mouse-mode disabled\n";
            }
        }
        elsif ( $mouse == 4 ) {
            my $return = binmode STDIN, ':raw';
            if ( $return ) {
                print SET_ANY_EVENT_MOUSE_1003;
                print SET_SGR_EXT_MODE_MOUSE_1006;
            }
            else {
                $mouse = 0;
                warn "binmode STDIN, :raw: $!\n";
                warn "mouse-mode disabled\n";
            }
        }
        else {
            my $return = binmode STDIN, ':raw';
            if ( $return ) {
                print SET_ANY_EVENT_MOUSE_1003;
            }
            else {
                $mouse = 0;
                warn "binmode STDIN, :raw: $!\n";
                warn "mouse-mode disabled\n";
            }
        }
    }
    Term::ReadKey::ReadMode( 'ultra-raw' );
    return $mouse;
};


sub __reset_mode {
    my ( $self, $mouse ) = @_;
    if ( $mouse ) {
        binmode STDIN, ':encoding(UTF-8)' or warn "binmode STDIN, :encoding(UTF-8): $!\n";
        print UNSET_EXT_MODE_MOUSE_1005     if $mouse == 3;
        print UNSET_SGR_EXT_MODE_MOUSE_1006 if $mouse == 4;
        print UNSET_ANY_EVENT_MOUSE_1003;
    }
    Term::ReadKey::ReadMode( 'restore' );
}


sub __get_term_size {
    my ( $self, $handle_out ) = @_;
    return( ( GetTerminalSize( $handle_out ) )[ 0, 1 ] );
}


sub __term_cursor_position {
    my ( $self ) = @_;
    #$self->{abs_cursor_x} = 0; # unused
    $self->{abs_cursor_y} = 0;
    print GET_CURSOR_POSITION;
}





1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Term::Choose::Linux - Plugin for Term::Choose.

=head1 VERSION

Version 1.110

=head1 SYNOPSIS

Internal use only.

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
