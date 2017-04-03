package X11::Xlib;

use 5.008000;

use strict;
use warnings;
use base qw(Exporter DynaLoader);
use Carp;
use Try::Tiny;

our $VERSION = '0.09_05';

sub dl_load_flags { 1 } # Make PerlXLib.c functions available to other XS modules

bootstrap X11::Xlib;

require X11::Xlib::Struct;
require X11::Xlib::Visual;

my %_constants= (
# BEGIN GENERATED XS CONSTANT LIST
  const_cmap => [qw( AllocAll AllocNone )],
  const_error => [qw( BadAccess BadAlloc BadAtom BadColor BadCursor BadDrawable
    BadFont BadGC BadIDChoice BadImplementation BadLength BadMatch BadName
    BadPixmap BadRequest BadValue BadWindow )],
  const_event => [qw( ButtonPress ButtonRelease CirculateNotify ClientMessage
    ColormapNotify ConfigureNotify CreateNotify DestroyNotify EnterNotify
    Expose FocusIn FocusOut GraphicsExpose GravityNotify KeyPress KeyRelease
    KeymapNotify LeaveNotify MapNotify MappingNotify MotionNotify NoExpose
    PropertyNotify ReparentNotify ResizeRequest SelectionClear SelectionNotify
    SelectionRequest UnmapNotify VisibilityNotify )],
  const_event_mask => [qw( Button1MotionMask Button2MotionMask
    Button3MotionMask Button4MotionMask Button5MotionMask ButtonMotionMask
    ButtonPressMask ButtonReleaseMask ColormapChangeMask EnterWindowMask
    ExposureMask FocusChangeMask KeyPressMask KeyReleaseMask KeymapStateMask
    LeaveWindowMask NoEventMask OwnerGrabButtonMask PointerMotionHintMask
    PointerMotionMask PropertyChangeMask ResizeRedirectMask
    StructureNotifyMask SubstructureNotifyMask SubstructureRedirectMask
    VisibilityChangeMask )],
  const_input => [qw( AnyKey AnyModifier AsyncBoth AsyncKeyboard AsyncPointer
    Button1Mask Button2Mask Button3Mask Button4Mask Button5Mask ControlMask
    GrabModeAsync GrabModeSync LockMask Mod1Mask Mod2Mask Mod3Mask Mod4Mask
    Mod5Mask NoSymbol ReplayKeyboard ReplayPointer ShiftMask SyncBoth
    SyncKeyboard SyncPointer XK_VoidSymbol )],
  const_sizehint => [qw( PAspect PBaseSize PMaxSize PMinSize PPosition
    PResizeInc PSize PWinGravity USPosition USSize )],
  const_visual => [qw( VisualAllMask VisualBitsPerRGBMask VisualBlueMaskMask
    VisualClassMask VisualColormapSizeMask VisualDepthMask VisualGreenMaskMask
    VisualIDMask VisualRedMaskMask VisualScreenMask )],
  const_win => [qw( CopyFromParent InputOnly InputOutput )],
  const_winattr => [qw( CWBackPixel CWBackPixmap CWBackingPixel CWBackingPlanes
    CWBackingStore CWBitGravity CWBorderPixel CWBorderPixmap CWColormap
    CWCursor CWDontPropagate CWEventMask CWOverrideRedirect CWSaveUnder
    CWWinGravity )],
# END GENERATED XS CONSTANT LIST
);
my %_functions= (
# BEGIN GENERATED XS FUNCTION LIST
  fn_conn => [qw( ConnectionNumber XCloseDisplay XOpenDisplay XServerVendor
    XSetCloseDownMode XVendorRelease )],
  fn_event => [qw( XCheckMaskEvent XCheckTypedEvent XCheckTypedWindowEvent
    XCheckWindowEvent XFlush XNextEvent XPutBackEvent XSelectInput XSendEvent
    XSync )],
  fn_input => [qw( XAllowEvents XBell XGrabButton XGrabKey XGrabKeyboard
    XGrabPointer XQueryKeymap XUngrabButton XUngrabKey XUngrabKeyboard
    XUngrabPointer keyboard_leds )],
  fn_keymap => [qw( XDisplayKeycodes XGetKeyboardMapping XGetModifierMapping
    XKeysymToKeycode XLookupString XRefreshKeyboardMapping XSetModifierMapping
    load_keymap save_keymap )],
  fn_keysym => [qw( IsFunctionKey IsKeypadKey IsMiscFunctionKey IsModifierKey
    IsPFKey IsPrivateKeypadKey XConvertCase XKeysymToString XStringToKeysym
    char_to_keysym codepoint_to_keysym keysym_to_char keysym_to_codepoint )],
  fn_pix => [qw( XCreateBitmapFromData XCreatePixmap
    XCreatePixmapFromBitmapData XFreePixmap )],
  fn_screen => [qw( DefaultColormap DefaultDepth DefaultGC DefaultScreen
    DefaultVisual DisplayHeight DisplayHeightMM DisplayWidth DisplayWidthMM
    RootWindow ScreenCount )],
  fn_vis => [qw( XCreateColormap XFreeColormap XGetVisualInfo XMatchVisualInfo
    XVisualIDFromVisual )],
  fn_win => [qw( XCreateSimpleWindow XCreateWindow XDestroyWindow XGetGeometry
    XGetWMNormalHints XGetWMSizeHints XMapWindow XSetWMNormalHints
    XSetWMSizeHints XUnmapWindow )],
  fn_xtest => [qw( XTestFakeButtonEvent XTestFakeKeyEvent XTestFakeMotionEvent
    )],
# END GENERATED XS FUNCTION LIST
);
our @EXPORT_OK= map { @$_ } values %_constants, values %_functions;
our %EXPORT_TAGS= (
    %_constants,
    %_functions,
    constants => [ map { @$_ } values %_constants ],
    functions => [ map { @$_ } values %_functions ],
    all => \@EXPORT_OK,
);
our @EXPORT= @{ $EXPORT_TAGS{fn_keysym} };

