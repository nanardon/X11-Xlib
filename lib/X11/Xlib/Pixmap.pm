package X11::Xlib::Pixmap;
use strict;
use warnings;
use parent 'X11::Xlib::XID';

=head1 DESCRIPTION

Object representing a Pixmap remote X11 resource.

=cut

sub DESTROY {
    my $self= shift;
    $self->display->XFreePixmap($self->xid)
        if $self->autofree;
}

1;
