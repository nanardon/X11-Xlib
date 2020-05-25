#! /usr/bin/env perl
use strict;
use warnings;
use autodie;

my $xlib_src= do { open my $fh, '<', 'lib/X11/Xlib.pm'; local $/; <$fh> };
$xlib_src =~ /our \$VERSION = ([^;]+);/ or die "Can't locate VERSION in lib/X11/Xlib.pm";
my $ver= $1;

for (<lib/X11/Xlib/*.pm>) {
    open my $src_fh, '+<', $_;
    my $src= do { local $/; <$src_fh> };
    if ($src =~ s/our \$VERSION *= *([^;]+);/our \$VERSION = $ver;/) {
        seek $src_fh, 0, 0;
        truncate $src_fh, 0;
        print $src_fh $src;
        close $src_fh;
    }
    else {
        warn "$_ does not have a \$VERSION\n";
    }
}
