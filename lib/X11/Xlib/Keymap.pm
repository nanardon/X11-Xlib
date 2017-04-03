package X11::Xlib::Keymap;
use strict;
use warnings;
use Carp;

=head1 NAME

X11::Xlib::Keymap - Object Oriented access to the X11 keymap

=head1 DESCRIPTION

For better or for worse, (hah, who am I kidding; worse) the X11 protocol gives
applications the direct keyboard scan codes from the input device, and
provides two tables to let applications do thwir own interpretation of the
codes.  The first table ("keymap") maps the scan codes (single byte) to one or
more symbolic constants describing the glyph on the key.  Choosing which of
the several symbols to use dpeends on which "modifiers" are in effect.
The second table is the "modifier map", which lists keys (scan codes, again)
that are part of each of the eight modifier groups.  Two modifier groups
(Shift and Control) have constant meaning, but the rest require some creative
logic to interpret.

The keymap can't be used without the modifier map, but the modifier map can't
be interpreted without the keymap, so both tables are rolled together into
this object.

While there are always less than 255 hardware scan codes, the set of device-
independent KeySym codes is huge (including Unicode as a subset).
Since the KeySym constants can't be practically exported by a Perl module,
this API mostly tries to let you use the symbolic names of keys, or unicode
characters.  Xlib can translate Keysyms to/from text with client-side lookup
tables, so using L<X11::Xlib/XKeysymToString> / L<X11::Xlib/XStringToKeysym>
is a practical alternative.

=head1 ATTRIBUTES

=head2 display

Holds a weak-ref to the Display, used for the loading and saving operations.

=cut

sub display {
    my $self= shift;
    weaken( $self->{display}= shift ) if @_;
    $self->{display};
}

=head2 keymap

Arrayref that maps from a key code (byte) to an arrayref of KeySyms.
The meaning of the positions of the arrayref roughly correspond to

  [ $normal_key, $key_with_shift, $mode2_normal_key, $mode2_key_with_shift ]

where "mode2" indicates a dynamic switch of key layout of some sort.
Additional elements of the array are vendor-specific.

This table is exactly as loaded from the X11 server

=head2 rkeymap

A hashref mapping from the symbolic name of a key to its scan code.

=cut

sub keymap {
    my $self= shift;
    if (@_) { $self->{keymap}= shift; delete $self->{rkeymap}; }
    $self->{keymap} ||= defined wantarray? $self->display->load_keymap : undef;
}

sub rkeymap {
    my $self= shift;
    $self->{rkeymap} ||= do {
        my %rkmap;
        my $kmap= $self->keymap;
        for (my $i= $#$kmap; $i >= 0; $i--) {
            next unless ref $kmap->[$i] eq 'ARRAY';
            defined $_ and $rkmap{$_}= $i for @{$kmap->[$i]};
        }
        \%rkmap;
    };
}

=head2 modmap

An arrayref of eight modifier groups, each element being the list
of key codes that are part of that modifier.

=head2 modmap_ident

A hashref of logical modifier group names to array index within the modmap.
On a modern English Linux desktop you will likely find:

  shift    => 0,
  lock     => 1, capslock => 1,
  control  => 2,
  alt      => 3, meta => 3,
  numlock  => 4,
  win      => 6, super => 6
  mode     => 7,

but the numbers 3..7 can be re-purposed by your particular key layout.
Note that X11 has a concept of "mode switching" where a modifier completely
changes the meaning of every key.  I think this is used by multi-lingual
setups, but I've not tested/confirmed this.

=cut

sub modmap {
    my $self= shift;
    if (@_) { $self->{modmap}= shift; delete $self->{modmap_ident}; }
    $self->{modmap} ||= defined wantarray? $self->display->XGetModifierMapping : undef;
}

sub modmap_ident {
    my $self= shift;
    $self->{modmap_ident} ||= do {
        my $km= $self->keymap;
        my $mm= $self->modmap;
        my %ident= ( shift => 0, lock => 1, control => 2, mod1 => 3, mod2 => 4, mod3 => 5, mod4 => 6, mod5 => 7 );
        # "lock" is either 'capslock' or 'shiftlock' depending on keymap.
        # for each member of lock, see if its member keys include XK_Caps_Lock
        if (grep { $_ && $_ eq 'Caps_Lock' } map { ($_ && defined $km->[$_])? @{ $km->[$_] } : () } @{ $mm->[1] }) {
            $ident{capslock}= 1;
        # Else check for the XK_Shift_Lock
        } elsif (grep { $_ && $_ eq 'Shift_Lock' } map { ($_ && defined $km->[$_])? @{ $km->[$_] } : () } @{ $mm->[1] }) {
            $ident{shiftlock}= 1;
        }
        # Identify the group based on what keys belong to it
        for (3..7) {
            my @syms= grep { $_ } map { ($_ && defined $km->[$_])? @{ $km->[$_] } : () } @{ $mm->[$_] };
            $ident{alt}=  $_    if grep { /^Alt/ } @syms;
            $ident{meta}= $_    if grep { /^Meta/ } @syms;
            $ident{hyper}= $_   if grep { /^Hyper/ } @syms;
            $ident{numlock}= $_ if grep { $_ eq 'Num_Lock' } @syms;
            $ident{mode}= $_    if grep { $_ eq 'Mode_switch' } @syms;
            if (grep { /^Super/ } @syms) {
                $ident{super}= $_;
                $ident{win}= $_;
            }
        }
        \%ident;
    };
}

