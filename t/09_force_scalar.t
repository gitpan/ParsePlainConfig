# 09_force_scalar.t
#
# Tests for proper operation of the force scalar directive

$|++;
print "1..2\n";
my $test = 1;
my $rcfile = './t/testrc2';

# 1 Load
use Parse::PlainConfig;
my $new = Parse::PlainConfig->new('DELIM' => '=', 
  'FORCE_SCALAR' => [ 'LIST 1', 'LIST 2' ]);
ref $new ? print "ok $test\n" : print "not ok $test\n";
$test++;

# 2 Make sure the list was returned as a scalar
$new->read($rcfile);
$new->get('LIST 1') eq 'value1, value2, value3' ?  print "ok $test\n" : 
  print "not ok $test\n";
$test++;

# end 09_force_scalar.t
