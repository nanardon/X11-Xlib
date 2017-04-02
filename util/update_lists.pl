#! /usr/bin/env perl
use strict;
use warnings;
use FindBin;
use File::Temp;
use File::Find;

my @constant_sets;
my @function_sets;
my @manifest;
my $xs_boot= qq{  HV* stash= gv_stashpvn("X11::Xlib", 9, 1);\n};
my %xs_ctor= (
    i => 'newSViv(%s)',
    u => 'newSVuv(%s)',
    n => 'newSVnv(%s)',
);

# Run from project root
chdir "$FindBin::Bin/..";

{ # Rebuild the exportable constants
    open my $consts_fh, "<", "PerlXlib_constants" or die;
    while (<$consts_fh>) {
        chomp;
        if ($_ =~ /^\w/) {
            push @constant_sets, [ $_ ];
        } elsif ($_ =~ /^ (\w) (\w+)/) {
            die "Unhandled type code $1" unless $xs_ctor{$1};
            $xs_boot .= sprintf('  newCONSTSUB(stash, "%s", '.$xs_ctor{$1}.");\n", $2, $2);
            push @{$constant_sets[-1]}, $2;
        } else {
            die "parse error: $_\n" if $_ =~ /\S/;
        }
    }
}
{ # Rebuild the list of exportable Xfunctions
    open my $xs_fh, "<", "Xlib.xs" or die;
    my $ignore= 1;
    while (<$xs_fh>) {
        if ($_ =~ /PACKAGE\s*=\s*(\S+)/) {
            #warn "Package $1\n";
            $ignore= $1 ne 'X11::Xlib';
        }
        next if $ignore;
        if ($_ =~ / \((fn_\w+)\) ---/) {
            push @function_sets, [ $1 ];
        } elsif ($_ =~ /^([A-Za-z]\w+)\(/) {
            push @{ $function_sets[-1] }, $1
                unless $1 eq 'DESTROY';
        }
    }
}
{ # Rebuild the MANIFEST files
    open my $manifest, "<", "MANIFEST" or die;
    @manifest= grep { $_ !~ m,^(lib|t)/, } <$manifest>;
    push @manifest, sort `find lib t -type f`;
}

sub wordwrap {
    my ($indent, $width, $str)= @_;
    my $prev= 0;
    while (length($str) - $prev > $width) {
        my $break_pos= rindex($str, ' ', $prev + $width);
        $break_pos > $prev or die "word longer than width?";
        substr($str, $break_pos, 1)= "\n" . (' ' x $indent);
        $prev= $break_pos;
    }
    $str;
}

sub patch_file {
    my ($fname, $token, $new_content)= @_;
    my $begin_token= "BEGIN $token";
    my $end_token=   "END $token";
    open my $orig, "<", $fname or die "open($fname): $!";
    my $new= File::Temp->new(DIR => ".", TEMPLATE => "${fname}_XXXX");
    while (<$orig>) {
        $new->print($_);
        last if index($_, $begin_token) >= 0;
    }
    $orig->eof and die "Didn't find $begin_token in $fname\n";
    $new->print($new_content);
    while (<$orig>) { if (index($_, $end_token) >= 0) { $new->print($_); last; } }
    $orig->eof and die "Didn't find $end_token in $fname\n";
    while (<$orig>) { $new->print($_) }
    $new->close or die "Failed to save $new";
    rename($new, $fname) or die "rename: $!";
}

my $consts_pl= join '',
    map {
        wordwrap(4, 79, "  ".shift(@$_)." => [qw( ".join(' ', sort @$_)." )],\n")
    } sort { $a->[0] cmp $b->[0] } @constant_sets;
my $fn_pl= join '',
    map {
        wordwrap(4, 79, "  ".shift(@$_)." => [qw( ".join(' ', sort @$_)." )],\n")
    } sort { $a->[0] cmp $b->[0] } @function_sets;

patch_file("Xlib.xs", 'GENERATED BOOT CONSTANTS', $xs_boot);
patch_file("lib/X11/Xlib.pm", 'GENERATED XS CONSTANT LIST', $consts_pl);
patch_file("lib/X11/Xlib.pm", 'GENERATED XS FUNCTION LIST', $fn_pl);
{ open my $fh, ">MANIFEST" or die "$!"; print $fh @manifest; close $fh or die "$!"; }
