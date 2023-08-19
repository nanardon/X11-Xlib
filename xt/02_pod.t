#! /usr/bin/env perl

use Test::More;

eval "use Test::Pod::Links";
plan skip_all => "Test::Pod::Links required for testing POD Links" if $@;
eval {
    no warnings "redefine";
    no warnings "once";
    use File::Find;
    my @pm;
    find (sub { -f && m/\.pm$/ and push @pm => $File::Find::name }, "lib");
    *Test::XTFiles::all_files = sub { sort @pm; };
    };
Test::Pod::Links->new->all_pod_files_ok;
