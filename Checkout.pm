package Checkout;

use strict;
use warnings;
no warnings 'uninitialized';

use Athena::Lib;
use AthenaUtils;
use Carp;

sub new {
	my ($class) = @_;
	my $self = {
		TOTAL => 0,
		ITEMS => {},
	};
	bless $self, $class;
	return $self;
}

# Reads a tab-delimited string describing item prices like this:
#	CODE	PRICE	SPECIAL PRICE
#	#1	$50.00/ea	
sub ReadPrices {
	my ($self, $args) = @_;
	AssertFields($args, ['FILE']);

	open my $filehandle, '<', $args->{FILE} or croak "couldn't open file $args->{FILE}: $!";

	# discard the first line, which contains headers
	<$filehandle>;

	# read each item
	while (my $line = <$filehandle>) {
		chomp $line;
		my ($code, $price, $special) = split /\t/, $line;

		$code =~ s/^#(\d+)$/$1/ or croak "couldn't parse item code '$code' in line '$line'";
		$price =~ s/^\$(\d+\.\d{2})\/ea$/$1/ or croak "couldn't parse item price '$price' in line '$line'";
		if ($special =~ /^\$(\d+\.\d{2})\/ea for (\d+)/) {
			$special = {
				PRICE => $1,
				AMOUNT => $2,
			};
		}

		$self->{ITEMS}{$code} = {
			PRICE => $price,
			SPECIAL => $special,
		};
	}

	close $filehandle;
	return;
}

# Scans an item.
sub Scan {
	my ($self, $args) = @_;
	AssertFields($args, ['CODE']);
	$self->{BASKET}{$args->{CODE}}++;

	my $price = $self->{ITEMS}{$args->{CODE}}{PRICE} or croak "unknown item code $args->{CODE}";
	$self->{TOTAL} += $price;
	return;
}

# Returns the total price of all scanned items.
sub Total {
	my ($self) = @_;

	my $total = 0;

	while (my ($code, $amount) = each %{$self->{BASKET}}) {
		my $item = $self->{ITEMS}{$code};
		my $price = $item->{PRICE};
		if ($item->{SPECIAL} && $item->{SPECIAL}{AMOUNT} <= $amount) {
			$price = $item->{SPECIAL}{PRICE};
		}
		$total += ($amount * $price);
	}
	return sprintf '%.2f', $total;
}

1;
