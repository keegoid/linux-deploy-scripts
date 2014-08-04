#!/bin/bash
echo "*********************************************"
echo "* A CentOS 7.0 deployment script to          "
echo "* add a swap file for a server deploy on a   "
echo "* Digital Ocean Droplet                      "
echo "*                                            "
echo "* Author : Keegan Mullaney                   "
echo "* Company: KM Authorized LLC                 "
echo "* Website: http://kmauthorized.com           "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*********************************************"

read -p "Press enter to add a swap file..."
swapon -s
echo
df
echo
read -p "Press enter to continue..."
dd if=/dev/zero of=/swapfile bs=1024 count=512k
mkswap /swapfile
swapon /swapfile
swapon -s
echo
read -p "Press enter to continue..."
chown root:root /swapfile 
chmod 0600 /swapfile && echo "permissions set on swapfile"
echo "current swappiness is:"
cat /proc/sys/vm/swappiness
echo
read -p "Press enter to set vm.swappiness to 10"
sysctl vm.swappiness=10 && echo "new swappiness is:"
cat /proc/sys/vm/swappiness
echo
read -p "Press enter to configure swap file..."
if cat /etc/fstab | grep -q "swap"; then
   echo "/etc/fstab was already configured"
else
   echo "swap                    /swapfile               swap    defaults        0 0" >> /etc/fstab
fi
if cat /etc/sysctl.conf | grep -q "# swap settings:"; then
   echo "/etc/sysctl.conf was already configured"
else
   printf "\n# swap settings:\nvm.swappiness=10" >> /etc/sysctl.conf && echo "swap file configured"
fi

echo "done with swap.sh"
