#!/bin/bash
echo "*********************************************"
echo "* A CentOS 7.0 x64 deployment script to      "
echo "* install Middleman and dependencies         "
echo "*                                            "
echo "* Author : Keegan Mullaney                   "
echo "* Company: KM Authorized LLC                 "
echo "* Website: http://kmauthorized.com           "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*********************************************"

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

# install Node.js for running the local web server and npm for the CLI
if rpm -qa | grep -q nodejs; then
   echo "nodejs was already installed"
else
   echo
   read -p "Press enter to install nodejs and npm..."
   yum --enablerepo=epel -y install nodejs npm
fi

# install Ruby and RubyGems
echo
read -p "Press enter to install ruby and rubygems..."
if ruby -v | grep -q "ruby $RUBY_VERSION"; then
   echo "ruby is already installed"
else
   curl -L $RUBY_URL | bash -s stable --ruby=$RUBY_VERSION
fi

# start using rvm
echo
read -p "Press enter to start using rvm..."
if cat $HOME/.bashrc | grep -q "/usr/local/rvm/scripts/rvm"; then
   echo "already added rvm to .bashrc"
else
   echo "source /usr/local/rvm/scripts/rvm" >> $HOME/.bashrc
   source /usr/local/rvm/scripts/rvm && echo "rvm sourced and added to .bashrc"
fi

echo
read -p "Press enter to update the gem package manager..."
gem update --system

# install Middleman
if $(gem list middleman -i); then
   echo "middleman gem already installed"
else
   echo
   read -p "Press enter to install middleman..."
   gem install middleman
fi

# Middleman web root
#mkdir -pv /var/www/$MIDDLEMAN_DOMAIN/public_html
#chown -R $USER_NAME:$USER_NAME /var/www/$MIDDLEMAN_DOMAIN
#echo "set permissions to $USER_NAME"

# local repository location
MM_REPOS="/home/$USER_NAME/repos"
if [ -d /home/$USER_NAME/Dropbox ]; then
   MM_REPOS="/home/$USER_NAME/Dropbox/Repos"
elif [ -d $HOME/Dropbox ]; then
   MM_REPOS=$REPOS
fi

# make repos directory if it doesn't exist
mkdir -pv $MM_REPOS

# change to repos directory
cd $MM_REPOS
echo "changing directory to $_"

# clone the blog template for Middleman
if [ -d "$MM_REPOS/$MIDDLEMAN_DOMAIN" ]; then
   echo "$MIDDLEMAN_DOMAIN directory already exists, skipping clone operation..."
else
   echo
   echo "***IMPORTANT***"
   echo "Before proceeding, make sure to fork $UPSTREAM_REPO"
   echo "and change the project name to $MIDDLEMAN_DOMAIN on GitHub"
   echo
   read -p "Press enter to clone $MIDDLEMAN_DOMAIN from your GitHub account..."
   if $HTTPS; then
      git clone https://github.com/$GITHUB_USER/$MIDDLEMAN_DOMAIN.git
   else
      git clone git@github.com:$GITHUB_USER/$MIDDLEMAN_DOMAIN.git
   fi
fi

# change to newly cloned directory
cd $MIDDLEMAN_DOMAIN
echo "changing directory to $_"

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

# update gems
echo
read -p "Press enter to update gems..."
gem update

# print git status
read -p "Press enter to view git status..."
STATUS=git status

if cat $STATUS | grep -q 'nothing to commit, working directory clean'; then
   echo "skipping commit..."
else
   # commit changes with git
   read -p "Press enter to commit changes..."
   git commit -am "first commit by $GITHUB_USER"

   # push commits to your remote repository (GitHub)
   read -p "Press enter to push changes to your remote repository (GitHub)..."
   git push
fi

# set permissions
echo
read -p "Press enter to change to set permissions..."
chown -R $USER_NAME:$USER_NAME $MM_REPOS
echo "set permissions on $MM_REPOS to $USER_NAME"

ME="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
echo "done with $ME"
