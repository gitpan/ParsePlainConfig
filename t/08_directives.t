# 08_directives.t
#
# Tests for proper operation of the purge modes

$|++;
print "1..2\n";
my $test = 1;
my $rcfile = './t/testrc2';

# 1 Load
use Parse::PlainConfig;
my $new = Parse::PlainConfig->new('DELIM' => '=');
ref $new ? print "ok $test\n" : print "not ok $test\n";
$test++;

# 2 Make sure we're returning the actual key names
$new->read($rcfile);
grep /^SCALAR 1$/, $new->directives ?  print "ok $test\n" : 
  print "not ok $test\n";
$test++;

# end 08_directives.t
