#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 5;
use X11::Xlib ':all';
sub err(&) { my $code= shift; my $ret; { local $@= ''; eval { $code->() }; $ret= $@; } $ret }

my $dpy= new_ok( 'X11::Xlib', [], 'connect to X11' );

my ($min, $max);
XDisplayKeycodes($dpy, $min, $max);
ok( $min > 0 && $min <= $max,    'Got Min Keycode' );
ok( $max >= $min && $max <= 255, 'Got Max Keycode' );

subtest modmap => sub {
    my $modmap;
    is( err{ $modmap= $dpy->XGetModifierMapping() }, '', 'XGetModifierMapping' )
     && is( ref $modmap, 'ARRAY', '...is an array' )
     && is( join('', map ref, @$modmap), 'ARRAY'x 8, '...of arrays' )
     or diag(explain $modmap), die "XGetModifierMapping failed.  Not continuing";
    
    # Seems like a bad idea, but need to test....
    is( err{ $dpy->XSetModifierMapping($modmap) }, '', 'XSetModifierMapping' );

    # Make sure we didn't change it
    my $modmap2;
    is( err{ $modmap2= $dpy->XGetModifierMapping() }, '', 'XGetModifierMapping (2)' );
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
        or diag explain $mapping;
    
    done_testing;
};
