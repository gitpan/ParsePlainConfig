# 05_hash.t
#
# Tests for proper writing of config files

$|++;
print "1..5\n";
my $test = 1;
my $rcfile = './t/testrc2';

# 1 load
use Parse::PlainConfig;
my $new = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => $rcfile);
ref $new ? print "ok $test\n" : print "not ok $test\n";
$test++;

# 2 hash test 1
scalar keys %{ $new->get("HASH 1") } == 4 ? print "ok $test\n" : 
	print "not ok $test\n";
$test++;

# 3 write test
$new->delim(':');
$new->write('./t/testrc3') == 1 ? print "ok $test\n" : print "not ok $test\n";
$test++;

# 4 reload
$new = undef;
$new = Parse::PlainConfig->new('FILE' => './t/testrc3');
ref $new ? print "ok $test\n" : print "not ok $test\n";
$test++;

# 5 hash test 2
scalar keys %{ $new->get("HASH 1") } == 4 ? print "ok $test\n" : 
	print "not ok $test\n";
$test++;

# end 05_hash.t
