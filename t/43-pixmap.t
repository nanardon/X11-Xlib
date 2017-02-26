#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 3;
use X11::Xlib qw( :all );
sub err(&) { my $code= shift; my $ret; { local $@= ''; eval { $code->() }; $ret= $@; } $ret }

my $dpy= new_ok( 'X11::Xlib', [], 'connect to X11' );

my $s= $dpy->screen;
ok( my $pmap= $dpy->XCreatePixmap($s->root_window, 128, 128, $s->visual_info->depth), 'XCreatePixmap' );
$dpy->XSync;
is(err{ $dpy->XFreePixmap($pmap) }, '', 'XFreePixmap' );
