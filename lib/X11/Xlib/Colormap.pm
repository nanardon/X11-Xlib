package X11::Xlib::Colormap;
use strict;
use warnings;
use parent 'X11::Xlib::XID';

=head1 DESCRIPTION

Object representing a Colormap, which is a remote X11 resource
referenced by an XID.  When this object goes out of scope it calls
L<XDestroyColormap|X11::Xlib::XDestroyColormap>.

=cut

sub DESTROY {
    my $self= shift;
    $self->display->XDestroyColormap($self->xid)
        if $self->autofree;
}

1;