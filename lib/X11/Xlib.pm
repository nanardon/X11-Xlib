package X11::Xlib;

use 5.008000;

use strict;
use warnings;
use base qw(Exporter);
use Carp;
use Try::Tiny;
use XSLoader;

our $VERSION = '0.03';

XSLoader::load(__PACKAGE__, $VERSION);

our @EXPORT_OK = qw(
    XOpenDisplay XCloseDisplay ConnectionNumber XSetCloseDownMode

    XSelectInput XNextEvent XCheckWindowEvent XCheckTypedWindowEvent XCheckMaskEvent
    XCheckTypedEvent XSendEvent XPutBackEvent XSync XFlush

    XKeysymToString XStringToKeysym
    IsFunctionKey IsKeypadKey IsMiscFunctionKey IsModifierKey IsPFKey IsPrivateKeypadKey
);
our @EXPORT = qw(
    XKeysymToString
    XStringToKeysym
    IsFunctionKey
    IsKeypadKey
    IsMiscFunctionKey
    IsModifierKey
    IsPFKey
    IsPrivateKeypadKey
);

sub new {
    require X11::Xlib::Display;
    my $class= shift;
    X11::Xlib::Display->new(@_);
}

# Used by XS.  In the spirit of letting perl users violate encapsulation
#  as needed, the XS code exposes its globals to Perl.
our (
    %_connections,              # weak-ref set of all connection objects, keyed by *raw pointer*
    $_error_nonfatal_installed, # boolean, whether handler is installed
    $_error_fatal_installed,    # boolean, whether handler is installed
    $_error_fatal_trapped,      # boolean, whether Xlib is dead from fatal error
    $on_error_cb,               # application-supplied callback
);
sub on_error {
    ref($_[-1]) eq 'CODE' or croak "Expected coderef";
    $on_error_cb= $_[-1];
    X11::Xlib::_install_error_handlers(1,1);
}
# called by XS, if installed
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
# called by XS, if installed
sub _error_fatal {
    my $conn= shift;
    $conn->_mark_dead; # this connection is dead immediately

    if ($on_error_cb) {
        try { $on_error_cb->($conn); }
        catch { warn $_; };
    }
    # also call a user callback in any Display object
    for my $dpy (values %X11::Xlib::_displays) {
        next unless defined $dpy && defined $dpy->on_error_cb;
        try { $dpy->on_error_cb->($dpy); }
        catch { warn $_; };
    }

    # Kill all X11 connections, since Xlib internal state might be toast after this
    $_->_mark_dead for grep { defined } values %_connections;
}

1;

__END__


=head1 NAME

X11::Xlib - Low-level access to the X11 library

=head1 SYNOPSIS

  use X11::Xlib;
  my $display = X11::Xlib::Display->new();
  ...

=head1 DESCRIPTION

This module provides low-level access to X11 libary functions.

This includes access to some X11 extensions like the X11 test library (Xtst).

If you import the Xlib functions directly, or call them as methods on an
instance of X11::Xlib, you get a near-C<C> experience where you are required to
manage the lifespan of resources, XIDs are integers instead of objects, and the
library doesn't make any attempt to keep you from passing bad data to Xlib.

If you instead create a L<X11::Xlib::Display> object and call all your methods
on that, you get a more friendly wrapper around Xlib that helps you manage
resource lifespan, wraps XIDs with perl objects, and does some sanity checking
on the state of the library when you call methods.

=cut

=head1 FUNCTIONS

Most functions can be called as methods on the Xlib connection object, since
this is usually the first argument.  All functions which are part of Xlib's API
can be exported.

=head2 new

This is an alias for C<< X11::Xlib::Display->new >>, to help encourage using
the object oriented interface.

=head2 install_error_handlers

  X11::Xlib::install_error_handlers( $bool_nonfatal, $bool_fatal );

Error handling in Xlib is pretty bad.  The first problem is that non-fatal
errors are reported asynchronously in an API that pretends to be synchronous.
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
you wrap up your script in a normal manner.  <b>However</b>, after a fatal
error Xlib's internal state could be dammaged, so it is unsafe to make any more
Xlib calls.  The library tries to help assert this by invalidating all the
connection objects.

If you really need your program to keep running your best bet is to state-dump
to shared memory and then exec() a fresh copy of your script and reload the
dumped state.  Or use XCB instead of Xlib.

=head1 XLIB API

