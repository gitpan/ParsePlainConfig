# 07_purge.t
#
# Tests for proper operation of the purge modes

$|++;
print "1..4\n";
my $test = 1;
my $rcfile = './t/testrc2';

# 1 Load
use Parse::PlainConfig;
my $new = Parse::PlainConfig->new('DELIM' => '=');
ref $new ? print "ok $test\n" : print "not ok $test\n";
$test++;

# 2 Load two files, make sure both sets of keys are present
$new->read('./t/testrc2');
$new->read('./t/testrc2.2');
scalar $new->directives == 10 ?  print "ok $test\n" : print "not ok $test\n";
$test++;

# 3 Manually purge
$new->purge;
scalar $new->directives == 0 ? print "ok $test\n" : print "not ok $test\n";
$test++;

# 4 Set & test purge mode 'on'
$new->purge(1);
$new->read('./t/testrc2');
$new->read('./t/testrc2.2');
scalar $new->directives == 5 ?  print "ok $test\n" : print "not ok $test\n";
$test++;

# end 07_purge.t
