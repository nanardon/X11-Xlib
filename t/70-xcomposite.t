#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use X11::Xlib;

plan skip_all => 'Xcomposite extension is not installed'
    unless X11::Xlib->can('XCompositeVersion');

my $dpy= new_ok( 'X11::Xlib', [], 'connect to X11' );

# Can't actually test much without royally screwing up the user's desktop
# TODO: add some env vars to conduct deeper tests

ok( X11::Xlib::XCompositeVersion(), 'XCompositeVersion' );
ok( X11::Xlib::XCompositeQueryVersion($dpy), 'XCompositeQueryVersion' );

done_testing;
