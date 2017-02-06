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
$types{$goal} or die "No type for $goal";
#p my $y= $types{$goal};

my %type_to_struct= qw(
	MotionNotify     XMotionEvent
	ButtonPress	     XButtonEvent
	ButtonRelease    XButtonEvent
	ColormapNotify   XColormapEvent
	EnterNotify      XCrossingEvent
	LeaveNotify	     XCrossingEvent
	Expose           XExposeEvent
	GraphicsExpose   XGraphicsExposeEvent
	NoExpose         XNoExposeEvent
	FocusIn          XFocusChangeEvent
	FocusOut         XFocusChangeEvent
	KeymapNotify     XKeymapEvent
	KeyPress         XKeyEvent
	KeyRelease       XKeyEvent
	MotionNotify     XMotionEvent
	PropertyNotify   XPropertyEvent
	ResizeRequest    XResizeRequestEvent
	CirculateNotify  XCirculateEvent
	ConfigureNotify	 XConfigureEvent
	DestroyNotify    XDestroyWindowEvent
	GravityNotify    XGravityEvent
	MapNotify        XMapEvent
	ReparentNotify   XReparentEvent
	UnmapNotify      XUnmapEvent
	CreateNotify     XCreateWindowEvent
	ClientMessage    XClientMessageEvent
	MappingNotify    XMappingEvent
	SelectionClear   XSelectionClearEvent
	SelectionNotify  XSelectionEvent
	SelectionRequest XSelectionRequestEvent
	VisibilityNotify XVisibilityEvent
);
my %struct_to_field;
for (keys %{ $types{$goal}{fields} }) {
	my $typ= $types{$goal}{fields}{$_};
	$struct_to_field{$typ}= $_ if ref ($types{$typ}||'')
}
my %type_to_field= map { $_ => $struct_to_field{$type_to_struct{$_}} }
	keys %type_to_struct;
my %field_to_type;
push @{$field_to_type{$type_to_field{$_}}}, $_
	for keys %type_to_field;

# Traverse struct recursively building a flat list of foo.bar.baz => $type
sub flatten_fields {
	my ($result, $struct_name, $struct, $path)= @_;
	ref $struct && ref $struct->{fields} eq 'HASH'
		or die "Not a container type: $struct_name $path\n";
	for my $fieldname (keys %{ $struct->{fields} || {} }) {
		my $fieldtype= $struct->{fields}{$fieldname};
		my $fieldstructtype= ref $fieldtype? $fieldtype : $types{$fieldtype};
		if (ref $fieldstructtype) {
			flatten_fields($result, $fieldtype, $fieldstructtype, "$path$fieldname.");
		} else {
			$result->{"$path$fieldname"}= $fieldtype;
		}
	}
}

#sub generate_reflection {
#    my $c= <<"@";
## This is auto-generated by $0, do not make manual edits
#
#%X11::Xlib::${goal}::type_subclass= {
#}
#
#typedef struct s_PerlXlib_${goal}_type_reflection {
#    const char* name;
#    int value;
#    const char* member_struct;
#} PerlXlib_${goal}_type_reflection_t;
#PerlXlib_${goal}_type_reflection_t PerlXlib_${goal}_type_reflection[]= {
#@
#    for my $type (sort keys %type_to_struct) {
#        $c .= qq{  { "$type", $type, "$type_to_struct{$type}" },\n};
#    }
#    substr($c,-2)= '';
#    $c .= <<"@";
#
#};
#const char* PerlXlib_{$goal}_union_members=
#@
#    for my $type (sort keys %struct_to_field) {
#        $c .= qq{  "$_ $struct_to_field{$_} 
#    return $c;
#}

my %members;
flatten_fields(\%members, $goal, $types{$goal}, '');

#p my $x= \%members;

my $ignore_re= qr/(^xerror|data$|c_new$)/;
my $member_known_type= join '|', grep { $_ =~ $ignore_re } keys %type_to_field;
my $known_member_type_re= qr/^($member_known_type)/;

