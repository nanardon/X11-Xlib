#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use X11::Xlib::XID;

my $xid1= new_ok( 'X11::Xlib::XID', [ display => 0, xid => 1 ], 'create XID' );
my $xid2= new_ok( 'X11::Xlib::XID', [ display => 0, xid => 2 ], 'create XID' );
my $xid1_again= new_ok( 'X11::Xlib::XID', [ display => 0, xid => 1 ], 'create XID' );
my $xid0= new_ok( 'X11::Xlib::XID', [ display => 0, xid => 0 ], 'create XID' );

is( $xid1, $xid1_again, 'Two obj of the same XID compare equal' );
isnt( $xid1, $xid2, 'Different XID compare !=' );
ok( $xid1 == 1, 'XID compared == 1' );
ok( !($xid1 == 2), 'XID compares <> 2' );
ok( 1 == $xid1, 'XID compared == 1' );
ok( 2 != $xid1, 'XID compares <> 2' );
ok( $xid1, 'XID 1 is true' );
ok( !$xid0, 'XID 0 is false' );

done_testing;
