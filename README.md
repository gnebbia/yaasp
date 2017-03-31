yaasp
================

YAASP stands for Yet Another Arp Spoofing Program, this software can be used to perform 
flexible Arp Spoofing attacks.

### Installation of yaasp

In order to install yaasp, few dependencies are required, once we have access to a cpan (or cpanm) we do:

```sh
$ cd path/to/yaasp
```

Now we first install cpanminus, I report the command to do it on Debian based GNU/Linux distros:

```sh
$ sudo apt install cpanminus
```

```sh
$ cpanm --installdeps . 
```

### Usage Examples

Let's see some usage examples:

##### Simple Unidirectional ARP Spoof

```sh
$ perl yaasp.pl --tell-ip 192.168.1.105 --i-am 192.168.1.1 --interface wlan0 --delay 1
```

This will perform an unidirectional arp-spoofing with a delay between arp packets
of 1 second.


##### Bidirectional Flood ARP Spoof

```sh
$>perl yaasp.pl --tell-ip 192.168.1.105 --i-am 192.168.1.1 --interface wlan0 --bidirectional
```

This will perform a bidirectional arp-spoofing with a delay between arp packets,
if the --delay is not specified, then packets are sent without any delay,
notice that this will generate a lot of traffic on the network.


##### Show Help

```sh
$ perl yaasp.pl --help
``` 

This will show a help message, where possible options are shown.