my %distinct_leaf=
	map { $_ =~ /(^|\.)(\w+)$/? ($2 => 1) : () }
	grep { $_ !~ $ignore_re }
	keys %members;

my %int_types= map { $_ => 1 } qw( int long Bool char );
my %unsigned_types= map { $_ => 1 } 'unsigned', 'unsigned int', 'unsigned long',
	qw( Window Drawable Colormap Atom Pixmap Time );

sub sv_read {
	my ($type, $access, $svname)= @_;
	return "$access= SvIV($svname);" if $int_types{$type};
	return "$access= SvUV($svname);" if $unsigned_types{$type};
	return "$access= PerlXlib_sv_to_display($svname);" if $type eq 'Display *';
	return "{"
		." if (!SvPOK($svname) || SvLEN($svname) != sizeof($1)*$2)"
		.'  croak("Expected scalar of length %d but got %d",'." sizeof($1)*$2, SvLEN($svname));"
		." memcpy($access, SvPVX($svname), sizeof($1)*$2);"
		."}" if $type =~ /^(\w+) \[ (\d+) \]$/;
	die "Don't know how to read $type from an SV";
}
sub sv_create {
	my ($type, $value)= @_;
	return "newSViv($value)" if $int_types{$type};
	return "newSVuv($value)" if $unsigned_types{$type};
	return "($value? sv_setref_pv(newSV(0), \"X11::Xlib\", (void*)$value) : &PL_sv_undef)" if $type eq 'Display *';
	return "newSVpvn((void*)$value, sizeof($1)*$2)"
		if $type =~ /^(\w+) \[ (\d+) \]$/;
	die "Don't know how to create SV from $type";
}

sub generate_constants {
    my $c= '';
    for (sort keys %type_to_struct) {
        $c .= qq{PerlXlib_CONSTi($_)\n};
    }
    return $c;
}

sub generate_xs_accessors {
	my $fieldname= shift;
	my @variations= sort grep { $_ =~ /(^|\.)$fieldname$/ } keys %members;
	my ($return, $output, $c2perl, $perl2c, $input_type);
	# Do they all agree on return type?
	my %distinct_type= map { $members{$_} => 1 } @variations;
	my ($via_xany)= grep { $_ =~ /^xany/ } @variations;
	if ($via_xany or keys %distinct_type == 1) {
		$return= $via_xany? $members{$via_xany} : $members{$variations[0]};
		$input_type= $return;
		$output= "  OUTPUT:\n    RETVAL\n";
		$c2perl= sub { 'RETVAL = ' . $_[1] . ';' };
		$perl2c= sub { $_[1] . '= value;' };
	}
	# If more than one type, or if it is an array type, we need to
	# declare the XS method to allow us to manipulate the stack directly.
	if (!$return or $return =~ /\w+ \[ \d+ \]/) {
		#warn "$fieldname has multiple types: ".join(', ', keys %distinct_type);
		$return= "void";
		$input_type= 'SV*';
		$output= '';
		$c2perl= sub { "PUSHs(sv_2mortal(" . sv_create(@_) . "));" };
		$perl2c= sub { sv_read(@_, 'value'); };
	}
	my ($reader, $writer);
	# If it is part of "xany", skip the switch statement
	if ($via_xany) {
		my $access= 'event->'.$via_xany;
		my $type= $members{$via_xany};
		$reader=
		    "$return\n"
		  . "_get_$fieldname(event)\n"
		  . "  XEvent *event\n"
		  . "  ".($output? 'CODE':'PPCODE').":\n"
		  . "    ".$c2perl->($type, $access)."\n"
		  . $output."\n";
		$writer=
		    "void\n"
		  . "_set_$fieldname(event, value)\n"
		  . "  XEvent *event\n"
		  . "  $input_type value\n"
		  . "  CODE:\n"
		  . "    ".$perl2c->($type, $access)."\n"
		  . "\n";
	}
	else {
		$reader=
		    "$return\n"
		  . "_get_$fieldname(event)\n"
		  . "  XEvent *event\n"
		  . "  ".($output? 'CODE':'PPCODE').":\n"
		  . "    switch( event->type ) {\n";
		$writer=
		    "void\n"
		  . "_set_$fieldname(event, value)\n"
		  . "  XEvent *event\n"
		  . "  $input_type value\n"
		  . "  CODE:\n"
		  . "    switch( event->type ) {\n";
		for (@variations) {
			# Find any typecode that makes use of this field
			my ($prefix)= ($_ =~ /^(\w+)/);
			my $typecodes= $field_to_type{$prefix};
			unless ($typecodes) {
				warn "Ignoring $_ because no type code references it\n";
				next;
			}
			$reader.= "    case $_:\n" for @$typecodes;
			$reader.= "      ".$c2perl->($members{$_}, 'event->'.$_)." break;\n";
			$writer.= "    case $_:\n" for @$typecodes;
			$writer.= "      ".$perl2c->($members{$_}, 'event->'.$_)." break;\n";
		}
		$reader .=
		    "    default: croak(\"Can't access XEvent.$fieldname for type=%d\", event->type);\n"
		  . "    }\n"
		  . $output."\n";
		$writer .=
		    "    default: croak(\"Can't access XEvent.$fieldname for type=%d\", event->type);\n"
		  . "    }\n";
	}
	return ($reader, $writer);
}

