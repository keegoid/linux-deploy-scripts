#!/bin/bash
echo "*********************************************"
echo "* A CentOS 6.5 deployment script.            "
echo "* Sets client alive interval and ssh port,   "
echo "* creates new shell user with SSH key and    "
echo "* disables root login.                       "
echo "* --written by Keegan Mullaney.              "
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
# TODO: replace my public SSH key with your own public SSH key
echo "ssh-rsa \
AAAAB3NzaC1yc2EAAAABJQAAAgEAlof8rpgxVf2v216VQ3HzD3QxG21aAOD5UZdI\
N1mmhSVjSlvCITKkhZzGtejhW1IgTrQnV7duXu6tJBxPhBH0m7caaBUG5A+WA4pW\
QnMxLTBycNxIHEZKK5H93dwkuuU2HJWjRZPrcX/vZKtK1lTWdD72QmGMp0luZybY\
0d7ksEuq99rTWCPPpjc8MCYaLH0c68q4pf6Bn60Fe67gyHd9ZLxiddIENr+6UZIY\
ODRPSQDzXftdTR9LIehnzOGgZcwe4Q+TkDDGXnHRvOs2A+jHYy4QsBvjlHWL+LHq\
49jNnAhdEKLp37G82v45vNYu6fu0wazF3cijtRpJDyishW8pUEcnj5bgN7EcI4PZ\
wcMrCe2vYgOL1J/YZnYWUdPndUgJPwcKhgoEgrj1uNPvpOlF+lnonohFRB6zXXCw\
CEL8gySWWxfdwSdYKsw243Fq9JMtqL+h0wxZTht0cRcfM/YxfsuCrW0Q9g1l34Lr\
Piq4l8SaXR0EwmJ9WZMvRqV3IsCKqxXJEqVAbPrneSaLc/QqHup0w5Za63RBz8Cs\
rXxVNuDwMoYUSg7/l6IyMZiY8ZYrGhwzVFqe0Y1jzApJ3Kk83U91dadCqn0wUUAR\
X/L1Hvr/klVph7k15GCN4hW3n96ioYJKwLIU2h0rJbzed0G6Yr2ZjMNq6LZosaOD\
EOMxZws= rsa-key-20140407 DigitalOcean" > $SSH_DIRECTORY/authorized_keys
   chmod 0644 $SSH_DIRECTORY/authorized_keys
   echo "set 0644 permissions on $SSH_DIRECTORY/authorized_keys"
   chown -R $USER_NAME:$USER_NAME /home/$USER_NAME
   echo "set owner and group to $USER_NAME for /home/$USER_NAME/*"
fi

# disable root user access
echo
read -p "Press enter to disable root access..."
sed -i -e "s|#PermitRootLogin yes|PermitRootLogin no|" -e "s|PasswordAuthentication yes|PasswordAuthentication no|" -e "s|UsePAM yes|UsePAM no|" -e "s|#UseDNS yes|UseDNS no|" /etc/ssh/sshd_config
if grep -Fxq "AllowUsers $USER_NAME" /etc/ssh/sshd_config
then
   echo "AllowUsers was already configured"
else
   printf "\nAllowUsers $USER_NAME" >> /etc/ssh/sshd_config && echo -e "\nroot login disallowed"
fi

echo
read -p "Press enter to reload the sshd service..."
service sshd reload
echo
echo "done with server_ssh.sh"