# Used by XS.  In the spirit of letting perl users violate encapsulation
#  as needed, the XS code exposes its globals to Perl.
our (
    %_connections,              # weak-ref set of all connection objects, keyed by *raw pointer*
    $_error_nonfatal_installed, # boolean, whether handler is installed
    $_error_fatal_installed,    # boolean, whether handler is installed
    $_error_fatal_trapped,      # boolean, whether Xlib is dead from fatal error
    $on_error_cb,               # application-supplied callback
);

sub new {
    require X11::Xlib::Display;
    my $class= shift;
    X11::Xlib::Display->new(@_);
}

sub autoclose {
    my $self= shift;
    $self->{autoclose}= shift if @_;
    return $self->{autoclose};
}

sub DESTROY {
    my $self= shift;
    $self->XCloseDisplay() if $self->autoclose;
    my $ptr= $self->_pointer_value;
    delete $_connections{$ptr} if $ptr;
}

sub on_error {
    shift if $_[0] eq __PACKAGE__;
    my $callback= shift;
    if (defined $callback) {
        ref($callback) eq 'CODE' or croak "Expected coderef";
        X11::Xlib::_install_error_handlers(1,1);
    }
    $on_error_cb= $callback;
}
# called by XS, if error handler is installed
sub _error_nonfatal {
    my $event= shift;
    my $dpy= $event->display;
    if ($on_error_cb) {
        try { $on_error_cb->($dpy, $event); }
        catch { warn $_; };
    }
    if ($dpy && $dpy->can('on_error_cb') && $dpy->on_error_cb) {
        try { $dpy->on_error_cb->($dpy, $event); }
        catch { warn $_; };
    }
}
# called by XS, if error handler is installed
sub _error_fatal {
    my $conn= shift;
    $conn->_mark_dead; # this connection is dead immediately

    if ($on_error_cb) {
        try { $on_error_cb->($conn); }
        catch { warn $_; };
    }
    # also call a user callback in any Display object
    for my $dpy (values %_connections) {
        next unless defined $dpy && $dpy->can('on_error_cb') && defined $dpy->on_error_cb;
        try { $dpy->on_error_cb->($dpy); }
        catch { warn $_; };
    }

    # Kill all X11 connections, since Xlib internal state might be toast after this
    $_->_mark_dead for grep { defined } values %_connections;
}

sub _mark_dead {
    my $self= shift;
    $self->autoclose(0);
    my $ptr= $self->_pointer_value;
    $self->_set_pointer_value(undef);
    $self->{_dead}= 1;
    $self->{_pointer_value}= $ptr;
    # above line removed $self from cache.  Put it back.
    Scalar::Util::weaken( $_connections{$ptr}= $self );
}

1;

__END__


=head1 NAME

X11::Xlib - Low-level access to the X11 library

=head1 SYNOPSIS

  # C-style
  
  use X11::Xlib ':all';
  my $display = XOpenDisplay($conn_string);
  XTestFakeMotionEvent($display, undef, 50, 50);
  XFlush($display);
  
  # or, Object-Oriented perl style:
  
  use X11::Xlib;
  my $display= X11::Xlib->new($conn_string);  # shortcut for X11::Xlib::Display->new
  $display->fake_motion(undef, 50, 50)
  $display->flush;

  # Remap Caps_Lock to a Smiley face
  
  use X11::Xlib;
  my $display= X11::Xlib->new;
  my $caps_code= $display->keymap->find_keycode('Caps_lock')
    or die "Already remapped";
  $display->keymap->keymap->[$caps_code]= ["U263A","U263A"];
  $display->keymap->save;

  # Remap Caps_Lock to the table-flip emoji  (runs as daemon)
  use X11::Xlib ':constants';
  my $display= X11::Xlib->new;
  my $caps_code= $display->keymap->find_keycode('Caps_lock') || 0x42;
  $display->keymap->keymap->[$caps_code]= [];
  
  $display->keymap->save;
  my $wnd= $display->new_window(class => InputOnly, event_mask => KeyPress);
  while (1) {
    my $e= $wnd->wait_event();
    if ($e->type == KeyPress) {
      
    }
  }

=head1 DESCRIPTION

This module provides low-level access to Xlib functions.

This includes access to some X11 extensions like the X11 test library (Xtst).

