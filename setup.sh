#!/bin/bash
echo "*********************************************"
echo "* A CentOS 7.0 x64 deployment script for     "
echo "* DigitalOcean Droplets or your workstation. "
echo "* ---                                        "
echo "* Updates Linux, installs LEMP stack,        "
echo "* configures Nginx with ngx_cache_purge and  "
echo "* installs WordPress and/or Middleman.       "
echo "*                                            "
echo "* Author : Keegan Mullaney                   "
echo "* Company: KM Authorized LLC                 "
echo "* Website: http://kmauthorized.com           "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*                                            "
echo "* ---run instructions---                     "
echo "* set execute permissions on this script:    "
echo "* chmod u+x setup.sh                         "
echo "* dos2unix -k setup.sh                       "
echo "* ./setup.sh                                 "
echo "*********************************************"

####################################################
# EDIT THESE VARIABLES WITH YOUR INFO
REAL_NAME='Keegan Mullaney'
USER_NAME='kmullaney'
EMAIL_ADDRESS='keegan@kmauthorized.com'
SSH_PORT='666' #set your own custom port number
SSH_KEY_COMMENT='kma server'
WORDPRESS_DOMAIN='kmauthorized.com'
MIDDLEMAN_DOMAIN='keeganmullaney.com'
GITHUB_USER='keegoid' #your GitHub username
####################################################

# project info
PROJECT='linux-deploy-scripts'
UPSTREAM_PROJECT='middleman-html5-foundation'
UPSTREAM_REPO="keegoid/$UPSTREAM_PROJECT.git"

# directories
REPOS="$HOME/repos"
if [ -d $HOME/Dropbox ]; then
   REPOS="$HOME/Dropbox/Repos"
fi
BUILD="$HOME/build"
RPM_KEYS="$HOME/rpm_keys"
PROJECT_DIRECTORY="$REPOS/$PROJECT"

# set software versions to latest
EPEL_VERSION='7-0.2'
REMI_VERSION='7'
NGINX_VERSION='1.7.4'
OPENSSL_VERSION='1.0.1h'
ZLIB_VERSION='1.2.8'
PCRE_VERSION='8.35'
FRICKLE_VERSION='2.1'
RUBY_VERSION='2.1.2'

# programs to install
# use " " as delimiter
REQUIRED_PROGRAMS='wget man lynx'
SERVER_PROGRAMS=''
WORKSTATION_PROGRAMS='gedit k3b ntfs-3g git'

# what services, TCP and UDP ports we allow from the Internet
# use " " as delimiter
SERVICES='http https smtp imaps pop3s ftp ntp'
TCP_PORTS="$SSH_PORT"
UDP_PORTS=''

# whitelisted IPs (Cloudflare)
TRUSTED_IPV4_HOSTS="199.27.128.0/21 \
173.245.48.0/20 \
103.21.244.0/22 \
103.22.200.0/22 \
103.31.4.0/22 \
141.101.64.0/18 \
108.162.192.0/18 \
190.93.240.0/20 \
188.114.96.0/20 \
197.234.240.0/22 \
198.41.128.0/17 \
162.158.0.0/15 \
104.16.0.0/12"

TRUSTED_IPV6_HOSTS="2400:cb00::/32 \
2606:4700::/32 \
2803:f800::/32 \
2405:b500::/32 \
2405:8100::/32"

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

# check to make sure script is being run as root
if [ "$(id -u)" != "0" ]; then
   printf "\033[40m\033[1;31mERROR: Root check FAILED (you MUST be root to use this script)! Quitting...\033[0m\n" >&2
   exit 1
fi

# run script after removing DOS line breaks
# takes one argument: name of script to be run
# source the script to be run so it can access local variables
RunScript()
{
   # reset back to root poject directory to run scripts
   cd $PROJECT_DIRECTORY
   echo "changing directory to $_"
   # make sure dos2unix is installed
   hash dos2unix 2>/dev/null || { echo >&2 "dos2unix will be installed."; yum -y install dos2unix; }
   RUN_FILE="scripts/$1"
   dos2unix -k $RUN_FILE && echo "carriage returns removed"
   chmod u+x $RUN_FILE && echo "execute permissions set"
   chown $(logname):$(logname) $RUN_FILE && echo "owner set to $(logname)"
   read -p "Press enter to run: $RUN_FILE"
   . ./$RUN_FILE
}

# import public GPG key if it doesn't already exist in list of RPM keys
# although rpm --import won't import duplicate keys, this is a proof of concept
# takes one argument: URL of the public key file
ImportPublicKey()
{
   cd $RPM_KEYS
   echo "changing directory to $_"
   # download keyfile
   wget -nc $1
   KEYFILE="$RPM_KEYS/${1##http*/}" #delete longest match from left
   # get key id
   KEYID=$(echo $(gpg --throw-keyids < $KEYFILE) | cut --characters=11-18 | tr [A-Z] [a-z])
   # import key if it doesn't exist
   if ! rpm -q gpg-pubkey-$KEYID > /dev/null 2>&1; then
      echo "Installing GPG public key with ID $KEYID from $KEYFILE..."
      rpm --import $KEYFILE
   fi
   # change directory back to previous one
   cd -
}

