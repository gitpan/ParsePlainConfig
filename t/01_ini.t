# 01_ini.t
#
# Tests for proper loading of the module

$|++;
print "1..2\n";
my $test = 1;
my $rcfile = './t/testrc';

# 1 load
use Parse::PlainConfig;
my $new = new Parse::PlainConfig;
ref $new ? print "ok $test\n" : print "not ok $test\n";
$test++;

# 2 alternate load
$new = undef;
$new = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => $rcfile);
(ref $new && ! $new->error) ? print "ok $test\n" : print "not ok $test\n";
$test++;

# end 01_ini.t