If you import the Xlib functions directly, or call them as methods on an
instance of X11::Xlib, you get a near-C experience where you are required to
manage the lifespan of resources, XIDs are integers instead of objects, and the
library doesn't make any attempt to keep you from passing bad data to Xlib.

If you instead create a L<X11::Xlib::Display> object and call all your methods
on that, you get a more friendly wrapper around Xlib that helps you manage
resource lifespan, wraps XIDs with perl objects, and does some sanity checking
on the state of the library when you call methods.

=head1 ATTRIBUTES

The X11::Xlib connection is a hashref with a few attributes and methods
independent of Xlib.

=head2 autoclose

Boolean flag that determines whether the destructor will call L</XCloseDisplay>.
Defaults to true for connections returned by L</XOpenDisplay>.

=head1 FUNCTIONS

=head2 new

This is an alias for C<< X11::Xlib::Display->new >>, to help encourage using
the object oriented interface.

=head2 install_error_handlers

  X11::Xlib::install_error_handlers( $bool_nonfatal, $bool_fatal );

Error handling in Xlib is pretty bad.  The first problem is that non-fatal
errors are reported asynchronously in an API masquerading as if they were
synchronous function calls.
This is mildly annoying.  This library eases the pain by giving you a nice
L<XEvent|X11::Xlib::XEvent> object to work with, and the ability to deliver
the errors to a callback on your display or window object.

The second much larger problem is that fatal errors (like losing the connection
to the server) cause a mandatory termination of the host program.  Seriously.
The default behavior of Xlib is to print a message and abort, but even if you
install the C error handler to try to gracefully recover, when the error
handler returns Xlib still kills your program.  Under normal circumstances you
would have to perform all cleanup with your stack tied up through Xlib, but
this library cheats by using croak (C<longjmp>) to escape the callback and let
you wrap up your script in a normal manner.  B<However>, after a fatal
error Xlib's internal state could be damaged, so it is unsafe to make any more
Xlib calls.  This library tries to help enforce that by invalidating all the
connection objects.

If you really need your program to keep running your best bet is to state-dump
to shared memory and then C<exec()> a fresh copy of your script and reload the
dumped state.  Or use XCB instead of Xlib.

=head1 XLIB API

Most functions can be called as methods on the Xlib connection object, since
this is usually the first argument.  Every Xlib function listed below can be
exported, and you can grab them all with

  use X11::Xlib ':functions';

=head2 CONNECTION FUNCTIONS

=head3 XOpenDisplay

  my $display= X11::Xlib::XOpenDisplay($connection_string);

Instantiate a new (C-level) L</Display> instance. This object contains the
connection to the X11 display.  This will be an instance of C<X11::Xlib>.
The L<X11::Xlib::Display> object constructor is recommended instead.

The C<$connection_string> variable specifies the display string to open.
(C<"host:display.screen">, or often C<":0"> to connect to the only screen of
the only display on C<localhost>)
If unset, Xlib uses the C<$DISPLAY> environement variable.

