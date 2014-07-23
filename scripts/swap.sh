#!/bin/bash
echo "*********************************************"
echo "* A CentOS 6.5 deployment script to          "
echo "* add a swap file for a server deploy        "
echo "* --by Keegan Mullaney                       "
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
egrep -i "swap" /etc/fstab
if [ $? -eq 0 ]; then
   echo "/etc/fstab was already configured"
else
   echo "swap                    /swapfile               swap    defaults        0 0" >> /etc/fstab
fi
egrep -i "# swap settings:" /etc/sysctl.conf
if [ $? -eq 0 ]; then
   echo "/etc/sysctl.conf was already configured"
else
   printf "\n# swap settings:\nvm.swappiness=10" >> /etc/sysctl.conf && echo "swap file configured"
fi
echo
echo "done with swap.sh"


