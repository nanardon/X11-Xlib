#! /usr/bin/env perl
use strict;
use warnings;

my $keysym_def_h= shift;
$keysym_def_h && -f $keysym_def_h
    or die "Missing required argument DEF_H (i.e. /usr/include/X11/keysymdefs.h)";

open my $fh, "<", $keysym_def_h or die "open: $!";
my @keysym;
# Control chars
$keysym[0xFF00+$_]= $_ for 0x08, 0x09, 0x0A, 0x0B, 0x0D, 0x1B;
# Num Keypad
$keysym[0xFF80]= 0x20;
$keysym[0xFF80+$_]= $_ for 0x09, 0x0D, 0x2A..0x39, 0x3D;
while (<$fh>) {
    if ($_ =~ m,0x(\w+).*U\+(\w+),) {
        my ($sym, $codepoint)= (hex($1), hex($2));
        next if ($sym >= 0x20 && $sym < 0x7F) # Don't need the table
                or ($sym >= 0xA0 && $sym <= 0xFF)
                or (($sym & 0xFF000000) == 0x01000000); # These don't need the table
        die "Codepoint above 0x7FFF" if $codepoint > 0x7FFF;
        $keysym[$sym]= $codepoint;
    }
}

# Identify consecutive ranges in the keysym table
my @ranges;
my $range_start= undef;
my $offset= 0;
for (my $i= 0; $i <= @keysym; $i++) {
    if (defined $keysym[$i] && !defined $range_start) {
        $range_start= $i;
        # ignore small gaps in the table
        if (@ranges && $ranges[-1][1]+4 > $i) {
            ($range_start, undef, $offset)= @{ pop @ranges };
        }
    } elsif (!defined $keysym[$i] && defined $range_start) {
        push @ranges, [ $range_start, $i, $offset ];
        $offset += $i - $range_start;
        $range_start= undef;
    }
}

# Build binary search "if" tree of ranges
sub detect_ranges {
    my ($indent, $start_checked, @r)= @_;
    if (@r > 2) {
        # compare on start of mid, then recurse
        my $mid= @r / 2;
        return $indent . sprintf("if (keysym < 0x%04X) {\n", $r[$mid][0])
            . detect_ranges("$indent  ", $start_checked, @r[0..$mid-1])
            . $indent . "} else {\n"
            . detect_ranges("$indent  ", 1, @r[$mid..$#r])
            . $indent . "}\n";
    } else {
        my $ret= $indent . "if (".($start_checked? "":sprintf("keysym >= 0x%04X && ", $r[0][0]))
            .sprintf("keysym < 0x%04X) {", $r[0][1])
            ." return symtab[keysym - $r[0][0] + $r[0][2] ]; }\n";
        $ret .= $indent . sprintf("if (keysym >= 0x%04X && keysym < 0x%04X) {", $r[1][0], $r[1][1])
            ." return symtab[keysym - $r[1][0] + $r[1][2] ]; }\n"
            if @r > 1;
        return $ret;
    }
}

my $table_values= '';
for (@ranges) {
    my ($begin, $end)= @$_;
    --$end;
    $table_values .= join '',
        sprintf("  /* 0x%04X - 0x%04X */\n", $begin, $end),
        '  ', (map { defined $_? sprintf("0x%04X,", $_) : "-1," } @keysym[$begin..$end]),
        "\n";
}
substr($table_values, -2)= '';
my $if_tree= detect_ranges("    ", 0, @ranges);
print <<"@";
static short symtab[]= {
$table_values
};
int PerlXlib_keysym_to_codepoint(KeySym keysym) {
    // If Latin-1 or direct-to-unicode, skip table lookup
    if ((keysym >= 0x0020 && keysym <= 0x007e) ||
        (keysym >= 0x00a0 && keysym <= 0x00ff))
        return keysym;
    if ((keysym & 0xff000000) == 0x01000000)
        return keysym & 0x00ffffff;
$if_tree
    return -1;
}
@
