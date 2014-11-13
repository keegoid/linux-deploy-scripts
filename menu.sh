#!/bin/bash
echo "# -------------------------------------------"
echo "# A CentOS 7.0 x64 deployment script for     "
echo "# DigitalOcean Droplets or your workstation. "
echo "# ---                                        "
echo "# Updates Linux, installs LEMP stack,        "
echo "# configures Nginx with ngx_cache_purge and  "
echo "# installs WordPress and/or Middleman.       "
echo "#                                            "
echo "# Author : Keegan Mullaney                   "
echo "# Company: KM Authorized LLC                 "
echo "# Website: http://kmauthorized.com           "
echo "#                                            "
echo "# MIT: http://kma.mit-license.org            "
echo "#                                            "
echo "# ---run instructions---                     "
echo "# set execute permissions on this script:    "
echo "# chmod +x setup.sh                          "
echo "# dos2unix -k setup.sh                       "
echo "# run after init.sh as root user: su root    "
echo "# ./setup.sh                                 "
echo "# -------------------------------------------"

source config.sh

# local repository location
echo
REPOS=$(locate_repos $USER_NAME $DROPBOX)
echo "repository location: $REPOS"

# set versions (which also sets download URLs)
set_software_versions 'EPEL REMI NGINX OPENSSL ZLIB PCRE FRICKLE RUBY'

# init option variables
SERVER_GO=false
WORKSTATION_GO=false
SSH_GO=false
FIREWALL_GO=false
ALIASES_GO=false
LINUX_UPDATE_GO=false
LEMP_GO=false
WORDPRESS_GO=false
MIDDLEMAN_GO=false
NGINX_CONFIG_GO=false
SWAP_GO=false

# collect user inputs to determine which sections of this script to execute
echo
echo "Is this a server or workstation deployment?"
select sw in "Server" "Workstation" "Quit"; do
   case $sw in
           "Server") SERVER_GO=true;;
      "Workstation") WORKSTATION_GO=true;;
             "Quit") echo "quiting..."
                     exit 0;;
                  *) echo "case not found, try again..."
                     continue;;
   esac
   break
done

# both servers and workstations need a firewall and EPEL
echo
echo "Do you wish to run the firewall script?"
select yn in "Yes" "No"; do
   case $yn in
      "Yes") FIREWALL_GO=true;;
       "No") break;;
          *) echo "case not found, try again..."
             continue;;
   esac
   break
done
echo
echo "Do you wish to add useful bash shell aliases for new SSH user?"
select yn in "Yes" "No"; do
   case $yn in
      "Yes") ALIASES_GO=true;;
       "No") break;;
          *) echo "case not found, try again..."
             continue;;
   esac
   break
done
echo
echo "Do you wish to update Linux and install basic programs?"
select yn in "Yes" "No"; do
   case $yn in
      "Yes") LINUX_UPDATE_GO=true;;
       "No") break;;
          *) echo "case not found, try again..."
             continue;;
   esac
   break
done

if $SERVER_GO; then
   echo
   echo "Do you wish to configure SSH and disable the root user?"
   select yn in "Yes" "No"; do
      case $yn in
         "Yes") SSH_GO=true;;
          "No") break;;
             *) echo "case not found, try again..."
                continue;;
      esac
      break
   done
   echo
   echo "Do you wish to install the LEMP stack?"
   select yn in "Yes" "No"; do
      case $yn in
         "Yes") LEMP_GO=true;;
          "No") break;;
             *) echo "case not found, try again..."
                continue;;
      esac
      break
   done
   echo
   echo "Do you wish to install WordPress?"
   select yn in "Yes" "No"; do
      case $yn in
         "Yes") WORDPRESS_GO=true;;
          "No") break;;
             *) echo "case not found, try again..."
                continue;;
      esac
      break
   done
   echo
   echo "Do you wish to configure Nginx?"
   select yn in "Yes" "No"; do
      case $yn in
         "Yes") NGINX_CONFIG_GO=true;;
          "No") break;;
             *) echo "case not found, try again..."
                continue;;
      esac
      break
   done
   echo
   echo "Do you wish to add a swap file?"
   select yn in "Yes" "No"; do
      case $yn in
         "Yes") SWAP_GO=true;;
          "No") break;;
             *) echo "case not found, try again..."
                continue;;
      esac
      break
   done
fi

if $WORKSTATION_GO; then
   echo
   echo "Do you wish to install Middleman?"
   select yn in "Yes" "No"; do
      case $yn in
         "Yes") MIDDLEMAN_GO=true;;
          "No") break;;
             *) echo "case not found, try again..."
                continue;;
      esac
      break
   done
fi

echo
echo "********************************"
echo "SECTION 1: USERS & SECURITY     "
echo "********************************"

if $SERVER_GO && $SSH_GO; then
   # set SSH port and client alive interval so SSH session doesn't quit so fast,
   # add public SSH key and restrict root user access
   run_script server_ssh.sh
else
   echo
   echo "skipping SSH..."
