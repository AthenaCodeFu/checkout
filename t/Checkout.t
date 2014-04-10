package Checkout;

use strict;
use warnings;
no warnings 'uninitialized';

use Athena::Lib;
use Checkout;
use Test::More;

my $co = Checkout->new('prices');
$co->ReadPrices({ FILE => './prices' });

is $co->Total(), "0.00", "initial total is 0";

$co->Scan({ CODE => 1 });
is $co->Total(), "50.00", 'total is $50 after scanning one item #1';

done_testing();
