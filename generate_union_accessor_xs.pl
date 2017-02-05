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

my %type_to_union_member= qw(
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
			#print " $fieldtype_name is a struct or union\n";
			apply_fields($fieldtype, "$access$fieldname.", $fieldtype_name);
		} else {
			#print " $fieldtype_name is not known\n";
			my $type= join ' ', @{ $t->{fields}{$fieldname} };
			$allfields{$fieldname}{type}{$t_name}= $type;
			$allfields{$fieldname}{access}{$t_name}= "$access$fieldname";
		}
	}
}
#use DDP;
$types{$goal} or die "No type for $goal";
#p my $y= $types{$goal};
apply_fields($types{$goal}, '', $goal);
#p my $x= \%allfields;

my %known_member_types= reverse %type_to_union_member;
my %ignore= map { $_ => 1 } qw( xerror data c_new );
	
for my $fieldname (sort keys %allfields) {
	next if $ignore{$fieldname};
	my ($get, $set)= generate_xs_accessors($fieldname) or next;
	print "$get\n$set\n";
}

sub sv_read {
	my ($type, $access, $svname)= @_;
	return "$access= SvIV($svname);" if $type eq 'int' || $type eq 'long';
	return "$access= SvUV($svname);" if $type eq 'unsigned' || $type eq 'unsigned int';
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
	return "newSVuv($value)" if $type eq 'unsigned' || $type eq 'unsigned int';
	return "newSVpvn($value, sizeof($1)*$2)"
		if $type =~ /^(\w+) \[ (\d+) \]$/;
	die "Don't know how to create SV from $type";
}

sub generate_xs_accessors {
	my $fieldname= shift;
	my $field= $allfields{$fieldname};
	my ($return, $output, $c2perl, $perl2c, $input_type);
	# Do they all agree on return type?
	my %distinct_type= map { $_ => 1 } values %{ $field->{type} };
	if (keys %distinct_type == 1 or $field->{access}{XAnyEvent}) {
		$return= $field->{type}{XAnyEvent} || (values %{ $field->{type} })[0];
		$input_type= $return;
		$output= "  OUTPUT:\n    RETVAL\n";
		$c2perl= sub { 'RETVAL = ' . $_[1] . ';' };
		$perl2c= sub { $_[1] . '= value;' };
	}
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
	if ($field->{access}{XAnyEvent}) {
		my $access= 'event->'.$field->{access}{XAnyEvent};
		my $type= $field->{type}{XAnyEvent};
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
		for my $typecode (keys %type_to_union_member) {
			my $access= $field->{access}{$type_to_union_member{$typecode}}
				or next;
			$access= 'event->'.$access;
			my $type= $field->{type}{$type_to_union_member{$typecode}};
			#print "$fieldname : $access\n";
			$reader.= "    case $typecode: ".$c2perl->($type, $access)." break;\n";
			$writer.= "    case $typecode: ".$perl2c->($type, $access)." break;\n";
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

