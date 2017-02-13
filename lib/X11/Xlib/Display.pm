package X11::Xlib::Display;
use strict;
use warnings;
use parent 'X11::Xlib';
use Scalar::Util;
use Carp;

require X11::Xlib::Screen;
require X11::Xlib::Colormap;
require X11::Xlib::Window;
require X11::Xlib::Pixmap;

=head1 ATTRIBUTES

=head2 connection

Instance of L</X11::Xlib> which acts as the C<Display *> parameter to all
X11 function calls.

=head3 connection_fh

Return the file handle to the X11 connection.  Useful for C<select>.

=cut

sub connection { shift->{connection} }

sub connection_fh {
    my $self= shift;
    $self->{connection_fh} ||= do {
        require IO::Handle;
        IO::Handle->new_from_fd( $self->ConnectionNumber, 'w+' );
    };
}

sub _xid_cache { $_[0]{_xid_cache} }
sub _get_cached_xid {
    my ($self, $xid, $class)= @_;
    my $obj;
    return $self->{_xid_cache}{$xid} || do {
        $obj= $class->new(display => $self, xid => $xid, autofree => 0);
        Scalar::Util::weaken( $self->{_xid_cache}{$xid}= $obj );
        $obj;
    };
}

=head3 screen_count

   for (0 .. $display->screen_count - 1) { ... }

Number of screens available on this display.

=head3 default_screen_num

Number of the default screen

=head3 screen

   my $screen= $display->screen();  # alias for $display->default_screen
   my $screen= $display->screen(3); # or some specific screen

Get a L<X11::Xlib::Screen> object, to query per-screen attributes.
(which is most of them)

=head3 default_screen

Alias for C<< $display->screen($display->default_screen_num) >>.

=cut

sub screen_count { $_[0]{screen_count} }
sub default_screen_num { $_[0]{default_screen_num} }
sub default_screen { $_[0]{default_screen} }
sub screen {
    @_ > 1? $_[0]{screens}[$_[1]] : $_[0]{default_screen};
}

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

Setting a value for this attribute automatically installs the Xlib error
handler.

Note that this callback is called from XS context, so your exceptions will
not travel up the stack.  Also note that on Xlib fatal errors, you cannot
call any more Xlib functions on the current connection, or on any connection
once the callback returns.

=cut

sub on_error_cb {
    my ($self, $callback)= @_;
    if (@_ > 1) {
        if (defined $callback) {
            ref($callback) eq 'CODE' or croak "Expected coderef";
            X11::Xlib::_install_error_handlers(1,1);
        }
        $self->{on_error_cb}= $callback;
    }
    $_[0]{on_error_cb}
}

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
        if (ref($X11::Xlib::_connections{$conn->_pointer_value})->isa(__PACKAGE__)) {
            carp "re-using existing Display object for this connection";
            return $X11::Xlib::_connections{$conn->_pointer_value};
        }
    }
    else {
        $args->{connection}= X11::Xlib::XOpenDisplay(defined $conn? ($conn) : ())
            or croak "Unable to connect to X11 server";
    }
    $self= bless $args, $class;
    my $key= $self->{connection}->_pointer_value;
    Scalar::Util::weaken( $X11::Xlib::_connections{$key}= $self );
    
    # initialize a few attributes that are commonly accessed
    $self->{screen_count}= $self->ScreenCount;
    $self->{default_screen_num}= $self->DefaultScreen;
    $self->{screens}[$_]= X11::Xlib::Screen->_new( display => $self, screen_number => $_ )
        for 0 .. $self->{screen_count} - 1;
    $self->{default_screen}= $self->{screens}[ $self->{default_screen_num} ];

    return $self;
}

sub DESTROY {
    my $self= shift;
    $self->XCloseDisplay;
}

1;

=head1 METHODS

=head2 COMMUNICATION FUNCTIONS

=head3 wait_event

  my $event= $display->wait_event(
    window     => $window,
    event_type => $type,
    event_mask => $mask,
    timeout    => $seconds,
  );

Each argument is optional.  If you specify C<window>, it will only return events
for that window.  If you specify C<event_mask>, it will limit which types of
event can be returned.  if you specify C<event_type>, then only that type of
event can be returned.

