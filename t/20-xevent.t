#!/usr/bin/env perl
use Carp::Always;
BEGIN { $Carp::Verbose= 1; }
use strict;
use warnings;
use Test::More tests => 20;

use_ok('X11::Xlib::Struct::XEvent') or die;
sub err(&) { my $code= shift; my $ret; { local $@= ''; eval { $code->() }; $ret= $@; } $ret }

# Create a new XEvent
my $blank_event= new_ok( 'X11::Xlib::Struct::XEvent', [], 'blank event' );
ok( defined $blank_event->buffer, 'buffer is defined' );
ok( length($blank_event->buffer) > 0, 'and has non-zero length' );
is( $blank_event->type,    0,     'type=0' );
is( $blank_event->display, undef, 'display=undef' );
is( $blank_event->window,  0,     'window=0' );
is( $blank_event->serial,  0,     'serial=0' );
is( $blank_event->send_event, 0,  'send_event=0' );

# Any method from other subtypes should not exist
like( err{ $blank_event->x }, qr/locate object method "x"/, 'subtype methods don\'t exist on root event class' );
# The XS version should also throw an exception after checking the type
like( err{ $blank_event->_x }, qr/XEvent\.x/, 'XS refuses to fetch subtype fields' );

# Create an XEvent with constructor arguments
my $bp_ev;
is( err{ $bp_ev= X11::Xlib::Struct::XEvent->new(type => 'ButtonPress'); }, '', 'create buttonpress event' );
isa_ok( $bp_ev, 'X11::Xlib::Struct::XEvent::XButtonEvent', 'event' )
    or diag explain $bp_ev;

is( $bp_ev->type, X11::Xlib::ButtonPress(), 'button press correct type' );

# Should be able to set button-only fields now
is( err{ $bp_ev->x(50) }, '', 'set x on button event' );
is( err{ $bp_ev->y(-7) }, '', 'set y on button event' );

# Clone an event via its fields:
my $clone= new_ok( 'X11::Xlib::Struct::XEvent', [$bp_ev->unpack], 'clone event with pack(unpack)' )
    or diag explain $bp_ev->unpack;
is( $clone->buffer, $bp_ev->buffer, 'clone contains identical bytes' );

is( $clone->x, 50, 'x value preserved' );
is( $clone->y, -7, 'y value preserved' );
