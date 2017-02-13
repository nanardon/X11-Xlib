package X11::Xlib::Screen;
use strict;
use warnings;
use X11::Xlib::Display;
require Scalar::Util;

=head1 ATTRIBUTES

=head2 display

Reference to L<X11::Xlib::Display>

=head2 screen_number

The integer identifying this screen.

=cut

sub display { $_[0]{display} }
sub screen_number { $_[0]{screen_number} }

=head2 root_window_xid

The XID of the root window of this screen

=head2 root_window

The L<X11::Xlib::Window> object for the root window of this screen

=cut

sub root_window_xid {
    my $self= shift;
    $self->{root_window_xid} ||=
        X11::Xlib::RootWindow($self->{display}, $self->{screen_number});
}

sub root_window {
    my $self= shift;
    # Allow strong ref to root window, since it isn't going anywhere
    $self->{root_window} ||=
        $self->{display}->_get_cached_xid($self->root_window_xid, 'X11::Xlib::Window');
}

=head2 visual

The default visual of this screen

=cut

sub visual {
    my $self= shift;
    $self->{visual} ||= $self->{display}->DefaultVisual($self->{screen_number});
}

=head1 METHODS

=cut

sub _new {
    my $class= shift;
    my %args= (@_ == 1 && ref $_[0] eq 'HASH')? %{$_[0]} : @_;
    defined $args{display} or die "'display' is required";
    defined $args{screen_number} or die "'screen_number' is required";
    Scalar::Util::weaken($args{display});
    bless \%args, $class;
}

=head2 visual_info

  my $vinfo= $screen->visual_info();  # uses defualt visual for this screen
  my $vinfo= $screen->visual_info($visual);
  my $vinfo= $screen->visual_info($visual_id);

Shortcut to L<X11::Xlib::Display/visual_info>, but using this screen's
default visual when no argument is given.

=cut

sub visual_info {
    my ($self, $visual_or_id)= @_;
    $self->display->visual_info(defined $visual_or_id? $visual_or_id : $self->visual);
}

=head2 match_visual_info

  my $vinfo= $screen->find_visual($depth, $class);

Like L<X11::Xlib::Display/match_visual_info> but without the C<$screen> argument.

=cut


1;
