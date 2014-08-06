#!/bin/bash
echo "*********************************************"
echo "* A CentOS 7.0 deployment script to          "
echo "* install the LEMP stack and build Nginx     "
echo "* with the ngx_cache_purge module            "
echo "*                                            "
echo "* Author : Keegan Mullaney                   "
echo "* Company: KM Authorized LLC                 "
echo "* Website: http://kmauthorized.com           "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*********************************************"

# install remi if not already installed (required for php-fpm)
echo
read -p "Press enter to test the remi install..."
if rpm -qa | grep -q remi-release; then
   echo "remi was already configured"
else
   read -p "Press enter to import the remi gpg key..."
   rpm --import http://rpms.famillecollet.com/RPM-GPG-KEY-remi
   # list imported gpg keys
   rpm -qa gpg*
   #echo
   # test the rpm install again
   #read -p "Press enter to test the remi install..."
   #rpm -Uvh --test http://rpms.famillecollet.com/enterprise/remi-release-${REMI_VERSION}.rpm
   # run the install
   echo
   read -p "Press enter to continue with remi install..."
   rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-${REMI_VERSION}.rpm
fi

# MARIADB (M)
if rpm -q mariadb; then
   echo "mariadb was already installed"
else
   echo
   read -p "Press enter to install mariadb-server and mariadb..."
   yum -y install mariadb-server mariadb && echo "mariadb installed"

   echo
   read -p "Press enter to set mariadb to start on server boot..."
   systemctl start mariadb
   systemctl enable mariadb
   echo "mariadb started and set to start on server boot"

   # configure mariadb
   echo
   read -p "Press enter to secure mariadb..."
   /usr/bin/mysql_secure_installation
   systemctl restart mariadb
fi

# PHP-FPM (P)
if rpm -q php-fpm; then
   echo "php-fpm was already installed"
else
   echo
   read -p "Press enter to install php-fpm and php-mysql..."
   yum --enablerepo=remi -y install php-fpm php-mysql && echo "php installed"

   echo
   read -p "Press enter to set php-fpm to start on server boot..."
   systemctl start php-fpm
   systemctl enable php-fpm
   echo "php-fpm started and set to start on server boot"
fi

# NGINX (E)
# check if nginx is already installed
read -p "Press enter to check if nginx-$NGINX_VERSION is already installed..."
if nginx -V 2>&1 | egrep -qo 'ngx_cache_purge'; then
   echo "nginx-$NGINX_VERSION has already been installed"
else
   echo "nginx-$NGINX_VERSION has not been installed yet"
fi

if rpm -qa | grep -q nginx; then
   systemctl stop nginx
   echo "removing yum version of nginx"
   yum -y erase nginx
fi

# make directories for building
BUILD="/home/$USER_NAME/build"
mkdir -p $BUILD/nginx-modules
echo "made directory: $_"

# make the cache directories for nginx
mkdir -p /run/nginx/client_body
mkdir -p /run/nginx/proxy
mkdir -p /run/nginx/fastcgi
mkdir -p /run/nginx/uwsgi
mkdir -p /run/nginx/scgi
echo "made directory: /run/nginx/client_body"
echo "made directory: /run/nginx/proxy"
echo "made directory: /run/nginx/fastcgi"
echo "made directory: /run/nginx/uwsgi"
echo "made directory: /run/nginx/scgi"

# install Nginx dependencies
echo
read -p "Press enter to install Development Tools..."
yum -y groupinstall 'Development Tools'

#if rpm -qa | grep -q yum-plugin-priorities; then
#   echo "yum-plugin-priorities was already installed"
#else
#   echo
#   read -p "Press enter to install yum-plugin-priorities..."
#   yum -y install yum-plugin-priorities
#fi

cd $BUILD
echo "changing directory to: $_"

# download and extract the latest nginx mainline, check http://wiki.nginx.org/Install#Source_Releases
echo
read -p "Press enter to download and extract nginx-$NGINX_VERSION.tar.gz..."
wget -nc http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz
tar -xzf nginx-$NGINX_VERSION.tar.gz

