#!/bin/bash
echo "*********************************************"
echo "* A CentOS 7.0 deployment script to          "
echo "* update Linux, install needed programs and  "
echo "* repos like EPEL and RPMforge               "
echo "*                                            "
echo "* Author : Keegan Mullaney                   "
echo "* Company: KM Authorized LLC                 "
echo "* Website: http://kmauthorized.com           "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*********************************************"

# update programs maintained by the package manager
read -p "Press enter to update Linux..."
yum -y update

# check for any available upgrades
echo
read -p "Press enter to upgrade Linux..."
yum -y upgrade

# download files in the console
echo
read -p "Press enter to install wget..."
yum -y install wget

# help manual pages
echo
read -p "Press enter to install man..."
yum -y install man

# for viewing webpages in the console
echo
read -p "Press enter to install lynx..."
yum -y install lynx

# EPEL
echo
read -p "Press enter to test the EPEL install..."
if rpm -qa | grep -q epel
then
   echo "EPEL was already configured"
else
#   read -p "Press enter to import the EPEL gpg key..."
   # key id 352c64e5 is not yet available for download
#   rpm --import https://fedoraproject.org/static/352c64e5.txt
   # list imported gpg keys
#   rpm -qa gpg*
   # test the rpm install
   #echo
   #read -p "Press enter to test the EPEL install..."
   #rpm -ivh --test http://dl.fedoraproject.org/pub/epel/beta/7/x86_64/epel-release-${EPEL_VERSION}.noarch.rpm
   # run the install
   echo
   read -p "Press enter to continue with EPEL install..."
   rpm -ivh http://dl.fedoraproject.org/pub/epel/beta/7/x86_64/epel-release-${EPEL_VERSION}.noarch.rpm
   # test new repo
   echo
   read -p "Press enter to test the new repo..."
   yum check-update
fi

if $WORKSTATION_GO; then
   # install a good graphical code/text editor
   echo
   read -p "Press enter to install gedit..."
   yum -y install gedit

   # install a good file syncing tool that can sync between two local folders
#   echo
#   read -p "Press enter to install unison..."
#   yum -y install unison

   # install k3b for burning iso images to disc
   echo
   read -p "Press enter to install k3b..."
   yum -y install k3b

   # install support for mounting NTFS
   echo
   read -p "Press enter to install ntfs-3g..."
   yum -y install ntfs-3g

   # install file version and control system
   echo
   read -p "Press enter to install git..."
   yum -y install git

   # configure git
   echo
   read -p "Press enter to configure git..."
   # specify a user
   git config --global user.name ${REAL_NAME}
   git config --global user.email ${EMAIL_ADDRESS}
   # select a text editor
   git config --global core.editor vi
   # add some SVN-like aliases
   git config --global alias.st status
   git config --global alias.co checkout
   git config --global alias.br branch
   git config --global alias.up rebase
   git config --global alias.ci commit
   # create a global .gitignore file
   echo -e "# global list of file types to ignore \
\n \
\n# gedit temp files \
\n*~" > /home/$USER_NAME/.gitignore
   git config --global core.excludesfile /home/$USER_NAME/.gitignore
   echo "git was configured"

   # RPMforge
   echo
   read -p "Press enter to test the RPMforge install..."
   if rpm -qa | grep -q rpmforge
   then
      echo "RPMforge was already configured"
   else
      # install rpmforge if not already installed (required for keychain)
      read -p "Press enter to import the RPMforge gpg key..."
      rpm --import http://dag.wieers.com/rpm/packages/RPM-GPG-KEY.dag.txt
      # list imported gpg keys
      rpm -qa gpg*
      # run the install
      echo
      read -p "Press enter to continue with RPMforge install..."
      rpm -Uvh http://apt.sw.be/redhat/el7/en/x86_64/dag/RPMS/rpmforge-release-${RPMFORGE_VERSION}.el7.rf.x86_64.rpm

      # test new repo
      echo
      read -p "Press enter to test the new repo..."
      yum check-update
   fi

   # install Keychain to manage the SSH-agent
   echo
   read -p "Press enter to install keychain..."
   yum -y install keychain

   # install a good graphical code/text editor
#   echo
#   read -p "Press enter to install vim-X11..."
#   yum -y install vim-X11

fi
echo
echo "done with linux_update.sh"

