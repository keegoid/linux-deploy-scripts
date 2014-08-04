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

# install required programs
for app in $REQUIRED_PROGRAMS; do
   if rpm -qa | grep -q $app; then
      echo "$app was already installed"
   else
      echo
      read -p "Press enter to install $app..."
      yum -y install $app
   fi
done

# EPEL
echo
read -p "Press enter to test the EPEL install..."
if rpm -qa | grep -q epel
then
   echo "EPEL was already configured"
else
   read -p "Press enter to import the EPEL gpg key..."
   rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7
   # list imported gpg keys
   rpm -qa gpg*
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

if $SERVER_GO; then
   # install server programs
   for app in $SERVER_PROGRAMS; do
      if rpm -qa | grep -q $app; then
         echo "$app was already installed"
      else
         echo
         read -p "Press enter to install $app..."
         yum -y install $app
      fi
   done
fi

if $WORKSTATION_GO; then
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

   # install workstation programs
   for app in $WORKSTATION_PROGRAMS; do
      if rpm -qa | grep -q $app; then
         echo "$app was already installed"
      else
         echo
         read -p "Press enter to install $app..."
         yum -y install $app
      fi
   done
fi

echo "done with linux_update.sh"

