#!/bin/bash
echo "*********************************************"
echo "* A CentOS 7.0 deployment script to          "
echo "* install IPv4 and IPv6 firewalls            "
echo "* script takes one argument for SSH port     "
echo "*                                            "
echo "* Author : Keegan Mullaney                   "
echo "* Company: KM Authorized LLC                 "
echo "* Website: http://kmauthorized.com           "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*                                            "
echo "* firewall scripts derived from:             "
echo "* https://gist.github.com/jirutka/3742890    "
echo "* http://tnt.aufbix.org/linux/firewall       "
echo "*********************************************"

read -p "Press enter to install the IPv4 firewall"

# IPv4 firewall config
SYSCTL="/sbin/sysctl"
 
# stop certain attacks
echo "Setting sysctl IPv4 settings..."
$SYSCTL net.ipv4.ip_forward=0
$SYSCTL net.ipv4.conf.all.send_redirects=0
$SYSCTL net.ipv4.conf.default.send_redirects=0
$SYSCTL net.ipv4.conf.all.accept_source_route=0
$SYSCTL net.ipv4.conf.all.accept_redirects=0
$SYSCTL net.ipv4.conf.all.secure_redirects=0
$SYSCTL net.ipv4.conf.all.log_martians=1
$SYSCTL net.ipv4.conf.default.accept_source_route=0
$SYSCTL net.ipv4.conf.default.accept_redirects=0
$SYSCTL net.ipv4.conf.default.secure_redirects=0
$SYSCTL net.ipv4.icmp_echo_ignore_broadcasts=1
#$SYSCTL net.ipv4.icmp_ignore_bogus_error_messages=1
$SYSCTL net.ipv4.tcp_syncookies=1
$SYSCTL net.ipv4.conf.all.rp_filter=1
$SYSCTL net.ipv4.conf.default.rp_filter=1
$SYSCTL kernel.exec-shield=1
$SYSCTL kernel.randomize_va_space=1
$SYSCTL vm.swappiness=10

# path to iptables/ip6tables
IPTB="/sbin/iptables"
IP6TB="/sbin/ip6tables"

# WAN Interface
INTERNET="eth0"

# what TCP ports/services we allow (and FORWARD) from Internet
# use " " as delimiter
TCP_PORTS="80 443 25 465 110 995 21 $1"

# what UDP ports/services we allow (and FORWARD) from Internet
# use "," as delimiter
UDP_PORTS="123"

# whitelisted IPs (Cloudflare)
TRUSTED_HOSTS="199.27.128.0/21 \
173.245.48.0/20 \
103.21.244.0/22 \
103.22.200.0/22 \
103.31.4.0/22 \
141.101.64.0/18 \
108.162.192.0/18 \
190.93.240.0/20 \
188.114.96.0/20 \
197.234.240.0/22 \
198.41.128.0/17 \
162.158.0.0/15 \
104.16.0.0/12"
TRUSTED_HOSTS6="2400:cb00::/32 \
2606:4700::/32 \
2803:f800::/32 \
2405:b500::/32 \
2405:8100::/32"

# first we flush the tables and policy
$IPTB -F
$IPTB -X
$IPTB -F INPUT
$IPTB -F FORWARD
$IPTB -F OUTPUT

$IPTB -t nat -F

# default policy
$IPTB -P INPUT DROP
$IPTB -P FORWARD DROP
$IPTB -P OUTPUT DROP

# separate/new queue
$IPTB -N ssh-access
$IPTB -N http-access

# we allow all loopback traffic
$IPTB -A INPUT -i lo -j ACCEPT
$IPTB -A OUTPUT -o lo -j ACCEPT

# allow full outgoing connection but no incoming stuff
$IPTB -A INPUT  -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPTB -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

# move all SSH and HTTP traffic to appropriate chains
$IPTB -A INPUT -p tcp -m state --syn --state NEW --dport $1 -j ssh-access
$IPTB -A INPUT -p tcp -m state --syn --state NEW --dport 80 -j http-access

