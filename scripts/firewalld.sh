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

# status
read -p "Press enter to check the current status of firewalld..."
systemctl status firewalld

# zones
echo
echo "default zone: "
DEFAULT_ZONE=$(firewall-cmd --get-default-zone)
echo "$DEFAULT_ZONE"
echo
echo "active zone: "
ACTIVE_ZONES=$(firewall-cmd --get-active-zones)
echo "$ACTIVE_ZONES"
echo
echo "available zones: "
AVAILABLE_ZONES=$(firewall-cmd --get-zones)
echo "$AVAILABLE_ZONES"

echo
read -p "Press enter to configure firewalld..."

# collect user inputs to determine which zone to set as default
echo
echo "Which zone would you like to set as default?"
select zone in $AVAILABLE_ZONES; do
   DEFAULT_ZONE="$zone"
   break
done

# set default zone
echo "$ACTIVE_ZONES" | grep "$DEFAULT_ZONE"
if [ $? -eq 0 ]; then
   echo "The default zone is already set."
else
   firewall-cmd --set-default-zone=$DEFAULT_ZONE && echo "Zone \"$DEFAULT_ZONE\" was set as default"
fi

# remove existing services from default zone
echo
read -p "Press enter to initialize default services..."
DEFAULT_SERVICES=$(firewall-cmd --list-services)
for svc in $DEFAULT_SERVICES; do
   firewall-cmd --remove-service=$svc --permanent
   echo "removed service: \"$svc\" from zone \"$DEFAULT_ZONE\""
done

# add trusted IPv4 hosts
echo
read -p "Press enter to add trusted IPv4 hosts..."
for h in $TRUSTED_IPV4_HOSTS; do
   firewall-cmd --add-source=$h --permanent
   echo "added host: $h"
done

# add trusted IPv6 hosts
echo
read -p "Press enter to add trusted IPv6 hosts..."
for h in $TRUSTED_IPV6_HOSTS; do
   firewall-cmd --add-source=$h --permanent
   echo "added host: $h"
done

# what we allow from Internet - services
echo
read -p "Press enter to add services..."
for s in $SERVICES; do
   firewall-cmd --add-service=$s --permanent
   echo "added service: $s"
done

# what we allow from Internet - TCP ports
echo
read -p "Press enter to add TCP ports..."
for p in $TCP_PORTS; do
   firewall-cmd --add-port=$p/tcp --permanent
   echo "added port: $p"
done

# what we allow from Internet - UDP ports
echo
read -p "Press enter to add UDP ports..."
for p in $UDP_PORTS; do
   firewall-cmd --add-port=$p/udp --permanent
   echo "added port: $p"
done

# restart the firewall without stopping current connections
echo
read -p "Press enter to reload the firewall..."
firewall-cmd --reload

# list the zone info
echo
read -p "Press enter to list the details for zone: ${DEFAULT_ZONE}"
firewall-cmd --list-all

echo "done with firewalld.sh"

