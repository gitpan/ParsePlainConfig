# 06_hash.t
#
# Tests for proper error return codes

$|++;
print "1..3\n";
my $test = 1;
my $rcfile = './t/testrc2';

# 1 Load
use Parse::PlainConfig;
my $new = new Parse::PlainConfig;
ref $new ? print "ok $test\n" : print "not ok $test\n";
$test++;

# 2 Error code -3
$new->read == -3 ? print "ok $test\n" : 
	print "not ok $test\n";
$test++;

# 3 Error code -2
$new->read('./t/testrc4') == -2 ? print "ok $test\n" : print "not ok $test\n";
$test++;

# end 06_hash.t
