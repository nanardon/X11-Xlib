package X11::Xlib;

use 5.008000;

use strict;
use warnings;
use base qw(Exporter);

use XSLoader;

our $VERSION = '0.03';

XSLoader::load(__PACKAGE__, $VERSION);

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

1;

__END__


=head1 NAME

X11::Xlib - Low-level access to the X11 library

=head1 SYNOPSIS

  use X11::Xlib;
  my $display = X11::Xlib->new();
  ...

=head1 DESCRIPTION

This module provides low-level access to X11 libary functions.

This includes access to some X11 extensions like the X11 test library (Xtst).

=cut

=head1 METHODS

=head2 X11::Xlib->new($display)

Instantiate a new C<X11::Xlib> object. This object contains the connection to the
X11 display.

The C<$display> variable specifies the display adress to open. If unset, the
C<$DISPLAY> environement variable is used.

=head2 DISPLAY METHODS

=head3 $display->DisplayWidth($screen)

Return the width of screen number C<$screen> (or 0 if not specified).

=head3 $display->DisplayHeight($screen)

Return the height of screen number C<$screen> (or 0 if not specified).

=head2 EVENT METHODS

=head3 $display->XTestFakeMotionEvent($screen, $x, $y, $EventSendDelay)

Fake a mouse movement on screen number C<$screen> to position C<$x>,C<$y>.

The optional C<$EventSendDelay> parameter specifies the number of milliseconds to wait
before sending the event. The default is 10 milliseconds.

=head3 $display->XTestFakeButtonEvent($button, $pressed, $EventSendDelay);

Simulate an action on mouse button number C<$button>. C<$pressed> indicates whether
the button should be pressed (true) or released (false). 

The optional C<$EventSendDelay> parameter specifies the number of milliseconds ro wait
before sending the event. The default is 10 milliseconds.

=head3 $display->XTestFakeKeyEvent($kc, $pressed, $EventSendDelay)

Simulate a event on any key on the keyboard. C<$kc> is the key code (8 to 255),
and C<$pressed> indicates if the key was pressed or released.

The optional C<$EventSendDelay> parameter specifies the number of milliseconds to wait
before sending the event. The default is 10 milliseconds.

=head3 $display->XBell($percent)

Make the X server emit a sound.

=head3 $display->XQueryKeymap

Return an array of the key codes currently pressed on the keyboard.

=head3 $display->keyboard_leds

Return a mask value for the currently-lit keyboard LEDs.

=head3 $display->XFlush

Flush pending events sent via the Fake* methods to the X11 server.

This method must be used to ensure the fake events take are triggered.

=head3 $display->XSync($flush)

Force the X server to sync event. The optional C<$flush> parameter allows pending
events to be discarded.

=head3 $display->XKeysymToKeycode($keysym)

Return the key code corresponding to the character number C<$keysym>.

=head3 $display->XGetKeyboardMapping($keycode, $count)

Return an array of character numbers corresponding to the key C<$keycode>.

Each value in the array corresponds to the action of a key modifier (Shift, Alt).

C<$count> is the number of the keycode to return. The default value is 1, e.g.
it returns the character corresponding to the given $keycode.

=head3 $display->RootWindow

Return an L<X11::Xlib::Window> object corresponding to the X11 root window.

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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2010 by Olivier Thauvin

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
