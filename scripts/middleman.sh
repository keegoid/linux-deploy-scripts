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

SSH=false

# use SSH?
echo
echo "Do you wish to use SSH for git operations (no uses HTTPS)?"
select yn in "Yes" "No"; do
   case $yn in
      "Yes") SSH=true;;
       "No") break;;
          *) echo "case not found..."
   esac
   break
done

# install Node.js for running the local web server and npm for the CLI
if rpm -qa | grep -q "nodejs"; then
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
source_rvm

echo
read -p "Press enter to update the gem package manager..."
gem update --system

# install Middleman
install_gem "middleman"

# Middleman web root
#mkdir -pv /var/www/$MIDDLEMAN_DOMAIN/public_html
#chown -R $USER_NAME:$USER_NAME /var/www/$MIDDLEMAN_DOMAIN
#echo "set permissions to $USER_NAME"

# change to repos directory
cd $REPOS
echo "changing directory to $_"

# clone the blog template for Middleman
clone_repo $UPSTREAM_PROJECT $SSH $REPOS $GITHUB_USER

# create a new branch for changes (keeping master for upstream changes)
create_branch $MIDDLEMAN_DOMAIN

# assign the original repository to a remote called "upstream"
merge_upstream_repo $UPSTREAM_PROJECT $SSH

# git commit and push if necessary
commit_and_push $GITHUB_USER

# update gems
echo
read -p "Press enter to update gems..."
gem update