C<timeout> is a number of seconds (can be fractional) to wait for a matching
event.  If C<timeout> is zero, the function acts like C<XCheckEvent> and returns
immediately.  If C<timeout> is not specified the function will wait indefinitely.
However, the wait is always interrupted by pending data from the X11 server, or
signals, so in practice the wait won't be very long and you should call it in
an appropriate loop.

Returns an L<X11::Xlib::XEvent> on success, or undef on timeout or interruption.

=cut

sub wait_event {
    my ($self, %args)= @_;
    my $event;
    $self->_wait_event(
        $args{window}||0,
        $args{event_type}||0,
        $args{event_mask}||0x7FFFFFFF,
        $event,
        ($args{timeout}||0)*1000 || 0x7FFFFFFF
    )
    ? $event : undef;
}

=head3 send_event

  $display->send_event( $xevent,
    window     => $wnd,
    propagate  => $bool,
    event_mask => $mask
  );

C<propogate> defaults to true.  C<window> defaults to the window field of the
event.  C<event_mask> must be specified but eventually I want to have it auto-
calculate from the event type.

=head3 putback_event

  $display->putback_event($event);

"un-get" or "unshift" an event back onto your own message queue.

=cut

sub send_event {
    my ($self, $event, %args)= @_;
    defined $args{event_mask} or croak "event_mask is required (for now)";
    defined $args{window} or $args{window}= $event->window;
    defined $args{propagate} or $args{propagate}= 1;
    $self->XSendEvent($args{window}, $args{propogate}, $args{event_mask}, $event);
}

sub putback_event {
    my ($self, $event)= @_;
    $self->XPutBackEvent($event);
}

=head3 flush

Push any queued messages to the X server.

=head3 flush_sync

Push any queued messages to the x server and wait for all replies.

=head3 flush_sync_discard

Push any queued messages to the server, wait for replies, and then delete the
entire input event queue.

=cut

sub flush              { shift->XFlush }
sub flush_sync         { shift->XSync }
sub flush_sync_discard { shift->XSync(1) }

=head3 fake_motion

  $display->fake_motion($screen, $x, $y, $send_delay = 10);

Generate a fake motion event on the server, optionally waiting
C<$send_delay> milliseconds.  If C<$screen> is -1, it references the
screen which the mouse is currently on.

=head3 fake_key

  $display->fake_button($button_number, $is_press, $send_delay = 10);

Generate a fake mouse button press or release.

=head3 fake_button

  $display->fake_key($key_code, $is_press, $send_delay = 10);

Generate a fake key press or release.

=cut

sub fake_motion { shift->XTestFakeMotionEvent(@_) }
sub fake_button { shift->XTestFakeButtonEvent(@_) }
sub fake_key    { shift->XTestFakeKeyEvent(@_) }

=head2 SCREEN ATTRIBUTES

The following convenience methods pass-through to the default screen object.

=head3 root_window

L<X11::Xlib::Screen/root_window>

=head3 width

L<X11::Xlib::Screen/width>

=head3 height

L<X11::Xlib::Screen/height>

=head3 width_mm

L<X11::Xlib::Screen/width_mm>

=head3 height_mm

L<X11::Xlib::Screen/height_mm>

=head3 visual

L<X11::Xlib::Screen/visual>

=head3 depth

L<X11::Xlib::Screen/depth>

=head3 colormap

L<X11::Xlib::Screen/colormap>

=cut

sub root_window  { shift->{default_screen}->root_window }
sub width        { shift->{default_screen}->width }
sub height       { shift->{default_screen}->height }
sub width_mm     { shift->{default_screen}->width_mm }
sub height_mm    { shift->{default_screen}->height_mm }
sub visual       { shift->{default_screen}->visual }
sub depth        { shift->{default_screen}->depth }
sub colormap     { shift->{default_screen}->colormap }

=head2 VISUAL/COLORMAP FUNCTIONS

=head3 visual_info

  my $info= $display->visual_info();  # for default visual of default screen
  my $info= $display->visual_info($visual);
  my $info= $display->visual_info($visual_id);

Returns a L<X11::Xlib::XVisualInfo> for the specified visual, or undef if
none was found.  See L<X11::Xlib/Visual> for an explanation of the different
types of object.

=head3 match_visual_info

  my $info= $display->find_visual_info($screen_num, $color_depth, $class)
    or die "No matching visual";

