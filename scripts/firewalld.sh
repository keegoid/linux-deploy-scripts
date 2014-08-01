#!/bin/bash
echo "*********************************************"
echo "* A CentOS 7.0 deployment script to          "
echo "* configure firewalld                        "
echo "* script takes one argument for SSH port     "
echo "*                                            "
echo "* Author : Keegan Mullaney                   "
echo "* Company: KM Authorized LLC                 "
echo "* Website: http://kmauthorized.com           "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*********************************************"

read -p "Press enter to configure firewalld"

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

# http chain
for httphosts in $TRUSTED_HOSTS;
do
   $IPTB -A http-access -s $httphosts -j ACCEPT
done

# what we allow from Internet - TCP ports
for i in $TCP_PORTS
do
   $IPTB -A INPUT -p tcp -m state --syn --state NEW  --dport $i -j ACCEPT
done

# what we allow from Internet - UDP ports
$IPTB -A INPUT -p udp -m multiport --dport $UDP_PORTS -j ACCEPT

# list the rules
echo
read -p "Press enter to list the rules"
$IPTB -vnL --line-numbers

echo
read -p "Press enter to commit these firewall rules and start the firewall"
chkconfig iptables on
systemctl iptables save
systemctl iptables restart
echo "iptables restarted and set to start on boot"

echo
echo "done with server_firewall.sh"

