package X11::Xlib::Window;
use strict;
use warnings;
use parent 'X11::Xlib::XID';

sub get_w_h {
    my $self= shift;
    $self->display->XGetGeometry($self->xid, undef, undef, undef, my $w, my $h);
    return $w, $h;
}

sub DESTROY {
    my $self= shift;
    $self->display->XDestroyWindow($self->xid)
        if $self->autofree;
}

1;

__END__

=head1 NAME

X11::Xlib::Window - Low-level access to X11 windows

=head1 SYNOPSIS

  use X11::Xlib;
  my $display = X11::Xlib->new();
  my $window = $display->RootWindow();
  ...

=head1 DESCRIPTION

This class extends .

=head1 METHODS

(inherits from L<X11::Xlib::XID>)

=head2 get_w_h

  my ($w, $h)= $window->get_w_h

Return width and height of the window by calling XGetGeometry.  This means it
always returns the current size of the window, which could have been altered
since the time the window was created.

=head1 SEE ALSO

L<X11::Xlib>

=head1 AUTHOR

Olivier Thauvin, E<lt>nanardon@nanardon.zarb.orgE<gt>

Michael Conrad, E<lt>mike@nrdvana.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2010 by Olivier Thauvin

Copyright (C) 2017 by Michael Conrad

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