# ssh chain
for sshhosts in $TRUSTED_HOSTS;
do
   $IPTB -A ssh-access -s $sshhosts -j ACCEPT
done

# ssh chain
# connection limit for SSH connections (1 connection per minute from one source IP)
# useful against ssh scanners if you MUST open SSH for every IP!
$IPTB -A ssh-access -m hashlimit --hashlimit 1/minute --hashlimit-burst 1 --hashlimit-mode srcip --hashlimit-name ssh -j ACCEPT
$IPTB -A ssh-access -j DROP

# http chain
for httphosts in $TRUSTED_HOSTS;
do
   $IPTB -A http-access -s $httphosts -j ACCEPT
done

# IPSEC
#$IPTB -A INPUT -i $INTERNET -p udp --sport 500 --dport 500  -j ACCEPT
#$IPTB -A INPUT -i $INTERNET -p 50 -j ACCEPT
#$IPTB -A INPUT -i $INTERNET -p 51 -j ACCEPT

# drop remote packets claiming to be from a loopback address.
$IPTB -A INPUT -s 127.0.0.0/8 ! -i lo -j LOG --log-prefix "false loopback> "
$IPTB -A INPUT -s 127.0.0.0/8 ! -i lo -j DROP

# drop invalid packets
$IPTB -A INPUT -m state --state INVALID -m limit --limit 1/minute -j LOG --log-prefix "packet not in conntrack> "
$IPTB -A INPUT -m state --state INVALID -j DROP

# drop broadcast and multicast packets
$IPTB -A INPUT -i $INTERNET -m pkttype --pkt-type broadcast -j DROP
$IPTB -A INPUT -i $INTERNET -m pkttype --pkt-type multicast -j DROP

# prevent syn-flood attack
$IPTB -A INPUT -m state --state NEW -p tcp ! --syn -j LOG --log-prefix "SYN-flood> "
$IPTB -A INPUT -m state --state NEW -p tcp ! --syn -j DROP

# FIN is set and ACK is not
$IPTB -A INPUT -p tcp --tcp-flags ACK,FIN FIN -j LOG --log-prefix "FIN> "
$IPTB -A INPUT -p tcp --tcp-flags ACK,FIN FIN -j DROP

# PSH is set and ACK is not
$IPTB -A INPUT -p tcp --tcp-flags ACK,PSH PSH -j LOG --log-prefix "PSH> "
$IPTB -A INPUT -p tcp --tcp-flags ACK,PSH PSH -j DROP

# URG is set and ACK is not
$IPTB  -A INPUT -p tcp --tcp-flags ACK,URG URG -j LOG --log-prefix "URG> "
$IPTB  -A INPUT -p tcp --tcp-flags ACK,URG URG -j DROP

# block XMAS scans
$IPTB -A INPUT -p tcp --tcp-flags ALL ALL  -j LOG --log-prefix "XMAS scan> "
$IPTB -A INPUT -p tcp --tcp-flags ALL ALL  -j DROP

# no flag is set
$IPTB -A INPUT -p tcp --tcp-flags ALL NONE -j LOG --log-prefix "NULL scan> "
$IPTB -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

# block port scans
$IPTB -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j LOG --log-prefix "pscan> "
$IPTB -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP

# SYN and FIN are both set
$IPTB -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j LOG --log-prefix "pscan 2> "
$IPTB -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP

# FIN and RST are both set
$IPTB -A INPUT -p tcp --tcp-flags FIN,RST FIN,RST -j LOG --log-prefix "fin/rts flag> "
$IPTB -A INPUT -p tcp --tcp-flags FIN,RST FIN,RST -j DROP

# drop lost fragments
$IPTB -A INPUT -f -j LOG --log-prefix "Lost FRAGMENT> "
$IPTB -A INPUT -f -j DROP

