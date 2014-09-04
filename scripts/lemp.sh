#!/bin/bash
echo "*********************************************"
echo "* A CentOS 7.0 x64 deployment script to      "
echo "* install the LEMP stack and build Nginx     "
echo "* with the ngx_cache_purge module            "
echo "*                                            "
echo "* Author : Keegan Mullaney                   "
echo "* Company: KM Authorized LLC                 "
echo "* Website: http://kmauthorized.com           "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*********************************************"

# build directory
BUILD="$HOME/build"

# install remi if not already installed (required for php-fpm)
install_repo "remi-release" "$REMI_URL" "$REMI_KEY"

# MARIADB (M)
if rpm -q mariadb; then
   echo "mariadb is already installed"
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
   echo "php-fpm is already installed"
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
echo
read -p "Press enter to check if nginx-${NGINX_V} is already installed..."
if nginx -V | grep -qw 'ngx_cache_purge'; then
   echo "nginx-${NGINX_V} has already been installed"
else
   echo "nginx-${NGINX_V} has not been installed yet"

   if rpm -q nginx; then
      echo "removing yum version of nginx"
      yum -y erase nginx
   fi

   # make directories for building
   mkdir -pv $BUILD/nginx-modules

   # make the cache directories for nginx
   mkdir -pv /run/nginx/client_body
   mkdir -pv /run/nginx/proxy
   mkdir -pv /run/nginx/fastcgi
   mkdir -pv /run/nginx/uwsgi
   mkdir -pv /run/nginx/scgi

   # install Nginx dependencies
   echo
   read -p "Press enter to install Development Tools..."
   yum -y group install 'Development Tools'

   cd $BUILD
   echo "changing directory to: $_"

   # download and extract the latest software versions
   get_software "$NGINX_URL $OPENSSL_URL $ZLIB_URL $PCRE_URL"

   # change to modules directory
   cd $BUILD/nginx-modules
   echo
   echo "changing directory to: $BUILD/nginx-modules"

   # download extract the latest Nginx Cache Purge Module
   get_software "$FRICKLE_URL"

   # change to nginx directory
   cd "$BUILD/nginx-${NGINX_V}"
   echo "changing directory to: $_"

   # export -fPIC
   export CFLAGS="-fPIC"

   # configure nginx with default compiling flags for CentOS x86_64 plus pagespeed and cache purge modules
   echo
   echo "These configuration arguments are tested to work with DigitalOcean"
   echo "Droplets on CentOS 7 x64."
   echo "Press enter to configure nginx with default compiling flags,"
   read -p "the most recent PCRE with JIT, ZLIB, OpenSSL and Frickle..."
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
   --with-pcre="$BUILD/pcre-${PCRE_V}" \
   --with-zlib="$BUILD/zlib-${ZLIB_V}" \
   --with-openssl="$BUILD/openssl-${OPENSSL_V}" \
   --add-module="$BUILD/nginx-modules/ngx_cache_purge-${FRICKLE_V}"

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
   read -p "Press enter to see which nginx modules are included in our nginx..."
   nginx -V | grep --color 'with-http_realip_module|ngx_cache_purge|with-http_stub_status_module|with-pcre-jit'
fi
