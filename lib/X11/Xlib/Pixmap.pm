package X11::Xlib::Pixmap;
use strict;
use warnings;
use Carp;
use parent 'X11::Xlib::XID';

=head1 DESCRIPTION

Object representing a Pixmap remote X11 resource.

=head1 ATTRIBUTES

=head2 width

Width, in pixels

=head2 height

Height, in pixels

=head2 depth

Color depth, in bits.

=head1 METHODS

=head2 get_w_h

  my ($w, $h)= $pixmap->get_w_h

Reutrn the width and height of the pixmap as a list

=cut

sub width  { croak "read-only" if @_ > 1; $_[0]{width} }
sub height { croak "read-only" if @_ > 1; $_[0]{height} }
sub depth  { croak "read-only" if @_ > 1; $_[0]{depth} }

sub get_w_h { croak "read-only" if @_ > 1; $_[0]{width}, $_[0]{height} }

sub DESTROY {
    my $self= shift;
    $self->display->XFreePixmap($self->xid)
        if $self->autofree && $self->xid;
}

1;
