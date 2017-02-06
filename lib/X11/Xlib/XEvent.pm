package X11::Xlib::XEvent;
use strict;
use warnings;
use Carp;
use X11::Xlib; # need constants loaded

=head1 DESCRiPTION

This object wraps an XEvent.  XEvent is a union of many different C structs,
though they all share a few common fields.  The storage space of an XEvent is
constant regardless of type, and so this class is backed by a simple scalar
ref.

The active struct of the union is determined by the L</type> field.  This object
heirarchy attempts to help you make correct usage of the union with respect to
the current C<type>, so as you change the value of C<type> the object will
automatically re-bless itself into the appropriate subclass, giving you access
to new struct fields.

Most of the "magic" occurs from Perl code, not XS, so it is possible to define
new event types if this module lacks any in your local copy of Xlib.  You can
also access the L</buffer> directly any time you want.  And, you don't even have
to use this object at all; any scalar or scalarref of the correct length can be
passed to the L<X11::Xlib> methods that expect an XEvent pointer.

=head1 METHODS

=head2 new

  my $xevent= X11::Xlib::XEvent->new();
  # or:                        ->new( %fields );
  # or:                        ->new( \%fields );

You can construct XEvent as an empty buffer, or initialize it with a hash or
hashref of fields.  Initialization is performed via L</pack>.  Un-set fields
are initialized to zero, and the L</buffer> is always padded to the length
of an XEvent.

=cut

sub new {
    my $class= shift;
    my $blank_scalar;
    my $self= bless \$blank_scalar, $class;
    if (@_) {
        $self->pack(@_); # If arguments, then initialize using pack.
    } else {
        $self->_get_type; # Inflate buffer by calling any XS method.
    }
    $self;
}

=head2 buffer

Direct access to the bytes of the XEvent.

=cut

sub buffer {
    ${$_[0]};
}

=head2 pack

  $xevent->pack( %fields );
  $xevent->pack( \%fields );

Wipe the contents of the current xevent and replace with the specified values.
If the L</type> changes as a result, then the XEvent will get re-blessed to
the appropriate type.

This method warns about unused arguments, but not missing arguments.
(any missing arguments get a zero value from the initial C<memset>.)

=cut

sub pack {
    my $self= shift;
    croak "Expected hashref or even-length list"
        unless 1 == @_ && ref($_[0]) eq 'HASH' or !(1 & @_);
    my %args= @_ == 1? %{ shift() } : @_;

    my $type= $args{type};
    if (defined $type && !Scalar::Util::looks_like_number($type)) {
        # Convert type name to type value
        croak "Unknown XEvent type '$type'" unless X11::Xlib->can($type);
        $args{type}= X11::Xlib->$type();
    }

    $self->_pack(\%args);

    # Update class to match Type, if known.
    my $pkg= $X11::Xlib::XEvent::_type_to_class{$self->_get_type || 0} || __PACKAGE__;
    bless $self, $pkg;

    # Warn about any unused arguments
    my @unused= grep { !$self->can($_) } keys %args;
    carp "Un-used parameters passed to new: ".join(',', @unused)
        if @unused;

    return $self;
}

=head2 unpack

  my $field_hash= $xevent->unpack;

Unpack the fields of an XEvent into a hashref.  Fields that reference objects
like Window IDs or Display handles will get inflated as appropriate.

=cut

sub unpack {
    my $self= shift;
    $self->_unpack(my $ret= {});
    if (my $d= $ret->{display}) {
        # Check to see if a X11::Xlib::Display object was created for it,
        #  and if so return that object instead.
        $d= $X11::Xlib::Display::Displays{$d->_pointer_value};
        $ret->{display}= $d if defined $d;
    }
    # TODO: same for window objects
    $ret;
}

=head1 ATTRIBUTES

All attributes of XEvent are divided into C<get_NAME()> and C<set_NAME($val)>
methods, but then we also provide a typical C<NAME(...)> accessor that acts as
both getter and setter depending on whether you pass an argument.

This design allows easy subclassing of get or set behavior without trying to
handle both in the same method.

=head2 Common Attributes

All XEvent subclasses have the following attributes:

=head3 type

This is the key attribute that determines all the rest.  Setting this value
will re-bless the object to the relevant sub-class.  If the type is unknown,
it becomes C<X11::Xlib::XEvent>.

=cut

sub set_type {
    my ($self, $type)= @_;
    my $ret= $self->_set_type($type);
    
    # If the type is known, then re-bless to that class.  Else re-bless to XEvent
    my $pkg= $X11::Xlib::XEvent::_type_to_class{$type} || __PACKAGE__;
    bless $self, $pkg;
    $ret;
}

=head3 display

The handle to the X11 connection that this message came from.

=cut

sub get_display {
    my $self= shift;
    # First, get the display handle from XS, which is an instance of X11::Xlib
    defined( my $d= $self->_get_display ) or return undef;
    # Then, check to see if a X11::Xlib::Display object was created for it,
    #  and if so return that object instead.
    return $X11::Xlib::Display::Displays{$d->_pointer_value} || $d;
}

=head3 serial

The X11 serial number

=cut

=head3 window

The Window/XID the message is associated with, or undef/0.  If the XEvent is
associated with a L<X11::Xlib::Display> object, you get a <X11::Xlib::Window>
object, else you just get an integer of the XID.  Use L</window_xid> to avoid
the magic object inflation.

=head3 window_xid

The raw integer XID of the window this event is associated with.

=cut

sub window_xid {
    shift->_window;
}

=head3 send_event

Boolean indicating whether the event was sent with XSendEvent

=head1 SEE ALSO

For information about the rest of these structures, consult the
L<official documentation|https://www.x.org/releases/X11R7.7/doc/libX11/libX11/libX11.html>

=head1 SUBCLASS ATTRIBUTES

=cut

# ----------------------------------------------------------------------------
# The code below is auto-generated.  To make overrides, simply define the
# _get.. or _set.. methods before the code below, or rearrange the data or
# symbol table at the bottom of this file.
#
# BEGIN GENERATED X11_Xlib_XEvent


*get_display= *_get_display unless defined *get_display{CODE};
*set_display= *_set_display unless defined *set_display{CODE};
sub display { $_[0]->set_display($_[1]) if @_ > 1; $_[0]->get_display() }

*get_send_event= *_get_send_event unless defined *get_send_event{CODE};
*set_send_event= *_set_send_event unless defined *set_send_event{CODE};
sub send_event { $_[0]->set_send_event($_[1]) if @_ > 1; $_[0]->get_send_event() }

*get_serial= *_get_serial unless defined *get_serial{CODE};
*set_serial= *_set_serial unless defined *set_serial{CODE};
sub serial { $_[0]->set_serial($_[1]) if @_ > 1; $_[0]->get_serial() }

