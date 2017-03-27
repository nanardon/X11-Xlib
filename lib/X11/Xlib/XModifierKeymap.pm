package X11::Xlib::XModifierKeymap;
use strict;
use warnings;
use Scalar::Util 'weaken';
use Carp;

# ABSTRACT - Table of each modifier's member keycodes

sub new {
    my $class= shift;
    croak("No arguments supported yet") if @_;
    bless [ ([]) x 8 ], $class;
}

sub shift_codes   { $_[0][0]= $_[1] if @_ > 1; $_[0][0] }
sub lock_codes    { $_[0][1]= $_[1] if @_ > 1; $_[0][1] }
sub control_codes { $_[0][2]= $_[1] if @_ > 1; $_[0][2] }
sub mod1_codes    { $_[0][3]= $_[1] if @_ > 1; $_[0][3] }
sub mod2_codes    { $_[0][4]= $_[1] if @_ > 1; $_[0][4] }
sub mod3_codes    { $_[0][5]= $_[1] if @_ > 1; $_[0][5] }
sub mod4_codes    { $_[0][6]= $_[1] if @_ > 1; $_[0][6] }
sub mod5_codes    { $_[0][7]= $_[1] if @_ > 1; $_[0][7] }

sub add {
    my ($self, $modifier, @codes)= @_;
    my $method= $modifier."_codes";
    my $modcodes= $self->$method;
    my %seen= ( 0 => 1 ); # prevent duplicates, and remove nulls
    @$modcodes= grep { !$seen{$_}++ } @$modcodes;
    my $n= @$modcodes;
    push @$modcodes, grep { !$seen{$_}++ } @codes;
    return @modcodes - $n;
}

sub del {
    my ($self, $modifier, @codes)= @_;
    my $count= 0;
    my %del= map { $_ => 1 } @codes;
    if ($modifier) {
        my $method= $modifier."_codes";
        my $codes= $self->$method;
        my $n= @$codes;
        @$codes= grep { !$del{$_} } @$codes;
        $count= $n - @$codes;
    }
    else {
        for (@$self) {
            my $n= @$_;
            @$_ = grep { !$del{$_} } @$_;
            $count += $n - @$_;
        }
    }
    return $count;
}

1;
__END__

=head1 DESCRIPTION

X11 defines eight "modifiers", which are: Shift, Lock, Control, Mod1, Mod2,
Mod3, Mod4, Mod5.  Each modifier can have one or more key codes included in
it.  For example, Shift might be composed of 0x32 (Shift_L) and 0x3E (Shift_R)
for your key layout.

The native Xlib struct for C<XModifierKeymap> is really nothing more than a
dynamically allocated 2D array of bytes, with a full-blown API for allocating,
reading, writing/resizing and freeing the block of memory.
Since perl's arrays are much nicer to use I skipped the Xlib struct entirely
and this class is backed by an arrayref (of arrayrefs).

=head1 ATTRIBUTES

Each of the L</shift_codes>, L</lock_codes>, L</control_codes>, L</mod1_codes>
..L</mod5_codes> accessors return the internal arrayref for that modifier, so
changes to it persist in this object.
Passing an arryref to the attribute replaces the arrayref for that slot.

  # get key codes
  my @key_codes= @{ $modmap->..._codes };
  
  # add a key code
  push @{ $modmap->..._codes }, 0x32;
  
  # Replace the key codes
  $modmap->..._codes([ 0x32, 0x3E ]);

=head2 shift_codes

Get/Set an arrayref of scan codes that act as shift keys.

=head2 lock_codes

Get/Set an arrayref of scan codes that act as CapsLock keys.

=head2 control_codes

Get/Set an arrayref of scan codes that act as control keys.

=head2 mod1_codes

Get/Set an arrayref of scan codes that act as mod1 keys,
which is likely Alt on modern Linux desktops.

=head2 mod2_codes

Get/Set an arrayref of scan codes that act as mod2 keys,
which is likely NumLock on modern Linux desktops.

=head2 mod3_codes

Get/Set an arrayref of scan codes that act as mod3 keys,
which seems unused on modern Linux desktops.

=head2 mod4_codes

Get/Set an arrayref of scan codes that act as mod4 keys,
which is likely the Window key on modern Linux desktops.

=head2 mod5_codes

Get/Set an arrayref of scan codes that act as mod5 keys,
which is likely the "Fn" laptop key on modern Linux desktops.

=head1 METHODS

=head2 new

Constructs an empty XModifierKeymap.  No arguments, yet.

=head2 add

  $modmap->add( $modifier_name, @key_codes );

Adds key codes (and remove duplicates) to one of the eight modifier groups.

=head2 del

  $modmap->del( $modifier_name, @key_codes );

Removes the listed key codes from the named modifier, or from all modifiers
if C<$modifier_name> is undef.  If one of the key codes doesn't actually
exist in the modifier map it is ignored.

=cut
