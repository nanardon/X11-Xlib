package X11::Xlib::XSizeHints;
require X11::Xlib::Struct;
__END__

=head1 ATTRIBUTES

The fields of the struct are as follows (from X11 docs)

    long flags;         /* marks which fields in this structure are defined */
    int x, y;           /* obsolete for new window mgrs, but clients */
    int width, height;  /* should set so old wm's don't mess up */
    int min_width, min_height;
    int max_width, max_height;
    int width_inc, height_inc;
    struct {
        int x;  /* numerator */
        int y;  /* denominator */
	} min_aspect, max_aspect;
    int base_width, base_height;  /* added by ICCCM version 1 */
    int win_gravity;              /* added by ICCCM version 1 */

The accessor methods for C<min_aspect> and C<max_aspect> are a special case:

  ->min_aspect_x
  ->min_aspect_y
  ->max_aspect_x
  ->max_aspect_y

The values for C<flags> are exported with

  use X11::Xlib ':const_sizehint';

and can be one of:

  USPosition   /* user specified x, y */
  USSize       /* user specified width, height */
  PPosition    /* program specified position */
  PSize        /* program specified size */
  PMinSize     /* program specified minimum size */
  PMaxSize     /* program specified maximum size */
  PResizeInc   /* program specified resize increments */
  PAspect      /* program specified min and max aspect ratios */
  PBaseSize    /* program specified base for incrementing */
  PWinGravity  /* program specified window gravity */

=head1 METHODS

See parent class L<X11::Xlib::Struct>

