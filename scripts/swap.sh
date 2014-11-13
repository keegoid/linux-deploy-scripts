#!/bin/bash
echo "# -------------------------------------------"
echo "# A CentOS 7.0 x64 deployment script to      "
echo "# add a swap file for a server deploy on a   "
echo "# DigitalOcean Droplet                       "
echo "#                                            "
echo "# Author : Keegan Mullaney                   "
echo "# Company: KM Authorized LLC                 "
echo "# Website: http://kmauthorized.com           "
echo "#                                            "
echo "# MIT: http://kma.mit-license.org            "
echo "# -------------------------------------------"

pause "Press enter to add a swap file..."
swapon -s
echo
df
echo
pause "Press enter to continue..."
dd if=/dev/zero of=/swapfile bs=1024 count=512k
mkswap /swapfile
swapon /swapfile
swapon -s
echo
pause "Press enter to continue..."
chown -c root:root /swapfile 
chmod -c 0600 /swapfile
echo "current swappiness is:"
cat /proc/sys/vm/swappiness
echo
pause "Press enter to set vm.swappiness to 10"
sysctl vm.swappiness=10 && echo "new swappiness is:"
cat /proc/sys/vm/swappiness
echo
pause "Press enter to configure swap file..."
if grep -qw "swap" /etc/fstab; then
   echo "/etc/fstab was already configured"
else
   echo "swap                    /swapfile               swap    defaults        0 0" >> /etc/fstab
fi
if grep -q "# swap settings:" /etc/sysctl.conf; then
   echo "/etc/sysctl.conf was already configured"
else
   printf "\n# swap settings:\nvm.swappiness=10" >> /etc/sysctl.conf && echo "swap file configured"
fi