=head2 XOpenDisplay($connection_string)

  my $display= X11::Xlib::XOpenDisplay($connection_string);

Instantiate a new C<X11::Xlib> object. This object contains the connection to
the X11 display.

The C<$connection_string> variable specifies the display string to open.
(C<"host:display.screen">, or often C<":0"> to connect to the default screen of
the only display on the localhost)
If unset, Xlib uses the C<$DISPLAY> environement variable.

This handle does *not* automatically close itself when freed!  You must pass
it to XCloseDisplay, or better, just use the X11::Xlib::Display wrapper.

=head2 XCloseDisplay($display)

Close a handle returned by XOpenDisplay.  Do not call this method if you are
using the object-oriented L<X11::Xlib::Display> interface because that one
will call it automatically when the handle goes out of scope.

=head2 DISPLAY FUNCTIONS

=head3 DisplayWidth($display, $screen)

Return the width of screen number C<$screen> (or default if not specified).

=head3 DisplayHeight($display, $screen)

Return the height of screen number C<$screen> (or default if not specified).

=head2 EVENT FUNCTIONS

=head3 XTestFakeMotionEvent($display, $screen, $x, $y, $EventSendDelay)

Fake a mouse movement on screen number C<$screen> to position C<$x>,C<$y>.

The optional C<$EventSendDelay> parameter specifies the number of milliseconds to wait
before sending the event. The default is 10 milliseconds.

=head3 XTestFakeButtonEvent($display, $button, $pressed, $EventSendDelay)

Simulate an action on mouse button number C<$button>. C<$pressed> indicates whether
the button should be pressed (true) or released (false). 

The optional C<$EventSendDelay> parameter specifies the number of milliseconds ro wait
before sending the event. The default is 10 milliseconds.

=head3 XTestFakeKeyEvent($display, $kc, $pressed, $EventSendDelay)

Simulate a event on any key on the keyboard. C<$kc> is the key code (8 to 255),
and C<$pressed> indicates if the key was pressed or released.

The optional C<$EventSendDelay> parameter specifies the number of milliseconds to wait
before sending the event. The default is 10 milliseconds.

=head3 XBell($display, $percent)

Make the X server emit a sound.

=head3 XQueryKeymap($display)

Return a list of the key codes currently pressed on the keyboard.

=head3 XFlush($display)

Flush pending events sent via the Fake* methods to the X11 server.

This method must be used to ensure the fake events take are triggered.

=head3 XSync($display, $flush)

Force the X server to sync event. The optional C<$flush> parameter allows pending
events to be discarded.

=head3 XKeysymToKeycode($display, $keysym)

Return the key code corresponding to the character number C<$keysym>.

=head3 XGetKeyboardMapping($display, $keycode, $count)

Return an array of character numbers corresponding to the key C<$keycode>.

Each value in the array corresponds to the action of a key modifier (Shift, Alt).

C<$count> is the number of the keycode to return. The default value is 1, e.g.
it returns the character corresponding to the given $keycode.

=head3 RootWindow($display)

Return the XID of the X11 root window.

=head2 KEYCODE FUNCTIONS

=head3 XKeysymToString($keysym)

Return the human-readable string for character number C<$keysym>.

C<XKeysymToString> is the exact reverse of C<XStringToKeysym>.

=head3 XStringToKeysym($string)

Return the keysym number for the human-readable character C<$string>.

C<XStringToKeysym> is the exact reverse of C<XKeysymToString>.

=head3 IsFunctionKey($keysym)

Return true if C<$keysym> is a function key (F1 .. F35)

=head3 IsKeypadKey($keysym)

Return true if C<$keysym> is on numeric keypad.

=head3 IsMiscFunctionKey($keysym)

Return true is key if... honestly don't know :\

=head3 IsModifierKey($keysym)

Return true if C<$keysym> is a modifier key (Shift, Alt).

=head3 IsPFKey($keysym)

No idea.

=head3 IsPrivateKeypadKey($keysym)

Again, no idea.

=cut

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

This module provides the same functions but with a high level approach.

=item L<Gtk2>

Functions provided by X11/Xlib are mostly included in the L<Gtk2> binding, but
through the GTK API and perl objects.

=back

=head1 NOTES

This module is still incomplete, but patches are welcome :)

=head1 AUTHOR

Olivier Thauvin, E<lt>nanardon@nanardon.zarb.orgE<gt>

Michael Conrad, E<lt>mike@nrdvana.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2010 by Olivier Thauvin

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
