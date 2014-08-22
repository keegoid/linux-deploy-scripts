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

# check to make sure script is being run as root
if [ "$(id -u)" != "0" ]; then
   printf "\033[40m\033[1;31mERROR: Root check FAILED (you MUST be root to use this script)! Quitting...\033[0m\n" >&2
   exit 1
fi

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

# switch to non-root user
su $USER_NAME

# local repository location
REPOS="$HOME/repos"
if [ -d $HOME/Dropbox ]; then
   REPOS="$HOME/Dropbox/Repos"
fi
PROJECT_DIRECTORY="$REPOS/$UPSTREAM_PROJECT"

# switch back to root user
exit

# make repos directory if it doesn't exist
mkdir -pv $REPOS

# files
SSH_KEY="$HOME/.ssh/id_rsa"
GIT_IGNORE="$HOME/.gitignore"

# init option variables
HTTPS=false
SSH=false

echo
echo "Do you wish to use HTTPS or SSH for git operations?"
select yn in "HTTPS" "SSH"; do
   case $yn in
      "HTTPS") HTTPS=true;;
        "SSH") SSH=true;;
            *) echo "case not found..."
   esac
   break
done

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
   # set default push and pull behavior to the old method
   git config --global push.default matching
   git config --global pull.default matching
   # create a global .gitignore file
   echo -e "# global list of file types to ignore \
\n \
\n# gedit temp files \
\n*~" > $GIT_IGNORE
   git config --global core.excludesfile $GIT_IGNORE
   echo "git was configured"
fi

if $SSH; then
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
fi

# linux-deploy-scripts repository
if $SSH; then
   echo
   echo "Have you copied id_rsa.pub (above) to the SSH keys section"
   echo "of your GitHub account?"
fi
echo
read -p "Press enter when ready..."

# change to repos directory
cd $REPOS
echo "changing directory to $_"

# clone the blog template for Middleman
if [ -d "$PROJECT_DIRECTORY" ]; then
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
      git clone git@github.com:$GITHUB_USER/$UPSTREAM_PROJECT.git;;
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
   git fetch upstream master
   echo "upstream fetch done"

   # merge any changes fetched into local working files
   echo
   read -p "Press enter to merge changes..."
   git merge upstream/master
fi

ME="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
echo "done with $ME"
echo "now you can configure and run setup.sh"
