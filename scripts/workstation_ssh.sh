#!/bin/bash
echo "*********************************************"
echo "* A CentOS 7.0 deployment script to          "
echo "* generate a new SSH key pair if none        "
echo "* exists and start the SSH-agent             "
echo "*                                            "
echo "* Author : Keegan Mullaney                   "
echo "* Company: KM Authorized LLC                 "
echo "* Website: http://kmauthorized.com           "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*********************************************"

# check if user exists
read -p "Press enter to check if user $USER_NAME exists"
if cat /etc/passwd | grep -q "^$USER_NAME"; then
   SSH_FILE="/home/$USER_NAME/.ssh/id_rsa"
   read -p "Press enter to check if id_rsa exists"
   if [ -e $SSH_FILE ]; then
      echo "$SSH_FILE already exists for $USER_NAME"
   else
      # create a new ssh key using the provided email as a label
      echo "create new key at: $SSH_FILE"
      read -p "Press enter to generate a new SSH key for $EMAIL_ADDRESS"
      ssh-keygen -b 4096 -t rsa -C $EMAIL_ADDRESS
      echo "SSH key generated"
      
      # give permissions to new user
      read -p "Press enter to set permissions on SSH key for $USER_NAME"
      chown $USER_NAME:$USER_NAME ${SSH_FILE}*
      echo "permissions changed"
      
      echo
      echo "copy contents of id_rsa.pub to remote server (Github)"
   fi
else
   echo "user $USER_NAME doesn't exist, create user $USER_NAME before configuring SSH"
fi

echo "done with workstation_ssh.sh"

