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
[ -d includes ] && source includes/km.lib || source km.lib

####################################################
# EDIT THESE VARIABLES WITH YOUR INFO
REAL_NAME='Keegan Mullaney'
EMAIL_ADDRESS='keegan@kmauthorized.com'
SSH_KEY_COMMENT='kma server'
GITHUB_USER='keegoid' #your GitHub username
####################################################

# upstream project name
UPSTREAM_PROJECT='linux-deploy-scripts'

# local repository location
REPOS=$(locate_repos)

# init variable
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

# install git
install_app "git"

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
clone_repo $UPSTREAM_PROJECT $SSH $REPOS $GITHUB_USER

# assign the original repository to a remote called "upstream"
merge_upstream_repo $UPSTREAM_PROJECT $SSH

script_name "done with "
echo "*********************************************"
echo "next: cd linux-deploy-scripts"
echo "then: configure and run setup.sh"
