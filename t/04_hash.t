# 04_hash.t
#
# Tests for proper extraction of hash values

$|++;
print "1..2\n";
my $test = 1;
my $rcfile = './t/testrc';

# 1 load
use Parse::PlainConfig;
my $new = new Parse::PlainConfig;
ref $new ? print "ok $test\n" : print "not ok $test\n";
$test++;

# 2 hash test 1
$new->read($rcfile);
scalar keys %{ $new->get("HASH 1") } == 4 ? print "ok $test\n" : 
	print "not ok $test\n";
$test++;

# end 04_hash.t
