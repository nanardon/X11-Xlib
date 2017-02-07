#! /usr/bin/env perl
use strict;
use warnings;
use File::Temp;

# Usage:
#  generate_union_accessor_xs.pl XEvent < /usr/include/X11/Xlib.h

my $goal= shift;

my $input= do { local $/= undef; <STDIN> };
my %types;
my @def_stack= ( { cur_field => undef, fields => \%types } );
my $comment= 0;
while ($input =~ m!(typedef\b|struct\b|union\b|\{|\}|\;|\[|\]|/\*[^*]+|,|\*/|//.*$|\s+|#.*$|\*|\w+\b|.)!cmg) {
    my $token= $1;
    next if $comment && ($token ne '*/');
    #printf " token '%s'\n\t(comment=%d)\t(def_stack=%2d)\t(cur_field=%2s)\n",
    #	$token, $comment, scalar @def_stack, $def_stack[-1]{cur_field}? scalar @{$def_stack[-1]{cur_field}} : 'undef'
    #	unless $token =~ /^\s*$/;
    next unless @def_stack > 1 || $def_stack[-1]{cur_field} || ($token =~ /^(typedef\b|union\b|struct\b|\/\*|\*\/)/);
    
    if ($token eq 'typedef' or $token eq 'struct' or $token eq 'union') {
        push @{ $def_stack[-1]{cur_field} }, $token;
    } elsif ($token eq '{') {
        my %type= ();
        $type{typedef}= shift @{$def_stack[-1]{cur_field}}
            if $def_stack[-1]{cur_field}[0] eq 'typedef';
        if ($def_stack[-1]{cur_field}[0] eq 'struct' or $def_stack[-1]{cur_field}[0] eq 'union') {
            $type{container_type}= shift @{$def_stack[-1]{cur_field}};
            $type{container_name}= shift @{$def_stack[-1]{cur_field}}
                if @{$def_stack[-1]{cur_field}};
        }
        @{$def_stack[-1]{cur_field}}= ( \%type );
        push @def_stack, \%type;
    } elsif ($token eq '}') {
        pop @def_stack;
    } elsif ($token eq ';') {
        my $cur_field= delete $def_stack[-1]{cur_field};
        if (@$cur_field) {
            # break apart commas into separate fields
            my @fields= ( [] );
            for my $part (@$cur_field) {
                if ($part eq ',') {
                    push @fields, [ grep { !($_ =~ /[][*&]/) } @{ $fields[-1] } ];
                    pop @{$fields[-1]}; # remove variable name
                } else {
                    push @{ $fields[-1] }, $part;
                }
            }
            for my $field (@fields) {
                # find and remove name portion
                my $name;
                for (my $i= $#$field; $i > 0; $i--) {
                    if ($field->[$i] =~ /^[a-zA-Z_]/) {
                        ($name)= splice(@$field, $i, 1);
                        last;
                    }
                }
                #if (@def_stack == 1) { warn "Found $name\n"; } else { warn "Found  .$name\n"; }
                $def_stack[-1]{fields}{$name}= normalize_type($field);
            }
        }
    } elsif (substr($token,0,2) eq '/*') {
        $comment= 1;
    } elsif ($token eq '*/') {
        $comment= 0;
    } elsif ($token =~ m,^//, or $token =~ /^\s/ or $token =~ /^#/) {
    } elsif ($token eq '*' or $token eq ',' or $token eq ')' or $token eq '(' or $token eq '[' or $token eq ']' or $token =~ /\w+/) {
        push @{ $def_stack[-1]{cur_field} }, $token;
    } else {
        die "Unexpected token '$token' near ".substr($input, pos($input) - 10, 10).'|'.substr($input, pos($input), 50)."\n";
    }
}

sub normalize_type {
    my $f= shift;
    my @parts= grep{ !($_ =~ /const|static|volatile/) } @$f;
    if (grep { ref $_ } @parts) {
        @parts == 1 or warn "Ignoring ".join(' ',@parts).' because it is too complicated';
        return $parts[0] if @parts == 1;
    } else {
        return join ' ', @parts;
    }
}

#use DDP;
#p %types;
$types{$goal} or die "No type for $goal";

# Traverse struct recursively building a flat list of foo.bar.baz => $type
sub flatten_unions {
    my ($result, $struct_name, $struct, $path)= @_;
    ref $struct && ref $struct->{fields} eq 'HASH'
        or die "Not a container type: $struct_name $path\n";
    for my $fieldname (keys %{ $struct->{fields} || {} }) {
        my $fieldtype= $struct->{fields}{$fieldname};
        my $fieldstructtype= ref $fieldtype? $fieldtype : $types{$fieldtype};
        if (ref $fieldstructtype && $fieldstructtype->{container_type} eq 'union') {
            flatten_unions($result, $fieldtype, $fieldstructtype, "$path$fieldname.");
        } else {
            $result->{"$path$fieldname"}= $fieldtype;
        }
    }
}

my %members;
flatten_unions(\%members, $goal, $types{$goal}, '');
delete $members{c_class};
#p my $x= \%members;

my %int_types= map { $_ => 1 } qw( int long Bool char );
my %unsigned_types= map { $_ => 1 } 'unsigned', 'unsigned int', 'unsigned long',
    qw( Window Drawable Colormap Atom Pixmap Time VisualID );

# This is redundant with the typemap, but don't know how to
# invoke the real one from outside.

sub sv_read {
    my ($type, $access, $svname)= @_;
    return "$access= SvIV($svname);" if $int_types{$type};
    return "$access= SvUV($svname);" if $unsigned_types{$type};
    return "$access= PerlXlib_sv_to_display($svname);" if $type eq 'Display *';
    return "{"
        ." if (!SvPOK($svname) || SvCUR($svname) != sizeof($type))"
        .'  croak("Expected scalar of length %d but got %d",'." sizeof($type), SvCUR($svname));"
        ." $access= * ($type *) SvPVX($svname);"
        ."}" if $type =~ /^\w+ \*$/;
    return "{"
        ." if (!SvPOK($svname) || SvCUR($svname) != sizeof($1)*$2)"
        .'  croak("Expected scalar of length %d but got %d",'." sizeof($1)*$2, SvCUR($svname));"
        ." memcpy($access, SvPVX($svname), sizeof($1)*$2);"
        ."}" if $type =~ /^(\w+) \[ (\d+) \]$/;
    die "Don't know how to read $type from an SV";
}
sub sv_create {
    my ($type, $value)= @_;
    return "newSViv($value)" if $int_types{$type};
    return "newSVuv($value)" if $unsigned_types{$type};
    return "($value? sv_setref_pv(newSV(0), \"X11::Xlib\", (void*)$value) : &PL_sv_undef)" if $type eq 'Display *';
    return "newSVpvn((void*) &$value, sizeof($type))"
        if $type =~ /^(\w+) \*$/;
    return "newSVpvn((void*)$value, sizeof($1)*$2)"
        if $type =~ /^(\w+) \[ (\d+) \]$/;
    die "Don't know how to create SV from $type";
}

sub generate_xs_accessor {
    my $fieldname= shift;
    return <<"@";
$members{$fieldname}
_get_${fieldname}(st)
    ${goal} *st
    CODE:
        RETVAL = st->${fieldname};
    OUTPUT:
        RETVAL

void
_set_${fieldname}(st, val)
    ${goal} *st
    $members{$fieldname} val
    CODE:
        st->${fieldname}= val;

@
}

sub generate_pack_c {
    my $c= <<"@";
void PerlXlib_${goal}_pack($goal *s, HV *fields) {
    SV **fp;

    memset(s, 0, sizeof(*s)); // wipe the struct
@
    for my $path (sort keys %members) {
        my $type= $members{$path};
        my ($name)= ($path =~ /([^.]+)$/);
        $c .= '    fp= hv_fetch(fields, "'.$name.'", '.length($name).", 0);\n"
           .  '    if (fp && *fp) { '.sv_read($type, 's->'.$path, '*fp')." }\n";
    }

    return $c . "\n}\n";
}

sub generate_unpack_c {
    # First, pack type, then pack fields for XAnyEvent, then any fields known for that type
    my $c= <<"@";
void PerlXlib_${goal}_unpack($goal *s, HV *fields) {
    // hv_store may return NULL if there is an error, or if the hash is tied.
    // If it does, we need to clean up the value.
    SV *sv= NULL;
@
    for my $path (sort keys %members) {
        my $type= $members{$path};
        my ($name)= ($path =~ /([^.]+)$/);
        $c .= sprintf "    if (!hv_store(fields, %-12s, %2d, (sv=%s), 0)) goto store_fail;\n",
            qq{"$name"}, length($name), sv_create($type, 's->'.$path);
    }

    $c .= <<'@';
    return;
    store_fail:
        if (sv) sv_2mortal(sv);
        croak("Can't store field in supplied hash (tied maybe?)");
}
@
    return $c;
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

my $out_xs= <<"@";

MODULE = X11::Xlib                PACKAGE = X11::Xlib::${goal}

void
_pack(s, fields)
    ${goal} *s
    HV *fields
    PPCODE:
        PerlXlib_${goal}_pack(s, fields);

void
_unpack(s, fields)
    ${goal} *s
    HV *fields
    PPCODE:
        PerlXlib_${goal}_unpack(s, fields);

@
$out_xs .= generate_xs_accessor($_) for keys %members;

my $out_pl= "\n";
my $out_const= "";

my $file_splice_token= "GENERATED X11_Xlib_${goal}";

my $out_c=  "\n";
$out_c  .= generate_pack_c() . "\n" . generate_unpack_c() . "\n";
patch_file("Xlib.xs", $file_splice_token, $out_xs);
patch_file("PerlXlib.c", $file_splice_token, $out_c);
