#!/bin/bash
echo "*********************************************"
echo "* A CentOS 7.0 x64 deployment script to      "
echo "* set client alive interval and ssh port,    "
echo "* create new shell user with SSH key and     "
echo "* disable root login                         "
echo "*                                            "
echo "* Author : Keegan Mullaney                   "
echo "* Company: KM Authorized LLC                 "
echo "* Website: http://kmauthorized.com           "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*********************************************"

# security inputs
read -ep "Enter the client alive interval in seconds to prevent SSH from dropping out: " -i "60" CLIENT_ALIVE

# edit /etc/ssh/sshd_config
echo
read -p "Press enter to configure sshd service..."
sed -i.bak -e "{
   s|#Port 22|Port $SSH_PORT|
   s|#ClientAliveInterval 0|ClientAliveInterval $CLIENT_ALIVE|
   }" /etc/ssh/sshd_config
echo
echo -e "SSH port set to $SSH_PORT\nclient alive interval set to $CLIENT_ALIVE"

# add public SSH key for new server user
SSH_DIRECTORY="/home/$USER_NAME/.ssh"

# generate SSH keypair or copy from root user
gen_ssh_keys $SSH_DIRECTORY "$SSH_COMMENT" $SSH $USER_NAME

# authorized SSH keys
authorized_ssh_keys $SSH_DIRECTORY $USER_NAME

# disable root user access
echo
read -p "Press enter to disable root access..."
sed -i -e "s|#PermitRootLogin yes|PermitRootLogin no|" -e "s|PasswordAuthentication yes|PasswordAuthentication no|" -e "s|UsePAM yes|UsePAM no|" -e "s|#UseDNS yes|UseDNS no|" /etc/ssh/sshd_config
if grep -q "AllowUsers $USER_NAME" /etc/ssh/sshd_config; then
   echo "AllowUsers is already configured"
else
   printf "\nAllowUsers $USER_NAME" >> /etc/ssh/sshd_config && echo -e "\nroot login disallowed"
fi

echo
read -p "Press enter to reload the sshd service..."
systemctl reload sshd