If the handle goes out of scope, its destructor calls C<XCloseDisplay>, unless
you already called C<XCloseDisplay> or the X connection was lost.  (Be sure to
read the notes under L</install_error_handlers>

=head3 XCloseDisplay

  XCloseDisplay($display);
  # or, just:
  undef $display

Close a handle returned by C<XOpenDisplay>.  You do not need to call this method
since the handle's destructor does it for you, unless you want to forcibly
stop communicating with X and can't track down your references.  Once closed,
all further Xlib calls on the handle will die with an exception.

=head3 ConnectionNumber

  my $fh= IO::Handle->new_from_fd( $display->ConnectionNumber, 'w+' );

Return the file descriptor (integer) of the socket connected to the server.
This is useful for select/poll designs.
(See also: L<X11::Xlib::Display/wait_event>)

=head3 XSetCloseDownMode

  XSetCloseDownMode($display, $close_mode)

Determines what resources are freed upon disconnect.  See X11 documentation.

=head2 COMMUNICATION FUNCTIONS

Most of these functions return an L</XEvent> by way of an "out" parameter that
gets overwritten during the call, in the style of C.  The variable receiving the
event does not need to be initialized.

=head3 XNextEvent

  XNextEvent($display, my $event_return)
  ... # event scalar is populated with event

You probably don't want this.  It blocks forever until an event arrives, even
ignoring signals.  I added it for completeness.
See L<X11::Xlib::Display/wait_event> for a more perl-ish interface.

=head3 XCheckMaskEvent

=head3 XCheckWindowEvent

=head3 XCheckTypedEvent

=head3 XCheckTypedWindowEvent

  if ( XCheckMaskEvent($display, $event_mask, my $event_return) ) ...
  if ( XCheckTypedEvent($display, $event_type, my $event_return) ) ...
  if ( XCheckWindowEvent($display, $event_mask, $window, my $event_return) ) ...
  if ( XCheckTypedWindowEvent($display, $event_type, $window, my $event_return) ) ...

Each of these variations checks whether there is a matching event received from
the server and not yet extracted form the message queue.  If so, it stores the
event into C<$event_return> and returns true.  Else it returns false without
blocking.

(Xlib also has another variant that uses a callback to choose which message to
 extract, but I didn't implement that because it seemed like a pain and probably
 nobody would use it.)

=head3 XSendEvent

  XSendEvent($display, $window, $propagate, $event_mask, $xevent)
    or die "Xlib hates us";

Send an XEvent to the server, to be redispatched however appropriate.

=head3 XPutBackEvent

  XPutBackEvent($display, $xevent)

Push an XEvent back onto your own incoming queue.
This can presumably put arbitrarily bogus events onto your own queue
since it returns void.

=head3 XFlush

  XFlush($display)

Push any queued messages to the X11 server.  Some Xlib calls perform an
implied flush of the queue, while others don't.  If you're wondering why
nothing happened when you called an XTest function, this is why.

=head3 XSync

  XSync($display);
  XSync($display, $discard);

Force a round trip to the server to process all pending messages and receive
the responses (or errors).  A true value for the second argument will wipe your
incoming event queue.

=head3 XSelectInput

  XSelectInput($display, $window, $event_mask)

Change the event mask for a window.

=head2 SCREEN ATTRIBUTES

Xlib provides opaque L</Display> and L</Screen> structs which have locally-
stored attributes, but which you must use method calls to access.
For each attribute of a screen, there are four separate ways to access it:

  DisplayFoo($display, $screen_num);     # C Macro like ->{screens}[$screen_num]{foo}
  XDisplayFoo($display, $screen_num);    # External linked function from Xlib
  FooOfScreen($screen_pointer);          # C Macro like ->{foo}
  XFooOfScreen($screen_pointer);         # External linked function from Xlib

Since screen pointers become invalid when the Display is closed, I decided not
to expose them, and since DisplayFoo and XDisplayFoo are identical I decided
to only implement the first since it makes one less symbol to link from Xlib.

So, if you grab some sample code from somewhere and wonder where those functions
went, drop the leading X and do a quick search on this page.

=head3 ScreenCount

  my $n= ScreenCount($display);

Return number of configured L</Screen>s of this display.

=head3 DisplayWidth

=head3 DisplayHeight

  my $w= DisplayWidth($display, $screen);
  my $h= DisplayHeight($display, $screen);
  # use instead of WidthOfScreen, HeightOfScreen

Return the width or height of screen number C<$screen>.  You can omit the
C<$screen> paramter to use the default screen of your L<Display> connection.

=head3 DisplayWidthMM

=head3 DisplayHeightMM

  my $w= DisplayWidthMM($display, $screen);
  my $h= DisplayHeightMM($display, $screen);
  # use instead of WidthMMOfScreen, HeightMMOfScreen

Return the physical width or height (in millimeters) of screen number C<$screen>.
You can omit the screen number to use the default screen of the display.

=head3 RootWindow

  my $xid= RootWindow($display, $screen)

Return the XID of the X11 root window.  C<$screen> is optional, and defaults to the
default screen of your connection.
If you want a Window object, call this method on L<X11::Xlib::Display>.

=head3 DefaultVisual

  my $visual= DefaultVisual($display, $screen);
  # use instead of DefaultVisualOfScreen

Screen is optional and defaults to the default screen of your connection.
This returns a L</Visual>, not a L</XVisualInfo>.

=head3 DefaultDepth

  my $bits_per_pixel= DefaultDepth($display, $screen);
  # use instead of DefaultDepthOfScreen, DisplayPlanes, PlanesOfScreen

Return bits-per-pixel of the root window of a screen.
If you omit C<$screen> it uses the default screen.

=head2 VISUAL/COLORMAP FUNCTIONS

=head3 XMatchVisualInfo

  XMatchVisualInfo($display, $screen, $depth, $class, my $xvisualinfo_return)
    or die "Don't have one of those";

Loads the details of a L</Visual> into the final argument,
which must be an L</XVisualInfo> (or undefined, to create one)

Returns true if it found a matching visual.

=head3 XGetVisualInfo

  my @info_structs= XGetVisualInfo($display, $mask, $xvis_template);

Returns a list of L</XVisualInfo> each describing an available L</Visual>
which matches the template you provided. (which is also an C<XVisualInfo>)

C<$mask> can be any combination of:

  VisualIDMask
  VisualScreenMask
  VisualDepthMask
  VisualClassMask
  VisualRedMaskMask
  VisualGreenMaskMask
  VisualBlueMaskMask
  VisualColormapSizeMask
  VisualBitsPerRGBMask
  VisualAllMask

each describing a field of L<X11::Xlib::XVisualInfo> which is relevant
to your search.

=head3 XVisualIDFromVisual

  my $vis_id= XVisualIDFromVisual($visual);
  # or, assuming $visual is blessed,
  my $vis_id= $visual->id;

Pull the visual ID out of the opaque object $visual.

If what you wanted was actually the L</XVisualInfo> for a C<$visual>, then try:

  my ($vis_info)= GetVisualInfo($display, VisualIDMask, { visualid => $vis_id });
  # or with Display object:
  $display->visual_by_id($vis_id);

=head3 XCreateColormap

  my $xid= XCreateColormap($display, $rootwindow, $visual, $alloc_flag);
  # or 99% of the time
  my $xid= XCreateColormap($display, RootWindow($display), DefaultVisual($display), AllocNone);
  # and thus these are the defaults
  my $xid= XCreateColormap($display);

Create a L</Colormap>.  The C<$visual> is a L</Visual>
object, and the C<$alloc_flag> is either C<AllocNone> or C<AllocAll>.

=head3 XFreeColormap

  XFreeColormap($display, $colormap);

Delete a L</Colormap>, and set the colormap to C<None> for any window that was
using it.

=head3 Colormap TODO

  XInstallColormap XUninstallColormap, XListInstalledColormaps
  XGetWMColormapWindows XSetWMColormapWindows, XSetWindowColormap
  XAllocColor XStoreColors XFreeColors XAllocColorPlanes XAllocNamedColor
  XQueryColors XCopyColormapAndFree

If anyone actually needs palette graphics anymore, send me a patch :-)