*get_type= *_get_type unless defined *get_type{CODE};
*set_type= *_set_type unless defined *set_type{CODE};
sub type { $_[0]->set_type($_[1]) if @_ > 1; $_[0]->get_type() }

*get_window= *_get_window unless defined *get_window{CODE};
*set_window= *_set_window unless defined *set_window{CODE};
sub window { $_[0]->set_window($_[1]) if @_ > 1; $_[0]->get_window() }
our %_type_to_class= (
  X11::Xlib::ButtonPress() => "X11::Xlib::XEvent::XButtonEvent",
  X11::Xlib::ButtonRelease() => "X11::Xlib::XEvent::XButtonEvent",
  X11::Xlib::CirculateNotify() => "X11::Xlib::XEvent::XCirculateEvent",
  X11::Xlib::ClientMessage() => "X11::Xlib::XEvent::XClientMessageEvent",
  X11::Xlib::ColormapNotify() => "X11::Xlib::XEvent::XColormapEvent",
  X11::Xlib::ConfigureNotify() => "X11::Xlib::XEvent::XConfigureEvent",
  X11::Xlib::CreateNotify() => "X11::Xlib::XEvent::XCreateWindowEvent",
  X11::Xlib::EnterNotify() => "X11::Xlib::XEvent::XCrossingEvent",
  X11::Xlib::LeaveNotify() => "X11::Xlib::XEvent::XCrossingEvent",
  X11::Xlib::DestroyNotify() => "X11::Xlib::XEvent::XDestroyWindowEvent",
  X11::Xlib::Expose() => "X11::Xlib::XEvent::XExposeEvent",
  X11::Xlib::FocusIn() => "X11::Xlib::XEvent::XFocusChangeEvent",
  X11::Xlib::FocusOut() => "X11::Xlib::XEvent::XFocusChangeEvent",
  X11::Xlib::GraphicsExpose() => "X11::Xlib::XEvent::XGraphicsExposeEvent",
  X11::Xlib::GravityNotify() => "X11::Xlib::XEvent::XGravityEvent",
  X11::Xlib::KeyPress() => "X11::Xlib::XEvent::XKeyEvent",
  X11::Xlib::KeyRelease() => "X11::Xlib::XEvent::XKeyEvent",
  X11::Xlib::KeymapNotify() => "X11::Xlib::XEvent::XKeymapEvent",
  X11::Xlib::MapNotify() => "X11::Xlib::XEvent::XMapEvent",
  X11::Xlib::MappingNotify() => "X11::Xlib::XEvent::XMappingEvent",
  X11::Xlib::MotionNotify() => "X11::Xlib::XEvent::XMotionEvent",
  X11::Xlib::NoExpose() => "X11::Xlib::XEvent::XNoExposeEvent",
  X11::Xlib::PropertyNotify() => "X11::Xlib::XEvent::XPropertyEvent",
  X11::Xlib::ReparentNotify() => "X11::Xlib::XEvent::XReparentEvent",
  X11::Xlib::ResizeRequest() => "X11::Xlib::XEvent::XResizeRequestEvent",
  X11::Xlib::SelectionClear() => "X11::Xlib::XEvent::XSelectionClearEvent",
  X11::Xlib::SelectionNotify() => "X11::Xlib::XEvent::XSelectionEvent",
  X11::Xlib::SelectionRequest() => "X11::Xlib::XEvent::XSelectionRequestEvent",
  X11::Xlib::UnmapNotify() => "X11::Xlib::XEvent::XUnmapEvent",
  X11::Xlib::VisibilityNotify() => "X11::Xlib::XEvent::XVisibilityEvent",
);

package X11::Xlib::XEvent::XButtonEvent;
@X11::Xlib::XEvent::XButtonEvent::ISA= ('X11::Xlib::XEvent');
*get_button= *X11::Xlib::XEvent::_get_button unless defined *get_button{CODE};
*set_button= *X11::Xlib::XEvent::_set_button unless defined *set_button{CODE};
sub button { $_[0]->set_button($_[1]) if @_ > 1; $_[0]->get_button() }
*get_root= *X11::Xlib::XEvent::_get_root unless defined *get_root{CODE};
*set_root= *X11::Xlib::XEvent::_set_root unless defined *set_root{CODE};
sub root { $_[0]->set_root($_[1]) if @_ > 1; $_[0]->get_root() }
*get_same_screen= *X11::Xlib::XEvent::_get_same_screen unless defined *get_same_screen{CODE};
*set_same_screen= *X11::Xlib::XEvent::_set_same_screen unless defined *set_same_screen{CODE};
sub same_screen { $_[0]->set_same_screen($_[1]) if @_ > 1; $_[0]->get_same_screen() }
*get_state= *X11::Xlib::XEvent::_get_state unless defined *get_state{CODE};
*set_state= *X11::Xlib::XEvent::_set_state unless defined *set_state{CODE};
sub state { $_[0]->set_state($_[1]) if @_ > 1; $_[0]->get_state() }
*get_subwindow= *X11::Xlib::XEvent::_get_subwindow unless defined *get_subwindow{CODE};
*set_subwindow= *X11::Xlib::XEvent::_set_subwindow unless defined *set_subwindow{CODE};
sub subwindow { $_[0]->set_subwindow($_[1]) if @_ > 1; $_[0]->get_subwindow() }
*get_time= *X11::Xlib::XEvent::_get_time unless defined *get_time{CODE};
*set_time= *X11::Xlib::XEvent::_set_time unless defined *set_time{CODE};
sub time { $_[0]->set_time($_[1]) if @_ > 1; $_[0]->get_time() }
*get_x= *X11::Xlib::XEvent::_get_x unless defined *get_x{CODE};
*set_x= *X11::Xlib::XEvent::_set_x unless defined *set_x{CODE};
sub x { $_[0]->set_x($_[1]) if @_ > 1; $_[0]->get_x() }
*get_x_root= *X11::Xlib::XEvent::_get_x_root unless defined *get_x_root{CODE};
*set_x_root= *X11::Xlib::XEvent::_set_x_root unless defined *set_x_root{CODE};
sub x_root { $_[0]->set_x_root($_[1]) if @_ > 1; $_[0]->get_x_root() }
*get_y= *X11::Xlib::XEvent::_get_y unless defined *get_y{CODE};
*set_y= *X11::Xlib::XEvent::_set_y unless defined *set_y{CODE};
sub y { $_[0]->set_y($_[1]) if @_ > 1; $_[0]->get_y() }
*get_y_root= *X11::Xlib::XEvent::_get_y_root unless defined *get_y_root{CODE};
*set_y_root= *X11::Xlib::XEvent::_set_y_root unless defined *set_y_root{CODE};
sub y_root { $_[0]->set_y_root($_[1]) if @_ > 1; $_[0]->get_y_root() }

