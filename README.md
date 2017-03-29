<h1>yaasp</h1>

YAASP stands for Yet Another Arp Spoofing Program, this software can be used to perform 
flexible Arp Spoofing attacks.

<h3>Installation of yaasp</h3>

In order to install yaasp, few dependencies are required, once we have access to a cpan (or cpanm) we do:

```$>cd path/to/yaasp```

Now we first install cpanminus, I report the command to do it on Debian based GNU/Linux distros:

```$>sudo apt install cpanminus```

```$>cpanm --installdeps . ```

<h3>Usage Examples</h3>

Let's see some usage examples:

<h5>Simple Unidirectional ARP Spoof</h5>

```$>perl yaasp.pl --tell-ip 192.168.1.105 --i-am 192.168.1.1 --interface wlan0 --delay 1```

This will perform an unidirectional arp-spoofing with a delay between arp packets
of 1 second.


<h5>Bidirectional Flood ARP Spoof</h5>

```$>perl yaasp.pl --tell-ip 192.168.1.105 --i-am 192.168.1.1 --interface wlan0 --bidirectional``` 

This will perform a bidirectional arp-spoofing with a delay between arp packets,
if the --delay is not specified, then packets are sent without any delay,
notice that this will generate a lot of traffic on the network.


<h5>Show Help</h5>

```$>perl yaasp.pl --help``` 

This will show a help message, where possible options are shown.

