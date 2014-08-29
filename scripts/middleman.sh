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

# upstream project name
UPSTREAM_PROJECT='middleman-html5-foundation'

# init
SSH=false

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
echo
read -p "Press enter to create a git branch for your site at $MIDDLEMAN_DOMAIN..."
git checkout -b $MIDDLEMAN_DOMAIN

# some work and some commits happen
# some time passes
#git fetch upstream
#git rebase upstream/master or git rebase interactive upstream/master

read -p "Press enter to push changes and set branch upstream in config..."
git push -u origin $MIDDLEMAN_DOMAIN

read -p "Press enter to checkout the master branch again..."
git checkout master

echo
echo "above could also be done with:"
echo "git branch $MIDDLEMAN_DOMAIN"
echo "git push origin $MIDDLEMAN_DOMAIN"
echo "git branch -u origin/$MIDDLEMAN_DOMAIN $MIDDLEMAN_DOMAIN"

echo
echo "*************************************************************************"
echo "* - use the $MIDDLEMAN_DOMAIN branch to make your own site               "
echo "* - use the master branch to fetch and merge changes from the remote     "
echo "* upstream repo: keegoid/$UPSTREAM_PROJECT.git                           "
echo "*************************************************************************"

# assign the original repository to a remote called "upstream"
merge_upstream_repo $UPSTREAM_PROJECT $SSH

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
chown -R $USER_NAME:$USER_NAME $REPOS/$UPSTREAM_PROJECT
echo "set permissions on $REPOS to $USER_NAME"
