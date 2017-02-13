package X11::Xlib::Colormap;
use strict;
use warnings;
use parent 'X11::Xlib::XID';

sub DESTROY {
    my $self= shift;
    $self->display->XDestroyColormap($self->xid)
        if $self->autofree;
}

1;