package X11::Xlib::XEvent::XCirculateEvent;
@X11::Xlib::XEvent::XCirculateEvent::ISA= ('X11::Xlib::XEvent');
*get_event= *X11::Xlib::XEvent::_get_event unless defined *get_event{CODE};
*set_event= *X11::Xlib::XEvent::_set_event unless defined *set_event{CODE};
sub event { $_[0]->set_event($_[1]) if @_ > 1; $_[0]->get_event() }
*get_place= *X11::Xlib::XEvent::_get_place unless defined *get_place{CODE};
*set_place= *X11::Xlib::XEvent::_set_place unless defined *set_place{CODE};
sub place { $_[0]->set_place($_[1]) if @_ > 1; $_[0]->get_place() }

package X11::Xlib::XEvent::XClientMessageEvent;
@X11::Xlib::XEvent::XClientMessageEvent::ISA= ('X11::Xlib::XEvent');
*get_b= *X11::Xlib::XEvent::_get_b unless defined *get_b{CODE};
*set_b= *X11::Xlib::XEvent::_set_b unless defined *set_b{CODE};
sub b { $_[0]->set_b($_[1]) if @_ > 1; $_[0]->get_b() }
*get_l= *X11::Xlib::XEvent::_get_l unless defined *get_l{CODE};
*set_l= *X11::Xlib::XEvent::_set_l unless defined *set_l{CODE};
sub l { $_[0]->set_l($_[1]) if @_ > 1; $_[0]->get_l() }
*get_s= *X11::Xlib::XEvent::_get_s unless defined *get_s{CODE};
*set_s= *X11::Xlib::XEvent::_set_s unless defined *set_s{CODE};
sub s { $_[0]->set_s($_[1]) if @_ > 1; $_[0]->get_s() }
*get_format= *X11::Xlib::XEvent::_get_format unless defined *get_format{CODE};
*set_format= *X11::Xlib::XEvent::_set_format unless defined *set_format{CODE};
sub format { $_[0]->set_format($_[1]) if @_ > 1; $_[0]->get_format() }
*get_message_type= *X11::Xlib::XEvent::_get_message_type unless defined *get_message_type{CODE};
*set_message_type= *X11::Xlib::XEvent::_set_message_type unless defined *set_message_type{CODE};
sub message_type { $_[0]->set_message_type($_[1]) if @_ > 1; $_[0]->get_message_type() }

package X11::Xlib::XEvent::XColormapEvent;
@X11::Xlib::XEvent::XColormapEvent::ISA= ('X11::Xlib::XEvent');
*get_colormap= *X11::Xlib::XEvent::_get_colormap unless defined *get_colormap{CODE};
*set_colormap= *X11::Xlib::XEvent::_set_colormap unless defined *set_colormap{CODE};
sub colormap { $_[0]->set_colormap($_[1]) if @_ > 1; $_[0]->get_colormap() }
*get_new= *X11::Xlib::XEvent::_get_new unless defined *get_new{CODE};
*set_new= *X11::Xlib::XEvent::_set_new unless defined *set_new{CODE};
sub new { $_[0]->set_new($_[1]) if @_ > 1; $_[0]->get_new() }
*get_state= *X11::Xlib::XEvent::_get_state unless defined *get_state{CODE};
*set_state= *X11::Xlib::XEvent::_set_state unless defined *set_state{CODE};
sub state { $_[0]->set_state($_[1]) if @_ > 1; $_[0]->get_state() }

package X11::Xlib::XEvent::XConfigureEvent;
@X11::Xlib::XEvent::XConfigureEvent::ISA= ('X11::Xlib::XEvent');
*get_above= *X11::Xlib::XEvent::_get_above unless defined *get_above{CODE};
*set_above= *X11::Xlib::XEvent::_set_above unless defined *set_above{CODE};
sub above { $_[0]->set_above($_[1]) if @_ > 1; $_[0]->get_above() }
*get_border_width= *X11::Xlib::XEvent::_get_border_width unless defined *get_border_width{CODE};
*set_border_width= *X11::Xlib::XEvent::_set_border_width unless defined *set_border_width{CODE};
sub border_width { $_[0]->set_border_width($_[1]) if @_ > 1; $_[0]->get_border_width() }
*get_event= *X11::Xlib::XEvent::_get_event unless defined *get_event{CODE};
*set_event= *X11::Xlib::XEvent::_set_event unless defined *set_event{CODE};
sub event { $_[0]->set_event($_[1]) if @_ > 1; $_[0]->get_event() }
*get_height= *X11::Xlib::XEvent::_get_height unless defined *get_height{CODE};
*set_height= *X11::Xlib::XEvent::_set_height unless defined *set_height{CODE};
sub height { $_[0]->set_height($_[1]) if @_ > 1; $_[0]->get_height() }
*get_override_redirect= *X11::Xlib::XEvent::_get_override_redirect unless defined *get_override_redirect{CODE};
*set_override_redirect= *X11::Xlib::XEvent::_set_override_redirect unless defined *set_override_redirect{CODE};
sub override_redirect { $_[0]->set_override_redirect($_[1]) if @_ > 1; $_[0]->get_override_redirect() }
*get_width= *X11::Xlib::XEvent::_get_width unless defined *get_width{CODE};
*set_width= *X11::Xlib::XEvent::_set_width unless defined *set_width{CODE};
sub width { $_[0]->set_width($_[1]) if @_ > 1; $_[0]->get_width() }
*get_x= *X11::Xlib::XEvent::_get_x unless defined *get_x{CODE};
*set_x= *X11::Xlib::XEvent::_set_x unless defined *set_x{CODE};
sub x { $_[0]->set_x($_[1]) if @_ > 1; $_[0]->get_x() }
*get_y= *X11::Xlib::XEvent::_get_y unless defined *get_y{CODE};
*set_y= *X11::Xlib::XEvent::_set_y unless defined *set_y{CODE};
sub y { $_[0]->set_y($_[1]) if @_ > 1; $_[0]->get_y() }

