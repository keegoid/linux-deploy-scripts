#!/bin/bash
echo "*********************************************"
echo "* A CentOS 7.0 init script to                "
echo "* install git, configure git, generate       "
echo "* ssh keys and clone the deployment scripts  "
echo "* from GitHub                                "
echo "*                                            "
echo "* Author : Keegan Mullaney                   "
echo "* Company: KM Authorized LLC                 "
echo "* Website: http://kmauthorized.com           "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*********************************************"

####################################################
# EDIT THESE VARIABLES WITH YOUR INFO
USER_NAME='kmullaney' #Linux user you will/already use
REAL_NAME='Keegan Mullaney'
EMAIL_ADDRESS='keegan@kmauthorized.com'
SSH_KEY_COMMENT='kma server'
SSH_PORT='666' #set your own custom port number
WORDPRESS_DOMAIN='kmauthorized.com'
MIDDLEMAN_DOMAIN='keeganmullaney.com'
GITHUB_USER='keegoid' #your GitHub username
LIBS_DIR='includes' #where you put extra stuff

# OPTIONALLY, UPDATE THESE VARIABLES
# set software versions here
EPEL_VERSION='7-1'         # http://dl.fedoraproject.org/pub/epel/beta/7/x86_64/
REMI_VERSION='7'           # http://rpms.famillecollet.com/enterprise/
NGINX_VERSION='1.7.4'      # http://nginx.org/download/
OPENSSL_VERSION='1.0.1i'   # http://www.openssl.org/source/
ZLIB_VERSION='1.2.8'       # http://zlib.net/
PCRE_VERSION='8.35'        # http://www.pcre.org/
FRICKLE_VERSION='2.1'      # http://labs.frickle.com/files/
RUBY_VERSION='2.1.2'       # https://www.ruby-lang.org/en/downloads/

# programs to install
# use " " as delimiter
REQUIRED_PROGRAMS='wget man lynx'
WORKSTATION_PROGRAMS='gedit k3b ntfs-3g git'
SERVER_PROGRAMS=''

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
####################################################

# upstream project names
UPSTREAM_PROJECT='linux-deploy-scripts'
MM_UPSTREAM_PROJECT='middleman-html5-foundation'

# software download URLs
EPEL_URL="http://dl.fedoraproject.org/pub/epel/beta/7/x86_64/epel-release-${EPEL_VERSION}.noarch.rpm"
REMI_URL="http://rpms.famillecollet.com/enterprise/remi-release-${REMI_VERSION}.rpm"
NGINX_URL="http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz"
OPENSSL_URL="http://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"
ZLIB_URL="http://zlib.net/zlib-${ZLIB_VERSION}.tar.gz"
PCRE_URL="ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${PCRE_VERSION}.tar.gz"
FRICKLE_URL="http://labs.frickle.com/files/ngx_cache_purge-${FRICKLE_VERSION}.tar.gz"
RUBY_URL="https://get.rvm.io"
WORDPRESS_URL="http://wordpress.org/latest.tar.gz"
DROPBOX_URL="https://www.dropbox.com/download?plat=lnx.x86_64"

# GPG public keys
EPEL_KEY="http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-${EPEL_VERSION}"
REMI_KEY='http://rpms.famillecollet.com/RPM-GPG-KEY-remi'

# init
DROPBOX=false
SSH=false

# library files
LIBS='linuxkm.lib gitkm.lib'

# source function libraries
for lib in $LIBS; do
   [ -d "$LIBS_DIR" ] && { source "$LIBS_DIR/$lib" > /dev/null 2>&1 && echo "sourced: $LIBS_DIR/$lib" || echo "can't find: $LIBS_DIR/$lib"; } ||
                         { source "$lib" > /dev/null 2>&1 && echo "sourced: $lib" || echo "can't find: $lib"; }
done

# check to make sure script is being run as root
is_root && echo "root user detected, proceeding..." || die "\033[40m\033[1;31mERROR: root check FAILED (you must be root to use this script). Quitting...\033[0m\n"

# use Dropbox?
echo
echo "Do you wish to use Dropbox for your repositories?"
select yn in "Yes" "No"; do
   case $yn in
      "Yes") DROPBOX=true;;
       "No") break;;
          *) echo "case not found..."
   esac
   break
done

# use SSH?
echo
echo "Do you wish to use SSH for git operations (no uses HTTPS)?"
select yn in "Yes" "No"; do
   case $yn in
      "Yes") SSH=true;;
       "No") break;;
          *) echo "case not found..."
   esac
   break
done

# create Linux non-root user
echo
read -p "Press enter to create user \"$USER_NAME\" if it doesn't exist..."
/usr/sbin/adduser $USER_NAME

# local repository location
echo
REPOS=$(locate_repos $USER_NAME $DROPBOX)
echo "repository location: $REPOS"

# install git
install_app "git"

# configure git
configure_git "$REAL_NAME" "$EMAIL_ADDRESS"

# generate an RSA SSH keypair if none exists
if $SSH; then
   gen_ssh_keys "/home/$USER_NAME/.ssh" $SSH_KEY_COMMENT
   echo
   echo "Have you copied id_rsa.pub (above) to the SSH keys section"
   echo "of your GitHub account?"
   select yn in "Yes" "No"; do
      case $yn in
         "Yes") break;;
          "No") echo "Copy the contents of id_rsa.pub (printed below) to the SSH keys section"
                echo "of your GitHub account."
                echo "Highlight the text with your mouse and press ctrl+shift+c to copy."
                echo
                cat "/home/$USER_NAME/.ssh/id_rsa.pub";;
             *) echo "case not found..."
      esac
      break
   done
   echo
   read -p "Press enter when ready..."
fi

# change to repos directory
cd $REPOS
echo "changing directory to $_"

# clone the blog template for Middleman
clone_repo $UPSTREAM_PROJECT $SSH $REPOS $GITHUB_USER

# assign the original repository to a remote called "upstream"
merge_upstream_repo $UPSTREAM_PROJECT $SSH $GITHUB_USER

# git commit and push if necessary
commit_and_push $GITHUB_USER

echo
script_name "          done with "
echo "*********************************************"
echo "next: cd $REPOS/$UPSTREAM_PROJECT"
echo "then: configure and run setup.sh"