=head1 METHODS

=head2 new

  my $keymap= X11::Xlib::Keymap->new(display => $dpy, %attrs);

Initialize a keymap with the list of parameters.  L</display> is required
for any load/save operations.  You can use most of the class with just the
L</keymap> and </modmap> attributes.

=cut

sub new {
    my $class= shift;
    my %args= (@_ == 1 and ref($_[0]) eq 'HASH')? %{ $_[0] }
        : ((@_ & 1) == 0)? @_
        : croak "Expected hashref or even-length list";
    bless \%args, $class;
}

=head2 find_keycode

  my $keycode= $display->find_keycode( $key_sym );

Return a keycode for the KeySym name.  If more than one key code maps to
the KeySym, this returns an arbitrary one of them.

=head2 find_keysym

  my $sym_name= $display->find_keysym( $key_code, $modifier_bits );
  my $sym_name= $display->find_keysym( $XKeyEvent );

Returns the symbolic name of a key, given its scan code and current modifier bits.

For convenience, you can pass an L<X11::Xlib::XEvent/XKeyEvent> object.

If you don't have modifier bits, pass 0.

=cut

sub find_keycode {
    my ($self, $sym)= @_;
    return $self->rkeymap->{$sym}
        || $self->rkeymap->{X11::Xlib::XKeysymToString(X11::Xlib::char_to_keysym($sym))};
}

sub find_keysym {
    my $self= shift;
    my ($keycode, $modifiers)=
        @_ == 1 && ref($_[0]) && ref($_[0])->can('pack')? ( $_[0]->keycode, $_[0]->state )
        : @_ == 2? @_
        : croak "Expected XKeyEvent or (code,modifiers)";
    my $km= $self->keymap->[$keycode]
        or return undef;
    # Shortcut
    return $km->[0] unless $modifiers;
    
    my $mod_id=    $self->modmap_ident;
    my $shift=     $modifiers & 1;
    my $capslock=  $mod_id->{capslock}  && ($modifiers & (1 << $mod_id->{capslock}));
    my $shiftlock= $mod_id->{shiftlock} && ($modifiers & (1 << $mod_id->{shiftlock}));
    my $numlock=   $mod_id->{numlock}   && ($modifiers & (1 << $mod_id->{numlock}));
    my $mode=      ($mod_id->{mode} && ($modifiers & (1 << $mod_id->{mode})))? 2 : 0;
    # If numlock and Num keypad KeySym...
    if ($numlock && ($km->[1] =~ /^KP_/)) {
        return (($shift || $shiftlock)? $km->[$mode+0] : $km->[$mode+1]);
    } elsif (!$shift && !$capslock && !$shiftlock) {
        return $km->[$mode];
    } elsif (!$shift && $capslock) {
        return uc($km->[$mode]);
    } elsif ($shift && $capslock) {
        return uc($km->[$mode+1]);
    } else { # if ($shift || $shiftlock)
        return $km->[$mode+1];
    }
}

=head2 keymap_reload

  $keymap->keymap_reload();        # reload all keys
  $keymap->keymap_reload(@codes);  # reload range from min to max

Reload all or a portion of the keymap.
If C<@codes> are given, then only load from min(@codes) to max(@codes).
(The cost of loading the extra codes not in the list is assumed to be
 less than the cost of multipe round trips to the server to pick only
 the specific codes)

=head2 keymap_save

  $keymap->keymap_save(@codes);    # Save changes to keymap (not modmap)

Save any changes to L</keymap> back to the server.
If C<@codes> are given, then only save from min(@codes) to max(@codes).

See L</save> to save both the L</keymap> and L</modmap>.

=cut

sub keymap_reload {
    my ($self, @codes)= @_;
    my ($min, $max)= @codes? ($codes[0], $codes[0]) : (0,255);
    for (@codes) { $min= $_ if $_ < $min; $max= $_ if $_ > $max; }
    my $km= $self->display->load_keymap(2, $min, $max);
    splice(@{$self->keymap}, $min, $max-$min+1, @$km);
    $self->keymap;
}

