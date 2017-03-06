package X11::Xlib::XID;
use strict;
use warnings;
use Carp;
use X11::Xlib;

sub new {
    my $class= shift;
    my %args= (@_ == 1 && ref $_[0] eq 'HASH')? %{$_[0]} : @_;
    defined $args{display} or croak "'display' is required";
    defined $args{xid}     or croak "'xid' is required";
    bless \%args, $class;
}

sub display { croak "read-only" if @_ > 1; $_[0]{display} }
sub xid     { croak "read-only" if @_ > 1; $_[0]{xid} }
*id= *xid;
*dpy= *display;
sub autofree { my $self= shift; $self->{autofree}= shift if @_; $self->{autofree} }

1;

__END__

=head1 NAME

X11::Xlib::XID - Base class for objects wrapping an XID

=head1 ATTRIBUTES

=head2 display

Required.  The L<X11::Xlib::Display> where the resource is located.

=head2 xid

Required.  The X11 numeric ID for this resource.

=head2 autofree

Whether this object should control the lifespan of the remote resource,
by calling an Xlib Free/Destroy function if it goes out of scope.
The default is False, since this base class has no idea how to release
any resources.

=cut
