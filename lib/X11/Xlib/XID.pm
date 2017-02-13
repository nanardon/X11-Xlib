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

sub dpy { shift->{dpy} }
sub xid { shift->{xid} }
sub id  { shift->{xid} }
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

=cut

=head1 METHODS

=head2 $window->id

Return the X11 numeric ID of the window.

=cut
