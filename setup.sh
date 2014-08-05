#!/bin/bash
echo "*********************************************"
echo "* A CentOS 7.0 deployment script.            "
echo "* Updates Linux, installs LEMP stack,        "
echo "* configures Nginx with ngx_cache_purge and  "
echo "* installs WordPress and/or Middleman        "
echo "*                                            "
echo "* Author : Keegan Mullaney                   "
echo "* Company: KM Authorized LLC                 "
echo "* Website: http://kmauthorized.com           "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*                                            "
echo "* I would like to thank nixCraft at:         "
echo "* http://www.cyberciti.biz/faq               "
echo "* for providing many clear and useful code   "
echo "* examples.                                  "
echo "*                                            "
echo "* ---run instructions---                     "
echo "* set execute permissions on this script:    "
echo "* chmod u+x setup.sh                         "
echo "* dos2unix -k setup.sh                       "
echo "* ./setup.sh                                 "
echo "*********************************************"

# set new Linux user name, SSH port number and website domain name
REAL_NAME='Keegan Mullaney'
USER_NAME='kmullaney'
EMAIL_ADDRESS='keegan@kmauthorized.com'
SSH_PORT='22' #set your own custom port number here
WORDPRESS_DOMAIN='kmauthorized.com'
MIDDLEMAN_DOMAIN='keeganmullaney.com'
MIDDLEMAN_PROJECT="mm-${MIDDLEMAN_DOMAIN%.*}"
UPSTREAM_REPO='BitBalloon/middleman-homepage.git'
GITHUB_USER='keegoid' #your GitHub username

# set software versions to latest
EPEL_VERSION='7-0.2'
REMI_VERSION='7'
RPMFORGE_VERSION='0.5.3-1'
NGINX_VERSION='1.7.3'
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

# set variable defaults
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
# takes name of script to be run as first argument
# source the script to be run so it can access local variables
RunScript()
{
   echo
   # make sure dos2unix is installed
   hash dos2unix 2>/dev/null || { echo >&2 "dos2unix will be installed."; yum -y install dos2unix; }
   RUN_FILE="scripts/$1"
   dos2unix -k $RUN_FILE && echo "carriage returns removed"
   chmod u+x $RUN_FILE && echo "execute permissions set"
   chown $(logname):$(logname) $RUN_FILE && echo "owner set to $(logname)"
   read -p "Press enter to run: $RUN_FILE"
   . ./$RUN_FILE
}

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

# both servers and workstations need SSH, a firewall and EPEL
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
   echo "Do you wish to install Middleman and deploy to BitBalloon?"
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

if $SSH_GO; then
   if $SERVER_GO; then
      # set SSH port and client alive interval so SSH session doesn't quit so fast, add public SSH key and restrict root user access
      RunScript server_ssh.sh
   elif $WORKSTATION_GO; then
      # generate new SSH key pair if none exist and start the SSH-agent
      RunScript workstation_ssh.sh
   fi
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
   ifconfig enp0s25 | grep --color inet | awk '{ print $2 }'
   ifconfig wlp3s0 | grep --color inet | awk '{ print $2 }'
fi

if $WORDPRESS_GO && [ -e /var/www/$WORDPRESS_DOMAIN/public_html/testphp.php ]; then
   # another way to get public IP
   PUBLIC_IP=$(curl http://ipecho.net/plain)
   echo
   echo "Go to http://$PUBLIC_IP/testphp.php to test the web server."
fi

if $MIDDLEMAN_GO; then
   echo
   echo "cd to: /home/$USER_NAME/repos/$MIDDLEMAN_DOMAIN/$MIDDLEMAN_PROJECT"
   echo "as non-root user and without sudo, install the bundle:"
   echo "   bundle install"
   echo "build middleman and push to BitBalloon:"
   echo "   bundle exec middleman deploy"
   echo "run the local middleman server at http://localhost:4567/"
   echo "   bundle exec middleman"
   echo "commit changes to git:"
   echo "   git commit -am \'first commit by $USER_NAME\'"
   echo "push commits to remote repository stored on GitHub:"
   echo "   git push origin master"
   echo
   echo "go to BitBalloon site and click: \"Link site to a Github repo\" link in the bottom right corner"
   echo "choose which branch you want to deploy (typically master)"
   echo "set the dir to \"Other ...\" and enter \"/build\""
   echo "for the build command, set: \"bundle exec middleman build\""
   echo "now whenever you push to Github, we'll run middleman and deploy the /build folder to your site."
fi

if $SERVER_GO && $SSH_GO; then
   echo
   echo "edit configuresudoers.sh with your Linux username for SSH access and run it to finish server setup"
fi

echo
