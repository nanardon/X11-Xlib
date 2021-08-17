#! /usr/bin/env perl

use strict;
use warnings;

use Test::More 1.001014;
use Test::TempDir::Tiny;

use X11::Xlib qw( :fn_resources );
use X11::Xlib::XrmDatabase;

my $HALF1 = <<'END';
xmh*Paned*activeForeground:     red
*incorporate.Foreground:     blue
END

my $HALF2 = <<'END';
xmh.toc*Command*activeForeground:     green
xmh.toc*?.Foreground:     white
xmh.toc*Command.activeForeground:     black
END

my $StringDB = $HALF1 . $HALF2;

XrmInitialize();

sub test_db {
    my $db = shift;

    my ( $bool, $type, $value )
      = $db->GetResource(
        'xmh.toc.messagefunctions.incorporate.activeForeground',
        'Xmh.Paned.Box.Command.Foreground' );

    is( !!$bool, 1,        'success' );
    is( $type,   'String', 'type' );
    is( $value,  'black',  "value" );
}

subtest 'File' => sub {
    test_db( XrmGetFileDatabase( 't/xresources' ) );
};

subtest String => sub {
    test_db( XrmGetStringDatabase( $StringDB ) );
};

sub Put {
    my ( $db, $put ) = @_;
    $put->( $db, 'xmh*Paned*activeForeground',       'red' );
    $put->( $db, '*incorporate.Foreground',          'blue' );
    $put->( $db, 'xmh.toc*Command*activeForeground', 'green' );
    $put->( $db, 'xmh.toc*?.Foreground',             'white' );
    $put->( $db, 'xmh.toc*Command.activeForeground', 'black' );
    test_db( $db );
}

sub test_put {
    my $put = shift;
    subtest 'explicit create' => \&Put, XrmGetStringDatabase( '' ), $put;
    subtest 'implicit create' => \&Put, undef, $put;
}

subtest Put => sub {
    test_put sub { XrmPutResource( $_[0], $_[1], 'String', $_[2] ) };
};

subtest PutString => sub {
    test_put sub { XrmPutStringResource( @_ ) };
};

subtest PutLine => sub {
    test_put sub { XrmPutLineResource( $_[0], $_[1] . ': ' . $_[2] ) };
};

subtest PutFileDatabase => sub {
    my $db = XrmGetStringDatabase( $StringDB );

    in_tempdir "method" => sub {
        $db->PutFileDatabase( "resources" );
        my $ndb = XrmGetFileDatabase( "resources" );
        test_db( $ndb );
    };

};

subtest CombineFileDatabase => sub {
    my $filename = 'resources';

    in_tempdir "PutFile" => sub {
        my $source_db = XrmGetStringDatabase( $HALF1 );
        $source_db->PutFileDatabase( $filename );
        my $target_db = XrmGetStringDatabase( $HALF2 );
        my $ok = XrmCombineFileDatabase( $filename, $target_db, 1 );
        ok( $ok, 'XrmCombineFileDatabase' );
        test_db( $target_db );
    };

};

subtest CombineDatabase => sub {

    my $source_db = XrmGetStringDatabase( $HALF1 );
    my $target_db = XrmGetStringDatabase( $HALF2 );
    $source_db->CombineDatabase( $target_db, 1 );
    test_db( $target_db );

};

subtest MergeDatabases => sub {

    my $source_db = XrmGetStringDatabase( $HALF1 );
    my $target_db = XrmGetStringDatabase( $HALF2 );
    $source_db->MergeDatabases( $target_db );
    test_db( $target_db );

};


done_testing;
