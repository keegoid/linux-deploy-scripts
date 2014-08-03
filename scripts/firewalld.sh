#!/bin/bash
echo "*********************************************"
echo "* A CentOS 7.0 deployment script to          "
echo "* configure firewalld                        "
echo "*                                            "
echo "* Author : Keegan Mullaney                   "
echo "* Company: KM Authorized LLC                 "
echo "* Website: http://kmauthorized.com           "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*********************************************"

read -p "Press enter to check the current status of firewalld..."
systemctl status firewalld
echo
echo "default zone: "
firewall-cmd --get-default-zone
echo
echo "active zones: "
firewall-cmd --get-active-zones

echo
read -p "Press enter to configure firewalld..."

# array to hold available firewall zones
ZONES=$(firewall-cmd --get-zones)
echo "available firewall zones: $ZONES"

# get default zone
DEFAULT_ZONE=$(firewall-cmd --get-default-zone)

# collect user inputs to determine which zone to set as default
echo
echo "Which zone would you like to set as default?"
select zone in $ZONES; do
   DEFAULT_ZONE="$zone"
   break
done

# set default zone
firewall-cmd --set-default-zone=$DEFAULT_ZONE
echo "Zone \"$DEFAULT_ZONE\" was set as default"

# remove existing services from default zone
echo
read -p "Press enter to initialize default zone..."
DEFAULT_SERVICES=$(firewall-cmd --list-services)
for svc in $DEFAULT_SERVICES; do
   firewall-cmd --remove-service=$svc --permanent
   echo "removed service \"$svc\" from zone \"$DEFAULT_ZONE\""
done

# add trusted IPv4 hosts
echo
read -p "Press enter to add trusted IPv4 hosts..."
for h in $TRUSTED_IPV4_HOSTS; do
   firewall-cmd --add-source=$h --permanent
done

# add trusted IPv6 hosts
echo
read -p "Press enter to add trusted IPv6 hosts..."
for h in $TRUSTED_IPV6_HOSTS; do
   firewall-cmd --add-source=$h --permanent
done

# what we allow from Internet - services
echo
read -p "Press enter to add services..."
for s in $SERVICES; do
   firewall-cmd --add-service=$s --permanent
done

# what we allow from Internet - TCP ports
echo
read -p "Press enter to add TCP ports..."
for p in $TCP_PORTS; do
   firewall-cmd --add-port=$p/tcp --permanent
done

# what we allow from Internet - UDP ports
echo
read -p "Press enter to add UDP ports..."
for p in $UDP_PORTS; do
   firewall-cmd --add-port=$p/udp --permanent
done

# restart the firewall without stopping current connections
echo
read -p "Press enter to reload the firewall..."
firewall-cmd --reload

# list the zone info
echo
read -p "Press enter to list the details for zone: ${DEFAULT_ZONE}..."
firewall-cmd --list-all

echo
echo "done with firewalld.sh"

