#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 8;
use X11::Xlib qw( KeyPress );
sub err(&) { my $code= shift; my $ret; { local $@= ''; eval { $code->() }; $ret= $@; } $ret }

my $dpy= new_ok( 'X11::Xlib', [], 'connect to X11' );

# This test does a lot of blocking things, so set up an alarm to use as a watchdog
$SIG{ALRM}= sub { fail("Timeout"); exit; };
alarm 5;

my ($send, $recv);
is( err{ $dpy->XPutBackEvent($send); }, '', 'push null event' );
is( err{ $dpy->XNextEvent($recv); }, '', 'read event' );
is( $$send, $$recv, 'inflated events are identical' );

is( err{ $dpy->XPutBackEvent({ type => KeyPress, window => 2 }); }, '', 'push event' );
is( err{ $dpy->XNextEvent($recv); }, '', 'read event' );
is( $recv->type, KeyPress, 'correct type' );
is( $recv->window, 2, 'correct window' );

