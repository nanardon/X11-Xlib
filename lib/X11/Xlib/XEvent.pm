package X11::Xlib::XEvent;
use X11::Xlib; # need constants loaded
use parent 'X11::Xlib::Struct';

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
  my $xevent= X11::Xlib::XEvent->new( %fields );
  my $xevent= X11::Xlib::XEvent->new( \%fields );

You can construct XEvent as an empty buffer, or initialize it with a hash or
hashref of fields.  Initialization is performed via L</pack>.  Un-set fields
are initialized to zero, and the L</buffer> is always padded to the length
of an XEvent.

=head2 bytes

Direct access to the bytes of the XEvent.

=head2 apply

  $xevent->apply( %fields );

Alias for C< pack( \%fields, 1, 1 ) >

=head2 pack

  $xevent->pack( \%fields, $consume, $warn );

Assign a set of fields to the packed struct, optionally removing them from
the hashref (C<$consume>) and warning about un-known names (C<$warn>).
If you supply a new value for L</type>, the XEvent will get re-blessed to
the appropriate type and all union-specific fields will be zeroed before
applying the rest of the supplied fields.

=head2 unpack

  my $field_hashref= $xevent->unpack;

Unpack the fields of an XEvent into a hashref.  The Display field gets
inflated to an X11::Xlib object.

=head1 ATTRIBUTES

=head2 Common Attributes

All XEvent subclasses have the following attributes:

=head3 type

This is the key attribute that determines all the rest.  Setting this value
will re-bless the object to the relevant sub-class.  If the type is unknown,
it becomes C<X11::Xlib::XEvent>.

=head3 display

The handle to the X11 connection that this message came from.

=head3 serial

The X11 serial number

=head3 window

The Window XID the message is associated with, or 0.

=head3 send_event

Boolean indicating whether the event was sent with XSendEvent

=head1 SEE ALSO

For information about the rest of these structures, consult the
L<official documentation|https://www.x.org/releases/X11R7.7/doc/libX11/libX11/libX11.html>

=head1 SUBCLASS ATTRIBUTES

=cut

sub pack {
    my $self= shift;
    # As a special case, convert type enum codes into numeric values
    if (my $type= $_[0]{type}) {
        unless ($type =~ /^[0-9]+$/) {
            # Look up the symbolic constant
            if (grep { $_ eq $type } @{ $X11::Xlib::EXPORT_TAGS{const_event} }) {
                $_[0]{type}= X11::Xlib->$type();
            } else {
                Carp::croak "Unknown XEvent type '$type'";
            }
        }
    }
    $self->SUPER::pack(@_);
}

# ----------------------------------------------------------------------------
# BEGIN GENERATED X11_Xlib_XEvent



@X11::Xlib::XEvent::XButtonEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XButtonEvent::button= *_button;
*X11::Xlib::XEvent::XButtonEvent::root= *_root;
*X11::Xlib::XEvent::XButtonEvent::same_screen= *_same_screen;
*X11::Xlib::XEvent::XButtonEvent::state= *_state;
*X11::Xlib::XEvent::XButtonEvent::subwindow= *_subwindow;
*X11::Xlib::XEvent::XButtonEvent::time= *_time;
*X11::Xlib::XEvent::XButtonEvent::x= *_x;
*X11::Xlib::XEvent::XButtonEvent::x_root= *_x_root;
*X11::Xlib::XEvent::XButtonEvent::y= *_y;
*X11::Xlib::XEvent::XButtonEvent::y_root= *_y_root;


@X11::Xlib::XEvent::XCirculateEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XCirculateEvent::event= *_event;
*X11::Xlib::XEvent::XCirculateEvent::place= *_place;


@X11::Xlib::XEvent::XCirculateRequestEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XCirculateRequestEvent::parent= *_parent;
*X11::Xlib::XEvent::XCirculateRequestEvent::place= *_place;


@X11::Xlib::XEvent::XClientMessageEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XClientMessageEvent::b= *_b;
*X11::Xlib::XEvent::XClientMessageEvent::l= *_l;
*X11::Xlib::XEvent::XClientMessageEvent::s= *_s;
*X11::Xlib::XEvent::XClientMessageEvent::format= *_format;
*X11::Xlib::XEvent::XClientMessageEvent::message_type= *_message_type;


@X11::Xlib::XEvent::XColormapEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XColormapEvent::colormap= *_colormap;
*X11::Xlib::XEvent::XColormapEvent::new= *_new;
*X11::Xlib::XEvent::XColormapEvent::state= *_state;