sub generate_pack_c {
	# First, pack type, then pack fields for XAnyEvent, then any fields known for that type
	my $c= <<"@";
void PerlXlib_${goal}_pack($goal *s, HV *fields) {
    SV **fp;

    memset(s, 0, sizeof(*s)); // wipe the struct
@
    # First pack the XAnyEvent fields
    my %have;
    for my $path (sort grep { $_ =~ /^xany/ } keys %members) {
        my $type= $members{$path};
        my ($name)= ($path =~ /([^.]+)$/);
        ++$have{$name};
        $c .= '      fp= hv_fetch(fields, "'.$name.'", '.length($name).", 0);\n"
           .  '      if (fp && *fp) { '.sv_read($type, 's->'.$path, '*fp')." }\n";
    }
    $c .= "    switch( s->type ) {\n";

    # Now sort fields by the type that defines them, for the case statements
    for my $prefix (sort keys %field_to_type) {
        my $typecodes= $field_to_type{$prefix};
        $c .= "    case $_:\n" for @$typecodes;
        for my $path (grep { $_ =~ qr/^$prefix\./ and $_ !~ $ignore_re } sort keys %members) {
            my ($name)= ($path =~ /([^.]+)$/);
            next if $have{$name};
            $c .= '      fp= hv_fetch(fields, "'.$name.'", '.length($name).", 0);\n"
               .  '      if (fp && *fp) { '.sv_read($members{$path}, 's->'.$path, '*fp')." }\n\n";
        }
        $c .= "      break;\n";
    }

    $c .= <<"@";
    default:
      croak("Unknown ${goal} type %d", s->type);
    }
}
@
    return $c;
}

