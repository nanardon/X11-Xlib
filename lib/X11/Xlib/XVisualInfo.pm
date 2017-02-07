package X11::Xlib::XVisualInfo;
use strict;
use warnings;
use X11::Xlib;
use Carp;

=head1 SYNOPSIS

  my $conn= X11::Xlib->new();
  my @visuals= map { $_->unpack } $conn->XGetVisualInfo(0, my $foo);
  use DDP;
  p @visuals;

=cut

sub new {
    my $class= shift;
    my $blank_scalar;
    my $self= bless \$blank_scalar, $class;
    if (@_) {
        $self->pack(@_); # If arguments, then initialize using pack.
    } else {
        $self->_get_screen; # Inflate buffer by calling any XS method.
    }
    $self;
}

sub pack {
    my $self= shift;
    croak "Expected hashref or even-length list"
        unless 1 == @_ && ref($_[0]) eq 'HASH' or !(1 & @_);
    my %args= @_ == 1? %{ shift() } : @_;
    $self->_pack(\%args);
    
    # Warn about any unused arguments
    my @unused= grep { !$self->can($_) } keys %args;
    carp "Un-used parameters passed to pack: ".join(',', @unused)
        if @unused;

    return $self;
}
sub unpack {
    my $self= shift;
    $self->_unpack(my $ret= {});
    $ret;
}

sub buffer        { ${$_[0]} }
sub visual        { $_[0]->_set_visual($_[1])        if @_ > 1; $_[0]->_get_visual()  }
sub visualid      { $_[0]->_set_visualid($_[1])      if @_ > 1; $_[0]->_get_visualid() }
sub screen        { $_[0]->_set_screen($_[1])        if @_ > 1; $_[0]->_get_screen() }
sub depth         { $_[0]->_set_depth($_[1])         if @_ > 1; $_[0]->_get_depth() }
sub class         { $_[0]->_set_class($_[1])         if @_ > 1; $_[0]->_get_class() }
sub red_mask      { $_[0]->_set_red_mask($_[1])      if @_ > 1; $_[0]->_get_red_mask() }
sub green_mask    { $_[0]->_set_green_mask($_[1])    if @_ > 1; $_[0]->_get_green_mask() }
sub blue_mask     { $_[0]->_set_blue_mask($_[1])     if @_ > 1; $_[0]->_get_blue_mask() }
sub colormap_size { $_[0]->_set_colormap_size($_[1]) if @_ > 1; $_[0]->_get_colormap_size() }
sub bits_per_rgb  { $_[0]->_set_bits_per_rgb($_[1])  if @_ > 1; $_[0]->_get_bits_per_rgb() }

1;
