package X11::Xlib::Window;

use 5.010000;

use strict;
use warnings;

use X11::Xlib;

our $VERSION = '0.01';

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

=cut

=head1 METHODS

=head2 $window->id

Return the X11 numeric ID of the window.

=head1 SEE ALSO

L<X11::Xlib>

=head1 AUTHOR

Olivier Thauvin, E<lt>nanardon@nanardon.zarb.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2010 by Olivier Thauvin

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