package X11::Xlib::XEvent::XCreateWindowEvent;
@X11::Xlib::XEvent::XCreateWindowEvent::ISA= ('X11::Xlib::XEvent');
*get_border_width= *X11::Xlib::XEvent::_get_border_width unless defined *get_border_width{CODE};
*set_border_width= *X11::Xlib::XEvent::_set_border_width unless defined *set_border_width{CODE};
sub border_width { $_[0]->set_border_width($_[1]) if @_ > 1; $_[0]->get_border_width() }
*get_height= *X11::Xlib::XEvent::_get_height unless defined *get_height{CODE};
*set_height= *X11::Xlib::XEvent::_set_height unless defined *set_height{CODE};
sub height { $_[0]->set_height($_[1]) if @_ > 1; $_[0]->get_height() }
*get_override_redirect= *X11::Xlib::XEvent::_get_override_redirect unless defined *get_override_redirect{CODE};
*set_override_redirect= *X11::Xlib::XEvent::_set_override_redirect unless defined *set_override_redirect{CODE};
sub override_redirect { $_[0]->set_override_redirect($_[1]) if @_ > 1; $_[0]->get_override_redirect() }
*get_parent= *X11::Xlib::XEvent::_get_parent unless defined *get_parent{CODE};
*set_parent= *X11::Xlib::XEvent::_set_parent unless defined *set_parent{CODE};
sub parent { $_[0]->set_parent($_[1]) if @_ > 1; $_[0]->get_parent() }
*get_width= *X11::Xlib::XEvent::_get_width unless defined *get_width{CODE};
*set_width= *X11::Xlib::XEvent::_set_width unless defined *set_width{CODE};
sub width { $_[0]->set_width($_[1]) if @_ > 1; $_[0]->get_width() }
*get_x= *X11::Xlib::XEvent::_get_x unless defined *get_x{CODE};
*set_x= *X11::Xlib::XEvent::_set_x unless defined *set_x{CODE};
sub x { $_[0]->set_x($_[1]) if @_ > 1; $_[0]->get_x() }
*get_y= *X11::Xlib::XEvent::_get_y unless defined *get_y{CODE};
*set_y= *X11::Xlib::XEvent::_set_y unless defined *set_y{CODE};
sub y { $_[0]->set_y($_[1]) if @_ > 1; $_[0]->get_y() }

package X11::Xlib::XEvent::XCrossingEvent;
@X11::Xlib::XEvent::XCrossingEvent::ISA= ('X11::Xlib::XEvent');
*get_detail= *X11::Xlib::XEvent::_get_detail unless defined *get_detail{CODE};
*set_detail= *X11::Xlib::XEvent::_set_detail unless defined *set_detail{CODE};
sub detail { $_[0]->set_detail($_[1]) if @_ > 1; $_[0]->get_detail() }
*get_focus= *X11::Xlib::XEvent::_get_focus unless defined *get_focus{CODE};
*set_focus= *X11::Xlib::XEvent::_set_focus unless defined *set_focus{CODE};
sub focus { $_[0]->set_focus($_[1]) if @_ > 1; $_[0]->get_focus() }
*get_mode= *X11::Xlib::XEvent::_get_mode unless defined *get_mode{CODE};
*set_mode= *X11::Xlib::XEvent::_set_mode unless defined *set_mode{CODE};
sub mode { $_[0]->set_mode($_[1]) if @_ > 1; $_[0]->get_mode() }
*get_root= *X11::Xlib::XEvent::_get_root unless defined *get_root{CODE};
*set_root= *X11::Xlib::XEvent::_set_root unless defined *set_root{CODE};
sub root { $_[0]->set_root($_[1]) if @_ > 1; $_[0]->get_root() }
*get_same_screen= *X11::Xlib::XEvent::_get_same_screen unless defined *get_same_screen{CODE};
*set_same_screen= *X11::Xlib::XEvent::_set_same_screen unless defined *set_same_screen{CODE};
sub same_screen { $_[0]->set_same_screen($_[1]) if @_ > 1; $_[0]->get_same_screen() }
*get_state= *X11::Xlib::XEvent::_get_state unless defined *get_state{CODE};
*set_state= *X11::Xlib::XEvent::_set_state unless defined *set_state{CODE};
sub state { $_[0]->set_state($_[1]) if @_ > 1; $_[0]->get_state() }
*get_subwindow= *X11::Xlib::XEvent::_get_subwindow unless defined *get_subwindow{CODE};
*set_subwindow= *X11::Xlib::XEvent::_set_subwindow unless defined *set_subwindow{CODE};
sub subwindow { $_[0]->set_subwindow($_[1]) if @_ > 1; $_[0]->get_subwindow() }
*get_time= *X11::Xlib::XEvent::_get_time unless defined *get_time{CODE};
*set_time= *X11::Xlib::XEvent::_set_time unless defined *set_time{CODE};
sub time { $_[0]->set_time($_[1]) if @_ > 1; $_[0]->get_time() }
*get_x= *X11::Xlib::XEvent::_get_x unless defined *get_x{CODE};
*set_x= *X11::Xlib::XEvent::_set_x unless defined *set_x{CODE};
sub x { $_[0]->set_x($_[1]) if @_ > 1; $_[0]->get_x() }
*get_x_root= *X11::Xlib::XEvent::_get_x_root unless defined *get_x_root{CODE};
*set_x_root= *X11::Xlib::XEvent::_set_x_root unless defined *set_x_root{CODE};
sub x_root { $_[0]->set_x_root($_[1]) if @_ > 1; $_[0]->get_x_root() }
*get_y= *X11::Xlib::XEvent::_get_y unless defined *get_y{CODE};
*set_y= *X11::Xlib::XEvent::_set_y unless defined *set_y{CODE};
sub y { $_[0]->set_y($_[1]) if @_ > 1; $_[0]->get_y() }
*get_y_root= *X11::Xlib::XEvent::_get_y_root unless defined *get_y_root{CODE};
*set_y_root= *X11::Xlib::XEvent::_set_y_root unless defined *set_y_root{CODE};
sub y_root { $_[0]->set_y_root($_[1]) if @_ > 1; $_[0]->get_y_root() }

package X11::Xlib::XEvent::XDestroyWindowEvent;
@X11::Xlib::XEvent::XDestroyWindowEvent::ISA= ('X11::Xlib::XEvent');
*get_event= *X11::Xlib::XEvent::_get_event unless defined *get_event{CODE};
*set_event= *X11::Xlib::XEvent::_set_event unless defined *set_event{CODE};
sub event { $_[0]->set_event($_[1]) if @_ > 1; $_[0]->get_event() }

package X11::Xlib::XEvent::XExposeEvent;
@X11::Xlib::XEvent::XExposeEvent::ISA= ('X11::Xlib::XEvent');
*get_count= *X11::Xlib::XEvent::_get_count unless defined *get_count{CODE};
*set_count= *X11::Xlib::XEvent::_set_count unless defined *set_count{CODE};
sub count { $_[0]->set_count($_[1]) if @_ > 1; $_[0]->get_count() }
*get_height= *X11::Xlib::XEvent::_get_height unless defined *get_height{CODE};
*set_height= *X11::Xlib::XEvent::_set_height unless defined *set_height{CODE};
sub height { $_[0]->set_height($_[1]) if @_ > 1; $_[0]->get_height() }
*get_width= *X11::Xlib::XEvent::_get_width unless defined *get_width{CODE};
*set_width= *X11::Xlib::XEvent::_set_width unless defined *set_width{CODE};
sub width { $_[0]->set_width($_[1]) if @_ > 1; $_[0]->get_width() }
*get_x= *X11::Xlib::XEvent::_get_x unless defined *get_x{CODE};
*set_x= *X11::Xlib::XEvent::_set_x unless defined *set_x{CODE};
sub x { $_[0]->set_x($_[1]) if @_ > 1; $_[0]->get_x() }
*get_y= *X11::Xlib::XEvent::_get_y unless defined *get_y{CODE};
*set_y= *X11::Xlib::XEvent::_set_y unless defined *set_y{CODE};
sub y { $_[0]->set_y($_[1]) if @_ > 1; $_[0]->get_y() }

