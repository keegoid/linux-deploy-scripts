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

####################################################
# EDIT THESE VARIABLES WITH YOUR INFO
USER_NAME='kmullaney' #Linux user you will/already use
REAL_NAME='Keegan Mullaney'
EMAIL_ADDRESS='keegan@kmauthorized.com'
SSH_KEY_COMMENT='kma server'
GITHUB_USER='keegoid' #your GitHub username
####################################################

# upstream project name
UPSTREAM_PROJECT='linux-deploy-scripts'

# init
DROPBOX=false
SSH=false

# library files
LIBS='linuxkm.lib gitkm.lib'

# source function libraries
for lib in $LIBS; do
   { source "$lib" > /dev/null 2>&1 && echo "sourced: $lib" || echo "can't find: $lib"; }
done

# check to make sure script is being run as root
is_root && echo "root user detected, proceeding..." || die "\033[40m\033[1;31mERROR: root check FAILED (you must be root to use this script). Quitting...\033[0m\n"

# use Dropbox?
echo
echo "Do you wish to use Dropbox for your repositories?"
select yn in "Yes" "No"; do
   case $yn in
      "Yes") DROPBOX=true;;
       "No") break;;
          *) echo "case not found..."
   esac
   break
done

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
if $SSH; then
   gen_ssh_keys "/home/$USER_NAME/.ssh" $SSH_KEY_COMMENT
   echo
   echo "Have you copied id_rsa.pub (above) to the SSH keys section"
   echo "of your GitHub account?"
   select yn in "Yes" "No"; do
      case $yn in
         "Yes") break;;
          "No") echo "Copy the contents of id_rsa.pub (printed below) to the SSH keys section"
                echo "of your GitHub account."
                echo "Highlight the text with your mouse and press ctrl+shift+c to copy."
                echo
                cat "/home/$USER_NAME/.ssh/id_rsa.pub";;
             *) echo "case not found..."
      esac
      break
   done
   echo
   read -p "Press enter when ready..."
fi

# change to repos directory
cd $REPOS
echo "changing directory to $_"

# clone the blog template for Middleman
clone_repo $UPSTREAM_PROJECT $SSH $REPOS $GITHUB_USER

# assign the original repository to a remote called "upstream"
merge_upstream_repo $UPSTREAM_PROJECT $SSH $GITHUB_USER

# git commit and push if necessary
commit_and_push $GITHUB_USER

echo
script_name "          done with "
echo "*********************************************"
echo "next: cd $REPOS/$UPSTREAM_PROJECT"
echo "then: configure and run setup.sh"
