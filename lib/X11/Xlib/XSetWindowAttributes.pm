package X11::Xlib::XSetWindowAttributes;
require X11::Xlib::Struct;
__END__

(most methods are inherited or XS, so there is no need to load this package file)

=head1 DESCRIPTION

This struct contains various attributes of a window, to be applied
with calls like L<XCreateWindow|X11::Xlib/XCreateWindow>
or L<XChangeWindowAttributes|X11::Xlib/XChangeWindowAttributes>.

=head1 ATTRIBUTES

(copied from X11 docs)

    Pixmap background_pixmap;       /* background, None, or ParentRelative */
	unsigned long background_pixel; /* background pixel */
	Pixmap border_pixmap;           /* border of the window or CopyFromParent */
	unsigned long border_pixel;     /* border pixel value */
	int bit_gravity;                /* one of bit gravity values */
	int win_gravity;                /* one of the window gravity values */
	int backing_store;              /* NotUseful, WhenMapped, Always */
	unsigned long backing_planes;   /* planes to be preserved if possible */
	unsigned long backing_pixel;    /* value to use in restoring planes */
	Bool save_under;                /* should bits under be saved? (popups) */
	long event_mask;                /* set of events that should be saved */
	long do_not_propagate_mask;     /* set of events that should not propagate */
	Bool override_redirect;         /* boolean value for override_redirect */
	Colormap colormap;              /* color map to be associated with window */
	Cursor cursor;                  /* cursor to be displayed (or None) */

=head1 METHODS

See parent class L<X11::Xlib::Struct>

=cut