# make necessary directories if they don't exist
mkdir -pv $REPOS
mkdir -pv $BUILD
mkdir -pv $RPM_KEYS

# collect user inputs to determine which sections of this script to execute
echo
echo "Is this a server or workstation deployment?"
select sw in "Server" "Workstation"; do
   case $sw in
           "Server") SERVER_GO=true;;
      "Workstation") WORKSTATION_GO=true;;
                  *) echo "case not found, exiting..."
                     exit 0;;
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
          *) echo "case not found";;
   esac
   break
done
echo
echo "Do you wish to add useful bash shell aliases for new SSH user?"
select yn in "Yes" "No"; do
   case $yn in
      "Yes") ALIASES_GO=true;;
       "No") break;;
          *) echo "case not found";;
   esac
   break
done
echo
echo "Do you wish to update Linux and install basic programs?"
select yn in "Yes" "No"; do
   case $yn in
      "Yes") LINUX_UPDATE_GO=true;;
       "No") break;;
          *) echo "case not found";;
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
             *) echo "case not found";;
      esac
      break
   done
   echo
   echo "Do you wish to install the LEMP stack?"
   select yn in "Yes" "No"; do
      case $yn in
         "Yes") LEMP_GO=true;;
          "No") break;;
             *) echo "case not found";;
      esac
      break
   done
   echo
   echo "Do you wish to install WordPress?"
   select yn in "Yes" "No"; do
      case $yn in
         "Yes") WORDPRESS_GO=true;;
          "No") break;;
             *) echo "case not found";;
      esac
      break
   done
   echo
   echo "Do you wish to configure Nginx?"
   select yn in "Yes" "No"; do
      case $yn in
         "Yes") NGINX_CONFIG_GO=true;;
          "No") break;;
             *) echo "case not found";;
      esac
      break
   done
   echo
   echo "Do you wish to add a swap file?"
   select yn in "Yes" "No"; do
      case $yn in
         "Yes") SWAP_GO=true;;
          "No") break;;
             *) echo "case not found";;
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
             *) echo "case not found";;
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
   RunScript server_ssh.sh
else
   echo
   echo "skipping SSH..."
fi

if $FIREWALL_GO; then
   # setup firewall rules
   RunScript firewalld.sh
else
   echo "skipping firewall..."
fi

if $ALIASES_GO; then
   # add useful aliases for new SSH user
   RunScript aliases.sh
else
   echo "skipping aliases..."
fi

echo
echo "********************************"
echo "SECTION 2: INSTALLS & UPDATES   "
echo "********************************"

if $LINUX_UPDATE_GO; then
   # LINUX (L)
   RunScript linux_update.sh
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
   RunScript lemp.sh
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
   RunScript wordpress_install.sh
else
   echo
   echo "skipping WordPress install..."
fi

if $MIDDLEMAN_GO; then
   # install Ruby, RubyGems, Middleman, Redcarpet and Rouge
   RunScript middleman.sh
else
   echo "skipping Middleman install..."
fi

echo
echo "********************************"
echo "SECTION 5: NGINX CONFIG         "
echo "********************************"

if $NGINX_CONFIG_GO; then
   # configure nginx with fastcgi_cache and cache purging
   RunScript nginx_config.sh
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
   RunScript swap.sh
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
   echo
   echo "**********************************************************************"
   echo "* login as a non-root user, cd to $MIDDLEMAN_DOMAIN and run:          "
   echo "*    sudo bundle install                                              "
   echo "*                                                                     "
   echo "* to run the local middleman server at http://localhost:4567/         "
   echo "*    bundle exec middleman                                            "
   echo "*                                                                     "
   echo "* commit changes with git:                                            "
   echo "*    git commit -am \'first commit by $USER_NAME\'                    "
   echo "*                                                                     "
   echo "* push commits to your remote repository stored on GitHub:            "
   echo "*    git push origin master                                           "
   echo "*                                                                     "
   echo "* go to the BitBalloon site and:                                      "
   echo "*    - do an initial manual drag and drop deploy of your new site     "
   echo "*    - go to your site in the BitBalloon UI                           "
   echo "*    - click \"Link site to a Github repo\" at the bottom right       "
   echo "*      (currently a beta feature so you may need to request access)   "
   echo "*    - choose which branch you want to deploy (typically master)      "
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
   echo "* Edit configuresudoers.sh with the new SSH user and run it.          "
   echo "* Otherwise, you'll lose SSH access to your server since root is      "
   echo "* disabled and the new user isn't completely set up yet.              "
   echo "**********************************************************************"
fi

echo
if $SERVER_GO; then
   echo "Thanks for using the linux-deploy-scripts for CentOS 7 on your server."
elif $WORKSTATION_GO; then
   echo "Thanks for using the linux-deploy-scripts for CentOS 7 on your workstation."
fi

