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
    CirculateRequest XCirculateRequestEvent
	ConfigureNotify	 XConfigureEvent
    ConfigureRequest XConfigureRequestEvent
	DestroyNotify    XDestroyWindowEvent
	GravityNotify    XGravityEvent
	MapNotify        XMapEvent
    MapRequest       XMapRequestEvent
	ReparentNotify   XReparentEvent
	UnmapNotify      XUnmapEvent
	CreateNotify     XCreateWindowEvent
	ClientMessage    XClientMessageEvent
	MappingNotify    XMappingEvent
	SelectionClear   XSelectionClearEvent
	SelectionNotify  XSelectionEvent
	SelectionRequest XSelectionRequestEvent
	VisibilityNotify XVisibilityEvent
    GenericEvent     XGenericEvent
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
	qw( Time );
my %xid_types= map { $_ => 1 } qw( Window Drawable Colormap Atom Pixmap );

sub sv_read {
	my ($type, $access, $svname)= @_;
	return "$access= SvIV($svname);" if $int_types{$type};
	return "$access= SvUV($svname);" if $unsigned_types{$type};
    return "$access= PerlXlib_sv_to_xid($svname);" if $xid_types{$type};
	return "$access= PerlXlib_sv_to_display($svname);" if $type eq 'Display *';
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
	return "newSVuv($value)" if $unsigned_types{$type} or $xid_types{$type};
	return "($value? sv_setref_pv(newSV(0), \"X11::Xlib\", (void*)$value) : &PL_sv_undef)" if $type eq 'Display *';
	return "newSVpvn((void*)$value, sizeof($1)*$2)"
		if $type =~ /^(\w+) \[ (\d+) \]$/;
	die "Don't know how to create SV from $type";
}

