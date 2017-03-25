#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use X11::Xlib qw( :fn_win :const_win :const_winattr :const_sizehint );
sub err(&) { my $code= shift; my $ret; { local $@= ''; eval { $code->() }; $ret= $@; } $ret }

my $dpy= new_ok( 'X11::Xlib', [], 'connect to X11' );

my @args= ($dpy, $dpy->RootWindow, 0, 0, 50, 50, 0,
    $dpy->DefaultDepth, InputOutput, $dpy->DefaultVisual,
    0, {});
my $win_id;
is( err{ $win_id= XCreateWindow(@args) }, '', 'CreateWindow' )
    or diag explain \@args;
ok( $win_id > 0, 'got window id' );

is( err{ XMapWindow($dpy, $win_id); }, '', 'XMapWindow' );
$dpy->XSync;

my ($root, $x, $y, $w, $h, $b, $d);
is( err{ XGetGeometry($dpy, $win_id, $root, $x, $y, $w, $h, $b, $d) }, '', 'XGetGeometry' );
is( $root, $dpy->screen->root_window_xid, 'correct root window' );
ok( defined $x, 'got x' );
ok( defined $y, 'got y' );
ok( defined $w, 'got w' );
ok( defined $h, 'got h' );
ok( defined $b, 'got border' );
ok( defined $d, 'got depth' );

my ($size_hints_in, $size_hints_out, $supplied);
$size_hints_in= { min_width => 100, min_height => 50, max_width => 200, max_height => 100, flags => PMinSize | PMaxSize };
is( err{ XSetWMNormalHints($dpy, $win_id, $size_hints_in) }, '', 'Set WM hints' );

is( err{ XGetWMNormalHints($dpy, $win_id, $size_hints_out, $supplied) }, '', 'Get WM hints' );
ok( $supplied & PMinSize, 'received min_size set' );
ok( $supplied & PMaxSize, 'received max_size set' );
is( $size_hints_out->min_width, 100, 'min_width matches' );
is( $size_hints_out->max_width, 200, 'max_width matches' );
is( $size_hints_out->min_height, 50, 'min_height matches' );
is( $size_hints_out->max_height, 100, 'max_height matches' );

is( err{ XUnmapWindow($dpy, $win_id); }, '', 'XUnmapWindow' );

is( err{ XDestroyWindow($dpy, $win_id); }, '', 'XDestroyWindow' );

done_testing;
