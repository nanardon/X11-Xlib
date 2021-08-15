package X11::Xlib::XrmDatabase;

use strict;
use warnings;

use X11::Xlib;

# All modules in dist share a version
our $VERSION = '0.20';

*XrmPutFileDatabase = \&X11::Xlib::XrmPutFileDatabase;
*XrmLocaleOfDatabase = \&X11::Xlib::XrmLocaleOfDatabase;
*XrmDestroyDatabase = \&X11::Xlib::XrmDestroyDatabase;
*XrmCombineDatabase = \&X11::Xlib::XrmCombineDatabase;
*XrmMergeDatabases = \&X11::Xlib::XrmMergeDatabases;
*XrmGetResource = \&X11::Xlib::XrmGetResource;
*XrmPutResource = \&X11::Xlib::XrmPutResource;
*XrmPutStringResource = \&X11::Xlib::XrmPutStringResource;
*XrmPutLineResource = \&X11::Xlib::XrmPutLineResource;

1;

=head1 NAME

X11::Xlib::XrmDatabase - Shadow class for X Resource Manager databases


=head1 SYNOPSIS

To make the methods available:

  use X11::Xlib::XrmDatabase;

Otherwise, they are as available as functions when using L<X11::Xlib>.

=head1 DESCRIPTION

See L<X11::Lib/RESOURCE FUNCTIONS> for more details.  Any C<Xrm>
function whose first parameter is an X Resource database handle can be
used as a method after importing this module.

=head1 AUTHOR

Diab Jerius, E<lt>djerius@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 by Diab Jerius

Copyright (C) 2021 by Smithsonian Astrophysical Observatory.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
