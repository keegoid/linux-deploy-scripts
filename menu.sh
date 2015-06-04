#!/bin/bash
echo "# -------------------------------------------"
echo "# A CentOS 7.0 x64 deployment script for     "
echo "# DigitalOcean Droplets or your workstation. "
echo "# ---                                        "
echo "# Updates Linux, installs LEMP stack,        "
echo "# configures Nginx with ngx_cache_purge and  "
echo "# installs WordPress.                        "
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

# init option variables
SERVER_GO=false
SSH_GO=false

# select workstation or server type first to determine 
# which sections of this script to execute
echo
echo "Is this a server deployment?"
select yn in "Yes" "No"; do
  case $yn in
    "Yes") SERVER_GO=true;;
     "No") break;;
        *) echo "case not found, try again..."
           continue;;
  esac
  break
done

# finish setup of SSH user on server before anything else
if $SERVER_GO; then
  # set versions for a server (which also sets download URLs)
  set_software_versions 'EPEL REMI NGINX OPENSSL ZLIB PCRE FRICKLE'

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

  if $SSH_GO; then
    # set SSH port and client alive interval so SSH session doesn't quit so fast,
    # add public SSH key and restrict root user access
    run_script server_ssh.sh
    echo
    echo "# --------------------------------------------------------------------"
    echo "# IMPORTANT: --DON'T CLOSE THE REMOTE TERMINAL WINDOW YET--           "
    echo "# Edit sudoers.sh with the new SSH user and run it.                   "
    echo "# Otherwise, you'll lose SSH access to your server since root is      "
    echo "# disabled and the new user isn't completely set up yet.              "
    echo "# --------------------------------------------------------------------"
  else
    echo
    echo "skipping SSH..."
  fi
else
  # set versions for a workstation
  set_software_versions 'EPEL'
fi

# -------------------------------------------
# options for servers and workstations
# -------------------------------------------

# firewall
function firewall_go()
{
  echo "# -------------------------------"
  echo "# SECTION 1: FIREWALL SETUP      "
  echo "# -------------------------------"

  # setup firewall rules
  run_script firewalld.sh
  pause
}

# aliases
function aliases_go()
{
  echo "# -------------------------------"
  echo "# SECTION 2: ALIASES             "
  echo "# -------------------------------"

  # add useful aliases for new SSH user
  run_script aliases.sh
  pause
}

# install software and update system
function updates_go()
{
  echo "# -------------------------------"
  echo "# SECTION 3: INSTALLS & UPDATES  "
  echo "# -------------------------------"

  # LINUX (L)
  run_script linux_update.sh

  # display the list of repositories
  echo
  pause "Press enter to view the repository list..."
  yum repolist
  pause
}
 
# -------------------------------------------
# options for servers only
# -------------------------------------------

# install the LEMP stack
function lemp_go()
{
  echo "# -------------------------------"
  echo "# SECTION 4: LEMP                "
  echo "# -------------------------------"

  # NGINX (E), MYSQL (M), PHP (P)
  run_script lemp.sh

  # get public IP
  echo
  echo "go to this IP address to confirm nginx is working:"
  INTERFACE=$(firewall-cmd --list-interface)
  ifconfig $INTERFACE | grep --color inet | awk '{ print $2 }'
  pause
}

# install WordPress
function wordpress_go()
{
  echo "# -------------------------------"
  echo "# SECTION 5: WORDRPESS INSTALL   "
  echo "# -------------------------------"

  echo "Server selected, installing WordPress..."
  # install WordPress and its MySql database
  run_script wordpress_install.sh

  if [ -e /var/www/$WORDPRESS_DOMAIN/public_html/testphp.php ]; then
    # another way to get public IP
    PUBLIC_IP=$(curl http://ipecho.net/plain)
    echo
    echo "Go to http://$PUBLIC_IP/testphp.php to test the web server."
  fi
  pause
}

# install Nginx
function nginx_go()
{
  echo "# -------------------------------"
  echo "# SECTION 6: NGINX CONFIG        "
  echo "# -------------------------------"

  # configure nginx with fastcgi_cache and cache purging
  run_script nginx_config.sh
  pause
}

# configure swap file
function swap_go()
{
  echo "# -------------------------------"
  echo "# SECTION 7: SWAP SETUP          "
  echo "# -------------------------------"

  # add swap to CentOS 6
  run_script swap.sh
  pause
}

# display the menu
display_menu()
{
  clear
  echo "~~~~~~~~~~~~~~~~~~~~~~~"	
  echo "   M A I N - M E N U   "
  echo "~~~~~~~~~~~~~~~~~~~~~~~"
  echo "1. FIREWALL SETUP"
  echo "2. ALIASES"
  echo "3. INSTALLS & UPDATES"
  if $SERVER_GO; then
    echo "4. LEMP"
    echo "5. WORDPRESS INSTALL"
    echo "6. NGINX CONFIG"
    echo "7. SWAP SETUP"
    echo "8. EXIT"
  else
    echo "4. EXIT"
  fi
}

# user selection varies for servers or workstations
select_options()
{
  local choice
  if $SERVER_GO; then
    read -p "Enter choice [1 - 8]: " choice
    case $choice in
      1) firewall_go;;
      2) aliases_go;;
      3) updates_go;;
      4) lemp_go;;
      5) wordpress_go;;
      6) nginx_go;;
      7) swap_go;;
      8) exit 0;;
      *) echo -e "${RED}Error...${STD}" && sleep 2
    esac
  else
    read -p "Enter choice [1 - 5]: " choice
    case $choice in
      1) firewall_go;;
      2) aliases_go;;
      3) updates_go;;
      5) exit 0;;
      *) echo -e "${RED}Error...${STD}" && sleep 2
    esac
  fi
}
 
# ----------------------------------------------
# trap CTRL+C, CTRL+Z and quit singles
# ----------------------------------------------
#trap '' SIGINT SIGQUIT SIGTSTP
 
# -----------------------------------
# main loop (infinite)
# ------------------------------------
while true; do
  display_menu
  select_options
done

# set ownership
echo
chown -cR $USER_NAME:$USER_NAME "$REPOS"

echo
if $SERVER_GO; then
   echo "Thanks for using the linux-deploy-scripts for CentOS 7 on your server."
else
   echo "Thanks for using the linux-deploy-scripts for CentOS 7 on your workstation."
fi