package X11::Xlib::XEvent::XFocusChangeEvent;
@X11::Xlib::XEvent::XFocusChangeEvent::ISA= ('X11::Xlib::XEvent');
*get_detail= *X11::Xlib::XEvent::_get_detail unless defined *get_detail{CODE};
*set_detail= *X11::Xlib::XEvent::_set_detail unless defined *set_detail{CODE};
sub detail { $_[0]->set_detail($_[1]) if @_ > 1; $_[0]->get_detail() }
*get_mode= *X11::Xlib::XEvent::_get_mode unless defined *get_mode{CODE};
*set_mode= *X11::Xlib::XEvent::_set_mode unless defined *set_mode{CODE};
sub mode { $_[0]->set_mode($_[1]) if @_ > 1; $_[0]->get_mode() }

package X11::Xlib::XEvent::XGraphicsExposeEvent;
@X11::Xlib::XEvent::XGraphicsExposeEvent::ISA= ('X11::Xlib::XEvent');
*get_count= *X11::Xlib::XEvent::_get_count unless defined *get_count{CODE};
*set_count= *X11::Xlib::XEvent::_set_count unless defined *set_count{CODE};
sub count { $_[0]->set_count($_[1]) if @_ > 1; $_[0]->get_count() }
*get_drawable= *X11::Xlib::XEvent::_get_drawable unless defined *get_drawable{CODE};
*set_drawable= *X11::Xlib::XEvent::_set_drawable unless defined *set_drawable{CODE};
sub drawable { $_[0]->set_drawable($_[1]) if @_ > 1; $_[0]->get_drawable() }
*get_height= *X11::Xlib::XEvent::_get_height unless defined *get_height{CODE};
*set_height= *X11::Xlib::XEvent::_set_height unless defined *set_height{CODE};
sub height { $_[0]->set_height($_[1]) if @_ > 1; $_[0]->get_height() }
*get_major_code= *X11::Xlib::XEvent::_get_major_code unless defined *get_major_code{CODE};
*set_major_code= *X11::Xlib::XEvent::_set_major_code unless defined *set_major_code{CODE};
sub major_code { $_[0]->set_major_code($_[1]) if @_ > 1; $_[0]->get_major_code() }
*get_minor_code= *X11::Xlib::XEvent::_get_minor_code unless defined *get_minor_code{CODE};
*set_minor_code= *X11::Xlib::XEvent::_set_minor_code unless defined *set_minor_code{CODE};
sub minor_code { $_[0]->set_minor_code($_[1]) if @_ > 1; $_[0]->get_minor_code() }
*get_width= *X11::Xlib::XEvent::_get_width unless defined *get_width{CODE};
*set_width= *X11::Xlib::XEvent::_set_width unless defined *set_width{CODE};
sub width { $_[0]->set_width($_[1]) if @_ > 1; $_[0]->get_width() }
*get_x= *X11::Xlib::XEvent::_get_x unless defined *get_x{CODE};
*set_x= *X11::Xlib::XEvent::_set_x unless defined *set_x{CODE};
sub x { $_[0]->set_x($_[1]) if @_ > 1; $_[0]->get_x() }
*get_y= *X11::Xlib::XEvent::_get_y unless defined *get_y{CODE};
*set_y= *X11::Xlib::XEvent::_set_y unless defined *set_y{CODE};
sub y { $_[0]->set_y($_[1]) if @_ > 1; $_[0]->get_y() }

package X11::Xlib::XEvent::XGravityEvent;
@X11::Xlib::XEvent::XGravityEvent::ISA= ('X11::Xlib::XEvent');
*get_event= *X11::Xlib::XEvent::_get_event unless defined *get_event{CODE};
*set_event= *X11::Xlib::XEvent::_set_event unless defined *set_event{CODE};
sub event { $_[0]->set_event($_[1]) if @_ > 1; $_[0]->get_event() }
*get_x= *X11::Xlib::XEvent::_get_x unless defined *get_x{CODE};
*set_x= *X11::Xlib::XEvent::_set_x unless defined *set_x{CODE};
sub x { $_[0]->set_x($_[1]) if @_ > 1; $_[0]->get_x() }
*get_y= *X11::Xlib::XEvent::_get_y unless defined *get_y{CODE};
*set_y= *X11::Xlib::XEvent::_set_y unless defined *set_y{CODE};
sub y { $_[0]->set_y($_[1]) if @_ > 1; $_[0]->get_y() }

package X11::Xlib::XEvent::XKeyEvent;
@X11::Xlib::XEvent::XKeyEvent::ISA= ('X11::Xlib::XEvent');
*get_keycode= *X11::Xlib::XEvent::_get_keycode unless defined *get_keycode{CODE};
*set_keycode= *X11::Xlib::XEvent::_set_keycode unless defined *set_keycode{CODE};
sub keycode { $_[0]->set_keycode($_[1]) if @_ > 1; $_[0]->get_keycode() }
*get_root= *X11::Xlib::XEvent::_get_root unless defined *get_root{CODE};
*set_root= *X11::Xlib::XEvent::_set_root unless defined *set_root{CODE};
sub root { $_[0]->set_root($_[1]) if @_ > 1; $_[0]->get_root() }
*get_same_screen= *X11::Xlib::XEvent::_get_same_screen unless defined *get_same_screen{CODE};
*set_same_screen= *X11::Xlib::XEvent::_set_same_screen unless defined *set_same_screen{CODE};
sub same_screen { $_[0]->set_same_screen($_[1]) if @_ > 1; $_[0]->get_same_screen() }
*get_state= *X11::Xlib::XEvent::_get_state unless defined *get_state{CODE};
*set_state= *X11::Xlib::XEvent::_set_state unless defined *set_state{CODE};
sub state { $_[0]->set_state($_[1]) if @_ > 1; $_[0]->get_state() }
*get_subwindow= *X11::Xlib::XEvent::_get_subwindow unless defined *get_subwindow{CODE};
*set_subwindow= *X11::Xlib::XEvent::_set_subwindow unless defined *set_subwindow{CODE};
sub subwindow { $_[0]->set_subwindow($_[1]) if @_ > 1; $_[0]->get_subwindow() }
*get_time= *X11::Xlib::XEvent::_get_time unless defined *get_time{CODE};
*set_time= *X11::Xlib::XEvent::_set_time unless defined *set_time{CODE};
sub time { $_[0]->set_time($_[1]) if @_ > 1; $_[0]->get_time() }
*get_x= *X11::Xlib::XEvent::_get_x unless defined *get_x{CODE};
*set_x= *X11::Xlib::XEvent::_set_x unless defined *set_x{CODE};
sub x { $_[0]->set_x($_[1]) if @_ > 1; $_[0]->get_x() }
*get_x_root= *X11::Xlib::XEvent::_get_x_root unless defined *get_x_root{CODE};
*set_x_root= *X11::Xlib::XEvent::_set_x_root unless defined *set_x_root{CODE};
sub x_root { $_[0]->set_x_root($_[1]) if @_ > 1; $_[0]->get_x_root() }
*get_y= *X11::Xlib::XEvent::_get_y unless defined *get_y{CODE};
*set_y= *X11::Xlib::XEvent::_set_y unless defined *set_y{CODE};
sub y { $_[0]->set_y($_[1]) if @_ > 1; $_[0]->get_y() }
*get_y_root= *X11::Xlib::XEvent::_get_y_root unless defined *get_y_root{CODE};
*set_y_root= *X11::Xlib::XEvent::_set_y_root unless defined *set_y_root{CODE};
sub y_root { $_[0]->set_y_root($_[1]) if @_ > 1; $_[0]->get_y_root() }

