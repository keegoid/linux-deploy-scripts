#!/bin/bash
echo "*********************************************"
echo "* A CentOS 7.0 deployment script to          "
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
read -e -p "Enter the client alive interval in seconds to prevent SSH from dropping out (enter to accept default): " -i "60" CLIENT_ALIVE

# edit /etc/ssh/sshd_config
echo
read -p "Press enter to configure sshd service..."
sed -i.bak -e "s|#Port 22|Port $SSH_PORT|" -e "s|#ClientAliveInterval 0|ClientAliveInterval $CLIENT_ALIVE|" /etc/ssh/sshd_config
echo
echo -e "SSH port set to $SSH_PORT\nclient alive interval set to $CLIENT_ALIVE"

# add new Linux user for SSH access
/usr/sbin/adduser $USER_NAME

# add public key for new user
SSH_DIRECTORY="/home/$USER_NAME/.ssh"
if [ -d $SSH_DIRECTORY ]; then
   echo "$SSH_DIRECTORY already exists for $USER_NAME"
else
   passwd $USER_NAME
   passwd root # for su root command
   mkdir $SSH_DIRECTORY
   echo "made directory: $SSH_DIRECTORY"
   chmod 0700 $SSH_DIRECTORY
   echo "set 0700 permissons on .ssh directory"
   read -e -p "Paste your public ssh-rsa key here: " SSH_RSA
   echo ${SSH_RSA} > $SSH_DIRECTORY/authorized_keys
   echo "public SSH key saved to $SSH_DIRECTORY/authorized_keys"
   chmod 0644 $SSH_DIRECTORY/authorized_keys
   echo "set 0644 permissions on $SSH_DIRECTORY/authorized_keys"
   chown -R $USER_NAME:$USER_NAME $SSH_DIRECTORY
   echo "set owner and group to $USER_NAME for $SSH_DIRECTORY/*"
fi

# disable root user access
echo
read -p "Press enter to disable root access..."
sed -i -e "s|#PermitRootLogin yes|PermitRootLogin no|" -e "s|PasswordAuthentication yes|PasswordAuthentication no|" -e "s|UsePAM yes|UsePAM no|" -e "s|#UseDNS yes|UseDNS no|" /etc/ssh/sshd_config
if cat /etc/ssh/sshd_config | grep -q "AllowUsers $USER_NAME"; then
   echo "AllowUsers was already configured"
else
   printf "\nAllowUsers $USER_NAME" >> /etc/ssh/sshd_config && echo -e "\nroot login disallowed"
fi

echo
read -p "Press enter to reload the sshd service..."
systemctl reload sshd

echo "done with server_ssh.sh"

