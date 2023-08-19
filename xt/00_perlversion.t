#!/pro/bin/perl

use strict;
use warnings;

eval "use Test::More 0.93";
if ($@ || $] < 5.010) {
    print "1..0 # perl-5.10.0 + Test::More 0.93 required for version checks\n";
    exit 0;
    }
eval "use Test::MinimumVersion";
if ($@) {
    print "1..0 # Test::MinimumVersion required for compatability tests\n";
    exit 0;
    }

use File::Find;
my @t;
find (sub {
    -f && m{\.(?:t|pl|pm|PL)$} or return;
    my $f = $File::Find::name =~ s{^\./}{}r;
    $f =~ m{^(?:blib|xt)/} and return;
    push @t => $f;
    }, ".");

all_minimum_version_ok ("5.008.000", { paths => [ sort @t ] });
done_testing ();
