package Checkout;

use strict;
use warnings;
no warnings 'uninitialized';

use Athena::Lib;
use Checkout;
use Test::More;

is_correct_total(1, 0, '0.00');
is_correct_total(1, 1, '50.00');
is_correct_total(3, 4, '40.00');
is_correct_total(3, 5, '45.00');
is_correct_total(4, 9, '54.00');
is_correct_total(4, 10, '55.00');
is_correct_total(5, 1, '25.00');
is_correct_total(5, 2, '45.00');
is_correct_total(5, 3, '70.00');
is_correct_total(6, 2, '14.00');
is_correct_total(6, 4, '27.00');

is_correct_total_hetero([qw( 1 2 3 4 5 6 )], '110.00');
is_correct_total_hetero([qw( 5 6 5 6 5 )], '84.00');


done_testing();

sub is_correct_total {
	my ($code, $quantity, $total) = @_;
	my $co = Checkout->new('prices');
	$co->ReadPrices({ FILE => './prices' });
	$co->Scan({ CODE => $code }) for (1..$quantity);
	is $co->Total(), $total, "total is $total after scaning $quantity item #$code";
}

sub is_correct_total_hetero {
	my ($codes, $total) = @_;
	my $co = Checkout->new('prices');
	$co->ReadPrices({ FILE => './prices' });
	foreach my $code (@$codes) {
		$co->Scan({ CODE => $code });
	}
	is $co->Total(), $total, "total is $total after scaning codes (" . join(', ', @$codes) . ")";
}
