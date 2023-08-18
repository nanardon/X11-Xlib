#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

eval "use Test::Pod";
plan skip_all => "Test::Pod 1.00 required for testing POD" if $@;
all_pod_files_ok ();
