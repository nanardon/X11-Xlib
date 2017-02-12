package X11::Xlib::Struct::XEvent;
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
  # or:                        ->new( %fields );
  # or:                        ->new( \%fields );

You can construct XEvent as an empty buffer, or initialize it with a hash or
hashref of fields.  Initialization is performed via L</pack>.  Un-set fields
are initialized to zero, and the L</buffer> is always padded to the length
of an XEvent.

=head2 buffer

Direct access to the bytes of the XEvent.

=head2 pack

  $xevent->pack( %fields );
  $xevent->pack( \%fields );

Wipe the contents of the current xevent and replace with the specified values.
If the L</type> changes as a result, then the XEvent will get re-blessed to
the appropriate type.

This method warns about unused arguments, but not missing arguments.
(any missing arguments get a zero value from the initial C<memset>.)

=head2 unpack

  my $field_hash= $xevent->unpack;

Unpack the fields of an XEvent into a hashref.  Fields that reference objects
like Window IDs or Display handles will get inflated as appropriate.

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

=head3 display

The handle to the X11 connection that this message came from.

=head3 serial

The X11 serial number

=cut

=head3 window

The Window XID the message is associated with, or 0.

=head3 send_event

Boolean indicating whether the event was sent with XSendEvent

=head1 SEE ALSO

For information about the rest of these structures, consult the
L<official documentation|https://www.x.org/releases/X11R7.7/doc/libX11/libX11/libX11.html>

=head1 SUBCLASS ATTRIBUTES

=cut

# ----------------------------------------------------------------------------
# The code below is auto-generated.

# BEGIN GENERATED X11_Xlib_XEvent



@X11::Xlib::Struct::XEvent::XButtonEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::button= *_button;
*X11::Xlib::Struct::XEvent::root= *_root;
*X11::Xlib::Struct::XEvent::same_screen= *_same_screen;
*X11::Xlib::Struct::XEvent::state= *_state;
*X11::Xlib::Struct::XEvent::subwindow= *_subwindow;
*X11::Xlib::Struct::XEvent::time= *_time;
*X11::Xlib::Struct::XEvent::x= *_x;
*X11::Xlib::Struct::XEvent::x_root= *_x_root;
*X11::Xlib::Struct::XEvent::y= *_y;
*X11::Xlib::Struct::XEvent::y_root= *_y_root;


@X11::Xlib::Struct::XEvent::XCirculateEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::event= *_event;
*X11::Xlib::Struct::XEvent::place= *_place;


@X11::Xlib::Struct::XEvent::XCirculateRequestEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::parent= *_parent;
*X11::Xlib::Struct::XEvent::place= *_place;


@X11::Xlib::Struct::XEvent::XClientMessageEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::b= *_b;
*X11::Xlib::Struct::XEvent::l= *_l;
*X11::Xlib::Struct::XEvent::s= *_s;
*X11::Xlib::Struct::XEvent::format= *_format;
*X11::Xlib::Struct::XEvent::message_type= *_message_type;


@X11::Xlib::Struct::XEvent::XColormapEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::colormap= *_colormap;
*X11::Xlib::Struct::XEvent::new= *_new;
*X11::Xlib::Struct::XEvent::state= *_state;


@X11::Xlib::Struct::XEvent::XConfigureEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::above= *_above;
*X11::Xlib::Struct::XEvent::border_width= *_border_width;
*X11::Xlib::Struct::XEvent::event= *_event;
*X11::Xlib::Struct::XEvent::height= *_height;
*X11::Xlib::Struct::XEvent::override_redirect= *_override_redirect;
*X11::Xlib::Struct::XEvent::width= *_width;
*X11::Xlib::Struct::XEvent::x= *_x;
*X11::Xlib::Struct::XEvent::y= *_y;


@X11::Xlib::Struct::XEvent::XConfigureRequestEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::above= *_above;
*X11::Xlib::Struct::XEvent::border_width= *_border_width;
*X11::Xlib::Struct::XEvent::detail= *_detail;
*X11::Xlib::Struct::XEvent::height= *_height;
*X11::Xlib::Struct::XEvent::parent= *_parent;
*X11::Xlib::Struct::XEvent::value_mask= *_value_mask;
*X11::Xlib::Struct::XEvent::width= *_width;
*X11::Xlib::Struct::XEvent::x= *_x;
*X11::Xlib::Struct::XEvent::y= *_y;


@X11::Xlib::Struct::XEvent::XCreateWindowEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::border_width= *_border_width;
*X11::Xlib::Struct::XEvent::height= *_height;
*X11::Xlib::Struct::XEvent::override_redirect= *_override_redirect;
*X11::Xlib::Struct::XEvent::parent= *_parent;
*X11::Xlib::Struct::XEvent::width= *_width;
*X11::Xlib::Struct::XEvent::x= *_x;
*X11::Xlib::Struct::XEvent::y= *_y;


