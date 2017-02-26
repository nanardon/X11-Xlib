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

X11::Xlib::Window - Low-level access to X11 windows

=head1 SYNOPSIS

  use X11::Xlib;
  my $display = X11::Xlib->new();
  my $window = $display->RootWindow();
  ...

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 display

The L<X11::Xlib::Display> where the resource is located.

=head2 xid

Return the X11 numeric ID for this window resource.

=head2 autofree

Whether this window object should control the lifespan of the remote resource,
by calling XDestroyWindow if it goes out of scope.

=head1 METHODS

=head2 new

This is mostly meant to be called by L<Display|X11::Xlib::Display>, but you
can wrap additional Window XIDs with:

  my $wnd= X11::Xlib::Window->new(display => $dpy, xid => $xid)

=cut
