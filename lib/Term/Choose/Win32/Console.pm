package # hide from PAUSE
Term::Choose::Win32::Console;

use warnings;
use strict;
use 5.008003;

our $VERSION = '1.625_01';

use parent qw( Win32::Console );


#========
sub new {
#========
    my($class, $param1, $param2) = @_;

    my $self = {};

    if (defined($param1)
    and ($param1 == constant("STD_INPUT_HANDLE",  0)
    or   $param1 == constant("STD_OUTPUT_HANDLE", 0)
    or   $param1 == constant("STD_ERROR_HANDLE",  0)))
    {
        $self->{'handle'} = _GetStdHandle($param1);
        # https://rt.cpan.org/Public/Bug/Display.html?id=33513#txn-577224 :
        $self->{'handle_is_std'} = 1;
    }
    else {
        $param1 = constant("GENERIC_READ", 0)    | constant("GENERIC_WRITE", 0) unless $param1;
        $param2 = constant("FILE_SHARE_READ", 0) | constant("FILE_SHARE_WRITE", 0) unless $param2;
        $self->{'handle'} = _CreateConsoleScreenBuffer($param1, $param2,
                                                       constant("CONSOLE_TEXTMODE_BUFFER", 0));
    }
    bless $self, $class;
    return $self;
}



#============
sub DESTROY {
#============
    my($self) = @_;
    # https://rt.cpan.org/Public/Bug/Display.html?id=33513#txn-577224 :
    #_CloseHandle($self->{'handle'});
    _CloseHandle($self->{'handle'}) unless $self->{'handle_is_std'};
}



1;

__END__
