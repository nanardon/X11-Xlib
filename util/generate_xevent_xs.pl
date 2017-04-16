#! /usr/bin/env perl
use strict;
use warnings;
use File::Temp;
use FindBin;
use Carp;

my $goal= shift
  or print <<'END';

Usage:
  generate_xevent_xs.pl XEvent < /usr/include/X11/Xlib.h

END

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
				if ($field->[-1] eq ')') {
					# TODO: parse function definitions
					# Nevermind, TODO: parse ctags instead of all this
				}
				elsif ($field->[-1] eq ']') {
					# skip backward past subscripts to find the field name
					for (my $i= $#$field; $i > 0; $i--) {
						if ($field->[$i] eq '[') {
							($name)= splice(@$field, $i-1, 1);
							last;
						}
					}
				} else {
					$name= pop @$field;
				}
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
	0                XErrorEvent
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

my %members;
flatten_fields(\%members, $goal, $types{$goal}, '');

#p my $x= \%members;

my $ignore_re= qr/(^data$|c_new$)/;
my $member_known_type= join '|', grep { $_ =~ $ignore_re } keys %type_to_field;
my $known_member_type_re= qr/^($member_known_type)/;

my %distinct_leaf=
	map { $_ =~ /(^|\.)(\w+)$/? ($2 => 1) : () }
	grep { $_ !~ $ignore_re }
	keys %members;

my %int_types= map { $_ => 1 } qw( int long Bool char );
my %unsigned_types= map { $_ => 1 } 'unsigned', 'unsigned char', 'unsigned int', 'unsigned long',
	qw( Time );
my %xid_types= map { $_ => 1 } qw( XID Window Drawable Colormap Atom Pixmap );

sub sv_read {
	my ($type, $access, $svname)= @_;
	return "$access= SvIV($svname);" if $int_types{$type};
	return "$access= SvUV($svname);" if $unsigned_types{$type};
    return "$access= PerlXlib_sv_to_xid($svname);" if $xid_types{$type};
	return "$access= PerlXlib_get_magic_dpy($svname, 0);" if $type eq 'Display *';
	return "{"
		." if (!SvPOK($svname) || SvCUR($svname) != sizeof($1)*$2)"
		.'  croak("Expected scalar of length %d but got %d",'." sizeof($1)*$2, SvCUR($svname));"
		." memcpy($access, SvPVX($svname), sizeof($1)*$2);"
		."}" if $type =~ /^(\w+) \[ (\d+) \]$/;
	croak "Don't know how to read $type from an SV";
}
sub sv_create {
	my ($type, $value)= @_;
	return "newSViv($value)" if $int_types{$type};
	return "newSVuv($value)" if $unsigned_types{$type} or $xid_types{$type};
	return "SvREFCNT_inc(PerlXlib_obj_for_display($value, 0))" if $type eq 'Display *';
	return "newSVpvn((void*)$value, sizeof($1)*$2)"
		if $type =~ /^(\w+) \[ (\d+) \]$/;
	croak "Don't know how to create SV from $type";
}

sub generate_xs_accessors {
    my $fieldname= shift;
    my @variations= sort grep { $_ =~ /(^|\.)$fieldname$/ } keys %members;
    my ($type, $output, $c2perl, $perl2c);
    # Do they all agree on return type?
    my %distinct_type= map { $members{$_} => 1 } @variations;
    my $common_type= 1 == keys %distinct_type ? (keys %distinct_type)[0] : undef;
    my ($via_xany)= grep { $_ =~ /^xany/ } @variations;
    return '' if $common_type && $distinct_type{'void *'};
    
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
          /* re-initialize all fields in the area that changed */
          memset( ((char*)(void*)event) + sizeof(XAnyEvent), 0, sizeof(XEvent)-sizeof(XAnyEvent) );
          /* re-bless the object if the thing passed to us was actually an object */
          if (sv_derived_from(ST(0), "X11::Xlib::XEvent"))
            sv_bless(ST(0), gv_stashpv(newpkg, GV_ADD));
        }
      }
    }
    PUSHs(sv_2mortal(newSViv(event->type)));

@
    }
    # If it is part of "xany", skip the switch statement, unless field is 'window'
    # in which case that name gets reused for other fields of sub-structs.
    elsif ($fieldname eq 'display' || $fieldname eq 'serial') {
        my $type= $members{$via_xany};
        my $sv_read= sv_read($type, "event->xany.$fieldname", 'value');
        my $sv_read2= sv_read($type, "event->xerror.$fieldname", 'value');
        my $sv_create= sv_create($type, "(event->type? event->xany.$fieldname : event->xerror.$fieldname)");
        $xs= <<"@";
void
$fieldname(event, value=NULL)
  XEvent *event
  SV *value
  PPCODE:
    if (value) {
      if (event->type) $sv_read else $sv_read2
      PUSHs(value);
    } else {
      PUSHs(sv_2mortal($sv_create));
    }

@
    }
    elsif ($fieldname eq 'send_event') {
        my $access= "event->xany.send_event";
        my $type= $members{$via_xany};
        my $sv_read= sv_read($type, $access, 'value');
        my $sv_create= sv_create($type, $access);
        $xs= <<"@";
void
$fieldname(event, value=NULL)
  XEvent *event
  SV *value
  PPCODE:
    if (!event->type) croak(\"Can't access XEvent.$fieldname for type=%d\", event->type);
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
    $common_type c_value= 0;
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
            $xs .= qq{    case $_:\n} for sort @$typecodes;
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
            $xs .= qq{    case $_:\n} for sort @$typecodes;
            $xs .= qq{      if (value) { $sv_read } else { PUSHs(sv_2mortal($sv_create)); } break;\n};
        }
        $xs .= <<"@";
    default: croak(\"Can't access XEvent.$fieldname for type=%d\", event->type);
    }

@
    }
    $xs =~ s/sv_2mortal\(SvREFCNT_inc\((.*?)\)\)/$1/g;
    return $xs;
}

