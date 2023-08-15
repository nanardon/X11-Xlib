#! /usr/bin/env perl
use strict;
use warnings;
use autodie;

my $xlib_src= do { open my $fh, '<', 'lib/X11/Xlib.pm'; local $/; <$fh> };
$xlib_src =~ /our \$VERSION = ([^;]+);/ or die "Can't locate VERSION in lib/X11/Xlib.pm";
my $ver_str= $1;

for (<lib/X11/Xlib/*.pm>) {
    open my $src_fh, '+<', $_;
    my $src= do { local $/; <$src_fh> };
    my $changed= 0;
    $src =~ s/our \$VERSION *= *([^;]+);/our \$VERSION = $ver_str;/
        and $changed= 1 or warn "$_ does not have a \$VERSION\n";
    my $year= (localtime)[5] + 1900;
    $src =~ s/Copyright \(C\) 2017-(?!$year)\d+/Copyright (C) 2017-$year/
        and $changed= 1 or warn "$_ does not have a Copyright\n";
    if ($changed) {
        seek $src_fh, 0, 0;
        truncate $src_fh, 0;
        print $src_fh $src;
        close $src_fh;
    }
}

# Verify changelog is up to date
my $changes= do { open my $fh, '<', 'Changes'; local $/; <$fh> };
my $ver= substr($ver_str,1,-1);
$changes =~ /^$ver - /m or die "Changes does not list an entry for version $ver";