@X11::Xlib::XEvent::XConfigureEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XConfigureEvent::above= *_above;
*X11::Xlib::XEvent::XConfigureEvent::border_width= *_border_width;
*X11::Xlib::XEvent::XConfigureEvent::event= *_event;
*X11::Xlib::XEvent::XConfigureEvent::height= *_height;
*X11::Xlib::XEvent::XConfigureEvent::override_redirect= *_override_redirect;
*X11::Xlib::XEvent::XConfigureEvent::width= *_width;
*X11::Xlib::XEvent::XConfigureEvent::x= *_x;
*X11::Xlib::XEvent::XConfigureEvent::y= *_y;


@X11::Xlib::XEvent::XConfigureRequestEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XConfigureRequestEvent::above= *_above;
*X11::Xlib::XEvent::XConfigureRequestEvent::border_width= *_border_width;
*X11::Xlib::XEvent::XConfigureRequestEvent::detail= *_detail;
*X11::Xlib::XEvent::XConfigureRequestEvent::height= *_height;
*X11::Xlib::XEvent::XConfigureRequestEvent::parent= *_parent;
*X11::Xlib::XEvent::XConfigureRequestEvent::value_mask= *_value_mask;
*X11::Xlib::XEvent::XConfigureRequestEvent::width= *_width;
*X11::Xlib::XEvent::XConfigureRequestEvent::x= *_x;
*X11::Xlib::XEvent::XConfigureRequestEvent::y= *_y;


@X11::Xlib::XEvent::XCreateWindowEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XCreateWindowEvent::border_width= *_border_width;
*X11::Xlib::XEvent::XCreateWindowEvent::height= *_height;
*X11::Xlib::XEvent::XCreateWindowEvent::override_redirect= *_override_redirect;
*X11::Xlib::XEvent::XCreateWindowEvent::parent= *_parent;
*X11::Xlib::XEvent::XCreateWindowEvent::width= *_width;
*X11::Xlib::XEvent::XCreateWindowEvent::x= *_x;
*X11::Xlib::XEvent::XCreateWindowEvent::y= *_y;


@X11::Xlib::XEvent::XCrossingEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XCrossingEvent::detail= *_detail;
*X11::Xlib::XEvent::XCrossingEvent::focus= *_focus;
*X11::Xlib::XEvent::XCrossingEvent::mode= *_mode;
*X11::Xlib::XEvent::XCrossingEvent::root= *_root;
*X11::Xlib::XEvent::XCrossingEvent::same_screen= *_same_screen;
*X11::Xlib::XEvent::XCrossingEvent::state= *_state;
*X11::Xlib::XEvent::XCrossingEvent::subwindow= *_subwindow;
*X11::Xlib::XEvent::XCrossingEvent::time= *_time;
*X11::Xlib::XEvent::XCrossingEvent::x= *_x;
*X11::Xlib::XEvent::XCrossingEvent::x_root= *_x_root;
*X11::Xlib::XEvent::XCrossingEvent::y= *_y;
*X11::Xlib::XEvent::XCrossingEvent::y_root= *_y_root;


@X11::Xlib::XEvent::XDestroyWindowEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XDestroyWindowEvent::event= *_event;


@X11::Xlib::XEvent::XExposeEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XExposeEvent::count= *_count;
*X11::Xlib::XEvent::XExposeEvent::height= *_height;
*X11::Xlib::XEvent::XExposeEvent::width= *_width;
*X11::Xlib::XEvent::XExposeEvent::x= *_x;
*X11::Xlib::XEvent::XExposeEvent::y= *_y;


@X11::Xlib::XEvent::XFocusChangeEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XFocusChangeEvent::detail= *_detail;
*X11::Xlib::XEvent::XFocusChangeEvent::mode= *_mode;


@X11::Xlib::XEvent::XGenericEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XGenericEvent::evtype= *_evtype;
*X11::Xlib::XEvent::XGenericEvent::extension= *_extension;


@X11::Xlib::XEvent::XGraphicsExposeEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XGraphicsExposeEvent::count= *_count;
*X11::Xlib::XEvent::XGraphicsExposeEvent::drawable= *_drawable;
*X11::Xlib::XEvent::XGraphicsExposeEvent::height= *_height;
*X11::Xlib::XEvent::XGraphicsExposeEvent::major_code= *_major_code;
*X11::Xlib::XEvent::XGraphicsExposeEvent::minor_code= *_minor_code;
*X11::Xlib::XEvent::XGraphicsExposeEvent::width= *_width;
*X11::Xlib::XEvent::XGraphicsExposeEvent::x= *_x;
*X11::Xlib::XEvent::XGraphicsExposeEvent::y= *_y;