=head3 search_visual_info

  # Search all visuals...
  my @infos= $display->search_visual_info(
    visualid      => $id,
    screen        => $screen,
    depth         => $depth,
    class         => $class,
    red_mask      => $mask,
    green_mask    => $mask,
    blue_mask     => $mask,
    colormap_size => $size,
    bits_per_rgb  => $n,
  );

Search for a visual by any of its VisualInfo members.  You can specify as
many or as few fields as you like.

=cut

sub visual_info {
    my ($self, $visual_or_id)= @_;
    my $id= !defined $visual_or_id? $self->default_screen->visual->id
        : ref $visual_or_id? $visual_or_id->id
        : $visual_or_id;
    my $tpl= X11::Xlib::XVisualInfo->new({ visualid => $id });
    my ($match)= $self->XGetVisualInfo(X11::Xlib::VisualIDMask, $tpl);
    return $match;
}

sub match_visual_info {
    my ($self, $screen, $depth, $class)= @_;
    my $info;
    return $self->XMatchVisualInfo($screen, $depth, $class, $info)?
        $info : undef;
}

sub search_visual_info {
    my ($self, %args)= @_;
    $args{screen}= $args{screen}->screen_number
        if defined $args{screen} && ref $args{screen};
    my $flags= (defined $args{visualid}? X11::Xlib::VisualIDMask : 0)
        | (defined $args{screen}?        X11::Xlib::VisualScreenMask : 0)
        | (defined $args{depth}?         X11::Xlib::VisualDepthMask : 0)
        | (defined $args{class}?         X11::Xlib::VisualClassMask : 0)
        | (defined $args{red_mask}?      X11::Xlib::VisualRedMaskMask : 0)
        | (defined $args{green_mask}?    X11::Xlib::VisualGreenMaskMask : 0)
        | (defined $args{blue_mask}?     X11::Xlib::VisualBlueMaskMask : 0)
        | (defined $args{colormap_size}? X11::Xlib::VisualColormapSizeMask : 0)
        | (defined $args{bits_per_rgb}?  X11::Xlib::VisualBitsPerRGBMask : 0);
    return $self->XGetVisualInfo($flags, \%args);
}

=head2 RESOURCE CREATION

=head3 new_colormap

  my $cmap= $display->new_colormap($rootwindow, $visual, $alloc_flag);

Creates a new L<Colormap|X11::Xlib/Colormap> on the server, and wraps it with
a L<X11::Xlib::Colormap> object to track its lifespan.  If the object goes
out of scope it calls L<XFreeColormap|X11::Xlib/XFreeColormap>.

C<$rootwindow> defaults to the root window of the default screen.
C<$visual> defaults to the visual of the root window.
C<$allocFlag> defaults to C<AllocNone>.

=cut

sub new_colormap {
    my $self= shift;
    my $cmap_xid= $self->XCreateColormap(@_)
        or croak "XCreateColormap failed"; # actually this is asynchronous
    return X11::Xlib::Colormap->new(
        display  => $self,
        xid      => $cmap_xid,
        autofree => 1
    );
}

=head3 new_pixmap

  my $pix= $display->new_pixmap($drawable, $width, $height, $color_depth);

Create a new L<Pixmap|X11::Xlib/Pixmap> on the server, and wrap it with a
L<X11::Xlib::Pixmap> object to track its lifespan.  If the object does
out of scope it calls L<XFreePixmap|X11::Xlib::XFreePixmap>.

C<$drawable>'s only purpose is to determine which screen to use, and so it
may also be a L<Screen|X11::Xlib::Screen> object.
C<$width> C<$height> and C<$color_depth> should be self-explanatory.

=cut

sub new_pixmap {
    my ($self, $drawable, $width, $height, $depth)= @_;
    $drawable= $drawable->root_window
        if ref $drawable && $drawable->isa('X11::Xlib::Screen');
    my $pix_xid= $self->XCreatePixmap($drawable, $width, $height, $depth)
        or croak "XCreatePixmap failed";
    return X11::Xlib::Pixmap->new(
        display  => $self,
        xid      => $pix_xid,
        autofree => 1
    );
}

