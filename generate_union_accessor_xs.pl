#! /usr/bin/env perl
use strict;
use warnings;

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

for my $leaf (sort keys %distinct_leaf) {
	my ($get, $set)= generate_xs_accessors($leaf) or next;
	print "$get\n$set\n";
}

sub sv_read {
	my ($type, $access, $svname)= @_;
	return "$access= SvIV($svname);" if $type eq 'int' || $type eq 'long';
	return "$access= SvUV($svname);"
		if $type eq 'unsigned' || $type eq 'unsigned int'
		|| $type eq 'Window' || $type eq 'Drawable' || $type eq 'Atom'
		|| $type eq 'Pixmap';
	return "{"
		." if (!SvPOK($svname) || SvLEN($svname) != sizeof($1)*$2)"
		.'  croak("Expected scalar of length %d but got %d",'." sizeof($1)*$2);"
		." memcpy($access, SvPVX($svname), sizeof($1)*$2);"
		."}" if $type =~ /^(\w+) \[ (\d+) \]$/;
	die "Don't know how to read $type from an SV";
}
sub sv_create {
	my ($type, $value)= @_;
	return "newSViv($value)" if $type eq 'int' || $type eq 'long';
	return "newSVuv($value)"
		if $type eq 'unsigned' || $type eq 'unsigned int'
		|| $type eq 'Window' || $type eq 'Drawable' || $type eq 'Atom'
		|| $type eq 'Pixmap';
	return "newSVpvn((char*)(void*)$value, sizeof($1)*$2)"
		if $type =~ /^(\w+) \[ (\d+) \]$/;
	die "Don't know how to create SV from $type";
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

sub generate_xs_pack {
	# First, pack type, then pack fields for XAnyEvent, then any fields known for that type
	my $c= <<'@';
void
_pack(fields)
  HV* fields
  INIT:
    XEvent e;
    SV **fp;
  PPCODE:
    // start with empty event object
    memset(&e, 0, sizeof(e));
    
	// Spend some effort coercing Type since it is the most important field
    fp= hv_fetch(fields, "type", 4, 0);
	if (!( fp && *fp && SvOK(*fp) )) croak("XEvent.type is required");
    e.type= SvIOK(*fp)? SvIV(*fp) : xevent_type_by_name(SvPV_nolen(*fp));
	if (e.type < 0) croak("invalid event type %s", SvPV_nolen(*fp));
    
@
	# First pack the XAnyEvent fields
	for my $path (grep { $_ =~ /^xany/ } keys %members) {
		my $type= $members{$path};
		my ($name)= ($path =~ /([^.]+)$/);
		$c .= '    fp= hv_fetch(fields, "'.$name.'", '.length($name).", 0);\n"
		   .  '    if (fp && *fp) { '.sv_read($type, 'e.'.$path, '*fp')." }\n"
		   .qq/    else { carp("Field $name uninitialized") }\n/;
	}
	$c .= "    switch( e.type ) {\n";

	# Now sort fields by the type that defines them, for the case statements
	for my $prefix (sort keys %field_to_type) {
		my $typecodes= $field_to_type{$prefix};
		$c .= "    case $_:\n" for @$typecodes;
		for my $path (grep { $_ =~ qr/^$prefix/ and $_ !~ $ignore_re } keys %members) {
			my ($name)= ($path =~ /([^.]+)$/);
			$c .= '      fp= hv_fetch(fields, "'.$name.'", '.length($name).", 0);\n"
			   .  '      if (fp && *fp) { '.sv_read($members{$path}, 'e.'.$path, '*fp')." }\n"
			   .qq/      else { carp("Field $name uninitialized") }\n/;
		}
		$c .= "    break;\n";
	}
	
	$c .= <<'@';
    default:
	  croak("Unknown XEvent type %d", e.type);
    }
	PUSHs(sv_2mortal(newSVpvn(&e, sizeof(e))));
@
	return $c;
}

sub generate_xs_unpack {
}
