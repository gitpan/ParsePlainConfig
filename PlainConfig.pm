# Parse::PlainConfig.pm -- Parser for plain-text configuration files
#
# (c) 2002, Arthur Corliss <corliss@digitalmages.com>,
#
# $Id: PlainConfig.pm,v 1.1 2002/01/18 07:08:28 corliss Exp corliss $
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#####################################################################

=head1 NAME

Parse::PlainConfig - Parser for plain-text configuration files

=head1 MODULE VERSION

$Id: PlainConfig.pm,v 1.1 2002/01/18 07:08:28 corliss Exp corliss $

=head1 SYNOPSIS

	use Parse::PlainConfig;

	$conf = new Parse::PlainConfig;

	$rv = $conf->read('myconf.conf');
	$rv = $conf->read;

	$conf->set(KEY1 => 'foo', KEY2 => 'bar');
	$field = $conf->get('KEY1');
	($field1, $field2) = $conf->get(qw(KEY1 KEY2));

	$hashref = $conf->get_ref;

=head1 REQUIREMENTS

Nothing outside of the core Perl modules.

=head1 DESCRIPTION

Parse::PerlConfig provides OO objects which can parse and generate
human-readable configuration files.

B<NOTE:> The write method is not yet implemented, but will be available
with the next revision.

=cut

#####################################################################
#
# Environment definitions
#
#####################################################################

package Parse::PlainConfig;

use strict;
use vars qw($VERSION);
use Text::ParseWords;
use Carp;
use Fcntl qw(:flock);

($VERSION) = (q$Revision: 1.1 $ =~ /(\d+(?:\.(\d+))+)/);

#####################################################################
#
# Module code follows
#
#####################################################################

=head1 FILE SYNTAX

The plain parser supports the reconstructions of relatively simple data
structures.  Simple scalar assignment and one-dimensional arrays and hashes
are possible.  Below are are various examples of constructs:

	# Scalar assignment
	FIRST_NAME: Joe
	LAST_NAME: Blow

	# Array assignment
	FAVOURITE_COLOURS: red, yellow, green
	ACCOUNT_NUMBERS:  9956-234-9943211, \
			  2343232-421231445, \
			  004422-03430-0343
	
	# Hash assignment
	CARS:  crown_vic => 1982, \
	       geo => 1993

As the example above demonstrates, all lines that begin with a '#' (leading
whitespace is allowed) are ignored as comments.  if '#" occurs in any other
position, it is accepted as part of the passed value.  This means that you
B<cannot> place comments on the same lines as values.

The above example also shows that escaping the end of a line (using '\' as the
trailing character) allows you to assign values that may span multiple lines.

B<Note:> If you wish to use a hash or list delimiter ('=>' & ',') as part of a
scalar value, you B<must> enclose that value within quotation marks.  If you
wish to preserve quotation marks as part of a value, you must escape the
quotation characters.

=head1 METHODS

=head2 new

	$conf = new Parse::PlainConfig;

The object constructor requires no arguments.

=cut

sub new {
	my $class = shift;
	my $self = {};

	bless $self, $class;

	$self->{CONF} = {};
	$self->{FILE} = undef;
	$self->{ERROR} = '';

	return $self;
}

=head2 read

	$rv = $conf->read('myconf.conf');
	$rv = $conf->read;

The read method is called initially with a filename as the only argument.
This causes the parser to read the file and extract all of the configuration
directives from it.  The return value will have one of five values, depending
on the success or type of error encountered:

	RV     Meaning
	==============================================
	-3     filename never defined
	-2     file does not exist
	-1     file is unreadable
	0      some other error occurred while reading
	1      read was successful

You'll notice that you can also call the read method without an argument.
This is only possible after calling the read method with a filename.  The name
of the file read is stored internally, and can be reread should you need to
restore your configuration hash.  If you call the read method without having
defined that filename at least once, you'll get a return value of -3.

=cut

sub read {
	my $self = shift;
	my $file = shift || $self->{FILE};
	my ($rv, $line, @lines);

	# $rv is one of the following values:
	#
	#	-3: filename never defined
	#	-2: file does not exist
	#	-1: file is unreadable
	#	0: error occurred while reading file
	#	1: read was successful

	# Early exit if no valid filename was ever given
	unless (defined $file && $file) {
		$self->{ERROR} = "No filename was defined for reading.";
		return -3;
	}

	# Update the internal filename if a new one was passed
	$self->{FILE} = $file if (! defined $self->{FILE} ||
		$self->{FILE} ne $file);

	# If the file both exists and is readable
	if (-e $file && -r _) {

		# Attempt to open the file
		if (open(RCFILE, "< $file")) {

			# Read the file
			flock(RCFILE, LOCK_SH);
			while (defined($line = <RCFILE>)) { 
				$line =~ s/\r?\n$//;
				push(@lines, $line);
			}
			flock(RCFILE, LOCK_UN);
			close(RCFILE);

			# Empty the current config hash
			$self->{CONF} = {};

			# Parse the rc file's lines
			$self->_parse(@lines);

		# Set the return value to show the read error
		} else {
			$rv = 0;
			$self->{ERROR} = "Error occured while reading $file: $!";
		}

	# The file didn't pass the above tests, so find out why and set
	# the return value and error message
	} else {
		if (! -e _) {
			$rv = -2;
			$self->{ERROR} = "$file does not exist."
		} elsif (! -r _) {
			$rv = -1;
			$self->{ERROR} = "$file is not readable by this process.";
		}
	}

	# Return the result code
	return $rv;
}

