# 05_hash.t
#
# Tests for proper writing of config files

$|++;
print "1..7\n";
my $test = 1;
my $rcfile = './t/testrc2';
my $trcfile = './t/testrc9';

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
$new->write("$trcfile.0") == 1 ? print "ok $test\n" : print "not ok $test\n";
$test++;

# 4 describe test 1
foreach ($new->directives) { $new->describe($_ => "This is field $_!") };
$new->write("$trcfile.1") == 1 ? print "ok $test\n" : print "not ok $test\n";
$test++;

# 5 describe test 2
foreach ($new->directives) { $new->describe($_ => "## This is field $_!") };
$new->write("$trcfile.2") == 1 ? print "ok $test\n" : print "not ok $test\n";
$test++;

# 6 reload
$new = undef;
$new = Parse::PlainConfig->new('FILE' => "$trcfile.0");
ref $new ? print "ok $test\n" : print "not ok $test\n";
$test++;

# 7 hash test 2
scalar keys %{ $new->get("HASH 1") } == 4 ? print "ok $test\n" : 
	print "not ok $test\n";
$test++;

# end 05_hash.t