$IPTB -A INPUT -p tcp --tcp-flags ALL SYN,FIN -j LOG --log-prefix "SYNFIN-SCAN> "
$IPTB -A INPUT -p tcp --tcp-flags ALL SYN,FIN -j DROP

$IPTB -A INPUT -p tcp --tcp-flags ALL URG,PSH,FIN -j LOG --log-prefix "NMAP-XMAS-SCAN> "
$IPTB -A INPUT -p tcp --tcp-flags ALL URG,PSH,FIN -j DROP

$IPTB -A INPUT -p tcp --tcp-flags ALL FIN -j LOG --log-prefix "FIN-SCAN> "
$IPTB -A INPUT -p tcp --tcp-flags ALL FIN -j DROP

$IPTB -A INPUT -p tcp --tcp-flags ALL URG,PSH,SYN,FIN -j LOG --log-prefix "NMAP-ID> "
$IPTB -A INPUT -p tcp --tcp-flags ALL URG,PSH,SYN,FIN -j DROP

# SYN and RST are both set
$IPTB -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j LOG --log-prefix "SYN-RST> "
$IPTB -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP

# what we allow from Internet - TCP ports
for i in $TCP_PORTS
do
   $IPTB -A INPUT -p tcp -m state --syn --state NEW  --dport $i -j ACCEPT
done

# what we allow from Internet - UDP ports
$IPTB -A INPUT -p udp -m multiport --dport $UDP_PORTS -j ACCEPT

# traceroute (udp - IOS, Uni*es)
$IPTB -A INPUT -p udp -m limit --limit 3/second  --sport 32769:65535 --dport 33434:33523 -j ACCEPT

# log and drop ICMP fragments (should not happen at all, but often used for DoS)
$IPTB -A INPUT -i $INTERNET --fragment -p icmp -j LOG --log-prefix "Fragmented incoming ICMP> "
$IPTB -A INPUT -i $INTERNET --fragment -p icmp -m hashlimit --hashlimit 10/second --hashlimit-burst 1 --hashlimit-mode srcip --hashlimit-name icmp-frag -j ACCEPT

# thou shall NOT block ALL ICMP, but only allow useful ICMP types to pass through echo-reply
#$IPTB -A INPUT -p icmp --icmp-type 0 -m hashlimit --hashlimit 10/second --hashlimit-burst 1 --hashlimit-mode srcip --hashlimit-name icmp0 -j ACCEPT
$IPTB -A INPUT -p icmp --icmp-type 3 -m hashlimit --hashlimit 10/second --hashlimit-burst 1 --hashlimit-mode srcip --hashlimit-name icmp3 -j ACCEPT
#$IPTB -A INPUT -p icmp --icmp-type 4 -m hashlimit --hashlimit 10/second --hashlimit-burst 1 --hashlimit-mode srcip --hashlimit-name icmp4 -j ACCEPT
$IPTB -A INPUT -p icmp --icmp-type 11 -m hashlimit --hashlimit 10/second --hashlimit-burst 1 --hashlimit-mode srcip --hashlimit-name icmp11 -j ACCEPT
$IPTB -A INPUT -p icmp --icmp-type 12 -m hashlimit --hashlimit 10/second --hashlimit-burst 1 --hashlimit-mode srcip --hashlimit-name icmp12 -j ACCEPT
# icmp-traceroute
$IPTB -A INPUT -p icmp --icmp-type 30 -m hashlimit --hashlimit 10/second --hashlimit-burst 1 --hashlimit-mode srcip --hashlimit-name icmp30 -j ACCEPT
# echo-request
$IPTB -A INPUT -p icmp --icmp-type 8 -m hashlimit --hashlimit 10/second --hashlimit-burst 1 --hashlimit-mode srcip --hashlimit-name icmp8 -j ACCEPT

