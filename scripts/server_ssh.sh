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
read -e -p "Enter the client alive interval in seconds to prevent SSH from dropping out (enter to accept default): " -i "60" CLIENT_ALIVE

# edit /etc/ssh/sshd_config
echo
read -p "Press enter to configure sshd service..."
sed -i.bak -e "{
   s|#Port 22|Port $SSH_PORT|
   s|#ClientAliveInterval 0|ClientAliveInterval $CLIENT_ALIVE|
   }" /etc/ssh/sshd_config
echo
echo -e "SSH port set to $SSH_PORT\nclient alive interval set to $CLIENT_ALIVE"

# add new Linux user for SSH access
/usr/sbin/adduser $USER_NAME

# add public SSH key for new user
SSH_DIRECTORY="/home/$USER_NAME/.ssh"

# SSH keys
# authorized_keys
echo
echo "Note: $SSH_DIRECTORY/authorized_keys are public keys that match private"
echo "keys of remote SSH users"
echo
if [ -e "$SSH_DIRECTORY/authorized_keys" ]; then
   echo "$SSH_DIRECTORY/authorized_keys already exists for $USER_NAME"
else
   passwd $USER_NAME
   echo
   echo "for su root command:"
   passwd root # for su root command
   mkdir $SSH_DIRECTORY
   echo "made directory: $SSH_DIRECTORY"
   chmod 0700 $SSH_DIRECTORY
   echo "set 0700 permissons on .ssh directory"
   echo
   echo "***IMPORTANT***"
   echo "Paste (using ctrl+shift+v) your public ssh-rsa key to SSH into this server."
   read -e -p "Paste it here: " SSH_RSA
   echo ${SSH_RSA} > $SSH_DIRECTORY/authorized_keys
   echo "public SSH key saved to $SSH_DIRECTORY/authorized_keys"
   chmod 0600 $SSH_DIRECTORY/authorized_keys
   echo "set 0600 permissions on $SSH_DIRECTORY/authorized_keys"
   chown -R $USER_NAME:$USER_NAME $SSH_DIRECTORY
   echo "set owner and group to $USER_NAME for $SSH_DIRECTORY"
fi

# move id_rsa to new user account or create new SSH keypair if none exists
echo
echo "Note: $SSH_DIRECTORY/id_rsa is for public/private key pairs to establish"
echo "outgoing SSH connections to remote systems"
echo
# check if id_rsa already exists and skip if true
if [ -e "$SSH_DIRECTORY/id_rsa" ]; then
   echo "$SSH_DIRECTORY/id_rsa already exists for $USER_NAME"
# if it doesn't exist, get it from root user
elif [ -e "$HOME/.ssh/id_rsa" ]; then
   cp $HOME/.ssh/id_rsa $SSH_DIRECTORY
   cp $HOME/.ssh/id_rsa.pub $SSH_DIRECTORY
   echo "moved $HOME/.ssh/id_rsa to $SSH_DIRECTORY/id_rsa"
   chmod 0600 $SSH_DIRECTORY/id_rsa
   echo "set 0600 permissions on $SSH_DIRECTORY/id_rsa"
   chown -R $USER_NAME:$USER_NAME $SSH_DIRECTORY/id_rsa
   echo "set owner and group to $USER_NAME for $SSH_DIRECTORY/id_rsa"
# if root user doesn't have id_rsa, create a new keypair
else
   # create a new ssh key with provided ssh key comment
   echo "create new key at: $SSH_DIRECTORY/id_rsa"
   read -p "Press enter to generate a new SSH key"
   ssh-keygen -b 4096 -t rsa -C "$SSH_KEY_COMMENT"
   echo "SSH key generated"
   echo
   echo "***IMPORTANT***"
   echo "copy contents of id_rsa.pub (printed below) to the SSH keys section"
   echo " of your GitHub account."
   echo "highlight the text with your mouse and press ctrl+shift+c to copy"
   echo
   cat $SSH_DIRECTORY/id_rsa.pub
   echo
   read -p "Press enter to continue..."
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