fi

if $FIREWALL_GO; then
   # setup firewall rules
   run_script firewalld.sh
else
   echo "skipping firewall..."
fi

if $ALIASES_GO; then
   # add useful aliases for new SSH user
   run_script aliases.sh
else
   echo "skipping aliases..."
fi

echo
echo "********************************"
echo "SECTION 2: INSTALLS & UPDATES   "
echo "********************************"

if $LINUX_UPDATE_GO; then
   # LINUX (L)
   run_script linux_update.sh
else
   echo
   echo "skipping Linux update..."
fi

echo
echo "********************************"
echo "SECTION 3: LEMP                 "
echo "********************************"

if $LEMP_GO; then 
   # NGINX (E), MYSQL (M), PHP (P)
   run_script lemp.sh
else
   echo
   echo "skipping LEMP install..."
fi

echo
echo "********************************"
echo "SECTION 4: WEBSITE PLATFORMS    "
echo "********************************"

if $WORDPRESS_GO; then
   # install WordPress and its MySql database
   run_script wordpress_install.sh
else
   echo
   echo "skipping WordPress install..."
fi

if $MIDDLEMAN_GO; then
   # install Ruby, RubyGems, Middleman, Redcarpet and Rouge
   run_script middleman.sh
else
   echo "skipping Middleman install..."
fi

echo
echo "********************************"
echo "SECTION 5: NGINX CONFIG         "
echo "********************************"

if $NGINX_CONFIG_GO; then
   # configure nginx with fastcgi_cache and cache purging
   run_script nginx_config.sh
else
   echo
   echo "skipping nginx config..."
fi

echo
echo "********************************"
echo "SECTION 6: ADDITIONAL SETTINGS  "
echo "********************************"

if $SWAP_GO; then
   # add swap to CentOS 6
   run_script swap.sh
fi

if $LINUX_GO; then
   # display the list of repositories
   echo
   read -p "Press enter to view the repository list..."
   yum repolist
fi

if $LEMP_GO; then
   # get public IP
   echo
   echo "go to this IP address to confirm nginx is working:"
   INTERFACE=$(firewall-cmd --list-interface)
   ifconfig $INTERFACE | grep --color inet | awk '{ print $2 }'
fi

if $WORDPRESS_GO && [ -e /var/www/$WORDPRESS_DOMAIN/public_html/testphp.php ]; then
   # another way to get public IP
   PUBLIC_IP=$(curl http://ipecho.net/plain)
   echo
   echo "Go to http://$PUBLIC_IP/testphp.php to test the web server."
fi

if $MIDDLEMAN_GO; then
   # manual steps to get BitBalloon working with Middleman and GitHub
   echo
   echo "**********************************************************************"
   echo "* manual steps:                                                       "
   echo "*                                                                     "
   echo "* login as a non-root user, cd to $MIDDLEMAN_DOMAIN and run:          "
   echo "*    sudo bundle install                                              "
   echo "*                                                                     "
   echo "* to run the local middleman server at http://localhost:4567/         "
   echo "*    bundle exec middleman                                            "
   echo "*                                                                     "
   echo "* commit changes with git:                                            "
   echo "*    git commit -am \'first commit by $GITHUB_USER\'                  "
   echo "*                                                                     "
   echo "* push commits to your remote repository stored on GitHub:            "
   echo "*    git push origin master                                           "
   echo "*                                                                     "
   echo "* go to the BitBalloon site and:                                      "
   echo "*    - do an initial manual drag and drop deploy of your new site     "
   echo "*    - go to your site in the BitBalloon UI                           "
   echo "*    - click \"Link site to a Github repo\" at the bottom right       "
   echo "*      (currently a beta feature so you may need to request access)   "
   echo "*    - choose which branch you want to deploy ($MIDDLEMAN_DOMAIN)     "
   echo "*    - set the dir to \"Other ...\" and enter \"/build\"              "
   echo "*    - for the build command, set: \"bundle exec middleman build\"    "
   echo "*                                                                     "
   echo "* Now whenever you push to Github, BitBalloon will run middleman      "
   echo "* and deploy the /build folder to your site.                          "
   echo "**********************************************************************"
fi

if $SERVER_GO && $SSH_GO; then
   echo
   echo "**********************************************************************"
   echo "* IMPORTANT: --DON'T CLOSE THE REMOTE TERMINAL WINDOW YET--           "
   echo "* Edit sudoers.sh with the new SSH user and run it.                   "
   echo "* Otherwise, you'll lose SSH access to your server since root is      "
   echo "* disabled and the new user isn't completely set up yet.              "
   echo "**********************************************************************"
fi

# set ownership
echo
chown -cR $USER_NAME:$USER_NAME "$REPOS"

echo
if $SERVER_GO; then
   echo "Thanks for using the linux-deploy-scripts for CentOS 7 on your server."
elif $WORKSTATION_GO; then
   echo "Thanks for using the linux-deploy-scripts for CentOS 7 on your workstation."
fi

