# 02_scalar.t
#
# Tests for proper extraction of scalar values

$|++;
print "1..3\n";
my $test = 1;
my $rcfile = './t/testrc';

# 1 load
use Parse::PlainConfig;
my $new = new Parse::PlainConfig;
ref $new ? print "ok $test\n" : print "not ok $test\n";
$test++;

# 2 scalar test 1
$new->read($rcfile);
$new->get("SCALAR 1") eq "value1" ? print "ok $test\n" : 
	print "not ok $test\n";
$test++;

# 3 scalar test 2
$new->get("SCALAR 2") eq "these, are, all one => value" ? print "ok $test\n" : 
	print "not ok $test\n";
$test++;

# end 02_scalar.t
