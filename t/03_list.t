# 03_list.t
#
# Tests for proper extraction of list values

$|++;
print "1..3\n";
my $test = 1;
my $rcfile = './t/testrc';

# 1 load
use Parse::PlainConfig;
my $new = new Parse::PlainConfig;
ref $new ? print "ok $test\n" : print "not ok $test\n";
$test++;

# 2 list test 1
$new->read($rcfile);
scalar @{ $new->get("LIST 1") } == 3 ? print "ok $test\n" : 
	print "not ok $test\n";
$test++;

# 3 list test 2
scalar @{ $new->get("LIST 2") } == 4 ? print "ok $test\n" : 
	print "not ok $test\n";
$test++;

# end 03_list.t
