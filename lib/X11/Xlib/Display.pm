package X11::Xlib::Display;
use strict;
use warnings;
use parent 'X11::Xlib';
use Scalar::Util;
use Carp;

require X11::Xlib::Window;

# Weak-ref to every active display.  Hash key is the *binary value* of the
# Xlib Display pointer.  This is used to map from Display* to the active
# object instance.  Mostly for the error handler.
our %Displays;

sub new {
    my ($class, $connection_string)= @_;
    my $conn= X11::Xlib::XOpenDisplay(defined $connection_string? ($connection_string) : ())
        or croak "Unable to connect to X11 server";
    my $self= bless { connection => $conn }, $class;
    Scalar::Util::weaken( $Displays{$conn->_pointer_value}= $self );
    return $self;
}

sub connection { shift->{connection} }

sub RootWindow {
    my $self= shift;
    my $ret= $self->SUPER::RootWindow(@_);
    return X11::Xlib::Window->new({ dpy => $self, xid => $ret });
}

sub DESTROY {
    my $self= shift;
    X11::Xlib::XCloseDisplay($self->connection);
}

1;

=head1 METHODS

=head2 DISPLAY METHODS

=head3 $display->keyboard_leds

Return a mask value for the currently-lit keyboard LEDs.

=head3 RootWindow

Returns a L<X11::Xlib::Window> object representing the root window

=cut