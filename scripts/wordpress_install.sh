#!/bin/bash
echo "*********************************************"
echo "* A CentOS 7.0 deployment script to          "
echo "* install WordPress and its MySql database   "
echo "*                                            "
echo "* Author : Keegan Mullaney                   "
echo "* Company: KM Authorized LLC                 "
echo "* Website: http://kmauthorized.com           "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*********************************************"

# get domain name and WordPress database info
read -e -p "Enter a WordPress database name to use for $WORDPRESS_DOMAIN: " DATABASE
read -e -p "Enter a WordPress database user to use for $WORDPRESS_DOMAIN: " DB_USER
read -e -p "Enter a WordPress database password to use for $WORDPRESS_DOMAIN: " DB_PASSWD

# change to repos directory
cd /home/$USER_NAME/repos
echo "changing directory to: $_"

# grab latest Wordpress and setup mysql database for WordPress
echo
read -p "Press enter to get the latest WordPress..."
wget -nc http://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz

# create file structure for each WordPress site
echo
read -p "Press enter to create WordPress sites..."
cp wordpress/wp-config-sample.php wordpress/wp-config.php
sed -i.bak -e "s|database_name_here|$DATABASE|" -e "s|username_here|$DB_USER|" -e "s|password_here|$DB_PASSWD|" wordpress/wp-config.php
mkdir -p /var/www/$WORDPRESS_DOMAIN/public_html
cp -r wordpress/* $_
echo "made directory: $_ and copied /home/$USER_NAME/repos/wordpress/* to it"

# create a sample "testphp.php" file in WordPress document root folder and append the lines as shown below:
echo
read -p "Press enter to create a test php page..."
echo "<?php phpinfo();?>" > /var/www/$WORDPRESS_DOMAIN/public_html/testphp.php
echo "WordPress for $WORDPRESS_DOMAIN has been configured"

# change to deploy directory
cd /home/$USER_NAME/deploy
echo "changing directory to: $_"

# create WordPress databases, users and passwords
read -p "Press enter to configure mysql..."
echo
read -e -p "Enter the root mysql password: " MYSQL_PASSWD
mysql -u root -p$MYSQL_PASSWD -Bse "CREATE DATABASE $DATABASE;CREATE USER $DB_USER;SET PASSWORD FOR $DB_USER= PASSWORD(\"$DB_PASSWD\");GRANT ALL PRIVILEGES ON $DATABASE.* TO $DB_USER IDENTIFIED BY \"$DB_PASSWD\";FLUSH PRIVILEGES;"
echo
echo "mysql for $WORDPRESS_DOMAIN has been configured"
echo
echo "done with wordpress_install.sh"