=head2 PIXMAP FUNCTIONS

=head3 XCreatePixmap

  my $xid= XCreatePixmap($display, $drawable, $width, $height, $depth);

The C<$drawable> parameter is just used to determine the screen.
You probably want to pass either C<DefaultRootWindow($display)> or the window
you're creating the pixmap for.

=head3 XFreePixmap

  XFreePixmap($display, $pixmap);

=head3 XCreateBitmapFromData

  my $pixmap_xid= XCreateBitmapFromData($display, $drawable, $data, $width, $height);

First, be aware that in X11, a "bitmap" is literally a "Bit" "Map" (1 bit per pixel).

The C<$drawable> determines which screen the pixmap is created for.
The C<$data> is a string of bytes.

The C<$data> should technically be opaque, written by another X11 function
after having rendering graphics to a pixmap or something, but since those
aren't implemented here yet, you'll just have to know the format.

=head3 XCreatePixmapFromBitmapData

  my $pixmap_xid= XCreatePixmapFromBitmapData($display, $drawable, $data,
    $width, $height, $fg, $bg, $depth);

This function uses a bitmap (1 bit per pixel) and a foreground and background
color to build a pixmap of those two colors.  It's basically upscaling color
from monochrome to C<$depth>.

=head2 WINDOW FUNCTIONS

=head3 XCreateWindow

  my $wnd_xid= XCreateWindow(
    $display,
    $parent_window,  # such as DefaultRootWindow()
    $x, $y,
    $width, $height,
    $border_width,
    $color_depth,    # such as $visual_info->depth or DefaultDepth($display)
    $class,          # InputOutput, InputOnly, or CopyFromParent
    $visual,         # such as $visual_info->visual or DefaultVisual($display)
    $attr_mask,      # indicates which fields of \%attrs are initialized
    \%attrs          # struct XSetWindowAttributes or hashref of its fields
  );

The parameters the probably need more explanation are C<$visual> and C<%attrs>.

C<$visual> is a L</Visual>.  You probably either want to use the default visual
of the screen (L</DefaultVisual>) or look up your own visual using
L</XGetVisualInfo> or L</XMatchVisualInfo> (which is a L</VisualInfo>, and has
an attribute C<< ->visual >>).  In the second case, you should also pass
C<< $visual_info->depth >> as the C<$depth> parameter, and create a matching
L</Colormap> which you pass via the C<\%attrs> parameter.

Since this function didn't have nearly enough parameters for the imaginations
of the Xlib creators, they added the full L<X11::Xlib::XSetWindowAttributes> structure
as a final argument.  But to save you the trouble of setting all I<those>
fields, they added an C<$attr_mask> to indicate which fields you are using.

The window is initially un-mapped (i.e. hidden).  See L</XMapWindow>

=head3 XCreateSimpleWindow

  my $wnd_xid= XCreateSimpleWindow(
    $display, $parent_window,
    $x, $y, $width, $height,
    $border_width, $border_color, $background_color
  );

This function basically creates a "child window", clipped to its parent, with
all the same visual configuration.

It is initially unmapped.  See L</XMapWindow>.

=head3 XMapWindow

  XMapWindow($display, $window);

Ask the X server to show a window.  This call is asynchronous and you should call
L</XFlush> if you want it to appear immediately.  The window will only appear if
the parent window is also mapped.  The server sends back a MapNotify event if
the Window event mask allows it, and if a variety of other conditions are met.
It's really pretty complicated and you should read the offical docs.

=head3 XGetGeometry

  my ($root, $x, $y, $width, $height, $border_width, $color_depth);
  XGetGeometry($display, $drawable, $root, $x, $y, $width, $height, $border_width, $color_depth)
    or die "XGetGeometry failed";
  # All vars declared above should now be defined

This function loads the geometry of the window into the variables you supply.
You may omit the ones you don't care about.

=head3 XGetWMNormalHints

  my ($hints_out, $supplied_fields_out);
  XGetWMNormalHints($display, $window, $hints_out, $supplied_fields_out)
    or warn "Doesn't have WM hints";

