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

# include functions library
source includes/_km.lib

####################################################
# EDIT THESE VARIABLES WITH YOUR INFO
REAL_NAME='Keegan Mullaney'
EMAIL_ADDRESS='keegan@kmauthorized.com'
SSH_KEY_COMMENT='kma server'
GITHUB_USER='keegoid' #your GitHub username
####################################################

# project info
UPSTREAM_PROJECT='linux-deploy-scripts'
UPSTREAM_REPO="keegoid/$UPSTREAM_PROJECT.git"

# local repository location
REPOS="$HOME/repos"
if [ -d $HOME/Dropbox ]; then
   REPOS="$HOME/Dropbox/Repos"
fi

# make repos directory if it doesn't exist
mkdir -pv $REPOS

# files
SSH_KEY="$HOME/.ssh/id_rsa"

# init option variables
HTTPS=false
SSH=false

echo
echo "Do you wish to use HTTPS or SSH for git operations?"
select hs in "HTTPS" "SSH"; do
   case $hs in
      "HTTPS") HTTPS=true;;
        "SSH") SSH=true;;
            *) echo "case not found..."
   esac
   break
done

# install git
if rpm -q "git"; then
   echo "git was already installed"
else
   echo
   read -p "Press enter to install git..."
   sudo yum -y install git
fi

# configure git
configure_git

# generate an RSA SSH keypair if none exists
if $SSH; then
   gen_ssh_keys $SSH_KEY_COMMENT
   echo
   echo "Have you copied id_rsa.pub (above) to the SSH keys section"
   echo "of your GitHub account?"
   echo
   read -p "Press enter when ready..."
fi

# change to repos directory
cd $REPOS
echo "changing directory to $_"

# clone the blog template for Middleman
if [ -d "$REPOS/$UPSTREAM_PROJECT" ]; then
   echo "$UPSTREAM_PROJECT directory already exists, skipping clone operation..."
else
   echo
   echo "***IMPORTANT***"
   echo "Before proceeding, make sure to fork $UPSTREAM_REPO"
   echo "on GitHub to your account."
   echo
   read -p "Press enter to clone $UPSTREAM_PROJECT from your GitHub account..."
   if $HTTPS; then
      git clone https://github.com/$GITHUB_USER/$UPSTREAM_PROJECT.git
   else
      git clone git@github.com:$GITHUB_USER/$UPSTREAM_PROJECT.git
   fi
fi

# change to newly cloned directory
cd $UPSTREAM_PROJECT
echo "changing directory to $_"

# check if an upstream repo exists
if echo $UPSTREAM_REPO | grep -q $GITHUB_USER; then
   echo "no upstream repository exists"
else
   # assign the original repository to a remote called "upstream"
   if git config --list | grep -q $UPSTREAM_REPO; then
      echo "upstream repo already configured: https://github.com/$UPSTREAM_REPO"
   else
      echo
      read -p "Press enter to assign upstream repository..."
      if $HTTPS; then
         git remote add upstream https://github.com/$UPSTREAM_REPO && echo "remote upstream added for https://github.com/$UPSTREAM_REPO"
      else
         git remote add upstream git@github.com:$UPSTREAM_REPO && echo "remote upstream added for git@github.com:$UPSTREAM_REPO"
      fi
   fi

   # pull in changes not present in local repository, without modifying local files
   echo
   read -p "Press enter to fetch changes from upstream repository..."
   git fetch upstream
   echo "upstream fetch done"

   # merge any changes fetched into local working files
   echo
   read -p "Press enter to merge changes..."
   git merge upstream/master

   # or combine fetch and merge with:
   #git pull upstream master
fi

script_name "done with "
echo "*********************************************"
echo "next: cd linux-deploy-scripts"
echo "then: configure and run setup.sh"
