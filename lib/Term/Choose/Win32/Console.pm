package # hide from PAUSE
Term::Choose::Win32::Console;

use warnings;
use strict;
use 5.008003;

our $VERSION = '1.625_03';

use parent qw( Win32::Console );


# https://rt.cpan.org/Public/Bug/Display.html?id=33513#txn-577224


*AUTOLOAD = \&Win32::Console::AUTOLOAD; # because use of inherited AUTOLOAD for non-method is no longer allowed


#========
sub new {
#========
    my($class, $param1, $param2) = @_;
    my $self = {};
    if ( defined( $param1 ) and (    $param1 == Win32::Console::constant( "STD_INPUT_HANDLE",  0 )
                                  or $param1 == Win32::Console::constant( "STD_OUTPUT_HANDLE", 0 )
                                  or $param1 == Win32::Console::constant( "STD_ERROR_HANDLE",  0 )
                                )
    ) {
        $self->{'handle'} = Win32::Console::_GetStdHandle( $param1 );
        $self->{'handle_is_std'} = 1; # from patch
    }
    else {
        $param1 = Win32::Console::constant( "GENERIC_READ"   , 0 ) | Win32::Console::constant( "GENERIC_WRITE"   , 0 ) unless $param1;
        $param2 = Win32::Console::constant( "FILE_SHARE_READ", 0 ) | Win32::Console::constant( "FILE_SHARE_WRITE", 0 ) unless $param2;
        $self->{'handle'} = Win32::Console::_CreateConsoleScreenBuffer(
                                $param1,
                                $param2,
                                Win32::Console::constant( "CONSOLE_TEXTMODE_BUFFER", 0 )
                            );
    }
    bless $self, $class;
    return $self;
}


#============
sub DESTROY {
#============
    my( $self ) = @_;
    Win32::Console::_CloseHandle($self->{'handle'}) unless $self->{'handle_is_std'}; # from patch
}



1;

__END__
