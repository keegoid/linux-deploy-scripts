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
   # install epel if not already installed (required for Nginx and ntfs-3g)
   # test the rpm install
   #rpm -Uvh --test http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
   # import the gpg key
   #echo
   read -p "Press enter to import the EPEL gpg key..."
   rpm --import https://fedoraproject.org/static/0608B895.txt
   # list imported gpg keys
   rpm -qa gpg*
   # test the rpm install again
   #echo
   #read -p "Press enter to test the EPEL install..."
   #rpm -Uvh --test http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
   # run the install
   echo
   read -p "Press enter to continue with EPEL install..."
   rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm

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

   # install a good graphical code/text editor
#   echo
#   read -p "Press enter to install vim-X11..."
#   yum -y install vim-X11

   # install a good file syncing tool that can sync between two local folders
   echo
   read -p "Press enter to install unison240..."
   yum -y install unison240

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
      rpm -Uvh http://apt.sw.be/redhat/el6/en/x86_64/dag/RPMS/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm

      # test new repo
      echo
      read -p "Press enter to test the new repo..."
      yum check-update
   fi

   # install Keychain to manage the SSH-agent
   echo
   read -p "Press enter to install keychain..."
   yum -y install keychain
fi
echo
echo "done with linux_update.sh"

