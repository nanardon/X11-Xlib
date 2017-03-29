#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 7;
use X11::Xlib ':all';
sub err(&) { my $code= shift; my $ret; { local $@= ''; eval { $code->() }; $ret= $@; } $ret }

my $dpy= new_ok( 'X11::Xlib', [], 'connect to X11' );

my ($min, $max);
XDisplayKeycodes($dpy, $min, $max);
ok( $min > 0 && $min <= $max,    'Got Min Keycode' );
ok( $max >= $min && $max <= 255, 'Got Max Keycode' );

sub save_temp {
    my ($name, $data)= @_;
    my $fname= sprintf("%s-%d.txt", $name, time);
    open my $fh, ">", $fname or die "open: $!";
    print $fh $data;
    close $fh;
    diag "Saved diagnostics to $fname";
}

subtest modmap => sub {
    my $modmap;
    is( err{ $modmap= $dpy->XGetModifierMapping() }, '', 'XGetModifierMapping' )
     && is( ref $modmap, 'ARRAY', '...is an array' )
     && is( join('', map ref, @$modmap), 'ARRAY'x 8, '...of arrays' )
     or diag(explain $modmap), die "XGetModifierMapping failed.  Not continuing";
    
    # Seems like a bad idea, but need to test....
    is( err{ $dpy->XSetModifierMapping($modmap) }, '', 'XSetModifierMapping' );

    # Make sure we didn't change it
    my $modmap2= $dpy->XGetModifierMapping();
    is_deeply( $modmap2, $modmap, 'same as last time' )
        or BAIL_OUT "SORRY! We changed your X11 key modifiers!";
    
    done_testing;
};

subtest keymap => sub {
    my @keysyms;
    is( err{ @keysyms= XGetKeyboardMapping($dpy, $min) }, '', 'XGetKeyboardMapping' );
    ok( @keysyms > 0, "Got keysyms for $min" );
    
    my $mapping;
    is( err{ $mapping= $dpy->_load_symbolic_keymap }, '', '_load_symbolic_keymap' );
    ok( ref($mapping) eq 'ARRAY' && @$mapping > 0 && ref($mapping->[-1]) eq 'ARRAY', '...is array of arrays' )
        or save_temp("keymap-before", explain $mapping);
    
    # Fingers crossed!
    is( err{ $dpy->_save_symbolic_keymap($mapping) }, '', '_save_symbolic_keymap' )
        or save_temp("keymap-before", explain $mapping);
    
    # Make sure we didn't change it
    my $kmap2= $dpy->_load_symbolic_keymap;
    is_deeply( $mapping, $kmap2, 'same as before' )
        or save_temp("keymap-after", explain $kmap2);
    
    done_testing;
};

subtest keymap_wrapper => sub {
    # TODO: this is sloppy and doesn't prove much
    ok( my $keymap= $dpy->keymap );
    is( err{ $keymap->keymap_reload }, '', 'keymap_reload' );
    is( err{ $keymap->keymap_save   }, '', 'keymap_save' );
    is( err{ $keymap->modmap_sym_list('shift') }, '', 'modmap_sym_list' );
    is( err{ $keymap->modmap_save   }, '', 'modmap_save' );
    is( err{ $keymap->modmap_add_syms(control => 'Control_L') }, '', 'modmap_add_syms' );
    is( err{ $keymap->modmap_del_syms(control => 'Control_L') }, '', 'modmap_del_syms' );
    done_testing;
};

subtest xlib_lookup => sub {
    # Pick some key from the modmap.  Probably every keyboard has at least shift or control?
    ok( my $keycode= $dpy->XKeysymToKeycode(XStringToKeysym('A')), 'XKeysymToKeycode' );
    my $key_event= { type => KeyPress, keycode => $keycode, display => $dpy };
    my ($name, $keysym);
    is( err{ XLookupString($key_event, $name, $keysym) }, '', 'XLookupString' );
    like( $name, qr/\w/, 'XLookupString returned a name' );
    ok( $keysym > 0, 'XLookupString returned a keysym' );
    
    done_testing;
};