=head2 write

Not yet implemented.

=cut

=head2 set

	$conf->set(KEY1 => 'foo', KEY2 => 'bar');

The set method takes any number of key/value pairs and copies them into the
internal configuration hash.

=cut

sub set {
	my $self = shift;
	my $conf = $self->{CONF};
	my %new = (@_);

	foreach (keys %new) { $$conf{$_} = $new{$_} };
}

=head2 get

	$field = $conf->get('KEY1');
	($field1, $field2) = $conf->get(qw(KEY1 KEY2));

The get method takes any number of keys to retrieve, and returns them.  Please
note that both hash and list values are passed by reference.  In order to
protect the internal state information, the contents of either reference is
merely a copy of what is in the configuration object's hash.  This will B<not>
pass you a reference to data stored internally in the object.  Because of
this, it's perfectly safe for you to shift off values from a list as you
process it, and so on.

=cut

sub get {
	my $self = shift;
	my $conf = $self->{CONF};
	my @fields = @_;
	my @results;

	# Take an early out if no fields were specified
	return undef unless scalar @fields;

	# Loop through each requested field
	foreach (@fields) {

		# Retrieve the value if it exists in the hash
		if (exists $$conf{$_}) {

			# Copy Array and Hash contents, instead of handing
			# a direct reference over to the internal conf hash
			if (ref($$conf{$_}) =~ /^ARRAY/) {
				push(@results, [ @{ $$conf{$_} } ]);
			} elsif (ref($$conf{$_}) =~ /^HASH/) {
				push(@results, { %{ $$conf{$_} } });

			# Else, just copy the value over
			} else {
				push(@results, $$conf{$_});
			}

		# Push an undef onto the array if it's not defined in the hash
		} else {
			push(@results, undef);
		}
	}

	# Return the values
	return (scalar @fields > 1) ? @results : $results[0];
}

=head2 get_ref

	$hashref = $conf->get_ref;

This method is made available for convenience, but it's certainly not
recommended that you use it.  If you need to work directly on the
configuration hash, though, this is one way to do it.

=cut

sub get_ref {
	my $self = shift;

	return $self->{CONF};
}

sub _parse {
	# This takes a list of lines and parses them for config values,
	# which it saves in the object's namespace.
	#
	# Internal use only.

	my $self = shift;
	my $conf = $self->{CONF};
	my @lines = @_;
	my ($line, $key, $value, @items, $item, @tmp, %tmp);

	while (defined ($line = shift @lines)) {

		# Skip blank or comment lines
		next if $line =~ /^\s*(?:#.*)$/;

		# Make sure we've got a key and value pair
		if ($line =~ /^\s*([\w\-\.\s]+):\s*(\S.*)$/) {

			# Save the pair
			($key, $value) = ($1, $2);

			# Check for line continuation marks
			while ($value =~ /\\$/) {

				# Strip trailing whitespace and contination mark
				$value =~ s/\s*\\$//;

				# Grab the next line
				if (defined ($line = shift @lines)) {

					# Get the next part of the value
					if ($line =~ /^\s*(\S.*)$/) {
						$value .= $1;

					# or exit, since there was nothing to append
					} else {
						last;
					}

				# Exit, since we've appeared to run out of lines
				} else {
					last;
				}
			}
		}

		# Strip leading and trailing whitespace
		$value =~ s/^\s*//;
		$value =~ s/\s*$//;

		# Attempt to determine the value type (scalar, array, hash)
		@tmp = ();
		%tmp = ();

		# It's a hash
		if (scalar (quotewords('\s*=>\s*', 0, $value)) > 1) {

			# Yes, we are going to attempt to save any list pairs
			# as hash pairs as well, just to be a little forgiving,
			# should someone screw up the syntax.
			@items = quotewords('\s*(?:,|=>)\s*', 0, $value);

			$$conf{$key} = { @items };

		} else {

			@items = quotewords('\s*,\s*', 0, $value);

			# It's a list
			if (scalar @items > 1) {
				$$conf{$key} = [ @items ];

			# It's a scalar
			} else {
				$$conf{$key} = $items[0];
			}
		}
	}
}

1;

=head1 HISTORY

None worth noting.  ;-)

=head1 AUTHOR/COPYRIGHT

(c) 2002 Arthur Corliss (corliss@digitalmages.com) 

=cut

