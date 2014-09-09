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
          *) echo "case not found, try again..."
             continue;;
   esac
   break
done

########## YUM ##########

# install Node.js for running the local web server and npm for the CLI
install_app 'nodejs npm' 'epel'

########## GEM ##########

# install Ruby and RubyGems
install_ruby

# start using rvm
source_rvm

# update gem package manager
echo
read -p "Press enter to update the gem package manager..."
gem update --system

# install necessary gems
install_gem 'middleman middleman-blog middleman-syntax middleman-livereload foundation'

# update gems
echo
read -p "Press enter to update gems..."
gem update

# view installed middleman gems
read -p "Press enter to view installed middleman gems..."
gem list middleman

########## NPM ##########

read -p "Press enter to install bower and grunt-cli..."
install_npm 'bower grunt-cli'

read -p "Press enter to view installed npm packages..."
npm ls

# Middleman web root
#mkdir -pv /var/www/$MIDDLEMAN_DOMAIN/public_html
#chown -cR $USER_NAME:$USER_NAME /var/www/$MIDDLEMAN_DOMAIN

# change to repos directory
cd $REPOS
echo "changing directory to $_"

read -p "Fork keegoid/$MM_UPSTREAM_PROJECT and rename to $MIDDLEMAN_DOMAIN before proceeding..."

# clone the Middleman project base
clone_repo $GITHUB_USER $MIDDLEMAN_DOMAIN $REPOS $SSH

# assign upstream repository if one exists
set_remote_repo $GITHUB_USER $MM_UPSTREAM_PROJECT true $SSH

# git commit and push if necessary
commit_and_push

# update gems
echo
read -p "Press enter to update gems..."
gem update