# download and extract the latest openssl version, check http://www.openssl.org/source/
read -p "Press enter to download and extract openssl-$OPENSSL_VERSION.tar.gz..."
wget -nc http://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz
tar -xzf openssl-$OPENSSL_VERSION.tar.gz

# download and extract the latest zlib version, check http://zlib.net/
read -p "Press enter to download and extract zlib-$ZLIB_VERSION.tar.gz..."
wget -nc http://zlib.net/zlib-$ZLIB_VERSION.tar.gz
tar -xzf zlib-$ZLIB_VERSION.tar.gz

# download and extract the latest pcre version, check ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/
read -p "Press enter to download and extract pcre-$PCRE_VERSION.tar.gz..."
wget -nc ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-$PCRE_VERSION.tar.gz
tar -xzf pcre-$PCRE_VERSION.tar.gz

# change to modules directory
cd $BUILD/nginx-modules
echo
echo "changing directory to: $BUILD/nginx-modules"

# download extract the latest Nginx Cache Purge Module, check http://labs.frickle.com/nginx_ngx_cache_purge/
echo
read -p "Press enter to download and extract ngx_cache_purge-$FRICKLE_VERSION.tar.gz..."
wget -nc http://labs.frickle.com/files/ngx_cache_purge-$FRICKLE_VERSION.tar.gz
tar -xzf ngx_cache_purge-$FRICKLE_VERSION.tar.gz 

# change to nginx directory
cd $BUILD/nginx-$NGINX_VERSION
echo "changing directory to: $_"

# export -fPIC
export CFLAGS="-fPIC"

# configure nginx with default compiling flags for CentOS x86_64 plus pagespeed and cache purge modules
echo
echo "These configuration arguments are tested to work with Digital Ocean Droplets on CentOS 7 x86_64."
read -p "Press enter to configure nginx with default compiling flags, the most recent PCRE with JIT, ZLIB, OpenSSL and Frickle..."
./configure \
--prefix=/usr/share/nginx \
--sbin-path=/usr/sbin/nginx \
--conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--http-client-body-temp-path=/run/nginx/client_body \
--http-proxy-temp-path=/run/nginx/proxy \
--http-fastcgi-temp-path=/run/nginx/fastcgi \
--http-uwsgi-temp-path=/run/nginx/uwsgi \
--http-scgi-temp-path=/run/nginx/scgi \
--pid-path=/run/nginx.pid \
--lock-path=/run/lock/subsys/nginx \
--user=nginx \
--group=nginx \
--with-file-aio \
--with-ipv6 \
--with-http_ssl_module \
--with-http_spdy_module \
--with-http_realip_module \
--with-http_flv_module \
--with-http_mp4_module \
--with-http_stub_status_module \
--with-pcre \
--with-pcre-jit \
--with-debug \
--with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic' \
--with-ld-opt='-Wl,-E' \
--with-pcre=$BUILD/pcre-$PCRE_VERSION \
--with-zlib=$BUILD/zlib-$ZLIB_VERSION \
--with-openssl=$BUILD/openssl-$OPENSSL_VERSION \
--add-module=$BUILD/nginx-modules/ngx_cache_purge-$FRICKLE_VERSION

# successful build arguments from CentOS 6.5
# --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic'
# --with-ld-opt=-Wl,-E

# arguments removed/changed from package manager version
# --http-client-body-temp-path=/var/lib/nginx/tmp/client_body
# --http-proxy-temp-path=/var/lib/nginx/tmp/proxy
# --http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi
# --http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi
# --http-scgi-temp-path=/var/lib/nginx/tmp/scgi
# --with-http_addition_module
# --with-http_xslt_module
# --with-http_image_filter_module
# --with-http_geoip_module
# --with-http_sub_module
# --with-http_dav_module
# --with-http_gunzip_module
# --with-http_gzip_static_module
# --with-http_random_index_module
# --with-http_secure_link_module
# --with-http_degradation_module
# --with-http_perl_module
# --with-mail
# --with-mail_ssl_module
# --with-google_perftools_module

