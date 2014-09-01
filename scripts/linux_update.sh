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
install_app $REQUIRED_PROGRAMS

# EPEL
install_repo "epel-release" $EPEL_URL $EPEL_KEY

if $SERVER_GO; then
   # install server programs
   install_app $SERVER_PROGRAMS
fi

if $WORKSTATION_GO; then
   # install workstation programs
   install_app $WORKSTATION_PROGRAMS
fi

if $DROPBOX; then
   install_repo "Dropbox" $DROPBOX_URL
fi