@X11::Xlib::Struct::XEvent::XCrossingEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::detail= *_detail;
*X11::Xlib::Struct::XEvent::focus= *_focus;
*X11::Xlib::Struct::XEvent::mode= *_mode;
*X11::Xlib::Struct::XEvent::root= *_root;
*X11::Xlib::Struct::XEvent::same_screen= *_same_screen;
*X11::Xlib::Struct::XEvent::state= *_state;
*X11::Xlib::Struct::XEvent::subwindow= *_subwindow;
*X11::Xlib::Struct::XEvent::time= *_time;
*X11::Xlib::Struct::XEvent::x= *_x;
*X11::Xlib::Struct::XEvent::x_root= *_x_root;
*X11::Xlib::Struct::XEvent::y= *_y;
*X11::Xlib::Struct::XEvent::y_root= *_y_root;


@X11::Xlib::Struct::XEvent::XDestroyWindowEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::event= *_event;


@X11::Xlib::Struct::XEvent::XExposeEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::count= *_count;
*X11::Xlib::Struct::XEvent::height= *_height;
*X11::Xlib::Struct::XEvent::width= *_width;
*X11::Xlib::Struct::XEvent::x= *_x;
*X11::Xlib::Struct::XEvent::y= *_y;


@X11::Xlib::Struct::XEvent::XFocusChangeEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::detail= *_detail;
*X11::Xlib::Struct::XEvent::mode= *_mode;


@X11::Xlib::Struct::XEvent::XGenericEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::evtype= *_evtype;
*X11::Xlib::Struct::XEvent::extension= *_extension;


@X11::Xlib::Struct::XEvent::XGraphicsExposeEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::count= *_count;
*X11::Xlib::Struct::XEvent::drawable= *_drawable;
*X11::Xlib::Struct::XEvent::height= *_height;
*X11::Xlib::Struct::XEvent::major_code= *_major_code;
*X11::Xlib::Struct::XEvent::minor_code= *_minor_code;
*X11::Xlib::Struct::XEvent::width= *_width;
*X11::Xlib::Struct::XEvent::x= *_x;
*X11::Xlib::Struct::XEvent::y= *_y;


@X11::Xlib::Struct::XEvent::XGravityEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::event= *_event;
*X11::Xlib::Struct::XEvent::x= *_x;
*X11::Xlib::Struct::XEvent::y= *_y;


@X11::Xlib::Struct::XEvent::XKeyEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::keycode= *_keycode;
*X11::Xlib::Struct::XEvent::root= *_root;
*X11::Xlib::Struct::XEvent::same_screen= *_same_screen;
*X11::Xlib::Struct::XEvent::state= *_state;
*X11::Xlib::Struct::XEvent::subwindow= *_subwindow;
*X11::Xlib::Struct::XEvent::time= *_time;
*X11::Xlib::Struct::XEvent::x= *_x;
*X11::Xlib::Struct::XEvent::x_root= *_x_root;
*X11::Xlib::Struct::XEvent::y= *_y;
*X11::Xlib::Struct::XEvent::y_root= *_y_root;


@X11::Xlib::Struct::XEvent::XKeymapEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::key_vector= *_key_vector;


@X11::Xlib::Struct::XEvent::XMapEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::event= *_event;
*X11::Xlib::Struct::XEvent::override_redirect= *_override_redirect;


@X11::Xlib::Struct::XEvent::XMapRequestEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::parent= *_parent;


@X11::Xlib::Struct::XEvent::XMappingEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::count= *_count;
*X11::Xlib::Struct::XEvent::first_keycode= *_first_keycode;
*X11::Xlib::Struct::XEvent::request= *_request;


@X11::Xlib::Struct::XEvent::XMotionEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::is_hint= *_is_hint;
*X11::Xlib::Struct::XEvent::root= *_root;
*X11::Xlib::Struct::XEvent::same_screen= *_same_screen;
*X11::Xlib::Struct::XEvent::state= *_state;
*X11::Xlib::Struct::XEvent::subwindow= *_subwindow;
*X11::Xlib::Struct::XEvent::time= *_time;
*X11::Xlib::Struct::XEvent::x= *_x;
*X11::Xlib::Struct::XEvent::x_root= *_x_root;
*X11::Xlib::Struct::XEvent::y= *_y;
*X11::Xlib::Struct::XEvent::y_root= *_y_root;


@X11::Xlib::Struct::XEvent::XNoExposeEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::drawable= *_drawable;
*X11::Xlib::Struct::XEvent::major_code= *_major_code;
*X11::Xlib::Struct::XEvent::minor_code= *_minor_code;


@X11::Xlib::Struct::XEvent::XPropertyEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::atom= *_atom;
*X11::Xlib::Struct::XEvent::state= *_state;
*X11::Xlib::Struct::XEvent::time= *_time;


@X11::Xlib::Struct::XEvent::XReparentEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::event= *_event;
*X11::Xlib::Struct::XEvent::override_redirect= *_override_redirect;
*X11::Xlib::Struct::XEvent::parent= *_parent;
*X11::Xlib::Struct::XEvent::x= *_x;
*X11::Xlib::Struct::XEvent::y= *_y;


