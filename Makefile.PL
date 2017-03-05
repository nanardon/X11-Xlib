use 5.008000;

use strict;
use warnings;

use ExtUtils::MakeMaker;

our %PREREQ_PM;
BEGIN {
    %PREREQ_PM= (
        'ExtUtils::Depends' => '0.405',
        'Devel::CheckLib'   => '1.03',
    );

    # If the prereqs for this script are missing,
    # write out a Makefile that tells CPAN to install them
    my $use_prereqs_code= join('', map { "use $_ '$PREREQ_PM{$_}'; " } keys %PREREQ_PM).'1;';
    print $use_prereqs_code."\n";
    unless (eval $use_prereqs_code) {
       warn "$@\n";
       WriteMakefile(
             NAME         => 'X11::Xlib',
             PREREQ_FATAL => 1,
             PREREQ_PM    => \%PREREQ_PM,
       );
       exit 1; # not reached
    }
}

my $dep= ExtUtils::Depends->new('X11::Xlib');

# TODO: follow the pattern of Glib perl module and detect which extensions are
#   present, then use that to determine which headers to include and which XS
#   files to merge together.

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

$dep->set_libs('-lX11 -lXtst -lXext');
$dep->add_c('PerlXlib.c');
$dep->add_xs('Xlib.xs');
$dep->add_typemaps('typemap');
$dep->install('PerlXlib.h');

mkdir 'build', 0777;
$dep->save_config('build/IFiles.pm');

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'X11::Xlib',
    VERSION_FROM => 'lib/X11/Xlib.pm',    # finds $VERSION
    PREREQ_PM    => {},                   # e.g., Module::Name => 1.1
    ($] >= 5.005 ?                        ## Add these new keywords supported since 5.005
          (ABSTRACT_FROM => 'lib/X11/Xlib.pm',    # retrieve abstract from module
            AUTHOR => [
              'Olivier Thauvin <nanardon@nanardon.zarb.org>',
              'Michael Conrad <mike@nrdvana.net>'
            ]) : ()),
    CONFIGURE_REQUIRES => \%PREREQ_PM,
    $dep->get_makefile_vars,
);