package X11::Xlib::XEvent::XKeymapEvent;
@X11::Xlib::XEvent::XKeymapEvent::ISA= ('X11::Xlib::XEvent');
*get_key_vector= *X11::Xlib::XEvent::_get_key_vector unless defined *get_key_vector{CODE};
*set_key_vector= *X11::Xlib::XEvent::_set_key_vector unless defined *set_key_vector{CODE};
sub key_vector { $_[0]->set_key_vector($_[1]) if @_ > 1; $_[0]->get_key_vector() }

package X11::Xlib::XEvent::XMapEvent;
@X11::Xlib::XEvent::XMapEvent::ISA= ('X11::Xlib::XEvent');
*get_event= *X11::Xlib::XEvent::_get_event unless defined *get_event{CODE};
*set_event= *X11::Xlib::XEvent::_set_event unless defined *set_event{CODE};
sub event { $_[0]->set_event($_[1]) if @_ > 1; $_[0]->get_event() }
*get_override_redirect= *X11::Xlib::XEvent::_get_override_redirect unless defined *get_override_redirect{CODE};
*set_override_redirect= *X11::Xlib::XEvent::_set_override_redirect unless defined *set_override_redirect{CODE};
sub override_redirect { $_[0]->set_override_redirect($_[1]) if @_ > 1; $_[0]->get_override_redirect() }

package X11::Xlib::XEvent::XMappingEvent;
@X11::Xlib::XEvent::XMappingEvent::ISA= ('X11::Xlib::XEvent');
*get_count= *X11::Xlib::XEvent::_get_count unless defined *get_count{CODE};
*set_count= *X11::Xlib::XEvent::_set_count unless defined *set_count{CODE};
sub count { $_[0]->set_count($_[1]) if @_ > 1; $_[0]->get_count() }
*get_first_keycode= *X11::Xlib::XEvent::_get_first_keycode unless defined *get_first_keycode{CODE};
*set_first_keycode= *X11::Xlib::XEvent::_set_first_keycode unless defined *set_first_keycode{CODE};
sub first_keycode { $_[0]->set_first_keycode($_[1]) if @_ > 1; $_[0]->get_first_keycode() }
*get_request= *X11::Xlib::XEvent::_get_request unless defined *get_request{CODE};
*set_request= *X11::Xlib::XEvent::_set_request unless defined *set_request{CODE};
sub request { $_[0]->set_request($_[1]) if @_ > 1; $_[0]->get_request() }

package X11::Xlib::XEvent::XMotionEvent;
@X11::Xlib::XEvent::XMotionEvent::ISA= ('X11::Xlib::XEvent');
*get_is_hint= *X11::Xlib::XEvent::_get_is_hint unless defined *get_is_hint{CODE};
*set_is_hint= *X11::Xlib::XEvent::_set_is_hint unless defined *set_is_hint{CODE};
sub is_hint { $_[0]->set_is_hint($_[1]) if @_ > 1; $_[0]->get_is_hint() }
*get_root= *X11::Xlib::XEvent::_get_root unless defined *get_root{CODE};
*set_root= *X11::Xlib::XEvent::_set_root unless defined *set_root{CODE};
sub root { $_[0]->set_root($_[1]) if @_ > 1; $_[0]->get_root() }
*get_same_screen= *X11::Xlib::XEvent::_get_same_screen unless defined *get_same_screen{CODE};
*set_same_screen= *X11::Xlib::XEvent::_set_same_screen unless defined *set_same_screen{CODE};
sub same_screen { $_[0]->set_same_screen($_[1]) if @_ > 1; $_[0]->get_same_screen() }
*get_state= *X11::Xlib::XEvent::_get_state unless defined *get_state{CODE};
*set_state= *X11::Xlib::XEvent::_set_state unless defined *set_state{CODE};
sub state { $_[0]->set_state($_[1]) if @_ > 1; $_[0]->get_state() }
*get_subwindow= *X11::Xlib::XEvent::_get_subwindow unless defined *get_subwindow{CODE};
*set_subwindow= *X11::Xlib::XEvent::_set_subwindow unless defined *set_subwindow{CODE};
sub subwindow { $_[0]->set_subwindow($_[1]) if @_ > 1; $_[0]->get_subwindow() }
*get_time= *X11::Xlib::XEvent::_get_time unless defined *get_time{CODE};
*set_time= *X11::Xlib::XEvent::_set_time unless defined *set_time{CODE};
sub time { $_[0]->set_time($_[1]) if @_ > 1; $_[0]->get_time() }
*get_x= *X11::Xlib::XEvent::_get_x unless defined *get_x{CODE};
*set_x= *X11::Xlib::XEvent::_set_x unless defined *set_x{CODE};
sub x { $_[0]->set_x($_[1]) if @_ > 1; $_[0]->get_x() }
*get_x_root= *X11::Xlib::XEvent::_get_x_root unless defined *get_x_root{CODE};
*set_x_root= *X11::Xlib::XEvent::_set_x_root unless defined *set_x_root{CODE};
sub x_root { $_[0]->set_x_root($_[1]) if @_ > 1; $_[0]->get_x_root() }
*get_y= *X11::Xlib::XEvent::_get_y unless defined *get_y{CODE};
*set_y= *X11::Xlib::XEvent::_set_y unless defined *set_y{CODE};
sub y { $_[0]->set_y($_[1]) if @_ > 1; $_[0]->get_y() }
*get_y_root= *X11::Xlib::XEvent::_get_y_root unless defined *get_y_root{CODE};
*set_y_root= *X11::Xlib::XEvent::_set_y_root unless defined *set_y_root{CODE};
sub y_root { $_[0]->set_y_root($_[1]) if @_ > 1; $_[0]->get_y_root() }

