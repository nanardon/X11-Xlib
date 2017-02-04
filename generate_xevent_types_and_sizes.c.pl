#! /usr/bin/env perl
use strict;
use warnings;

# Usage:
#  generate_xevent_types_and_sizes.pl XEvent < /usr/include/X11/Xlib.h > xevent_types_and_sizes.c

my $goal= shift;

my $input= do { local $/= undef; <STDIN> };
my %types;
my @def_stack= ( { cur_field => undef, fields => \%types } );
my $comment= 0;
while ($input =~ m!(typedef\b|struct\b|union\b|\{|\}|\;|\[|\]|/\*[^*]+|,|\*/|//.*$|\s+|#.*$|\*|\w+\b|.)!cmg) {
	my $token= $1;
	next if $comment && ($token ne '*/');
	printf " token '%s'\n\t(comment=%d)\t(def_stack=%2d)\t(cur_field=%2s)\n",
		$token, $comment, scalar @def_stack, $def_stack[-1]{cur_field}? scalar @{$def_stack[-1]{cur_field}} : 'undef'
		unless $token =~ /^\s*$/;
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
				if (@def_stack == 1) { warn "Found $name\n"; } else { warn "Found  .$name\n"; }
				$def_stack[-1]{fields}{$name}= $field;
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

my %type_code_to_event_struct= qw(
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

print <<END;
#define PX11_EventTypeInfoStr_2(ev_type_name, ev_type_val, ev_field) "!T" #ev_type_name "," #ev_type_val "," #ev_field
#define PX11_EventTypeInfoStr(ev_type_name, ev_field) PX11_EventTypeInfoStr2( #ev_type_name, ev_type_name, ev_field )

#define PX11_EventStructInfoStr(ev_field, struct_name) "!S" #ev_field "," #struct_name ":"
#define PX11_EventFieldInfoStr(struct_field) #struct_field "," #byte_ofs "," #field_size

#define PX11_EventFieldSizeCalc(ev_field, struct_field) \
	(( (uint8_t*)(void*) &((XEvent*)10000)->ev_field.struct_field ) - ( (uint8_t*)(void*)((XEvent*)10000) )), \
	sizeof( ((XEvent*)10000)->ev_field.struct_field ),
static int16_t x11_event_field_size_info[]= {
END

# Find the name of the XEvent union member which gives us each type of message
my %event_struct_to_union_member;
my $t= $types{'XEvent'};

	for my $fieldname (keys %{ $t->{fields} || {} }) {
		my ($fieldtype_name)= grep{ !($_ =~ /const|static|volatile/) } @{ $t->{fields}{$fieldname} };
		my $fieldtype= $types{$fieldtype_name};
		if ($fieldtype && grep{ ref $_ and $_->{container_type} } @$fieldtype) {
			print " $fieldtype_name is a struct or union\n";
			apply_fields($fieldtype, "$access$fieldname.", $fieldtype_name);
		} else {
			print " $fieldtype_name is not known\n";
			my $type= join ' ', @{ $t->{fields}{$fieldname} };
			$allfields{$fieldname}{type}{$type}++;
			$allfields{$fieldname}{access}{$t_name}= "$access$fieldname";
		}
	}


for (sort keys %type_code_to_event_struct) {
	print qq{    "!T$_,$type_to_union_member{$_}"\n};
}
my %xevent_structs= reverse %type_to_union_member;
for (sort keys %xevent_structs) {
	my $type= $types{$_} or next;
	my $event_field= grep { $_->{
}

	const char* name;
	char offset;
	char length;
for (keys %xevent_structs) {
	
}


# Build total list of all members of any member struct
my %allfields;
sub apply_fields {
	my ($t, $access, $t_name)= @_;
	# Find the structured part of this type definition
	($t)= grep { ref $_ } @$t;
	ref $t eq 'HASH' && ref $t->{fields} eq 'HASH' or die "Not a container type: $t\n";
	#use DDP;
	#p $t;
	for my $fieldname (keys %{ $t->{fields} || {} }) {
		my ($fieldtype_name)= grep{ !($_ =~ /const|static|volatile/) } @{ $t->{fields}{$fieldname} };
		my $fieldtype= $types{$fieldtype_name};
		if ($fieldtype && grep{ ref $_ and $_->{container_type} } @$fieldtype) {
			print " $fieldtype_name is a struct or union\n";
			apply_fields($fieldtype, "$access$fieldname.", $fieldtype_name);
		} else {
			print " $fieldtype_name is not known\n";
			my $type= join ' ', @{ $t->{fields}{$fieldname} };
			$allfields{$fieldname}{type}{$type}++;
			$allfields{$fieldname}{access}{$t_name}= "$access$fieldname";
		}
	}
}
use DDP;
$types{$goal} or die "No type for $goal";
p my $y= $types{$goal};
apply_fields($types{$goal}, '', $goal);
p my $x= \%allfields;

for my $fieldname (sort keys %allfields) {
	my $field= $allfields{$fieldname};
	my $return;
	my $output;
	my $assign;
	# Do they all agree on return type?
	if (keys %{ $field->{type} } > 1) {
		warn "$fieldname has multiple types: ".join(', ', keys %{ $field->{type} });
		$return= "void";
		$output= '';
		$assign= "PUSHs(sv_2mortal(%s));";
	} else {
		($return)= keys %{ $field->{type} };
		$output= "  OUTPUT:\n    RETVAL\n";
		$assign= "RETVAL = %s;";
	}
	# If it is part of "xany", skip the switch statement
	if ($field->{access}{XAnyEvent}) {
		$xs= "$return\n"
		   . "$fieldname(event)\n"
		   . "  XEvent *event\n"
		   . ($output? "  CODE:\n" : "  PPCODE:\n")
		   . sprintf('    '.$assign."\n", 'event->'.$field->{access}{XAnyEvent});
		print $output."\n";
	} else {
		print "$return\n";
		print "$fieldname(event)\n";
		print "  XEvent *event\n";
		print $output? "  CODE:\n" : "  PPCODE:\n";
		print "    switch( event->type ) {\n";
		for my $typecode (keys %type_to_union_member) {
			my $access= $field->{access}{$type_to_union_member{$typecode}};
			print "    case $typecode: ".sprintf($assign, 'event->'.$access)." break;\n"
				if $access;
		}
		print "    default: croak(\"Can't access XEvent.$fieldname for type=%d\", event->type\");\n";
		print "    }\n";
		print $output."\n";
	}
}