sub generate_pack_c {
    my $c= <<"@";
const char* PerlXlib_xevent_pkg_for_type(int type) {
  switch (type) {
@
    $c .= qq{  case $_: return "X11::Xlib::$type_to_struct{$_}";\n}
        for sort keys %type_to_struct;
    $c .= <<"@";
  default: return "X11::Xlib::XEvent";
  }
}

/* First, pack type, then pack fields for XAnyEvent, then any fields known for that type */
void PerlXlib_${goal}_pack($goal *s, HV *fields, Bool consume) {
    SV **fp;
    int newtype;
    const char *oldpkg, *newpkg;

    /* Type gets special handling */
    fp= hv_fetch(fields, "type", 4, 0);
    if (fp && *fp) {
      newtype= SvIV(*fp);
      if (s->type != newtype) {
        oldpkg= PerlXlib_xevent_pkg_for_type(s->type);
        newpkg= PerlXlib_xevent_pkg_for_type(newtype);
        s->type= newtype;
        if (oldpkg != newpkg) {
          /* re-initialize all fields in the area that changed */
          memset( ((char*)(void*)s) + sizeof(XAnyEvent), 0, sizeof(XEvent)-sizeof(XAnyEvent) );
        }
      }
      if (consume) hv_delete(fields, "type", 4, G_DISCARD);
    }
    if (s->type) {
@
    # Next, pack the fields common to all, and the deviant fields of xerror
    my %have;
    for my $path ('xany.display', 'xany.send_event', 'xany.serial', 'xany.type', '', 'xerror.serial','xerror.display') {
        if (!$path) {
            $c .= "    }\n    else {\n";
            next;
        }
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
    $c .= "    }\n    switch( s->type ) {\n";
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
      warn("Unknown ${goal} type %d", s->type);
    }
}
@
    return $c;
}

sub generate_unpack_c {
    # First, pack type, then pack fields for XAnyEvent, then any fields known for that type
    my $c= <<"@";
void PerlXlib_${goal}_unpack($goal *s, HV *fields) {
    /* hv_store may return NULL if there is an error, or if the hash is tied.
     * If it does, we need to clean up the value!
     */
    SV *sv= NULL;
    if (!hv_store(fields, "type", 4, (sv= newSViv(s->type)), 0)) goto store_fail;
@
    # First pack the XAnyEvent fields, and deviant fields of XError
    my %have;
    $c .= "    if (s->type) {\n";
    for my $path ('xany.display', 'xany.send_event', 'xany.serial', 'xany.type', '', 'xerror.display', 'xerror.serial') {
        if (!$path) {
            $c .= "    }\n    else {\n";
            next;
        }
        my $type= $members{$path};
        my ($name)= ($path =~ /([^.]+)$/);
        ++$have{$name};
        $c .= sprintf "      if (!hv_store(fields, %-12s, %2d, (sv=%s), 0)) goto store_fail;\n",
            qq{"$name"}, length($name), sv_create($type, 's->'.$path);
    }
    $c .= "    }\n    switch( s->type ) {\n";

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

    $c .= <<"@";
    default:
      warn("Unknown ${goal} type %d", s->type);
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
    my %have= ( display => 1, send_event => 1, serial => 1, type => 1 );

    for my $member_struct (sort keys %struct_to_field) {
        my $field= $struct_to_field{$member_struct};
        my $typecodes= $field_to_type{$field};
        if (!$typecodes) {
            warn "member_struct=$member_struct field=$field\n";
#            use DDP; p %field_to_type;
        }
        next if $member_struct eq 'XAnyEvent' or !$typecodes or !@$typecodes;
        $pod .= "=head2 $member_struct\n\n"
            . "Used for event type: ".join(', ', sort @$typecodes)."\n\n";
        $subclasses .= "\n\n\@X11::Xlib::${member_struct}::ISA= ( __PACKAGE__ );\n";
        my $n;
        for my $path (sort grep { $_ =~ qr/^$field\./ and $_ !~ $ignore_re } keys %members) {
            my ($name)= ($path =~ /([^.]+)$/);
            next if $have{$name};
            ++$n;
            $pod .= sprintf("  %-17s - %s\n", $name, $members{$path});
            $subclasses .= "*X11::Xlib::${member_struct}::$name= *_$name;\n";
        }
        $pod .= "\n";
    }
    $pod .= "=cut\n\n";
    return $subclasses . "\n" . $pod;
}

sub patch_file {
    my ($fname, $token, $new_content)= @_;
    my $begin_token= "BEGIN $token";
    my $end_token=   "END $token";
    open my $orig, "<", "$FindBin::Bin/../$fname" or die "open($fname): $!";
    my $new= File::Temp->new(DIR => "$FindBin::Bin/..", TEMPLATE => "${fname}_XXXX");
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
    rename($new, "$FindBin::Bin/../$fname") or die "rename: $!";
}

my $out_xs= <<"@";
void
_initialize(s)
    SV *s
    INIT:
        void *sptr;
    PPCODE:
        sptr= PerlXlib_get_struct_ptr(s, 1, "X11::Xlib::${goal}", sizeof($goal),
            (PerlXlib_struct_pack_fn*) &PerlXlib_${goal}_pack
        );
        memset((void*) sptr, 0, sizeof($goal));

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
        /* re-bless the object if the thing passed to us was actually an object */
        if (oldpkg != newpkg && sv_derived_from(ST(0), "X11::Xlib::XEvent"))
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
patch_file("lib/X11/Xlib/XEvent.pm", $file_splice_token, $out_pl);
