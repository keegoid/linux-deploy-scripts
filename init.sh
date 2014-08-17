#!/bin/bash
echo "*********************************************"
echo "* A CentOS 7.0 init script to                "
echo "* install git, configure git, generate       "
echo "* ssh keys and clone the deployment scripts  "
echo "* from GitHub                                "
echo "*                                            "
echo "* Author : Keegan Mullaney                   "
echo "* Company: KM Authorized LLC                 "
echo "* Website: http://kmauthorized.com           "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*********************************************"

####################################################
# EDIT THESE VARIABLES WITH YOUR INFO
REAL_NAME='Keegan Mullaney'
EMAIL_ADDRESS='keegan@kmauthorized.com'
SSH_KEY_COMMENT='kma server'
GITHUB_USER='keegoid' #your GitHub username
####################################################

# project info
LDS='linux-deploy-scripts'
LDS_UPSTREAM="keegoid/$LDS.git"

# directories
REPOS="$HOME/repos"
if [ -d $HOME/Dropbox ]; then
   REPOS="$HOME/Dropbox/Repos"
fi
LDS_DIRECTORY="$REPOS/$LDS"

# files
SSH_KEY="$HOME/.ssh/id_rsa"
GIT_IGNORE="$HOME/.gitignore"

# install git
if rpm -q git; then
   echo "git was already installed"
else
   echo
   read -p "Press enter to install git..."
   yum -y install git
fi

# configure git
if git config --list | grep -q $GIT_IGNORE; then
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
\n*~" > $GIT_IGNORE
   git config --global core.excludesfile $GIT_IGNORE
   echo "git was configured"
fi

echo
read -p "Press enter to check if id_rsa exists"
if [ -e $SSH_KEY ]; then
   echo "$SSH_KEY already exists"
else
   # create a new ssh key with provided ssh key comment
   echo "create new key: $SSH_KEY"
   read -p "Press enter to generate a new SSH key"
   ssh-keygen -b 4096 -t rsa -C "$SSH_KEY_COMMENT"
   echo "SSH key generated"
   echo
   echo "***IMPORTANT***"
   echo "copy contents of id_rsa.pub (printed below) to the SSH keys section"
   echo " of your GitHub account."
   echo "highlight the text with your mouse and press ctrl+shift+c to copy"
   echo
   cat $SSH_KEY.pub
   echo
   read -p "Press enter to continue..."
fi

# linux-deploy-scripts repository
echo
echo "Have you copied id_rsa.pub (above) to the SSH keys section"
echo "of your GitHub account?"
echo "If not, choose HTTPS for the clone operation when prompted."
echo
read -p "Press enter when ready..."

# make and change to repos directory
mkdir -pv $REPOS
cd $REPOS
echo "changing directory to $_"

# generate a blog template for Middleman
if [ -d "$LDS_DIRECTORY" ]; then
   echo "$LDS directory already exists, skipping clone operation..."
else
   echo
   echo "***IMPORTANT***"
   echo "Before proceeding, make sure to fork $LDS_UPSTREAM"
   echo "on GitHub to your account."
   echo
   read -p "Press enter to clone $LDS from your GitHub account..."
   echo
   echo "Do you wish to clone using HTTPS or SSH (recommended)?"
   select hs in "HTTPS" "SSH"; do
      case $hs in
         "HTTPS") git clone https://github.com/$GITHUB_USER/$LDS.git;;
           "SSH") git clone git@github.com:$GITHUB_USER/$LDS.git;;
               *) echo "case not found..."
      esac
      break
   done
fi

# change to newly cloned directory
cd $LDS
echo "changing directory to $_"

if echo $LDS_UPSTREAM | grep -q $GITHUB_USER; then
   echo "no upstream repository exists"
else
   # assign the original repository to a remote called "upstream"
   if git config --list | grep -q $LDS_UPSTREAM; then
      echo "upstream repo already configured: https://github.com/$LDS_UPSTREAM"
   else
      echo
      read -p "Press enter to assign upstream repository..."
      git remote add upstream https://github.com/$LDS_UPSTREAM && echo "remote upstream added for https://github.com/$LDS_UPSTREAM"
   fi

   # pull in changes not present local repository, without modifying local files
   echo
   read -p "Press enter to fetch changes from upstream repository..."
   git fetch upstream
   echo "upstream fetch done"

   # merge any changes fetched into local working files
   echo
   read -p "Press enter to merge changes..."
   git merge upstream/master
fi

echo "done with init.sh"
echo "now you can configure and run setup.sh"
