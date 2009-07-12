package X11::Xlib;

use 5.010000;
use strict;
use warnings;
use Carp;

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('X11::Xlib', $VERSION);

use Exporter 'import';

our @EXPORT = qw(XKeysymToString XStringToKeysym);

=head1 NAME

X11::Xlib - Low level access to the X11 library

=head1 SYNOPSIS

  use X11::Xlib;
  my $display = X11::Xlib->new();
  ...

=head1 DESCRIPTION

The X11::Xlib module provide low level access to X11 libary function.

This include access to some X11 extension like the X11 test library (xtst).

=cut

=head1 FUNCTIONS

=head2 X11::Xlib->new($display)

Instanciate a new X11::Xlib access. This object contains the connection to the
X11 display.

The C<$display> variable specify the display adress to open. If unset the
C<$DISPLAY> envirronement variable is used.

=head2 DISPLAY FUNCTION

=head3 $dpy->DisplayWidth($screen)

Return the width of the screen number C<$screen> (or 0 if not specified).

=head3 $dpy->DisplayHeight($screen)

Return the height of the screen number C<$screen> (or 0 if not specified).

=head2 EVENT FUNCTIONS

=head3 $dpy->XTestFakeMotionEvent($screen, $x, $y, $EventSendDelay)

Fake a mouse movement on screen number C<$screen> to position C<$x>,C<$y>.

The optional $EventSendDelay is a delay to wait before sending the event in
milliseconds, default value is 10.

=head3 $dpy->XTestFakeButtonEvent($button, $pressed, $EventSendDelay);

Simulate an action on mouse button number C<$button>. C<$pressed> indicate if
the button is either pressed (True) or released (False). 

The optional $EventSendDelay is a delay to wait before sending the event in
milliseconds, default value is 10.

=head3 $dpy->XTestFakeKeyEvent($kc, $pressed, $EventSendDelay)

Simulate an event on any key on the keyboard. C<$kc> is the key code (8 to 255)
and C<$pressed> indicate if the key get pressed or released.

The optional $EventSendDelay is a delay to wait before sending the event in
milliseconds, default value is 10.

=head3 $dpy->XBell($percent)

Make the Xserver emit a sound.

=head3 $dpy->XQueryKeymap

Return an array of the key code currently pressed on the keyboard.

=head3 $dpy->keyboard_leds

Return a mask value for keyboard leds currently on.

=head3 $dpy->XFlush

Flush pending events sent with *Fake* functions to X11 server.

This function must be used to make fake event taking effect.

=head2 WINDOW FUNCTIONS

=head3 $dpy->RootWindow

Return a L<X11::Xlib::Window> object corresponding to the X11 root window.

=head2 KEYCODE FUNCTIONS

=head3 XKeysymToString($keysym)

Return the human readable string for caracter number $keysym.

XKeysymToString is the exact reverse of XStringToKeysym.

=head3 XStringToKeysym($string)

Return the keysym number for human readable caracter $string.

XStringToKeysym is the exact reverse of XKeysymToString.

=head3 $dpy->XKeysymToKeycode($keysym)

Return the key code returning the caracter number $keysym.

=head3 $dpy->XGetKeyboardMapping($keycode, $count)

Return an array of caracter number corresponding to the key $keycode.

Each value in the array correspond to the action of a key modifier (Shift, Alt).

The $count is the number of keycode to return. Default value is 1, eg returning
caracter for the given $keycode.

=cut

1;

__END__

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Olivier Thauvin, E<lt>olivier@localdomainE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Olivier Thauvin

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
