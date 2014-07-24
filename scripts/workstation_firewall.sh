#!/bin/bash
echo "*********************************************"
echo "* A CentOS 7.0 deployment script to          "
echo "* install IPv4 and IPv6 firewalls            "
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

# IPv4 firewall config
read -p "Press enter to auto-configure the IPv4 firewall settings"
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

# IPv4 firewall
read -p "Press enter to install the IPv4 firewall"
echo "*************"
echo "* Starting the IPv4 firewall..."
echo "* http://tnt.aufbix.org/ linux firewall script"
echo "* Modified by Keegan Mullaney"
echo "*************"

# path to iptables/ip6tables
IPTB="/sbin/iptables"
IP6TB="/sbin/ip6tables"

# WAN Interface
INTERNET="eth0"

# what TCP ports/services we allow (and FORWARD) from Internet
# use " " as delimiter
TCP_PORTS="80 443 25 465 110 995"

# what UDP ports/services we allow (and FORWARD) from Internet
# use "," as delimiter
UDP_PORTS=""

# whitelisted IPs
TRUSTED_HOSTS="192.168.1.1 \
192.168.2.1"

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
$IPTB -N http-access

# we allow all loopback traffic
$IPTB -A INPUT -i lo -j ACCEPT
$IPTB -A OUTPUT -o lo -j ACCEPT

# allow full outgoing connection but no incoming stuff
$IPTB -A INPUT  -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPTB -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

# move all HTTP traffic to appropriate chains
$IPTB -A INPUT -p tcp -m state --syn --state NEW --dport 80 -j http-access

# http chain
for httphosts in $TRUSTED_HOSTS;
do
   $IPTB -A http-access -s $httphosts -j ACCEPT
done

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
#$IPTB -A INPUT -p udp -m multiport --dport $UDP_PORTS -j ACCEPT

# drop packets that are going to ports used by SMB (Samba / Windows Sharing)
$IPTB -A INPUT -p udp -m multiport --dports 135,445 -j DROP
$IPTB -A INPUT -p udp --dport 137:139 -j DROP
$IPTB -A INPUT -p udp --sport 137 --dport 1024:65535 -j DROP
$IPTB -A INPUT -p tcp -m multiport --dports 135,139,445 -j DROP

# drop packets that are going to port used by UPnP protocol
$IPTB -A INPUT -p udp --dport 1900 -j DROP

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
read -p "Press enter to list the rules"
$IPTB -vnL --line-numbers

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
echo "default policy is to drop all IPv6 traffic because I didn't have time to implement it yet"

# list the rules
read -p "Press enter to list the rules"
$IP6TB -vnL --line-numbers

read -p "Press enter to commit these firewall rules and start the firewall"
chkconfig ip6tables on
service ip6tables save
service ip6tables restart
echo "ip6tables restarted and set to start on boot"
echo
echo "done with workstation_firewall.sh"