@X11::Xlib::Struct::XEvent::XResizeRequestEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::height= *_height;
*X11::Xlib::Struct::XEvent::width= *_width;


@X11::Xlib::Struct::XEvent::XSelectionClearEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::selection= *_selection;
*X11::Xlib::Struct::XEvent::time= *_time;


@X11::Xlib::Struct::XEvent::XSelectionEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::property= *_property;
*X11::Xlib::Struct::XEvent::requestor= *_requestor;
*X11::Xlib::Struct::XEvent::selection= *_selection;
*X11::Xlib::Struct::XEvent::target= *_target;
*X11::Xlib::Struct::XEvent::time= *_time;


@X11::Xlib::Struct::XEvent::XSelectionRequestEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::owner= *_owner;
*X11::Xlib::Struct::XEvent::property= *_property;
*X11::Xlib::Struct::XEvent::requestor= *_requestor;
*X11::Xlib::Struct::XEvent::selection= *_selection;
*X11::Xlib::Struct::XEvent::target= *_target;
*X11::Xlib::Struct::XEvent::time= *_time;


@X11::Xlib::Struct::XEvent::XUnmapEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::event= *_event;
*X11::Xlib::Struct::XEvent::from_configure= *_from_configure;


@X11::Xlib::Struct::XEvent::XVisibilityEvent::ISA= ( __PACKAGE__ );
*X11::Xlib::Struct::XEvent::state= *_state;

=head2 XButtonEvent

Used for event type: ButtonPress, ButtonRelease

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

Used for event type: CirculateNotify

=head3 event

=head3 place

=head2 XCirculateRequestEvent

Used for event type: CirculateRequest

=head3 parent

=head3 place

=head2 XClientMessageEvent

Used for event type: ClientMessage

=head3 b

=head3 l

=head3 s

=head3 format

=head3 message_type

=head2 XColormapEvent

Used for event type: ColormapNotify

=head3 colormap

=head3 new

=head3 state

=head2 XConfigureEvent

Used for event type: ConfigureNotify

=head3 above

=head3 border_width

=head3 event

=head3 height

=head3 override_redirect

=head3 width

=head3 x

=head3 y

=head2 XConfigureRequestEvent

Used for event type: ConfigureRequest

=head3 above

=head3 border_width

=head3 detail

=head3 height

=head3 parent

=head3 value_mask

=head3 width

=head3 x

=head3 y

=head2 XCreateWindowEvent

Used for event type: CreateNotify

=head3 border_width

=head3 height

=head3 override_redirect

=head3 parent

=head3 width

=head3 x

=head3 y

=head2 XCrossingEvent

Used for event type: EnterNotify, LeaveNotify

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

Used for event type: DestroyNotify

=head3 event

=head2 XExposeEvent

Used for event type: Expose

=head3 count

=head3 height

=head3 width

=head3 x

=head3 y

=head2 XFocusChangeEvent

Used for event type: FocusIn, FocusOut

=head3 detail

=head3 mode

=head2 XGenericEvent

Used for event type: GenericEvent

=head3 evtype

=head3 extension

=head2 XGraphicsExposeEvent

Used for event type: GraphicsExpose

=head3 count

=head3 drawable

=head3 height

=head3 major_code

=head3 minor_code

=head3 width

=head3 x

=head3 y

=head2 XGravityEvent

Used for event type: GravityNotify

=head3 event

=head3 x

=head3 y

=head2 XKeyEvent

Used for event type: KeyPress, KeyRelease

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

Used for event type: KeymapNotify

=head3 key_vector

=head2 XMapEvent

Used for event type: MapNotify

=head3 event

=head3 override_redirect

=head2 XMapRequestEvent

Used for event type: MapRequest

=head3 parent

=head2 XMappingEvent

Used for event type: MappingNotify

=head3 count

=head3 first_keycode

=head3 request

=head2 XMotionEvent

Used for event type: MotionNotify

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

Used for event type: NoExpose

=head3 drawable

=head3 major_code

=head3 minor_code

=head2 XPropertyEvent

Used for event type: PropertyNotify

=head3 atom

=head3 state

=head3 time

=head2 XReparentEvent

Used for event type: ReparentNotify

=head3 event

=head3 override_redirect

=head3 parent

=head3 x

=head3 y

=head2 XResizeRequestEvent

Used for event type: ResizeRequest

=head3 height

=head3 width

=head2 XSelectionClearEvent

Used for event type: SelectionClear

=head3 selection

=head3 time

=head2 XSelectionEvent

Used for event type: SelectionNotify

=head3 property

=head3 requestor

=head3 selection

=head3 target

=head3 time

=head2 XSelectionRequestEvent

Used for event type: SelectionRequest

=head3 owner

=head3 property

=head3 requestor

=head3 selection

=head3 target

=head3 time

=head2 XUnmapEvent

Used for event type: UnmapNotify

=head3 event

=head3 from_configure

=head2 XVisibilityEvent

Used for event type: VisibilityNotify

=head3 state

=cut

# END GENERATED X11_Xlib_XEvent
# ----------------------------------------------------------------------------

1;
