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

# make sure curl is installed
hash curl 2>/dev/null || { echo >&2 "curl will be installed."; yum -y install curl; }

# download necessary files
read -p "Press enter to download three library files to this directory..."
curl -kfsSLO https://raw.githubusercontent.com/keegoid/linux-deploy-scripts/master/includes/base.lib
curl -kfsSLO https://raw.githubusercontent.com/keegoid/linux-deploy-scripts/master/includes/software.lib
curl -kfsSLO https://raw.githubusercontent.com/keegoid/linux-deploy-scripts/master/includes/git.lib && echo "done with downloads"

read -p "Press enter to continue..."
source config.sh

# init
SSH=false
WORKING_DIR="$PWD"

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

# create Linux non-root user
echo
read -p "Press enter to create user \"$USER_NAME\" if it doesn't exist..."
/usr/sbin/adduser $USER_NAME

# local repository location
echo
REPOS=$(locate_repos $USER_NAME $DROPBOX)
echo "repository location: $REPOS"

# install git
install_app "git"

# configure git
configure_git "$REAL_NAME" "$EMAIL_ADDRESS"

# generate an RSA SSH keypair if none exists
gen_ssh_keys "/home/$USER_NAME/.ssh" $SSH_KEY_COMMENT $SSH

# change to repos directory
cd $REPOS
echo "changing directory to $_"

# clone the blog template for Middleman
clone_repo $UPSTREAM_PROJECT $SSH $REPOS $GITHUB_USER

# assign the original repository to a remote called "upstream"
merge_upstream_repo $UPSTREAM_PROJECT $SSH $GITHUB_USER

# copy config.sh to repository location
echo
cp -rf "$WORKING_DIR/config.sh" . && echo "copied config.sh to $PWD"

# git commit and push if necessary
commit_and_push $GITHUB_USER

# set ownership
echo
chown -R $USER_NAME:$USER_NAME "$REPOS"
echo "set permissions on $_ to $USER_NAME"

# remove temporary files
rm -f "$WORKING_DIR/linuxkm.lib"
rm -f "$WORKING_DIR/gitkm.lib"

echo
script_name "          done with "
echo "*********************************************"
echo "next: cd $REPOS/$UPSTREAM_PROJECT"
echo "then: ./setup.sh"
