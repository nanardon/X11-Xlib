package X11::Xlib::Visual;
require X11::Xlib;

sub id {
    X11::Xlib::XVisualIDFromVisual(shift);
}

__END__

=head1 DESCRIPTION

This is an opaque structure describing an available visual configuration
of a screen.  The only thing you can do with this object is pass it to
X11 functions, or get its L</id> to look up the L<X11::Xlib::XVisualInfo>.

=head1 ATTRIBUTES

=head2 id

Return the numeric ID of this visual.

=cut