package X11::Xlib::XEvent::XNoExposeEvent;
@X11::Xlib::XEvent::XNoExposeEvent::ISA= ('X11::Xlib::XEvent');
*get_drawable= *X11::Xlib::XEvent::_get_drawable unless defined *get_drawable{CODE};
*set_drawable= *X11::Xlib::XEvent::_set_drawable unless defined *set_drawable{CODE};
sub drawable { $_[0]->set_drawable($_[1]) if @_ > 1; $_[0]->get_drawable() }
*get_major_code= *X11::Xlib::XEvent::_get_major_code unless defined *get_major_code{CODE};
*set_major_code= *X11::Xlib::XEvent::_set_major_code unless defined *set_major_code{CODE};
sub major_code { $_[0]->set_major_code($_[1]) if @_ > 1; $_[0]->get_major_code() }
*get_minor_code= *X11::Xlib::XEvent::_get_minor_code unless defined *get_minor_code{CODE};
*set_minor_code= *X11::Xlib::XEvent::_set_minor_code unless defined *set_minor_code{CODE};
sub minor_code { $_[0]->set_minor_code($_[1]) if @_ > 1; $_[0]->get_minor_code() }

package X11::Xlib::XEvent::XPropertyEvent;
@X11::Xlib::XEvent::XPropertyEvent::ISA= ('X11::Xlib::XEvent');
*get_atom= *X11::Xlib::XEvent::_get_atom unless defined *get_atom{CODE};
*set_atom= *X11::Xlib::XEvent::_set_atom unless defined *set_atom{CODE};
sub atom { $_[0]->set_atom($_[1]) if @_ > 1; $_[0]->get_atom() }
*get_state= *X11::Xlib::XEvent::_get_state unless defined *get_state{CODE};
*set_state= *X11::Xlib::XEvent::_set_state unless defined *set_state{CODE};
sub state { $_[0]->set_state($_[1]) if @_ > 1; $_[0]->get_state() }
*get_time= *X11::Xlib::XEvent::_get_time unless defined *get_time{CODE};
*set_time= *X11::Xlib::XEvent::_set_time unless defined *set_time{CODE};
sub time { $_[0]->set_time($_[1]) if @_ > 1; $_[0]->get_time() }

package X11::Xlib::XEvent::XReparentEvent;
@X11::Xlib::XEvent::XReparentEvent::ISA= ('X11::Xlib::XEvent');
*get_event= *X11::Xlib::XEvent::_get_event unless defined *get_event{CODE};
*set_event= *X11::Xlib::XEvent::_set_event unless defined *set_event{CODE};
sub event { $_[0]->set_event($_[1]) if @_ > 1; $_[0]->get_event() }
*get_override_redirect= *X11::Xlib::XEvent::_get_override_redirect unless defined *get_override_redirect{CODE};
*set_override_redirect= *X11::Xlib::XEvent::_set_override_redirect unless defined *set_override_redirect{CODE};
sub override_redirect { $_[0]->set_override_redirect($_[1]) if @_ > 1; $_[0]->get_override_redirect() }
*get_parent= *X11::Xlib::XEvent::_get_parent unless defined *get_parent{CODE};
*set_parent= *X11::Xlib::XEvent::_set_parent unless defined *set_parent{CODE};
sub parent { $_[0]->set_parent($_[1]) if @_ > 1; $_[0]->get_parent() }
*get_x= *X11::Xlib::XEvent::_get_x unless defined *get_x{CODE};
*set_x= *X11::Xlib::XEvent::_set_x unless defined *set_x{CODE};
sub x { $_[0]->set_x($_[1]) if @_ > 1; $_[0]->get_x() }
*get_y= *X11::Xlib::XEvent::_get_y unless defined *get_y{CODE};
*set_y= *X11::Xlib::XEvent::_set_y unless defined *set_y{CODE};
sub y { $_[0]->set_y($_[1]) if @_ > 1; $_[0]->get_y() }

package X11::Xlib::XEvent::XResizeRequestEvent;
@X11::Xlib::XEvent::XResizeRequestEvent::ISA= ('X11::Xlib::XEvent');
*get_height= *X11::Xlib::XEvent::_get_height unless defined *get_height{CODE};
*set_height= *X11::Xlib::XEvent::_set_height unless defined *set_height{CODE};
sub height { $_[0]->set_height($_[1]) if @_ > 1; $_[0]->get_height() }
*get_width= *X11::Xlib::XEvent::_get_width unless defined *get_width{CODE};
*set_width= *X11::Xlib::XEvent::_set_width unless defined *set_width{CODE};
sub width { $_[0]->set_width($_[1]) if @_ > 1; $_[0]->get_width() }

package X11::Xlib::XEvent::XSelectionClearEvent;
@X11::Xlib::XEvent::XSelectionClearEvent::ISA= ('X11::Xlib::XEvent');
*get_selection= *X11::Xlib::XEvent::_get_selection unless defined *get_selection{CODE};
*set_selection= *X11::Xlib::XEvent::_set_selection unless defined *set_selection{CODE};
sub selection { $_[0]->set_selection($_[1]) if @_ > 1; $_[0]->get_selection() }
*get_time= *X11::Xlib::XEvent::_get_time unless defined *get_time{CODE};
*set_time= *X11::Xlib::XEvent::_set_time unless defined *set_time{CODE};
sub time { $_[0]->set_time($_[1]) if @_ > 1; $_[0]->get_time() }

package X11::Xlib::XEvent::XSelectionEvent;
@X11::Xlib::XEvent::XSelectionEvent::ISA= ('X11::Xlib::XEvent');
*get_property= *X11::Xlib::XEvent::_get_property unless defined *get_property{CODE};
*set_property= *X11::Xlib::XEvent::_set_property unless defined *set_property{CODE};
sub property { $_[0]->set_property($_[1]) if @_ > 1; $_[0]->get_property() }
*get_requestor= *X11::Xlib::XEvent::_get_requestor unless defined *get_requestor{CODE};
*set_requestor= *X11::Xlib::XEvent::_set_requestor unless defined *set_requestor{CODE};
sub requestor { $_[0]->set_requestor($_[1]) if @_ > 1; $_[0]->get_requestor() }
*get_selection= *X11::Xlib::XEvent::_get_selection unless defined *get_selection{CODE};
*set_selection= *X11::Xlib::XEvent::_set_selection unless defined *set_selection{CODE};
sub selection { $_[0]->set_selection($_[1]) if @_ > 1; $_[0]->get_selection() }
*get_target= *X11::Xlib::XEvent::_get_target unless defined *get_target{CODE};
*set_target= *X11::Xlib::XEvent::_set_target unless defined *set_target{CODE};
sub target { $_[0]->set_target($_[1]) if @_ > 1; $_[0]->get_target() }
*get_time= *X11::Xlib::XEvent::_get_time unless defined *get_time{CODE};
*set_time= *X11::Xlib::XEvent::_set_time unless defined *set_time{CODE};
sub time { $_[0]->set_time($_[1]) if @_ > 1; $_[0]->get_time() }