# run the install
read -p "Press enter to make nginx..."
make
echo
read -p "Press enter to make install nginx..."
make install

# change back to home directory
cd
echo "changing directory to: $_"

# create init script so nginx will work with 'systemctl' commands
echo
read -p "Press enter to create the nginx init.d script at /etc/init.d/nginx..."
cat << 'EOF' > /etc/init.d/nginx
#!/bin/bash
#
# nginx - this script starts and stops the nginx daemon
#
# chkconfig:   - 85 15 
# description:  Nginx is an HTTP(S) server, HTTP(S) reverse \
#               proxy and IMAP/POP3 proxy server
# processname: nginx
# config:      /etc/nginx/nginx.conf
# config:      /etc/sysconfig/nginx
# pidfile:     /run/nginx.pid
 
# Source function library.
. /etc/rc.d/init.d/functions
 
# Source networking configuration.
. /etc/sysconfig/network
 
# Check that networking is up.
[ "$NETWORKING" = "no" ] && exit 0
 
nginx="/usr/sbin/nginx"
prog=$(basename $nginx)

NGINX_CONF_FILE="/etc/nginx/nginx.conf"
 
[ -f /etc/sysconfig/nginx ] && . /etc/sysconfig/nginx
 
lockfile=/var/lock/subsys/nginx
 
make_dirs() {
   # make required directories
   user=`$nginx -V 2>&1 | grep "configure arguments:" | sed 's|[^*]*--user=\([^ ]*\).*|\1|g' -`
   if [ -z "`grep $user /etc/passwd`" ]; then
       useradd -M -s /bin/nologin $user
   fi
   options=`$nginx -V 2>&1 | grep 'configure arguments:'`
   for opt in $options; do
       if [ `echo $opt | grep '.*-temp-path'` ]; then
           value=`echo $opt | cut -d "=" -f 2`
           if [ ! -d "$value" ]; then
               # echo "creating" $value
               mkdir -p $value && chown -R $user $value
           fi
       fi
   done
}
 
start() {
    [ -x $nginx ] || exit 5
    [ -f $NGINX_CONF_FILE ] || exit 6
    make_dirs
    echo -n $"Starting $prog: "
    daemon $nginx -c $NGINX_CONF_FILE
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $lockfile
    return $retval
}
 
stop() {
    echo -n $"Stopping $prog: "
    killproc $prog -QUIT
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $lockfile
    return $retval
}
 
restart() {
    configtest || return $?
    stop
    sleep 1
    start
}
 
reload() {
    configtest || return $?
    echo -n $"Reloading $prog: "
    killproc $nginx -HUP
    RETVAL=$?
    echo
}
 
force_reload() {
    restart
}
 
configtest() {
  $nginx -t -c $NGINX_CONF_FILE
}
 
rh_status() {
    status $prog
}
 
rh_status_q() {
    rh_status >/dev/null 2>&1
}
 
case "$1" in
    start)
        rh_status_q && exit 0
        $1
        ;;
    stop)
        rh_status_q || exit 0
        $1
        ;;
    restart|configtest)
        $1
        ;;
    reload)
        rh_status_q || exit 7
        $1
        ;;
    force-reload)
        force_reload
        ;;
    status)
        rh_status
        ;;
    condrestart|try-restart)
        rh_status_q || exit 0
            ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload|configtest}"
        exit 2
esac
EOF
echo "/etc/init.d/nginx has been configured"

# set execute permissions for all users on the init.d script for nginx
chmod a+x /etc/init.d/nginx

echo
read -p "Press enter to set nginx to start on server boot..."
systemctl start nginx
chkconfig nginx on
echo "nginx started and set to start on server boot"

echo
read -p "Press enter to see which nginx modules are included with the package managed nginx..."
nginx -V 2>&1 | egrep --color 'with-http_realip_module|ngx_cache_purge|with-http_stub_status_module|with-pcre-jit'

echo "done with lemp.sh"
