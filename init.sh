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
echo "*                                            "
echo "* ---run instructions---                     "
echo "* set execute permissions on this script:    "
echo "* chmod +x init.sh                           "
echo "* dos2unix -k init.sh                        "
echo "* run before setup.sh as root user: su root  "
echo "* ./init.sh                                  "
echo "*********************************************"

# save current directory
WORKING_DIR="$PWD"

# make temp library directory
mkdir -pv "libtmp"

# make sure curl is installed
hash curl 2>/dev/null || { echo >&2 "curl will be installed."; yum -y install curl; }

# download necessary files
read -p "Press enter to download three library files to libtmp..."
cd "libtmp"
echo "changing directory to $_"
curl -kfsSLO https://raw.githubusercontent.com/keegoid/linux-deploy-scripts/master/includes/base.lib
curl -kfsSLO https://raw.githubusercontent.com/keegoid/linux-deploy-scripts/master/includes/software.lib
curl -kfsSLO https://raw.githubusercontent.com/keegoid/linux-deploy-scripts/master/includes/git.lib && echo "done with downloads"
cd -
echo "changing directory back to $WORKING_DIR"

read -p "Press enter to continue..."
source config.sh

# init
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
cp -fv "$WORKING_DIR/config.sh" .

# git commit and push if necessary
commit_and_push $GITHUB_USER

# set ownership
echo
chown -cR $USER_NAME:$USER_NAME "$REPOS"

# remove temporary files
rm -rf "$WORKING_DIR/libtmp"

echo
script_name "          done with "
echo "*********************************************"
echo "next: cd $REPOS/$UPSTREAM_PROJECT"
echo "then: ./setup.sh"