@X11::Xlib::XEvent::XGravityEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XGravityEvent::event= *_event;
*X11::Xlib::XEvent::XGravityEvent::x= *_x;
*X11::Xlib::XEvent::XGravityEvent::y= *_y;


@X11::Xlib::XEvent::XKeyEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XKeyEvent::keycode= *_keycode;
*X11::Xlib::XEvent::XKeyEvent::root= *_root;
*X11::Xlib::XEvent::XKeyEvent::same_screen= *_same_screen;
*X11::Xlib::XEvent::XKeyEvent::state= *_state;
*X11::Xlib::XEvent::XKeyEvent::subwindow= *_subwindow;
*X11::Xlib::XEvent::XKeyEvent::time= *_time;
*X11::Xlib::XEvent::XKeyEvent::x= *_x;
*X11::Xlib::XEvent::XKeyEvent::x_root= *_x_root;
*X11::Xlib::XEvent::XKeyEvent::y= *_y;
*X11::Xlib::XEvent::XKeyEvent::y_root= *_y_root;


@X11::Xlib::XEvent::XKeymapEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XKeymapEvent::key_vector= *_key_vector;


@X11::Xlib::XEvent::XMapEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XMapEvent::event= *_event;
*X11::Xlib::XEvent::XMapEvent::override_redirect= *_override_redirect;


@X11::Xlib::XEvent::XMapRequestEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XMapRequestEvent::parent= *_parent;


@X11::Xlib::XEvent::XMappingEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XMappingEvent::count= *_count;
*X11::Xlib::XEvent::XMappingEvent::first_keycode= *_first_keycode;
*X11::Xlib::XEvent::XMappingEvent::request= *_request;


@X11::Xlib::XEvent::XMotionEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XMotionEvent::is_hint= *_is_hint;
*X11::Xlib::XEvent::XMotionEvent::root= *_root;
*X11::Xlib::XEvent::XMotionEvent::same_screen= *_same_screen;
*X11::Xlib::XEvent::XMotionEvent::state= *_state;
*X11::Xlib::XEvent::XMotionEvent::subwindow= *_subwindow;
*X11::Xlib::XEvent::XMotionEvent::time= *_time;
*X11::Xlib::XEvent::XMotionEvent::x= *_x;
*X11::Xlib::XEvent::XMotionEvent::x_root= *_x_root;
*X11::Xlib::XEvent::XMotionEvent::y= *_y;
*X11::Xlib::XEvent::XMotionEvent::y_root= *_y_root;


@X11::Xlib::XEvent::XNoExposeEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XNoExposeEvent::drawable= *_drawable;
*X11::Xlib::XEvent::XNoExposeEvent::major_code= *_major_code;
*X11::Xlib::XEvent::XNoExposeEvent::minor_code= *_minor_code;


@X11::Xlib::XEvent::XPropertyEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XPropertyEvent::atom= *_atom;
*X11::Xlib::XEvent::XPropertyEvent::state= *_state;
*X11::Xlib::XEvent::XPropertyEvent::time= *_time;


@X11::Xlib::XEvent::XReparentEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XReparentEvent::event= *_event;
*X11::Xlib::XEvent::XReparentEvent::override_redirect= *_override_redirect;
*X11::Xlib::XEvent::XReparentEvent::parent= *_parent;
*X11::Xlib::XEvent::XReparentEvent::x= *_x;
*X11::Xlib::XEvent::XReparentEvent::y= *_y;


@X11::Xlib::XEvent::XResizeRequestEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XResizeRequestEvent::height= *_height;
*X11::Xlib::XEvent::XResizeRequestEvent::width= *_width;


@X11::Xlib::XEvent::XSelectionClearEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XSelectionClearEvent::selection= *_selection;
*X11::Xlib::XEvent::XSelectionClearEvent::time= *_time;


@X11::Xlib::XEvent::XSelectionEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XSelectionEvent::property= *_property;
*X11::Xlib::XEvent::XSelectionEvent::requestor= *_requestor;
*X11::Xlib::XEvent::XSelectionEvent::selection= *_selection;
*X11::Xlib::XEvent::XSelectionEvent::target= *_target;
*X11::Xlib::XEvent::XSelectionEvent::time= *_time;


@X11::Xlib::XEvent::XSelectionRequestEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XSelectionRequestEvent::owner= *_owner;
*X11::Xlib::XEvent::XSelectionRequestEvent::property= *_property;
*X11::Xlib::XEvent::XSelectionRequestEvent::requestor= *_requestor;
*X11::Xlib::XEvent::XSelectionRequestEvent::selection= *_selection;
*X11::Xlib::XEvent::XSelectionRequestEvent::target= *_target;
*X11::Xlib::XEvent::XSelectionRequestEvent::time= *_time;


