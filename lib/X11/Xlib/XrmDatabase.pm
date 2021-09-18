package X11::Xlib::XrmDatabase;

use strict;
use warnings;

use X11::Xlib;

# All modules in dist share a version
our $VERSION = '0.20';

# these are in the order they appear in the Xlib.xs file to make it
# easier to check for completeness.

sub GetFileDatabase {
    my ( $class, $filename ) = @_;
    X11::Xlib::XrmGetFileDatabase( $filename );
};

*PutFileDatabase   = \&X11::Xlib::XrmPutFileDatabase;

# XResourceManagerString: unimplemented
# XScreenResourceString: unimplemented

sub GetStringDatabase {
    my ( $class, $string ) = @_;
    X11::Xlib::XrmGetStringDatabase( $string );
}

*LocaleOfDatabase  = \&X11::Xlib::XrmLocaleOfDatabase;

*DestroyDatabase   = \&X11::Xlib::XrmDestroyDatabase;

# XrmSetDatabase: unimplemented
# XrmGetDatabase: unimplemented
# XrmCombineFileDatabase: unimplemented

*CombineDatabase   = \&X11::Xlib::XrmCombineDatabase;

*MergeDatabases    = \&X11::Xlib::XrmMergeDatabases;

*GetResource       = \&X11::Xlib::XrmGetResource;

*PutResource       = \&X11::Xlib::XrmPutResource;

*PutStringResource = \&X11::Xlib::XrmPutStringResource;

*PutLineResource   = \&X11::Xlib::XrmPutLineResource;

1;

=head1 NAME

X11::Xlib::XrmDatabase - Object-Oriented Convenience Class for X Resource Manager Databases.

=head1 SYNOPSIS

  use X11::Xlib::XrmDatabase;

  $db = X11::Xlib::XrmDatabase->GetFileDatabase( $file );
  $db = X11::Xlib::XrmDatabase->GetStringDatabase( $string );

=head1 DESCRIPTION

This module provides some object-oriented support for X Resource
Manager Databases. The method name is derived from the function name
by removing the C<Xrm> prefix, e.g. if the function name is

  XrmGetFileDatabase

the associated method will be

  GetFileDatabase

Not all of the Resource Manager functionality is exposed here.

For more information see L<X11::Lib/RESOURCE FUNCTIONS>.

=head1 CONSTRUCTORS

=head2 GetFileDatabase

  $db = X11::Xlib::XrmDatabase->GetFileDatabase( $file );

=head2 GetStringDatabase

  $db = X11::Xlib::XrmDatabase->GetStringDatabase( $string );

=head1 METHODS

=head2 PutFileDatabase

  $db->PutFileDatabase( $filename );

=head2 LocaleOfDatabse

  $string = $db->LocaleOfDatabase;

=head2 DestroyDatabase

  $db->DestroyDatabase

=head2 CombineDatabase

  $db->CombineDatabase( $target_db, $override );

=head2 MergeDatabases

  $db->MergeDatabases( $target_db );

=head2 GetResource

  ($bool, $type, $value ) = $db->GetResource( $name, $class );

=head2 PutResource

  $db->PutResource( $specifier, $type, $value );

=head2 PutStringResource

  $db->PutStringResource( $specifier, $value );

=head2 PutLineResource

  $db->PutLineResource( $line );


=head1 AUTHOR

Diab Jerius, E<lt>djerius@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 by Diab Jerius

Copyright (C) 2021 by Smithsonian Astrophysical Observatory.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
