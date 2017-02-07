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
our %_displays;

=head1 ATTRIBUTES

=head2 connection

Instance of L</X11::Xlib> which acts as the C<Display *> parameter to all
X11 function calls.

=head2 on_error_cb

  $display->on_error_cb(sub {
    my ($display, $event)= @_;
    if ($event) {
      # inspect $event (instance of XEvent) and handle/log as appropriate
    } else {
      # Fatal Xlib error, perform cleanup and prepare for program exit
    }
  });

Optional callback to handle error conditions in the X11 protocol, or fatal
Xlib errors.  If the C<$event> argument is not null, it was a protocol error
and you can recover.  If it was an Xlib error the program must terminate.

Note that this callback is called from XS context, so your exceptions will
not travel up the stack.  Also note that on Xlib fatal errors, you cannot
call any more Xlib functions on the current connection, or on any connection
once the callback returns.

=cut

sub connection { shift->{connection} }
sub on_error_cb { $_[0]{on_error_cb}= $_[1] if @_ > 1; $_[0]{on_error_cb} }

=head1 METHODS

=head2 new

  my $display= X11::Xlib::Display->new(); # uses $ENV{DISPLAY}
  my $display= X11::Xlib::Display->new( $connect_string );
  my $display= X11::Xlib::Display->new( $conn );
  my $display= X11::Xlib::Display->new( \%attributes );

Construct a new Display, either from an existing X11::Xlib connection
instance, or from a connection string by establishing a new connection.

If you pass a single argument, it is understood to be the L</connection>
attribute.  If you do not pass a connection attribute it is given to
XOpenDisplay as NULL, which then uses C<$ENV{DISPLAY}>.

If you pass a connection instance and a Display object already exists for
it, you will get back the previous object and all other attributes you
supplied are ignored.  You also get a warning.

If you pass a connection string and the call to XOpenDisplay fails, this
constructor dies.

=cut

sub new {
    my $class= shift;
    my $args= @_ == 1 && ref($_[0]) eq 'HASH'? { %{$_[0]} }
        : @_ == 1? { connection => $_[0] }
        : (1 & @_) == 0? { @_ }
        : croak "Expected hashref, single connection scalar, or even-length list";
    my $self;
    my $conn= $args->{connection};
    if ($conn && ref $conn && ref($conn)->isa('X11::Xlib')) {
        # Check if object already exists for this connection
        if (defined ($self= $_displays{$conn->_pointer_value})) {
            carp "re-using existing Display object for this connection";
            return $self;
        }
    }
    else {
        $args->{connection}= X11::Xlib::XOpenDisplay(defined $conn? ($conn) : ())
            or croak "Unable to connect to X11 server";
    }
    $self= bless $args, $class;
    Scalar::Util::weaken( $_displays{$self->{connection}->_pointer_value}= $self );
    return $self;
}

sub RootWindow {
    my $self= shift;
    my $ret= $self->SUPER::RootWindow(@_);
    return X11::Xlib::Window->new({ dpy => $self, xid => $ret });
}

sub DESTROY {
    my $self= shift;
    $self->XCloseDisplay;
}

1;

=head1 METHODS

=head2 DISPLAY METHODS

=head3 $display->keyboard_leds

Return a mask value for the currently-lit keyboard LEDs.

=head3 RootWindow

Returns a L<X11::Xlib::Window> object representing the root window

=cut