sub generate_unpack_c {
    # First, pack type, then pack fields for XAnyEvent, then any fields known for that type
    my $c= <<"@";
void PerlXlib_${goal}_unpack($goal *s, HV *fields) {
    hv_store(fields, "type", 4, newSViv(s->type), 0);
@
    # First pack the XAnyEvent fields
    my %have;
    for my $path (grep { $_ =~ /^xany/ } keys %members) {
        my $type= $members{$path};
        my ($name)= ($path =~ /([^.]+)$/);
        ++$have{$name};
        $c .= sprintf "    hv_store(fields, %-12s, %2d, %s, 0);\n",
            qq{"$name"}, length($name), sv_create($type, 's->'.$path);
    }
    $c .= "    switch( s->type ) {\n";

    # Now sort fields by the type that defines them, for the case statements
    for my $prefix (sort keys %field_to_type) {
        my $typecodes= $field_to_type{$prefix};
        $c .= "    case $_:\n" for @$typecodes;
        for my $path (grep { $_ =~ qr/^$prefix\./ and $_ !~ $ignore_re } sort keys %members) {
            my $type= $members{$path};
            my ($name)= ($path =~ /([^.]+)$/);
            next if $have{$name};
            $c .= sprintf "      hv_store(fields, %-13s, %2d, %s, 0);\n",
                qq{"$name"}, length($name), sv_create($type, 's->'.$path);
        }
        $c .= "      break;\n";
    }

    $c .= <<'@';
    default:
      warn("Unknown XEvent type %d", s->type);
    }
}
@
	return $c;
}

sub generate_subclasses {
    my $pl= '';
    # First expose the XAnyEvent fields at the top level
    my %have;
    for my $path (grep { $_ =~ /^xany/ } keys %members) {
        my $type= $members{$path};
        my ($name)= ($path =~ /([^.]+)$/);
        ++$have{$name};

        $pl .= <<"@";

*get_$name= *_get_$name unless defined *get_${name}{CODE};
*set_$name= *_set_$name unless defined *set_${name}{CODE};
sub $name { \$_[0]->set_$name(\$_[1]) if \@_ > 1; \$_[0]->get_$name() }
@
    }

    my $typecodemap= "our %_type_to_class= (\n";
    my $subclasses= '';
    my $pod= '';

    for my $member_struct (sort keys %struct_to_field) {
        my $field= $struct_to_field{$member_struct};
        my $typecodes= $field_to_type{$field};
        my @consts= map { "X11:Xlib::${_}()" } @$typecodes;
        next unless @consts;
        $typecodemap .= qq{  X11::Xlib::${_}() => "X11::Xlib::${goal}::$member_struct",\n}
            for @$typecodes;
        $pod .= "=head2 $member_struct\n\n";
        $subclasses .= <<"@";

package X11::Xlib::${goal}::$member_struct;
\@X11::Xlib::${goal}::${member_struct}::ISA= ('X11::Xlib::${goal}');
@
        my $n;
        for my $path (grep { $_ =~ qr/^$field\./ and $_ !~ $ignore_re } sort keys %members) {
            my ($name)= ($path =~ /([^.]+)$/);
            next if $have{$name};
            ++$n;
            $pod .= "=head3 $name\n\n";
            $subclasses .= <<"@";
*get_${name}= *X11::Xlib::${goal}::_get_${name} unless defined *get_${name}{CODE};
*set_${name}= *X11::Xlib::${goal}::_set_${name} unless defined *set_${name}{CODE};
sub $name { \$_[0]->set_$name(\$_[1]) if \@_ > 1; \$_[0]->get_$name() }
@
        }
    }
    $pl .= $typecodemap . ");\n" . $subclasses . "\n" . $pod;
    return $pl;
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

my $out_xs= "\n";
my $out_c=  "\n";
my $out_pl= "\n";
my $out_const= "";
my $file_splice_token= "GENERATED X11_Xlib_${goal}";

for my $leaf (sort keys %distinct_leaf) {
	my ($get, $set)= generate_xs_accessors($leaf) or next;
	$out_xs .= "$get\n$set\n";
}
$out_c  .= generate_pack_c() . "\n" . generate_unpack_c() . "\n";
$out_pl .= generate_subclasses();
$out_const .= generate_constants();
patch_file("Xlib.xs", $file_splice_token, $out_xs);
patch_file("PerlXlib.c", $file_splice_token, $out_c);
patch_file("lib/X11/Xlib/${goal}.pm", $file_splice_token, $out_pl);
patch_file("PerlXlib_constants.inc", $file_splice_token, $out_const);