sub generate_xs_accessors {
    my $fieldname= shift;
    my @variations= sort grep { $_ =~ /(^|\.)$fieldname$/ } keys %members;
    my ($type, $output, $c2perl, $perl2c);
    # Do they all agree on return type?
    my %distinct_type= map { $members{$_} => 1 } @variations;
    my $common_type= 1 == keys %distinct_type ? (keys %distinct_type)[0] : undef;
    my ($via_xany)= grep { $_ =~ /^xany/ } @variations;
    
    # Special case for 'type' field
    my $xs;
    if ($fieldname eq 'type') {
        $xs= <<"@";
void
type(event, value=NULL)
  XEvent *event
  SV *value
  INIT:
    const char *oldpkg, *newpkg;
  PPCODE:
    if (value) {
      if (event->type != SvIV(value)) {
        oldpkg= PerlXlib_xevent_pkg_for_type(event->type);
        event->type= SvIV(value);
        newpkg= PerlXlib_xevent_pkg_for_type(event->type);
        if (oldpkg != newpkg) {
          // re-initialize all fields in the area that changed
          memset( ((char*)(void*)event) + sizeof(XAnyEvent), 0, sizeof(XEvent)-sizeof(XAnyEvent) );
          // re-bless the object if the thing passed to us was actually an object
          if (sv_derived_from(ST(0), "X11::Xlib::Struct::XEvent"))
            sv_bless(ST(0), gv_stashpv(newpkg, GV_ADD));
        }
      }
    }
    PUSHs(sv_2mortal(newSViv(event->type)));

@
    }
    # If it is part of "xany", skip the switch statement
    elsif ($via_xany) {
        my $access= 'event->'.$via_xany;
        my $type= $members{$via_xany};
        my $sv_read= sv_read($type, $access, 'value');
        my $sv_create= sv_create($type, $access);
        $xs= <<"@";
void
$fieldname(event, value=NULL)
  XEvent *event
  SV *value
  PPCODE:
    if (value) {
      $sv_read
      PUSHs(value);
    } else {
      PUSHs(sv_2mortal($sv_create));
    }

@
    }
    elsif ($common_type && !($common_type =~ /\[/)) {
        my $sv_read= sv_read($common_type, 'c_value', 'value');
        my $sv_create= sv_create($common_type, 'c_value');
        $xs= <<"@";
void
_$fieldname(event, value=NULL)
  XEvent *event
  SV *value
  INIT:
    $common_type c_value;
  PPCODE:
    if (value) { $sv_read }
    switch (event->type) {
@
        for (@variations) {
            # Find any typecode that makes use of this field
            my ($prefix)= ($_ =~ /^(\w+)/);
            my $typecodes= $field_to_type{$prefix};
            unless ($typecodes) {
                warn "Ignoring $_ because no type code references it\n";
                next;
            }
            $xs .= qq{    case $_:\n} for @$typecodes;
            $xs .= qq{      if (value) { event->$_ = c_value; } else { c_value= event->$_; } break;\n}
        }
        $xs .= <<"@";
    default: croak(\"Can't access XEvent.$fieldname for type=%d\", event->type);
    }
    PUSHs(value? value : sv_2mortal($sv_create));

@
    }
    else {
        $xs= <<"@";
void
_$fieldname(event, value=NULL)
  XEvent *event
  SV *value
  PPCODE:
    switch (event->type) {
@
        for (@variations) {
            # Find any typecode that makes use of this field
            my ($prefix)= ($_ =~ /^(\w+)/);
            my $typecodes= $field_to_type{$prefix};
            unless ($typecodes) {
                warn "Ignoring $_ because no type code references it\n";
                next;
            }
            my $access= "event->$_";
            my $sv_read= sv_read($members{$_}, $access, 'value');
            my $sv_create= sv_create($members{$_}, $access);
            $xs .= qq{    case $_:\n} for @$typecodes;
            $xs .= qq{      if (value) { $sv_read } else { PUSHs(sv_2mortal($sv_create)); } break;\n};
        }
        $xs .= <<"@";
    default: croak(\"Can't access XEvent.$fieldname for type=%d\", event->type);
    }

@
    }
    return $xs;
}

sub generate_pack_c {
    my $c= <<"@";
const char* PerlXlib_xevent_pkg_for_type(int type) {
  switch (type) {
@
    $c .= qq{  case $_: return "X11::Xlib::Struct::XEvent::$type_to_struct{$_}";\n}
        for keys %type_to_struct;
    $c .= <<"@";
  default: return "X11::Xlib::Struct::XEvent";
  }
}

// First, pack type, then pack fields for XAnyEvent, then any fields known for that type
void PerlXlib_${goal}_pack($goal *s, HV *fields, Bool consume) {
    SV **fp;
    int newtype;
    const char *oldpkg, *newpkg;

    // Type gets special handling
    fp= hv_fetch(fields, "type", 4, 0);
    if (fp && *fp) {
      newtype= SvIV(*fp);
      if (s->type != newtype) {
        oldpkg= PerlXlib_xevent_pkg_for_type(s->type);
        newpkg= PerlXlib_xevent_pkg_for_type(newtype);
        s->type= newtype;
        if (oldpkg != newpkg) {
          // re-initialize all fields in the area that changed
          memset( ((char*)(void*)s) + sizeof(XAnyEvent), 0, sizeof(XEvent)-sizeof(XAnyEvent) );
        }
      }
      if (consume) hv_delete(fields, "type", 4, G_DISCARD);
    }
    
@
    # Next, pack the fields common to all
    my %have;
    for my $path (sort grep { $_ =~ /^xany/ } keys %members) {
        my $type= $members{$path};
        my ($name)= ($path =~ /([^.]+)$/);
        my $name_len= length($name);
        my $sv_read= sv_read($type, "s->$path", "*fp");
        ++$have{$name};
        $c .= <<"@";
    fp= hv_fetch(fields, "$name", $name_len, 0);
    if (fp && *fp) { $sv_read; if (consume) hv_delete(fields, "$name", $name_len, G_DISCARD); }
@
    }
    $c .= "    switch( s->type ) {\n";
    # Now sort fields by the type that defines them, for the case statements
    for my $prefix (sort keys %field_to_type) {
        my $typecodes= $field_to_type{$prefix};
        $c .= "    case $_:\n" for sort @$typecodes;
        for my $path (sort grep { $_ =~ qr/^$prefix\./ and $_ !~ $ignore_re } keys %members) {
            my ($name)= ($path =~ /([^.]+)$/);
            next if $have{$name};
            my $name_len= length($name);
            my $sv_read= sv_read($members{$path}, "s->$path", "*fp");
            $c .= <<"@";
      fp= hv_fetch(fields, "$name", $name_len, 0);
      if (fp && *fp) { $sv_read; if (consume) hv_delete(fields, "$name", $name_len, G_DISCARD); }
@
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
    // hv_store may return NULL if there is an error, or if the hash is tied.
    // If it does, we need to clean up the value!
    SV *sv= NULL;
    if (!hv_store(fields, "type", 4, (sv= newSViv(s->type)), 0)) goto store_fail;
@
    # First pack the XAnyEvent fields
    my %have;
    for my $path (sort grep { $_ =~ /^xany/ } keys %members) {
        my $type= $members{$path};
        my ($name)= ($path =~ /([^.]+)$/);
        ++$have{$name};
        $c .= sprintf "    if (!hv_store(fields, %-12s, %2d, (sv=%s), 0)) goto store_fail;\n",
            qq{"$name"}, length($name), sv_create($type, 's->'.$path);
    }
    $c .= "    switch( s->type ) {\n";

    # Now sort fields by the type that defines them, for the case statements
    for my $prefix (sort keys %field_to_type) {
        my $typecodes= $field_to_type{$prefix};
        $c .= "    case $_:\n" for sort @$typecodes;
        for my $path (sort grep { $_ =~ qr/^$prefix\./ and $_ !~ $ignore_re } keys %members) {
            my $type= $members{$path};
            my ($name)= ($path =~ /([^.]+)$/);
            next if $have{$name};
            $c .= sprintf "      if (!hv_store(fields, %-13s, %2d, (sv=%s), 0)) goto store_fail;\n",
                qq{"$name"}, length($name), sv_create($type, 's->'.$path);
        }
        $c .= "      break;\n";
    }

    $c .= <<'@';
    default:
      warn("Unknown XEvent type %d", s->type);
    }
    return;
    store_fail:
        if (sv) sv_2mortal(sv);
        croak("Can't store field in supplied hash (tied maybe?)");
}
@
	return $c;
}

sub generate_subclasses {
    my $subclasses= '';
    my $pod= '';
    my %have;
    for my $path (sort grep { $_ =~ /^xany/ } keys %members) {
        my ($name)= ($path =~ /([^.]+)$/);
        ++$have{$name};
    }

    for my $member_struct (sort keys %struct_to_field) {
        my $field= $struct_to_field{$member_struct};
        my $typecodes= $field_to_type{$field};
        if (!$typecodes) {
            warn "member_struct=$member_struct field=$field\n";
#            use DDP; p %field_to_type;
        }
        next if $member_struct eq 'XAnyEvent' or !$typecodes or !@$typecodes;
        $pod .= "=head2 $member_struct\n\n"
            . "Used for event type: ".join(', ', @$typecodes)."\n\n";
        $subclasses .= "\n\n\@X11::Xlib::Struct::${goal}::${member_struct}::ISA= ( __PACKAGE__ );\n";
        my $n;
        for my $path (sort grep { $_ =~ qr/^$field\./ and $_ !~ $ignore_re } keys %members) {
            my ($name)= ($path =~ /([^.]+)$/);
            next if $have{$name};
            ++$n;
            $pod .= "=head3 $name\n\n";
            $subclasses .= "*X11::Xlib::Struct::${goal}::${member_struct}::$name= *_$name;\n";
        }
    }
    $pod .= "=cut\n\n";
    return $subclasses . "\n" . $pod;
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
void
_initialize(e)
    XEvent *e
    PPCODE:
        memset((void*) e, 0, sizeof(*e));

int
_sizeof(ignored)
    SV *ignored
    CODE:
        RETVAL = sizeof(XEvent);
    OUTPUT:
        RETVAL

void
_pack(e, fields, consume)
    XEvent *e
    HV *fields
    Bool consume
    INIT:
        const char *oldpkg, *newpkg;
    PPCODE:
        oldpkg= PerlXlib_xevent_pkg_for_type(e->type);
        PerlXlib_XEvent_pack(e, fields, consume);
        newpkg= PerlXlib_xevent_pkg_for_type(e->type);
        // re-bless the object if the thing passed to us was actually an object
        if (oldpkg != newpkg && sv_derived_from(ST(0), "X11::Xlib::Struct::XEvent"))
            sv_bless(ST(0), gv_stashpv(newpkg, GV_ADD));

void
_unpack(e, fields)
    XEvent *e
    HV *fields
    PPCODE:
        PerlXlib_XEvent_unpack(e, fields);

@

my $out_c=  "\n";
my $out_pl= "\n";
my $out_const= "";
my $file_splice_token= "GENERATED X11_Xlib_${goal}";

for my $leaf (sort keys %distinct_leaf) {
	my $xs= generate_xs_accessors($leaf) or next;
	$out_xs .= $xs;
}
$out_c  .= generate_pack_c() . "\n" . generate_unpack_c() . "\n";
$out_pl .= generate_subclasses();
patch_file("Xlib.xs", $file_splice_token, $out_xs);
patch_file("PerlXlib.c", $file_splice_token, $out_c);
patch_file("lib/X11/Xlib/Struct/XEvent.pm", $file_splice_token, $out_pl);
