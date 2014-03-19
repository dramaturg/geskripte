#!/usr/bin/env perl
#
# locator.pl
#
# Print out network and geoip infromation about current host in cfengine format.
#
# 2013-01-09 Sebastian Krohn <seb@darksystem.net>
# 
# Restrictions:
#  - Uses first non-loopback IPv4, doesn't care about other interfaces
#  - IPv4 only
#  - Insufficient error checking
#  - Linux only
# 

use strict;
use warnings;

use Net::DNS;
use Net::Whois::IP;
use Geo::IP;

my $geoip_path = "/usr/share/GeoIP/GeoIPCity.dat";


#
# Get our default interface ip address - lets cheat a bit
#

my $ip;

open my $IFCONFIG, "-|", "ifconfig" || die "Fail: $!\n";
while (<$IFCONFIG>) {
	chomp $_;
	next if $_ !~ m/^\s+inet\s(?:addr:)?([^\s]+)/;
	$ip = $1;
	last if $ip !~ m/^(?:127\.)/;
}
close $IFCONFIG;

# no IP found
die if $ip !~ m/^(\d+\.){3}\d+$/;


#
# If we've got a private IP, we need to find out our external one. There are
# other ways to do it but this usually works quite well.
#

if ($ip =~ m/^(?:127\.|192\.168\.|10\.|172\.(?:1[6-9]|2\d|3[0-1]))/) {

	my $res = Net::DNS::Resolver->new(
		nameservers => [(
			'208.67.222.222',	# resolver1.opendns.com
			'208.67.220.220',	# resolver2.opendns.com
			'208.67.222.220',	# resolver3.opendns.com
			'208.67.220.222')],	# resolver4.opendns.com
		recurse     => 1);

	my $query = $res->query('myip.opendns.com', 'A');

	if ($query) {
		foreach ($query->answer) {
			next unless $_->type eq "A";
			$ip = $_->address;
		}
	} else {
		die "DNS lookup failed: ", $res->errorstring, "\n";
	}
}


#
# finally find some useful information about our location
#
# first the local AS and hosting company
#

my $r=whoisip_query($ip);
$r->{descr}=~s/\s+/_/g;

print "+loc_".$r->{origin}."\n";
print "+loc_".$r->{descr}."\n";

if ( $r->{descr} =~ /^HETZNER/m) {
	print "+loc_HETZNER\n";
}


# now the geographic location

die if not -f $geoip_path; # die if no Geoip database

my $gi = Geo::IP->open($geoip_path, GEOIP_STANDARD);
my $record = $gi->record_by_addr($ip);

print "+loc_" . lc($record->country_code) . "\n";
print "+cc_" . lc($record->country_code) . "\n";
print "=cc=" . lc($record->country_code) . "\n";

