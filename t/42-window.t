#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 13;
use X11::Xlib qw( :fn_win :const_win :const_winattr );
sub err(&) { my $code= shift; my $ret; { local $@= ''; eval { $code->() }; $ret= $@; } $ret }

my $dpy= new_ok( 'X11::Xlib', [], 'connect to X11' );

my @args= ($dpy, $dpy->RootWindow, 0, 0, 50, 50, 0,
    $dpy->DefaultDepth, InputOutput, $dpy->DefaultVisual,
    0, my $attrs);
my $win_id;
is( err{ $win_id= XCreateWindow(@args) }, '', 'CreateWindow' )
    or diag explain \@args;
ok( $win_id > 0, 'got window id' );

is( err{ XMapWindow($dpy, $win_id); }, '', 'XMapWindow' );
$dpy->XSync;

my ($root, $x, $y, $w, $h, $b, $d);
is( err{ XGetGeometry($dpy, $win_id, $root, $x, $y, $w, $h, $b, $d) }, '', 'XGetGeometry' );
is( $root, $dpy->RootWindow(), 'correct root window' );
ok( defined $x, 'got x' );
ok( defined $y, 'got y' );
ok( defined $w, 'got w' );
ok( defined $h, 'got h' );
ok( defined $b, 'got border' );
ok( defined $d, 'got depth' );

is( err{ XUnmapWindow($dpy, $win_id); }, '', 'XUnmapWindow' );
