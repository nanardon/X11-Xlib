use Test::More tests => 10;
BEGIN { use_ok('X11::Xlib') };

ok(my $display = X11::Xlib->new, "Can get display");
ok($display->DisplayWidth(0), "Can get Display Width");
ok($display->DisplayHeight(0), "Can get Display Height");
is(XKeysymToString(0x61), 'a', "Can get String from keysym");
is(XStringToKeysym('a'), 0x61, "Can get keysym from String");

# We cannot really test here because depending of keyboard
# data changes
my @keysym = $display->XGetKeyboardMapping(54);
ok(@keysym, "can get the keyboard mapping");

ok(my $rootwindow = $display->RootWindow(0), "Can get root window");
isa_ok($rootwindow, 'X11::Xlib::Window');
ok($rootwindow->id, "Can get window id");

