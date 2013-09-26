#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  lowlat.pl
#
#        USAGE:  ./lowlat.pl [list of hosts] 
#
#  DESCRIPTION:  compare ping round-trip times of a bunch of hosts
#                to find the nearest machine to log in to.
#
#      OPTIONS:  see pod below
# REQUIREMENTS:  Net::Ping, Getopt::AsDocumented
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Sebastian Krohn, seb@gaia.sunn.de
#      COMPANY:  Darksystem Projects
#      VERSION:  0.2
#      CREATED:  03/23/09 11:36:44
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;

use Net::Ping;
use threads ('stack_size' => 16*4096);
use threads::shared;
use Getopt::AsDocumented;

my $opt = Getopt::AsDocumented->process(\@ARGV) or exit 1;
my %hosts : shared;
my $port : shared = 22;
$port = $opt->port if ($opt->port);

if ($#ARGV + 1) {
   foreach (0 .. $#ARGV) {
      $hosts{$ARGV[$_]} = -1;
   }
} else {
   # for my everyday use a bunch of login servers
   %hosts = ( 'host1.foo.bar'     => -1,
              'host2.foo.bar'     => -1,
              'host3.foo.bar'     => -1 );
}

sub pinger {
   my $h = shift;

   my $p = Net::Ping->new("tcp", 2);
   $p->service_check(1);
   $p->port_number($port);
   $p->hires();

   my ($ret, $dur, $ip) = $p->ping($h);

   if ($ret and $ret == 1) {           # service available
      $hosts{$h} = $dur;
   } elsif (!$ret or $ret == 0) {      # service not available
      $hosts{$h} = -2;
   }

   $p->close();
}

foreach (keys %hosts) {
   threads->create(\&pinger, $_); }
foreach (threads->list()) { 
   $_->join; }

foreach (sort {$hosts{$a} cmp $hosts{$b}} keys %hosts ) {
   if ($hosts{$_} >= 0) {
      if ($opt->verbose) {
         printf "%-30s %-5.2f\n", $_, $hosts{$_}*1000;
      } else {
         print "$_\n";
         exit if ($opt->there_can_be_only_one);
      }
   } elsif ($opt->verbose) {
      print "$_ is not reachable and/or service is down\n";
   }
}

__END__

=pod

=head1 NAME

   lowlat - network latency checker

=head1 USAGE

   lowlat [-v|--verbose] [-p|--port port]
          [-1|--there-can-be-only-one] [host]...

=head1 DESCRIPTION

   lowlat checks a bunch  of  hosts  for  network  latency  and  service
   availability using simple tcp-pings. Output will be ordered with  the
   fastest responding host first. Not available hosts or hosts  with  no
   active service on the  specified  port  are  ommited  unless  verbose
   output is chosen.

=head1 OPTIONS

=over

=item -v, --verbose

   Verbose output. Try it! It's totally useless! :-)

=item -p, --port port

   Specifies port to check. Default is 22/SSH.

=item -1, --there_can_be_only_one

   "In the end, there can be only one." - Only output the fastest
   host. To be use in something like "ssh `lowlat -1 ...`" Does
   not work with verbose.

=back

=head1 AUTHOR
   
   Written by Sebastian Krohn <seb@gaia.sunn.de>.

=head1 LICENSE

   This shit is beer-ware. Should you find it useful, you are encouraged
   to buy the author a beer AND (not 'or') drink a beer in the  author's
   honor.

=cut
