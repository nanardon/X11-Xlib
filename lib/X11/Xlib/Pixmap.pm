package X11::Xlib::Pixmap;
use strict;
use warnings;
use parent 'X11::Xlib::XID';

sub DESTROY {
    my $self= shift;
    $self->display->XDestroyPixmap($self->xid)
        if $self->autofree;
}

1;