package X11::Xlib::XEvent::XSelectionRequestEvent;
@X11::Xlib::XEvent::XSelectionRequestEvent::ISA= ('X11::Xlib::XEvent');
*get_owner= *X11::Xlib::XEvent::_get_owner unless defined *get_owner{CODE};
*set_owner= *X11::Xlib::XEvent::_set_owner unless defined *set_owner{CODE};
sub owner { $_[0]->set_owner($_[1]) if @_ > 1; $_[0]->get_owner() }
*get_property= *X11::Xlib::XEvent::_get_property unless defined *get_property{CODE};
*set_property= *X11::Xlib::XEvent::_set_property unless defined *set_property{CODE};
sub property { $_[0]->set_property($_[1]) if @_ > 1; $_[0]->get_property() }
*get_requestor= *X11::Xlib::XEvent::_get_requestor unless defined *get_requestor{CODE};
*set_requestor= *X11::Xlib::XEvent::_set_requestor unless defined *set_requestor{CODE};
sub requestor { $_[0]->set_requestor($_[1]) if @_ > 1; $_[0]->get_requestor() }
*get_selection= *X11::Xlib::XEvent::_get_selection unless defined *get_selection{CODE};
*set_selection= *X11::Xlib::XEvent::_set_selection unless defined *set_selection{CODE};
sub selection { $_[0]->set_selection($_[1]) if @_ > 1; $_[0]->get_selection() }
*get_target= *X11::Xlib::XEvent::_get_target unless defined *get_target{CODE};
*set_target= *X11::Xlib::XEvent::_set_target unless defined *set_target{CODE};
sub target { $_[0]->set_target($_[1]) if @_ > 1; $_[0]->get_target() }
*get_time= *X11::Xlib::XEvent::_get_time unless defined *get_time{CODE};
*set_time= *X11::Xlib::XEvent::_set_time unless defined *set_time{CODE};
sub time { $_[0]->set_time($_[1]) if @_ > 1; $_[0]->get_time() }

package X11::Xlib::XEvent::XUnmapEvent;
@X11::Xlib::XEvent::XUnmapEvent::ISA= ('X11::Xlib::XEvent');
*get_event= *X11::Xlib::XEvent::_get_event unless defined *get_event{CODE};
*set_event= *X11::Xlib::XEvent::_set_event unless defined *set_event{CODE};
sub event { $_[0]->set_event($_[1]) if @_ > 1; $_[0]->get_event() }
*get_from_configure= *X11::Xlib::XEvent::_get_from_configure unless defined *get_from_configure{CODE};
*set_from_configure= *X11::Xlib::XEvent::_set_from_configure unless defined *set_from_configure{CODE};
sub from_configure { $_[0]->set_from_configure($_[1]) if @_ > 1; $_[0]->get_from_configure() }

package X11::Xlib::XEvent::XVisibilityEvent;
@X11::Xlib::XEvent::XVisibilityEvent::ISA= ('X11::Xlib::XEvent');
*get_state= *X11::Xlib::XEvent::_get_state unless defined *get_state{CODE};
*set_state= *X11::Xlib::XEvent::_set_state unless defined *set_state{CODE};
sub state { $_[0]->set_state($_[1]) if @_ > 1; $_[0]->get_state() }

=head2 XButtonEvent

=head3 button

=head3 root

=head3 same_screen

=head3 state

=head3 subwindow

=head3 time

=head3 x

=head3 x_root

=head3 y

=head3 y_root

=head2 XCirculateEvent

=head3 event

=head3 place

=head2 XClientMessageEvent

=head3 b

=head3 l

=head3 s

=head3 format

=head3 message_type

=head2 XColormapEvent

=head3 colormap

=head3 new

=head3 state

=head2 XConfigureEvent

=head3 above

=head3 border_width

=head3 event

=head3 height

=head3 override_redirect

=head3 width

=head3 x

=head3 y

=head2 XCreateWindowEvent

=head3 border_width

=head3 height

=head3 override_redirect

=head3 parent

=head3 width

=head3 x

=head3 y

=head2 XCrossingEvent

=head3 detail

=head3 focus

=head3 mode

=head3 root

=head3 same_screen

=head3 state

=head3 subwindow

=head3 time

=head3 x

=head3 x_root

=head3 y

=head3 y_root

=head2 XDestroyWindowEvent

=head3 event

=head2 XExposeEvent

=head3 count

=head3 height

=head3 width

=head3 x

=head3 y

=head2 XFocusChangeEvent

=head3 detail

=head3 mode

=head2 XGraphicsExposeEvent

=head3 count

=head3 drawable

=head3 height

=head3 major_code

=head3 minor_code

=head3 width

=head3 x

=head3 y

=head2 XGravityEvent

=head3 event

=head3 x

=head3 y

=head2 XKeyEvent

=head3 keycode

=head3 root

=head3 same_screen

=head3 state

=head3 subwindow

=head3 time

=head3 x

=head3 x_root

=head3 y

=head3 y_root

=head2 XKeymapEvent

=head3 key_vector

=head2 XMapEvent

=head3 event

=head3 override_redirect

=head2 XMappingEvent

=head3 count

=head3 first_keycode

=head3 request

=head2 XMotionEvent

=head3 is_hint

=head3 root

=head3 same_screen

=head3 state

=head3 subwindow

=head3 time

=head3 x

=head3 x_root

=head3 y

=head3 y_root

=head2 XNoExposeEvent

=head3 drawable

=head3 major_code

=head3 minor_code

=head2 XPropertyEvent

=head3 atom

=head3 state

=head3 time

=head2 XReparentEvent

=head3 event

=head3 override_redirect

=head3 parent

=head3 x

=head3 y

=head2 XResizeRequestEvent

=head3 height

=head3 width

=head2 XSelectionClearEvent

=head3 selection

=head3 time

=head2 XSelectionEvent

=head3 property

=head3 requestor

=head3 selection

=head3 target

=head3 time

=head2 XSelectionRequestEvent

=head3 owner

=head3 property

=head3 requestor

=head3 selection

=head3 target

=head3 time

=head2 XUnmapEvent

=head3 event

=head3 from_configure

=head2 XVisibilityEvent

=head3 state

# END GENERATED X11_Xlib_XEvent
# ----------------------------------------------------------------------------

1;