# specifically reject identd requests and other common ports
$IPTB -A INPUT -i $INTERNET -p tcp -m state --syn --state NEW -m multiport --dports 1080,3128,8080 -j REJECT
$IPTB -A INPUT -i $INTERNET -p tcp --dport 113 -j REJECT --reject-with tcp-reset
$IPTB -A INPUT -i $INTERNET -p udp --dport 113 -j REJECT

# log and drop the rest
$IPTB -A INPUT  -m limit --limit 10/minute --limit-burst 1 -j LOG --log-prefix "input IPv4 drop> "
$IPTB -A INPUT  -j DROP
$IPTB -A OUTPUT -j LOG --log-prefix "output IPv4 drop> "
$IPTB -A OUTPUT -j DROP

# list the rules
echo
read -p "Press enter to list the rules"
$IPTB -vnL --line-numbers

echo
read -p "Press enter to commit these firewall rules and start the firewall"
chkconfig iptables on
service iptables save
service iptables restart
echo "iptables restarted and set to start on boot"

# IPv6 firewall
echo "*******************************************"
read -p "Press enter to install the IPv6 firewall"

# first we flush the tables and policy
$IP6TB -F
$IP6TB -X
$IP6TB -F INPUT
$IP6TB -F FORWARD
$IP6TB -F OUTPUT

# default policy
$IP6TB -P INPUT DROP
$IP6TB -P FORWARD DROP
$IP6TB -P OUTPUT DROP

# separate/new queue
$IP6TB -N ssh-access6
$IP6TB -N http-access6

# we allow all loopback traffic
$IP6TB -A INPUT  -i lo -j ACCEPT
$IP6TB -A OUTPUT -o lo -j ACCEPT

# allow full outgoing connection but no incoming stuff
$IP6TB -A INPUT  -m state --state ESTABLISHED,RELATED -j ACCEPT
$IP6TB -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

# allow localhost traffic. This rule is for all protocols.
$IP6TB -A INPUT -s ::1 -d ::1 -j ACCEPT

# allow Link-Local addresses
$IP6TB -A INPUT  -s fe80::/10 -j ACCEPT
$IP6TB -A OUTPUT -s fe80::/10 -j ACCEPT

# move all SSH and HTTP traffic to appropriate chains
$IP6TB -A INPUT -p tcp -m state --syn --state NEW --dport $1 -j ssh-access6
$IP6TB -A INPUT -p tcp -m state --syn --state NEW --dport 80 -j http-access6

# ssh chain
# connection limit for SSH connections (1 connection per minute from one source IP)
# useful against ssh scanners if you MUST open SSH for every IP!
for sshhosts in $TRUSTED_HOSTS6;
do
   $IP6TB -A ssh-access6 -s $sshhosts -j ACCEPT
done
$IP6TB -A ssh-access6 -m hashlimit --hashlimit 1/minute --hashlimit-burst 1 --hashlimit-mode srcip --hashlimit-name ssh6 -j ACCEPT
$IP6TB -A ssh-access6 -j DROP

# http chain
for httphosts in $TRUSTED_HOSTS6;
do
   $IP6TB -A http-access6 -s $httphosts -j ACCEPT
done

# IPSEC
#$IP6TB -A INPUT -i $INTERNET -p udp --sport 500 --dport 500  -j ACCEPT
#$IP6TB -A INPUT -i $INTERNET -p 50 -j ACCEPT
#$IP6TB -A INPUT -i $INTERNET -p 51 -j ACCEPT

# drop remote packets claiming to be from a loopback address.
$IP6TB -A INPUT -s ::1/128 ! -i lo -j DROP

# drop invalid packets
$IP6TB -A INPUT -m state --state INVALID -m limit --limit 1/minute -j LOG --log-prefix "packet not in conntrack> "
$IP6TB -A INPUT -m state --state INVALID -j DROP

# what we allow from Internet - TCP ports
for i in $TCP_PORTS
do
   $IP6TB -A INPUT -p tcp -m state --syn --state NEW  --dport $i -j ACCEPT
