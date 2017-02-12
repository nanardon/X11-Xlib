package X11::Xlib::XVisualInfo;
require X11::Xlib::Struct;
__END__

(most methods are inherited or XS, so there is no need to load this package file)

=head1 SYNOPSIS

  my $conn= X11::Xlib->new();
  my @visuals= map { $_->unpack } $conn->XGetVisualInfo(0, my $foo);
  use DDP;
  p @visuals;

=head1 DESCRIPTION

The real "Visual" structure in Xlib is hidden from users, but various
functions give you XVisualInfo to be able to inspect a Visual without
making lots of method calls.

=head1 ATTRIBUTES

(copied from Xlib docs)

  typedef struct {
    Visual *visual;
    VisualID visualid;
    int screen;
    unsigned int depth;
    int class;
    unsigned long red_mask;
    unsigned long green_mask;
    unsigned long blue_mask;
    int colormap_size;
    int bits_per_rgb;
  } XVisualInfo;

=cut
