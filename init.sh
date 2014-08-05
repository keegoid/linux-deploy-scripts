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

# inputs
REAL_NAME='Keegan Mullaney'
EMAIL_ADDRESS='keegan@kmauthorized.com'
SSH_KEY_COMMENT='kma server'
LDS_PROJECT='linux-deploy-scripts'
UPSTREAM_REPO="keegoid/$LDS_PROJECT.git"
GITHUB_USER='keegoid' #your GitHub username

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
echo
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
   echo "copy contents of id_rsa.pub to the SSH keys section of your GitHub account:"
   cat $HOME/.ssh/id_rsa.pub
fi

# linux-deploy-scripts repository
echo "Have you copied id_rsa.pub to the SSH keys section of your GitHub account?"
echo "If not, choose HTTPS for the clone operation when prompted."
read -p "Press enter when ready..."
LDS_DIRECTORY="$HOME/repos"
if [ -d $LDS_DIRECTORY ]; then
   echo "$LDS_DIRECTORY directory already exists"
else
   echo
   read -p "Press enter to create repos directory..."
   mkdir -p $LDS_DIRECTORY
   echo "made directory: $_"
fi

# change to repos directory
cd $LDS_DIRECTORY
echo "changing directory to $_"

# generate a blog template for Middleman
if [ -d "$LDS_DIRECTORY/$LDS_PROJECT" ]; then
   echo "$LDS_PROJECT directory already exists, skipping clone operation..."
else
   echo
   echo "Before proceeding, make sure to fork $UPSTREAM_REPO on GitHub to your own account."
   read -p "Press enter to clone $LDS_PROJECT from GitHub..."
   echo
   echo "Do you wish to clone using HTTPS or SSH (recommended)?"
   select hs in "HTTPS" "SSH"; do
      case $hs in
         "HTTPS") git clone https://github.com/$GITHUB_USER/$LDS_PROJECT.git;;
           "SSH") git clone git@github.com:$GITHUB_USER/$LDS_PROJECT.git;;
               *) echo "case not found..."
      esac
      break
   done
fi

# change to newly cloned directory
cd $LDS_PROJECT
echo "changing directory to $_"

if echo $UPSTREAM_REPO | grep -q $GITHUB_USER; then
   echo "no upstream repository exists"
else
   # assign the original repository to a remote called "upstream"
   if git config --list | grep -q $UPSTREAM_REPO; then
      echo "upstream repo already configured: https://github.com/$UPSTREAM_REPO"
   else
      echo
      read -p "Press enter to assign upstream repository..."
      git remote add upstream https://github.com/$UPSTREAM_REPO && echo "remote upstream added for https://github.com/$UPSTREAM_REPO"
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