done

# what we allow from Internet - UDP ports
$IP6TB -A INPUT -p udp -m multiport --dport $UDP_PORTS -j ACCEPT

# identd requests
$IP6TB -A INPUT -p tcp --dport 113 -j REJECT --reject-with tcp-reset

# traceroute (udp - IOS, Uni*es)
$IP6TB -A INPUT -p udp -m limit --limit 3/second  --sport 32769:65535 --dport 33434:33523 -j ACCEPT

# recommended, but unsupported on older kernels
$IP6TB -A INPUT   -m rt --rt-type 0 -j DROP
$IP6TB -A OUTPUT  -m rt --rt-type 0 -j DROP
$IP6TB -A FORWARD -m rt --rt-type 0 -j DROP

# allow but rate-limit echo request/reply
$IP6TB -A INPUT  -i $INTERNET -p icmpv6 --icmpv6-type 128 -m limit --limit 900/min -j ACCEPT
$IP6TB -A INPUT  -i $INTERNET -p icmpv6 --icmpv6-type 129 -m limit --limit 900/min -j ACCEPT
$IP6TB -A OUTPUT -o $INTERNET -p icmpv6 --icmpv6-type 128 -m limit --limit 900/min -j ACCEPT
$IP6TB -A OUTPUT -o $INTERNET -p icmpv6 --icmpv6-type 129 -m limit --limit 900/min -j ACCEPT

# allow router advertisements on local network segments
for icmptype in 133 134 135 136 137
do
   $IP6TB -A INPUT -p icmpv6 --icmpv6-type $icmptype -m hl --hl-eq 255 -j ACCEPT
   $IP6TB -A OUTPUT -p icmpv6 --icmpv6-type $icmptype -m hl --hl-eq 255 -j ACCEPT
done

# allow RFC 4890 but with rate-limiting
for icmptype in 1 2 3/0 3/1 4/0 4/1 4/2 130 131 132 133 141 142 143 148 149 151 152 153
do
   $IP6TB -A INPUT  -p icmpv6 --icmpv6-type $icmptype -m limit --limit 900/min -j ACCEPT
   $IP6TB -A OUTPUT -p icmpv6 --icmpv6-type $icmptype -m limit --limit 900/min -j ACCEPT
done

# log all other icmpv6 types
$IP6TB -A INPUT -p icmpv6 -j LOG --log-prefix "dropped ICMPv6> "

# allow RFC 4890 but with rate-limiting
for icmptype in 1 2 3 4 130 131 132 141 142 143 148 149 151 152
do
   $IP6TB -A OUTPUT -p icmpv6 --icmpv6-type $icmptype -m limit --limit 900/min -j ACCEPT
done

# specifically reject identd requests and other common ports
$IP6TB -A INPUT -i $INTERNET -p tcp -m state --syn --state NEW -m multiport --dports 1080,3128,8080 -j REJECT
$IP6TB -A INPUT -i $INTERNET -p tcp --dport 113 -j REJECT --reject-with tcp-reset
$IP6TB -A INPUT -i $INTERNET -p udp --dport 113 -j REJECT

# log and drop the rest
$IP6TB -A INPUT  -m limit --limit 10/minute --limit-burst 1 -j LOG --log-prefix "input IPv6 drop> "
$IP6TB -A INPUT  -j DROP
$IP6TB -A OUTPUT -j LOG --log-prefix "output IPv6 drop> "
$IP6TB -A OUTPUT -j DROP

# list the rules
echo
read -p "Press enter to list the rules"
$IP6TB -vnL --line-numbers

echo
read -p "Press enter to commit these firewall rules and start the IPv6 firewall"
chkconfig ip6tables on
service ip6tables save
service ip6tables restart
echo "ip6tables restarted and set to start on boot"
echo
echo "done with server_firewall.sh"