@X11::Xlib::XEvent::XUnmapEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XUnmapEvent::event= *_event;
*X11::Xlib::XEvent::XUnmapEvent::from_configure= *_from_configure;


@X11::Xlib::XEvent::XVisibilityEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::XEvent::XVisibilityEvent::state= *_state;

=head2 XButtonEvent

Used for event type: ButtonPress, ButtonRelease

=over

=item button

=item root

=item same_screen

=item state

=item subwindow

=item time

=item x

=item x_root

=item y

=item y_root

=back

=head2 XCirculateEvent

Used for event type: CirculateNotify

=over

=item event

=item place

=back

=head2 XCirculateRequestEvent

Used for event type: CirculateRequest

=over

=item parent

=item place

=back

=head2 XClientMessageEvent

Used for event type: ClientMessage

=over

=item b

=item l

=item s

=item format

=item message_type

=back

=head2 XColormapEvent

Used for event type: ColormapNotify

=over

=item colormap

=item new

=item state

=back

=head2 XConfigureEvent

Used for event type: ConfigureNotify

=over

=item above

=item border_width

=item event

=item height

=item override_redirect

=item width

=item x

=item y

=back

=head2 XConfigureRequestEvent

Used for event type: ConfigureRequest

=over

=item above

=item border_width

=item detail

=item height

=item parent

=item value_mask

=item width

=item x

=item y

=back

=head2 XCreateWindowEvent

Used for event type: CreateNotify

=over

=item border_width

=item height

=item override_redirect

=item parent

=item width

=item x

=item y

=back

=head2 XCrossingEvent

Used for event type: EnterNotify, LeaveNotify

=over

=item detail

=item focus

=item mode

=item root

=item same_screen

=item state

=item subwindow

=item time

=item x

=item x_root

=item y

=item y_root

=back

=head2 XDestroyWindowEvent

Used for event type: DestroyNotify

=over

=item event

=back

=head2 XExposeEvent

Used for event type: Expose

=over

=item count

=item height

=item width

=item x

=item y

=back

=head2 XFocusChangeEvent

Used for event type: FocusIn, FocusOut

=over

=item detail

=item mode

=back

=head2 XGenericEvent

Used for event type: GenericEvent

=over

=item evtype

=item extension

=back

=head2 XGraphicsExposeEvent

Used for event type: GraphicsExpose

=over

=item count

=item drawable

=item height

=item major_code

=item minor_code

=item width

=item x

=item y

=back

=head2 XGravityEvent

Used for event type: GravityNotify

=over

=item event

=item x

=item y

=back

=head2 XKeyEvent

Used for event type: KeyPress, KeyRelease

=over

=item keycode

=item root

=item same_screen

=item state

=item subwindow

=item time

=item x

=item x_root

=item y

=item y_root

=back

=head2 XKeymapEvent

Used for event type: KeymapNotify

=over

=item key_vector

=back

=head2 XMapEvent

Used for event type: MapNotify

=over

=item event

=item override_redirect

=back

=head2 XMapRequestEvent

Used for event type: MapRequest

=over

=item parent

=back

=head2 XMappingEvent

Used for event type: MappingNotify

=over

=item count

=item first_keycode

=item request

=back

=head2 XMotionEvent

Used for event type: MotionNotify

=over

=item is_hint

=item root

=item same_screen

=item state

=item subwindow

=item time

=item x

=item x_root

=item y

=item y_root

=back

=head2 XNoExposeEvent

Used for event type: NoExpose

=over

=item drawable

=item major_code

=item minor_code

=back

=head2 XPropertyEvent

Used for event type: PropertyNotify

=over

=item atom

=item state

=item time

=back

=head2 XReparentEvent

Used for event type: ReparentNotify

=over

=item event

=item override_redirect

=item parent

=item x

=item y

=back

=head2 XResizeRequestEvent

Used for event type: ResizeRequest

=over

=item height

=item width

=back

=head2 XSelectionClearEvent

Used for event type: SelectionClear

=over

=item selection

=item time

=back

=head2 XSelectionEvent

Used for event type: SelectionNotify

=over

=item property

=item requestor

=item selection

=item target

=item time

=back

=head2 XSelectionRequestEvent

Used for event type: SelectionRequest

=over

=item owner

=item property

=item requestor

=item selection

=item target

=item time

=back

=head2 XUnmapEvent

Used for event type: UnmapNotify

=over

=item event

=item from_configure

=back

=head2 XVisibilityEvent

Used for event type: VisibilityNotify

=over

=item state

=back

=cut

# END GENERATED X11_Xlib_XEvent
# ----------------------------------------------------------------------------

1;
