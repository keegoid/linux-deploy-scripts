#!/bin/bash
echo "*********************************************"
echo "* A CentOS 7.0 init script to                "
echo "* install git, generate ssh keys and         "
echo "* clone the deployment scripts from GitHub   "
echo "*                                            "
echo "* Author : Keegan Mullaney                   "
echo "* Company: KM Authorized LLC                 "
echo "* Website: http://kmauthorized.com           "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*********************************************"

# inputs
REAL_NAME='Keegan Mullaney'
EMAIL_ADDRESS='keegan@kmauthorized.com'
SSH_KEY_COMMENT='kma server'

# install git
if rpm -qa | grep -q git; then
   echo "git was already installed"
else
   echo
   read -p "Press enter to install git..."
   yum -y install git
fi

# configure git
if git config --list | grep -q "$HOME/.gitignore"; then
   echo "git was already configured."
else
   echo
   read -p "Press enter to configure git..."
   # specify a user
   git config --global user.name "$REAL_NAME"
   git config --global user.email "$EMAIL_ADDRESS"
   # select a text editor
   git config --global core.editor vi
   # add some SVN-like aliases
   git config --global alias.st status
   git config --global alias.co checkout
   git config --global alias.br branch
   git config --global alias.up rebase
   git config --global alias.ci commit
   # set default push.default behavior to the old method
   git config --global push.default matching
   # create a global .gitignore file
   echo -e "# global list of file types to ignore \
\n \
\n# gedit temp files \
\n*~" > $HOME/.gitignore
   git config --global core.excludesfile $HOME/.gitignore
   echo "git was configured"
fi

SSH_FILE="$HOME/.ssh/id_rsa"
read -p "Press enter to check if id_rsa exists"
if [ -e $SSH_FILE ]; then
   echo "$SSH_FILE already exists"
else
   # create a new ssh key using the provided email as a label
   echo "create new key at: $SSH_FILE"
   read -p "Press enter to generate a new SSH key"
   ssh-keygen -b 4096 -t rsa -C $SSH_KEY_COMMENT
   echo "SSH key generated"
   
   echo
   echo "copy contents of id_rsa.pub to remote server (Github):"
   cat $HOME/.ssh/id_rsa.pub
fi

echo
echo "done with init.sh"
