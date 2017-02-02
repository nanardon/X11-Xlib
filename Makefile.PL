use 5.008000;

use strict;
use warnings;

use Devel::CheckLib;
use ExtUtils::MakeMaker;

check_lib_or_exit(
    lib    => 'X11',
    header => [ 'X11/Xlib.h', 'X11/Xutil.h' ]
);

check_lib_or_exit(
    lib    => 'Xtst',
    header => [ 'X11/extensions/XTest.h' ]
);

check_lib_or_exit(
    lib    => 'Xext'
);

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'X11::Xlib',
    VERSION_FROM => 'lib/X11/Xlib.pm',    # finds $VERSION
    PREREQ_PM    => {},                   # e.g., Module::Name => 1.1
    ($] >= 5.005 ?                        ## Add these new keywords supported since 5.005
          (ABSTRACT_FROM => 'lib/X11/Xlib.pm',    # retrieve abstract from module
            AUTHOR => 'Olivier Thauvin <nanardon@nanardon.zarb.org>') : ()),
    LIBS   => [ '-lX11 -lXtst -lXext' ],  # e.g., '-lm'
    DEFINE => '',                         # e.g., '-DHAVE_SOMETHING'
    INC    => '-I.',                      # e.g., '-I. -I/usr/include/other'
    CONFIGURE_REQUIRES => {
        'Devel::CheckLib' => '1.03',
    },
    # Un-comment this if you add C files to link with later:
    # OBJECT            => '$(O_FILES)', # link all the C files too
);