=head3 new_window

  my $win= $display->new_window(
    parent                => $window,
    x                     => $x,
    y                     => $y,
    width                 => $width,
    height                => $height,
    border_width          => $border_width,
    depth                 => $color_depth,
    class                 => $class,
    visual                => $visual,
    background_pixmap     => $pixmap,
    background_pixel      => $color_int,
    border_pixmap         => $pixmap,
    border_pixel          => $color_int,
    bit_gravity           => $val,
    win_gravity           => $val,
    backing_store         => $val,
    backing_planes        => $n_planes,
    backing_pixel         => $color_int,
    save_under            => $bool,
    event_mask            => $event_mask,
    do_not_propagate_mask => $event_mask,
    override_redirect     => $bool,
    colormap              => $colormap,
    cursor                => $cursor,
  );

This method takes any argument to the XCreateWindow function and also any of
the fields of the L<X11::Xlib::XSetWindowAttributes> struct or L<X11::Xlib::XSizeHints>.
This saves you the trouble of calculating the attribute mask, and of a second
call to L<X11::Xlib::SetWMNormalHints> if you wanted to set those fields.

It first calls XCreateWindow, which returns an XID, then wraps it with a
L<X11::Xlib::Window> object (which calls C<XDestroyWindow> if it goes out of
scope), then calls C<SetWMNormalHints> if you specified any of those fields.

=cut

my %attr_flags= (
    background_pixmap     => X11::Xlib::CWBackPixmap,
    background_pixel      => X11::Xlib::CWBackPixel,
    border_pixmap         => X11::Xlib::CWBorderPixmap,
    border_pixel          => X11::Xlib::CWBorderPixel,
    bit_gravity           => X11::Xlib::CWBitGravity,
    win_gravity           => X11::Xlib::CWWinGravity,
    backing_store         => X11::Xlib::CWBackingStore,
    backing_planes        => X11::Xlib::CWBackingPlanes,
    backing_pixel         => X11::Xlib::CWBackingPixel,
    save_undef            => X11::Xlib::CWSaveUnder,
    event_mask            => X11::Xlib::CWEventMask,
    do_not_propagate_mask => X11::Xlib::CWDontPropagate,
    override_redirect     => X11::Xlib::CWOverrideRedirect,
    colormap              => X11::Xlib::CWColormap,
    cursor                => X11::Xlib::CWCursor,
);
my @sizehint_specific_fields= qw(
    min_width min_height max_width max_height width_inc height_inc
    min_aspect_x min_aspect_y max_aspect_x max_aspect_y base_width
    base_height win_gravity
);
sub new_window {
    my ($self, %args)= @_;

    # Extract fields of XSetWindowAttributes
    my ($attrflags, %attrs)= (0);
    for (keys %attr_flags) {
        next unless defined $args{$_};
        $attrs{$_}= delete $args{$_};
        $attrflags |= $attr_flags{$_};
    }

    # Extract XCreateWindow args.
    # x,y,width,height are shared by XSizeHints
    my ($x, $y, $w, $h, $parent, $border, $depth, $class, $visual)
        = delete @args{qw( x y width height parent border_width depth class visual )};
    $x ||= 0;
    $y ||= 0;
    $w ||= $args{min_width} || 0;
    $h ||= $args{min_height} || 0;

    # Now extract fields specific to XSizeHints
    my %sizehints;
    defined $args{$_} && ($sizehints{$_}= delete $args{$_})
        for @sizehint_specific_fields;

    # croak if there is anything left over
    croak("Unknown attributes passed to new_window: ".join(',', keys %args))
        if keys %args;

    my $xid= $self->XCreateWindow(
        $args{parent} || $self->root_window,
        $x, $y, $w, $h,
        $border || 0,
        $depth || $self->depth,
        $class || X11::Xlib::CopyFromParent,
        $visual || $self->visual,
        $attrflags, \%attrs
    );
    my $wnd= X11::Xlib::Window->new( display => $self, xid => $xid, autofree => 1 );

    if (keys %sizehints) {
        # XSizeHints->pack will set its own flags for the fields that are present.
        @sizehints{qw( x y width height )}= ($x, $y, $w, $h);
        $self->XSetWMNormalHints(\%sizehints)
    }
    
    return $wnd;
}

=head2 INPUT STATE/CONTROL

=head3 $display->keyboard_leds

Return a mask value for the currently-lit keyboard LEDs.

=cut

# comes from XS

1;
