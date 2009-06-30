use Test::More tests => 4;
BEGIN { use_ok('X11::Xlib') };

ok(my $display = X11::Xlib->new, "Can get display");
ok($display->DisplayWidth(0), "Can get Display Width");
ok($display->DisplayHeight(0), "Can get Display Height");