sub keymap_save {
    my ($self, @codes)= @_;
    my $km= $self->keymap;
    my ($min, $max)= @codes? ($codes[0], $codes[0]) : (0, $#$km);
    for (@codes) { $min= $_ if $_ < $min; $max= $_ if $_ > $max; }
    $self->display->save_keymap($km, $min, $max);
}

=head2 modmap_sym_list

  my @keysym_names= $display->modmap_sym_list( $modifier );
  
Get the default keysym names for all the keys bound to the C<$modifier>.
Modifier is one of 'shift','lock','control','mod1','mod2','mod3','mod4','mod5',
 'alt','meta','capslock','shiftlock','win','super','numlock','hyper'.

Any modifier after mod5 in that list may not be defined for your keymap
(and return an empty list, rather than an error).

=cut

sub modmap_sym_list {
    my ($self, $modifier)= @_;
    my $km= $self->keymap;
    my $mod_id= $self->modmap_ident->{$modifier};
    return unless defined $mod_id;
    return map { $km->[$_][0]? ( $km->[$_][0] ) : () } @{ $self->modmap->[$mod_id] };
}

=head2 modmap_add_codes

  $keymap->modmap_add_codes( $modifier, @key_codes );

Adds key codes (and remove duplicates) to one of the eight modifier groups.
C<$modifier> is one of the values listed above.

Throws an exception if C<$modifier> doesn't exist.
Returns the number of key codes added.

=head2 modmap_add_syms

  $keymap->modmap_add_syms( $modifier, @keysym_names );

Convert keysym names to key codes and then call L</modmap_add_codes>.

Warns if any keysym is not part of the current keyboard layout.
Returns the number of key codes added.

=cut

sub modmap_add_codes {
    my ($self, $modifier, @codes)= @_;
    my $mod_id= $self->modmap_ident->{$modifier};
    croak "Modifier '$modifier' does not exist in this keymap"
        unless defined $mod_id;
    
    my $modcodes= $self->modmap->[$mod_id];
    my %seen= ( 0 => 1 ); # prevent duplicates, and remove nulls
    @$modcodes= grep { !$seen{$_}++ } @$modcodes;
    my $n= @$modcodes;
    push @$modcodes, grep { !$seen{$_}++ } @codes;
    return @$modcodes - $n;
}

sub modmap_add_syms {
    my ($self, $modifier, @names)= @_;
    my $rkeymap= $self->rkeymap;
    my (@codes, @notfound);
    for (@names) {
        my $c= $rkeymap->{$_};
        defined $c? push(@codes, $c) : push(@notfound, $_);
    }
    croak "Key codes not found: ".join(' ', @notfound)
        if @notfound;
    $self->modmap_add_codes($modifier, @codes);
}

=head2 modmap_del_codes

  $keymap->modmap_del_syms( $modifier, @key_codes );

Removes the listed key codes from the named modifier, or from all modifiers
if C<$modifier> is undef.

Warns if C<$modifier> doesn't exist.
Silently ignores key codes that don't exist in the modifiers.
Returns number of key codes removed.

=head2 modmap_del_syms

  $display->modmap_del_syms( $modifier, @keysym_names );

Convert keysym names to key codes and then call L</modmap_del_codes>.

Warns if any keysym is not part of the current keyboard layout.
Returns number of key codes removed.

=cut

sub modmap_del_codes {
    my ($self, $modifier, @codes)= @_;
    my $count= 0;
    my %del= map { $_ => 1 } @codes;
    if (defined $modifier) {
        my $mod_id= $self->modmap_ident->{$modifier};
        croak "Modifier '$modifier' does not exist in this keymap"
            unless defined $mod_id;
        my $cur_codes= $self->modmap->[$mod_id];
        my $n= @$cur_codes;
        @$cur_codes= grep { !$del{$_} } @$cur_codes;
        $count= $n - @$cur_codes;
    }
    else {
        for (@{ $self->modmap }) {
            my $n= @$_;
            @$_ = grep { !$del{$_} } @$_;
            $count += $n - @$_;
        }
    }
    return $count;
}

sub modmap_del_syms {
    my ($self, $modifier, @names)= @_;
    my $rkeymap= $self->rkeymap;
    my (@codes, @notfound);
    for (@names) {
        my $c= $rkeymap->{$_};
        defined $c? push(@codes, $c) : push(@notfound, $_);
    }
    carp "Key codes not found: ".join(' ', @notfound)
        if @notfound;
    $self->modmap_del_codes($modifier, @codes);
}

=head2 modmap_save

  $keymap->modmap_save;

Call L<X11::Xlib/XSetModifierMapping> for the current L</modmap>.

=head2 save

  $keymap->save

Save the full L</keymap> and L</modmap>.

=cut

sub modmap_save {
    my ($self, $new_modmap)= @_;
    $self->{modmap}= $new_modmap if defined $new_modmap;
    $self->display->XSetModifierMapping($self->modmap);
}

sub save {
    my $self= shift;
    $self->keymap_save;
    $self->modmap_save;
}

1;

__END__

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