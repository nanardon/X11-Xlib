#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

eval "use Test::Pod::Coverage 1.00; use Pod::Coverage::TrustPod 0.1; 1"
    or plan skip_all => "Test::Pod::Coverage 1.00 and Pod::Coverage::TrustPod 0.1 required for testing POD coverage. $@";
all_pod_coverage_ok ({ coverage_class => 'Pod::Coverage::TrustPod' });
