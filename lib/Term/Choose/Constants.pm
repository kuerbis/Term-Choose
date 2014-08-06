package # hide from PAUSE
Term::Choose::Constants;

use warnings;
use strict;
use 5.010001;

our $VERSION = '1.113_06';

use Exporter qw( import );

our @EXPORT_OK = qw(
        ROW COL MIN MAX
        UP RIGHT LEFT LF CR
        HIDE_CURSOR SHOW_CURSOR WIDTH_CURSOR
        MAX_ROW_MOUSE_1003 MAX_COL_MOUSE_1003
        GET_CURSOR_POSITION
        SET_ANY_EVENT_MOUSE_1003 SET_EXT_MODE_MOUSE_1005 SET_SGR_EXT_MODE_MOUSE_1006
        UNSET_ANY_EVENT_MOUSE_1003 UNSET_EXT_MODE_MOUSE_1005 UNSET_SGR_EXT_MODE_MOUSE_1006
        BEEP BOLD CLEAR_SCREEN CLEAR_TO_END_OF_SCREEN RESET REVERSE UNDERLINE
        NEXT_get_key
        CONTROL_SPACE CONTROL_A CONTROL_B CONTROL_C CONTROL_D CONTROL_E CONTROL_F CONTROL_H KEY_BTAB CONTROL_I KEY_TAB
        KEY_ENTER KEY_ESC KEY_SPACE KEY_h KEY_j KEY_k KEY_l KEY_q KEY_Tilde KEY_BSPACE
        VK_PAGE_UP VK_PAGE_DOWN VK_END VK_HOME VK_LEFT VK_UP VK_RIGHT VK_DOWN VK_INSERT VK_DELETE
        MOUSE_WHEELED
        LEFTMOST_BUTTON_PRESSED RIGHTMOST_BUTTON_PRESSED FROM_LEFT_2ND_BUTTON_PRESSED
);

our %EXPORT_TAGS = (
    choose => [ qw(
        ROW COL MIN MAX
        LF CR
        WIDTH_CURSOR
        MAX_ROW_MOUSE_1003 MAX_COL_MOUSE_1003
        GET_CURSOR_POSITION
        BEEP BOLD CLEAR_SCREEN CLEAR_TO_END_OF_SCREEN RESET REVERSE UNDERLINE
        NEXT_get_key
        CONTROL_SPACE CONTROL_A CONTROL_B CONTROL_C CONTROL_D CONTROL_E CONTROL_F CONTROL_H KEY_BTAB CONTROL_I KEY_TAB
        KEY_ENTER KEY_ESC KEY_SPACE KEY_h KEY_j KEY_k KEY_l KEY_q KEY_Tilde KEY_BSPACE
        VK_PAGE_UP VK_PAGE_DOWN VK_END VK_HOME VK_LEFT VK_UP VK_RIGHT VK_DOWN VK_INSERT VK_DELETE
    ) ],
    linux  => [ qw(
        HIDE_CURSOR SHOW_CURSOR
        GET_CURSOR_POSITION
        SET_ANY_EVENT_MOUSE_1003 SET_EXT_MODE_MOUSE_1005 SET_SGR_EXT_MODE_MOUSE_1006
        UNSET_ANY_EVENT_MOUSE_1003 UNSET_EXT_MODE_MOUSE_1005 UNSET_SGR_EXT_MODE_MOUSE_1006
        NEXT_get_key
        KEY_BTAB KEY_ESC
        VK_PAGE_UP VK_PAGE_DOWN VK_END VK_HOME VK_LEFT VK_UP VK_RIGHT VK_DOWN VK_INSERT VK_DELETE
    ) ],
    win32  => [ qw(
        NEXT_get_key
        CONTROL_SPACE
        VK_PAGE_UP VK_PAGE_DOWN VK_END VK_HOME VK_LEFT VK_UP VK_RIGHT VK_DOWN VK_INSERT VK_DELETE
        MOUSE_WHEELED
        LEFTMOST_BUTTON_PRESSED RIGHTMOST_BUTTON_PRESSED FROM_LEFT_2ND_BUTTON_PRESSED
    ) ]
);


sub ROW () { 0 }
sub COL () { 1 }
sub MIN () { 0 }
sub MAX () { 1 }

sub UP                     () { "\e[A" }
sub RIGHT                  () { "\e[C" }
sub LEFT                   () { "\e[D" }
sub LF                     () { "\n" }
sub CR                     () { "\r" }

sub BEEP                   () { "\a" }
sub CLEAR_SCREEN           () { "\e[2J\e[1;1H" }
sub CLEAR_TO_END_OF_SCREEN () { "\e[0J" }
sub RESET                  () { "\e[0m" }
sub BOLD                   () { "\e[1m" }
sub UNDERLINE              () { "\e[4m" }
sub REVERSE                () { "\e[7m" }

sub HIDE_CURSOR            () { "\e[?25l" }
sub SHOW_CURSOR            () { "\e[?25h" }
sub WIDTH_CURSOR           () { 1 }


sub GET_CURSOR_POSITION           () { "\e[6n" }

sub SET_ANY_EVENT_MOUSE_1003      () { "\e[?1003h" }
sub SET_EXT_MODE_MOUSE_1005       () { "\e[?1005h" }
sub SET_SGR_EXT_MODE_MOUSE_1006   () { "\e[?1006h" }
sub UNSET_ANY_EVENT_MOUSE_1003    () { "\e[?1003l" }
sub UNSET_EXT_MODE_MOUSE_1005     () { "\e[?1005l" }
sub UNSET_SGR_EXT_MODE_MOUSE_1006 () { "\e[?1006l" }


sub MAX_ROW_MOUSE_1003 () { 223 }
sub MAX_COL_MOUSE_1003 () { 223 }


sub MOUSE_WHEELED                () { 0x0004 }

sub LEFTMOST_BUTTON_PRESSED      () { 0x0001 }
sub RIGHTMOST_BUTTON_PRESSED     () { 0x0002 }
sub FROM_LEFT_2ND_BUTTON_PRESSED () { 0x0004 }


sub NEXT_get_key  () { -1 }

sub CONTROL_SPACE () { 0x00 }
sub CONTROL_A     () { 0x01 }
sub CONTROL_B     () { 0x02 }
sub CONTROL_C     () { 0x03 }
sub CONTROL_D     () { 0x04 }
sub CONTROL_E     () { 0x05 }
sub CONTROL_F     () { 0x06 }
sub CONTROL_H     () { 0x08 }
sub KEY_BTAB      () { 0x08 }
sub CONTROL_I     () { 0x09 }
sub KEY_TAB       () { 0x09 }
sub KEY_ENTER     () { 0x0d }
sub KEY_ESC       () { 0x1b }
sub KEY_SPACE     () { 0x20 }
sub KEY_h         () { 0x68 }
sub KEY_j         () { 0x6a }
sub KEY_k         () { 0x6b }
sub KEY_l         () { 0x6c }
sub KEY_q         () { 0x71 }
sub KEY_Tilde     () { 0x7e }
sub KEY_BSPACE    () { 0x7f }

sub VK_PAGE_UP    () { 33 }
sub VK_PAGE_DOWN  () { 34 }
sub VK_END        () { 35 }
sub VK_HOME       () { 36 }
sub VK_LEFT       () { 37 }
sub VK_UP         () { 38 }
sub VK_RIGHT      () { 39 }
sub VK_DOWN       () { 40 }
sub VK_INSERT     () { 45 } # unused
sub VK_DELETE     () { 46 } # unused



1;

__END__
