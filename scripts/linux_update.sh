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
   # make directory for rpm gpg public keys
   mkdir -p "$HOME/rpm_keys"
   cd $_
   echo "changing directories to $_"
   # download keyfile
   wget -nc http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7
   KEYFILE="$HOME/rpm_keys/RPM-GPG-KEY-EPEL-7"
   # get key id
   KEYID=$(echo $(gpg --throw-keyids < $KEYFILE) | cut --characters=11-18 | tr [A-Z] [a-z])
   # import key if it doesn't exist
   if ! rpm -q gpg-pubkey-$KEYID > /dev/null 2>&1; then
      echo "Installing GPG public key with ID $KEYID from $KEYFILE..."
      rpm --import $KEYFILE
   fi
   # list imported gpg keys and highlight the recently added one
   rpm -qa gpg*
   cd
   echo "changing directories to $HOME"   # test the rpm install
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

