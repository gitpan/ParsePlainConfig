# 01_ini.t
#
# Tests for proper loading of the module

$|++;
print "1..1\n";
my $test = 1;

# 1 load
use Parse::PlainConfig;
my $new = new Parse::PlainConfig;
ref $new ? print "ok $test\n" : print "not ok $test\n";
$test++;

# end 01_ini.t
