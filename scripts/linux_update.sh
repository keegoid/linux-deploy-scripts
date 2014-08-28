#!/bin/bash
echo "*********************************************"
echo "* A CentOS 7.0 x64 deployment script to      "
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
   if rpm -qa | grep -qw $app; then
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
if rpm -qa | grep -qw "epel-release"
then
   echo "EPEL was already configured"
else
   read -p "Press enter to import the EPEL gpg key..."
   # import rpm key
   ImportPublicKey $EPEL_KEY
   # list imported gpg keys
   rpm -qa gpg*
   # test the rpm install
   #echo
   #read -p "Press enter to test the EPEL install..."
   #rpm -ivh --test $EPEL_URL
   # run the install
   echo
   read -p "Press enter to continue with EPEL install..."
   rpm -ivh $EPEL_URL
   # test new repo
   echo
   read -p "Press enter to test the new repo..."
   yum check-update
fi

if $SERVER_GO; then
   # install server programs
   for app in $SERVER_PROGRAMS; do
      if rpm -qa | grep -qw $app; then
         echo "$app was already installed"
      else
         echo
         read -p "Press enter to install $app..."
         yum -y install $app
      fi
   done
fi

if $WORKSTATION_GO; then
   # install workstation programs
   for app in $WORKSTATION_PROGRAMS; do
      if rpm -qa | grep -qw $app; then
         echo "$app was already installed"
      else
         echo
         read -p "Press enter to install $app..."
         yum -y install $app
      fi
   done
fi
