#!/bin/bash
echo "*********************************************"
echo "* A CentOS 7.0 x64 deployment script to      "
echo "* install WordPress and its MySql database   "
echo "*                                            "
echo "* Author : Keegan Mullaney                   "
echo "* Company: KM Authorized LLC                 "
echo "* Website: http://kmauthorized.com           "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*********************************************"

# get domain name and WordPress database info
echo "***IMPORTANT***"
echo "Don't press enter yet, user input requested..."
read -e -p "Enter a WordPress database name to use for $WORDPRESS_DOMAIN: " DATABASE
read -e -p "Enter a WordPress database user to use for $WORDPRESS_DOMAIN: " DB_USER
read -e -p "Enter a WordPress database password to use for $WORDPRESS_DOMAIN: " DB_PASSWD

# make repos directory if it doesn't exist and change to it
cd $REPOS
echo "changing directory to: $_"

# grab latest Wordpress and setup mysql database for WordPress
get_software $WORDPRESS_URL

# create file structure for each WordPress site
read -p "Press enter to create WordPress sites..."
cp wordpress/wp-config-sample.php wordpress/wp-config.php
sed -i.bak -e "s|database_name_here|$DATABASE|" -e "s|username_here|$DB_USER|" -e "s|password_here|$DB_PASSWD|" wordpress/wp-config.php
mkdir -pv /var/www/$WORDPRESS_DOMAIN/public_html
cp -r wordpress/* $_
echo "copied $REPOS/wordpress/* to $_"

# create a sample "testphp.php" file in WordPress document root folder and append the lines as shown below:
echo
read -p "Press enter to create a test php page..."
echo "<?php phpinfo();?>" > /var/www/$WORDPRESS_DOMAIN/public_html/testphp.php
echo "WordPress for $WORDPRESS_DOMAIN has been configured"

# create WordPress databases, users and passwords
echo
read -p "Press enter to configure mysql..."
echo
read -e -p "Enter the root mysql password: " MYSQL_PASSWD
mysql -u root -p$MYSQL_PASSWD -Bse "CREATE DATABASE $DATABASE;CREATE USER $DB_USER;SET PASSWORD FOR $DB_USER= PASSWORD(\"$DB_PASSWD\");GRANT ALL PRIVILEGES ON $DATABASE.* TO $DB_USER IDENTIFIED BY \"$DB_PASSWD\";FLUSH PRIVILEGES;"
echo
echo "mysql for $WORDPRESS_DOMAIN has been configured"