If a window has Window Manager Normal Hints defined on it, this function will
store them into the C<$hints_out> variable (which will become a L<X11::Xlib::XSizeHints>
if it wasn't already).  It will also set the bits of C<$supplied_fields_out> to
indicate which fields the X11 server knows about.  This is different from the
bits in C<< $hints_out->flags >> that indicate which individual fields are defined
for this window.

=head3 XSetWMNormalHints

  XSetWMNormalHints($display, $window, $hints);

Set window manager hints for the specified window.  C<$hints> is an instance of
L<X11::Xlib::XSizeHints>, or a hashref of its fields.  Note that the C<< ->flags >>
member of this struct will be initialized for you if you pass a hashref, according
to what fields exist in the hashref.

=head3 XUnmapWindow

  XUnmapWindow($display, $window);

Hide a window.

=head3 XDestroyWindow

  XDestroyWindow($display, $window);

Unmap and destroy a window.

=head2 XTEST INPUT SIMULATION

These methods create fake server-wide input events, useful for automated testing.
They are available through the XTEST extension.

Don't forget to call L</XFlush> after these methods, if you want the events to
happen immediately.

=head3 XTestFakeMotionEvent

  XTestFakeMotionEvent($display, $screen, $x, $y, $EventSendDelay)

Fake a mouse movement to position C<$x>,C<$y> on screen number C<$screen>.

The optional C<$EventSendDelay> parameter specifies the number of milliseconds to wait
before sending the event. The default is 10 milliseconds.

=head3 XTestFakeButtonEvent

  XTestFakeButtonEvent($display, $button, $pressed, $EventSendDelay)

Simulate an action on mouse button number C<$button>. C<$pressed> indicates whether
the button should be pressed (true) or released (false). 

The optional C<$EventSendDelay> parameter specifies the number of milliseconds ro wait
before sending the event. The default is 10 milliseconds.

=head3 XTestFakeKeyEvent

  XTestFakeKeyEvent($display, $kc, $pressed, $EventSendDelay)

Simulate a event on any key on the keyboard. C<$kc> is the key code (8 to 255),
and C<$pressed> indicates if the key was pressed or released.

The optional C<$EventSendDelay> parameter specifies the number of milliseconds to wait
before sending the event. The default is 10 milliseconds.

=head2 KEYSYM FUNCTIONS

These utility functions help identify and convert KeySym values, and do not
depend on a connection to an X server.

=head3 XKeysymToString

  XKeysymToString($keysym)

Return the human-readable string for character number C<$keysym>.

C<XKeysymToString> is the exact reverse of C<XStringToKeysym>.

=head3 XStringToKeysym

  XStringToKeysym($string)

Return the keysym number for the human-readable character C<$string>.

C<XStringToKeysym> is the exact reverse of C<XKeysymToString>.

=head3 codepoint_to_keysym

  my $keysym= codepoint_to_keysym(ord($char));

Convert a Unicode codepoint to a keysym value.  This isn't a true Xlib
function, but fills a gap in the API.  Every normal unicode codepoint has a
keysym value, but if you pass an invalid codepoint you will get C<undef>.

=head3 keysym_to_codepoint

  my $cp= keysym_to_codepoint($keysym);
  my $char= defined $cp? chr($cp) : undef;

Convert a KeySym to a unicode codepoint.  Many KeySyms (like F1, Control, etc)
do not have any character associated with them, and will return C<undef>.

=head3 char_to_keysym

Like L</codepoint_to_keysym> example above, but takes a string from which it
calls L<ord()> on the first character.  Returns undef if the string doesn't
have a first character.

=head3 keysym_to_char

Like L</keysym_to_codepoint> example above, but returns a string if there is
a valid codepoint, and C<undef> otherwise.

=head3 XConvertCase

  XConvertCase($keysym, $lowercase_out, $uppercase_out);

Return the lowercase and uppercase KeySyms values for C<$keysym>.

=head3 IsFunctionKey

  IsFunctionKey($keysym)

Return true if C<$keysym> is a function key (F1 .. F35)

=head3 IsKeypadKey

  IsKeypadKey($keysym)

Return true if C<$keysym> is on numeric keypad.

=head3 IsMiscFunctionKey

  IsMiscFunctionKey($keysym)

Return true is key if... honestly don't know :\

=head3 IsModifierKey

  IsModifierKey($keysym)

Return true if C<$keysym> is a modifier key (Shift, Alt).

=head3 IsPFKey

  IsPFKey($keysym)

Xlib docs are fun.  No mention of what "PF" might be.

=head3 IsPrivateKeypadKey

  IsPrivateKeypadKey($keysym)

True for vendor-private key codes.

=head2 KEYCODE FUNCTIONS

=head3 XQueryKeymap

  XQueryKeymap($display)

Return a list of the key codes currently pressed on the keyboard.

=head3 XGrabKeyboard

  $bool= XGrabKeyboard($display, $window, $owner_events, $pointer_mode, $keyboard_mode, $timestamp)

=head3 XUngrabKeyboard

  XUngrabKeyboard($display, $timestamp)

=head3 XGrabKey

  XGrabKey($display, $keycode, $modifiers, $window, $owner_events, $pointer_mode, $keyboard_mode)

Register a window to receive any matching key events, optionally hiding them
from the normal target window.

C<$keycode> is the keyboard scan code to watch for, or L<AnyKey>.
C<$modifiers> is a bit mask combined from C<ControlMask>, C<LockMask>,
C<Mod1Mask>, C<Mod2Mask>, C<Mod3Mask>, C<Mod4Mask>, C<Mod5Mask>, C<ShiftMask>,
or the special mask C<AnyModifier> which means any I<or none> of the modifiers.
C<$window> is the XID or L<X11::Xlib::Window> to direct events toward.
C<$owner_events> is a boolean of whether to also let the normal target of the
key event receive them.  C<$pointer_mode> and C<$keyboard_mode> are either
C<GrabModeSync> or C<GrabModeAsync>.

=head3 XUngrabKey

  XUngrabKey($display, $keycode, $modifiers, $window)

Cancel a grab registered by L</XGrabKey>.

=head3 XGrabPointer

  $bool= XGrabPointer($display, $window, $owner_events, $event_mask,
    $pointer_mode, keyboard_mode, confine_to, cursor, timestamp)

=head3 XUngrabPointer

  XUngrabPointer(dpy, timestamp)

=head3 XGrabButton

  XGrabButton($display, $button, $modifiers, $window, $owner_events,
    $event_mask, $pointer_mode, $keyboard_mode, $confine_to, $cursor)

=head3 XUngrabButton

  XUngrabButton($display, $button, $modifiers, $window)

=head3 XAllowEvents

  XAllowEvents($display, $event_mode, $timestamp)

=head3 XGetKeyboardMapping

  XGetKeyboardMapping($display, $keycode, $count)

Return an array of KeySym numbers corresponding to C<$count> keys, starting
at C<$keycode>.

Each value in the array corresponds to a combination of key modifiers (Shift,
Lock, Mode).  The X11 server may return a variable number of codes per key,
which you can determine by dividing the total number of values returned by this
function by the C<$count>.

For a more perl-friendly interface, see L</load_keymap>.  For object-oriented
access, see L<X11::Xlib::Keymap>.

=head3 XSetKeyboardMapping

  XChangeKeyboardMapping($display, $first_keycode, $keysym_per_keycode, \@keysyms, $num_codes);
  
  # Best explained with an example...
  my @keycodes= (
    ord('a'), ord('A'), ord('a'), ord('A'),  # want to assign these to KeyCode 38
    ord('s'), ord('S'), ord('s'), ord('S'),  # and these to KeyCode 39
  );
  XChangeKeyboardMapping($display, 38, 4, \@keycodes, scalar @keycodes);

Update some/all of the KeySyms attached to one or more KeyCodes.
In the example above, only the first 4 KeySyms of each KeyCode will be changed.
Specify a larger number of C<$keysym_per_keycode> to overwrite more of them.

For a more perl-friendly interface, see L</save_keymap>.  For object-oriented
access, see L<X11::Xlib::Keymap>.

=head3 load_keymap

  my $keymap= load_keymap($display, $symbolic, $min_key, $max_key);
  my $keymap= load_keymap($display, $symbolic); # all keys
  my $keymap= load_keymap($display); # all keys, symbolic=2

This is a wrapper around L</XGetKeyboardMapping> which returns an arrayref
of arrayrefs, and also translates KeySym values into KeySym names or unicode
characters.  If C<$symbolic> is 0, the elements of the arrays are numbers.
If C<$symbolic> is 1, the elements are the KeySym name (or integers, if a name
is not available).
If C<$symbolic> is 2, the elements are characters for every KeySym that can be
un-ambiguously represented by a character, else KeySym names, else integers.

The minimum KeyCode of an X server is never below 8.  If you omit C<$min_key>
it defaults to 0, and so the returned array will always have at least 8 undef
values at the start.  This minor waste allows you to index into the array
directly with a KeyCode.

=head3 save_keymap

  save_keymap($display, \@keymap, $min_key, $max_key);
  save_keymap($display, \@keymap); # to update all keycodes

This is a wrapper around L</XChangeKeyboardMapping> that accepts the same
array-of-arrays returned by L</load_keymap>.  The first element of the array
is assumed to be C<$min_key> B<unless the array is longer than C<$max_key> >
in which case the array is assumed to start at 0 and you are requesting that
only elements C<($min_key .. $max_key)> be sent to the X server.

Each element of the inner array can be an integer KeySym, or a KeySym name
recognized by L</XStringToKeysym>, or a single unicode character.
If the KeySym is an integer, it must be at least two integer digits, which
all real KeySyms should be (other that NoSymbol which has the value 0, and
should be represented by C<undef>) to avoid ambiguity with the characters of
the number keys.

=head3 XGetModifierMapping

  my $mapping= XGetModifierMapping($display);

Return an arrayref of 8 arrayrefs, one for each of the possible modifiers.
The inner arrayrefs can contain a variable number of key codes which belong
to the modifier group.  See L<X11::Xlib::Keymap> for an explanation.

=head3 XSetModifierMapping

  XSetModifierMapping($display, \@modifiers);

C<@modifiers> is an array of 8 arrayrefs, each holding the set of key codes
that are part of the modifier.  This is the same format as returned by
C<XGetModifierMapping>.

=head3 XRefreshKeyboardMapping

  XRefreshKeyboardMapping($mapping_event);

Given a XMappingEvent, reload the internal Xlib cache for the parts of the
keymap or modmap which have changed.

The functions below (using the internal Xlib cache) are an alternative to
processing the keymap directly.

=head3 XLookupString

  XLookupString($key_event, $text_out, $keycode_out);

Given a XKeyEvent, translate the key code and modifiers vs. the internal Xlib
cached keymap/modmap and write the text name of the key into C<$text_out>.
This will either be a name of a key, or the character the key normally
generates in a Latin-1 environment.  If C<$keycode_out> is given, it will be
overwritten with the numeric value of the KeySym.

(If you want to do more than Latin-1, see L<X11::Xlib::Keymap> for utilities
 to manipulate the keymap directly.)

=head3 XKeysymToKeycode

  XKeysymToKeycode($display, $keysym)

Return the key code corresponding to the character number C<$keysym>.

=head3 XBell

  XBell($display, $percent)

Make the X server emit a sound.

=head1 STRUCTURES

Xlib has a lot of C B<struct>s.  Most of them do not have much "depth"
(i.e. pointers to further nested structs) and so I chose to represent them
as simple blessed scalar refs to a byte string.  This gives you the ability
to pack new values into the struct which might not be known by this module,
and keeps the object relatively lightweight.  Most also have a C<pack> and
C<unpack> method which convert from/to a hashref.
Sometimes however these structs do contain a raw pointer value, and so you
should take extreme care if you do modify the bytes.

Xlib also has a lot of B<opaque pointers> where they just give you a pointer
and some methods to access it without any explanation of its inner fields.
I represent these with the matching Perl feature for blessed opaque references,
so the only way to interact with the pointer value is through XS code.
In each case, when the object goes out of scope, this library calls any
appropriate "Free" function.

Finally, there are lots of objects which exist on the server, and Xlib just
gives you a number (L</XID>) to refer to them when making future requests.
Windows are the most common example.  Since these are simple integers, and
can be shared among any program connected to the same display, this module
allows a mix of simple scalar values or blessed objects when calling any
function that expects an C<XID>.  The blessed objects derive from L<X11::Xlib::XID>.

Most supported structures have their own package with further documentation,
but here is a quick list:

=head2 Display

Represents a connection to an X11 server.  Xlib provides an B<opaque pointer>
C<Display*> on which you can call methods.  These are represented by this
package, C<X11::Xlib>.  The L<X11::Xlib::Display> package provides a more
perl-ish interface and some helper methods to "DWIM".

=head2 Screen

The Xlib C<Screen*> is not exported by this module, since most methods that
use a C<Screen*> have a matching method that uses a C<Display*>.
If you are using the object-oriented L<Display|X11::Xlib::Display> you then
get L<Screen|X11::Xlib::Screen> objects for convenience, but they are just
a wrapper around the Display and screen number instead of screen pointer.

=head2 Visual

An B<opaque pointer> describing binary representation of pixels for some mode of
the display.  There's probably only one in use on the entire display (i.e. RGBA)
but Xlib makes you look it up and pass it around to various functions.

=head2 XVisualInfo

A more useful B<struct> describing a Visual.  See L<X11::Xlib::XVisualInfo>.

=head2 XEvent

A B<struct> that can hold any sort of message sent to/from the server.  The struct
is a union of many other structs, which you can read about in L<X11::Xlib::XEvent>.

=head2 Colormap

An B<XID> referencing what used to be a palette for 8-bit graphics but which is
now mostly a useless appendage to be passed to L</XCreateWindow>.  When using
the object-oriented C<Display>, these are wrapped by L<X11::Xlib::Colormap>.

=head2 Pixmap

An B<XID> referencing a rectangular pixel buffer.  Has dimensions and color
depth and is bound to a L</Screen>.  Can be used for copying images, or tiling.
When using the object-oriented C<Display>, these are wrapped by L<X11::Xlib::Pixmap>.

=head2 Window

An B<XID> referencing a Window.  Used for painting, event/input delivery, and
having data tagged to them.  Not abused nearly as much as the Win32 API abuses
its Window structures.  See L<X11::Xlib::Window> for details.

=head1 SYSTEM DEPENDENCIES

Xlib libraries are found on most graphical Unixes, but you might lack the header
files needed for this module.  Try the following:

=over

=item Debian (Ubuntu, Mint)

sudo apt-get install libxtst-dev

=item Fedora

sudo yum install libXtst-devel

=back

=head1 SEE ALSO

=over 4

=item L<X11::GUITest>

This module provides a higher-level API for X input simulation and testing.

=item L<Gtk2>

Functions provided by X11/Xlib are mostly included in the L<Gtk2> binding, but
through the GTK API and perl objects.

=item L<X11::Protocol>

Pure-perl implementation of the X11 protocol.

=back

=head1 TODO

This module still only covers a fraction of the Xlib API.
Patches are welcome :)

=head1 AUTHOR

Olivier Thauvin, E<lt>nanardon@nanardon.zarb.orgE<gt>

Michael Conrad, E<lt>mike@nrdvana.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2010 by Olivier Thauvin

Copyright (C) 2017 by Michael Conrad

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
