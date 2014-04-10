package Checkout;

use strict;
use warnings;
no warnings 'uninitialized';

use Athena::Lib;
use Checkout;
use Test::More;

is_correct_total(1, 0, '0.00');
is_correct_total(1, 1, '50.00');
is_correct_total(1, 0, '0.00');
is_correct_total(1, 0, '0.00');
is_correct_total(1, 0, '0.00');
is_correct_total(1, 0, '0.00');

my $co = Checkout->new('prices');
$co->ReadPrices({ FILE => './prices' });

is $co->Total(), "0.00", "initial total is 0";

$co->Scan({ CODE => 1 });
is $co->Total(), "50.00", 'total is $50 after scanning one item #1';

$co->Scan({ CODE => 3 }) for (1..4);
is $co->Total(), "90.00", 'total is $90 after scanning four item #3';
$co->Scan({ CODE => 3 });
is $co->Total(), "95.00", 'total is $95 after scanning five item #3';

$co->Scan({ CODE => 4 }) for (1..9);
is $co->Total(), "149.00", 'total is $149 after scanning nine item #4';
$co->Scan({ CODE => 4 });
is $co->Total(), "150.00", 'total is $149 after scanning nine item #4';

done_testing();

sub is_correct_total {
	my ($code, $quantity, $total) = @_;
	my $co = Checkout->new('prices');
	$co->ReadPrices({ FILE => './prices' });
	$co->Scan({ CODE => $code }) for (1..$quantity);
	is $co->Total(), $total, "total is $total after scaning $quantity item #$code";
}
