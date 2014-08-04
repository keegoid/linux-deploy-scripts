#!/bin/bash
echo "*********************************************"
echo "* A CentOS 7.0 deployment script to          "
echo "* configure nginx and php with               "
echo "* fastcgi_cache and cache purging            "
echo "*                                            "
echo "* Author : Keegan Mullaney                   "
echo "* Company: KM Authorized LLC                 "
echo "* Website: http://kmauthorized.com           "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*********************************************"

# set permissions on WordPress sites for nginx
read -p "Press enter to set permissions for nginx and SSH user to use WordPress directories..."
chown -R nginx:nginx /var/www/
chmod 755 $_
usermod -a -G nginx $USER_NAME && echo "nginx user modified successfully"

# php.ini
echo
read -p "Press enter to configure /etc/php.ini..."
sed -i.bak 's|;cgi.fix_pathinfo=1|cgi.fix_pathinfo=0|' /etc/php.ini && echo "fix_pathinfo has been configured"

# www.conf
if cat /etc/php-fpm.d/www.conf | grep -q "listen.group = nginx"; then
   echo "www.conf was already configured"
else
   echo
   read -p "Press enter to configure /etc/php-fpm.d/www.conf..."
   sed -i.bak -e 's|listen = 127.0.0.1:9000|;listen = 127.0.0.1:9000|' -e 's|user = apache|user = nginx|' -e 's|group = apache|group = nginx|' -e '|listen = 127.0.0.1:9000|a \
listen = /run/php-fpm.sock' -e 's|;listen.owner = nobody|listen.owner = nginx|' -e 's|;listen.group = nobody|listen.group = nginx|' -e 's|;listen.mode = 0660|listen.mode = 0660|' /etc/php-fpm.d/www.conf &&
   echo -e "configured permissions to user: nginx and group: nginx\nset php-fpm socket for fastcgi_cache and socket permissions"
fi

# nginx.conf
echo
read -p "Press enter to configure /etc/nginx/nginx.conf..."
cat << 'EOF' > /etc/nginx/nginx.conf
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;

# this number should be, at maximum, the number of CPU cores on your system
# since nginx doesn't benefit from more than one worker per CPU.
worker_processes 4;

# only log critical errors
error_log /var/log/nginx/error.log crit;

pid /run/nginx.pid;

events {
   # determines how many clients will be served by each worker process
   #(max clients = worker_connections * worker_processes)
    worker_connections 2048;

   # accept as many connections as possible, after nginx gets notification about a new connection
   # may flood worker_connections, if that option is set too low
   multi_accept on;
}

http {
   include /etc/nginx/mime.types;
   default_type application/octet-stream;

   log_format main      '$remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for"';
   log_format caching   '$remote_addr - $upstream_cache_status [$time_local]  '
                        '"$request" $status $body_bytes_sent '
                        '"$http_referer" "$http_user_agent"';

   # caches information about open FDs, freqently accessed files
   # cache metadata if a file is accessed 2 times within 2 minute, valid for 1 minute
   open_file_cache max=10000 inactive=2m;
   open_file_cache_valid 1m;
   open_file_cache_min_uses 2;
   open_file_cache_errors on;

   # buffer log writes to speed up IO, or disable them altogether
   access_log /var/log/nginx/access.log main buffer=16k;

   # sendfile copies data between one FD and other from within the kernel 
   # more efficient than read() + write(), since that requires transferring data to and from the user space
   sendfile on;

   # tcp_nopush causes nginx to attempt to send its HTTP response head in one packet, 
   # instead of using partial frames. This is useful for prepending headers before calling sendfile, 
   # or for throughput optimization.
   tcp_nopush on;

   # don't buffer data-sends (disable Nagle algorithm), good for sending frequent small bursts of data in real time
   tcp_nodelay on; 

   # timeout for keep-alive connections, server will close connections after this time
   keepalive_timeout 30;
 
   # number of requests a client can make over the keep-alive connection (testing: 100000)
   keepalive_requests 10000;

   # allow the server to close the connection after a client stops responding, frees up socket-associated memory
   reset_timedout_connection on;

   # send the client a "request timed out" if the body is not loaded by this time (default 60)
   client_body_timeout 20;

   # if the client stops reading data, free up the stale client connection after this much time (default 60)
   send_timeout 20;
  
   # gzip compression, reduces the amount of data that needs to be transferred over the network
   gzip              on;
   gzip_comp_level   2;
   gzip_proxied      expired no-cache no-store private auth;
   gzip_types        text/css text/xml application/javascript application/atom+xml application/rss+xml text/plain image/svg+xml application/font-woff application/json application/xhtml+xml;
   gzip_min_length   1024; #10240;

   # disable for IE < 6 because there are some known problems
   gzip_disable "msie6";

   # add a vary header for downstream proxies to avoid sending cached gzipped files to IE6
   gzip_vary on;

   # global fastcgi_cache settings
   fastcgi_cache_path      /dev/shm/nginx levels=1:2 keys_zone=WORDPRESS:100m inactive=60m;
   fastcgi_cache_key       "$scheme$request_method$host$request_uri";
   fastcgi_cache_use_stale error timeout invalid_header http_500;
#   fastcgi_ignore_headers  Cache-Control Expires Set-Cookie;
   add_header NGX-Cache    $upstream_cache_status;
 
   index index.php index.html index.htm;

   # upstream to abstract backend connection(s) for PHP.
   upstream php {
      #this should match value of "listen" directive in php-fpm pool
      server unix:/run/php-fpm.sock;
   }

   # set Cloudflare subnets as trusted
   set_real_ip_from 199.27.128.0/21;
   set_real_ip_from 173.245.48.0/20;
   set_real_ip_from 103.21.244.0/22;
   set_real_ip_from 103.22.200.0/22;
   set_real_ip_from 103.31.4.0/22;
   set_real_ip_from 141.101.64.0/18;
   set_real_ip_from 108.162.192.0/18;
   set_real_ip_from 190.93.240.0/20;
   set_real_ip_from 188.114.96.0/20;
   set_real_ip_from 197.234.240.0/22;
   set_real_ip_from 198.41.128.0/17;
   set_real_ip_from 162.158.0.0/15;
   set_real_ip_from 104.16.0.0/12;
   set_real_ip_from 2400:cb00::/32;
   set_real_ip_from 2606:4700::/32;
   set_real_ip_from 2803:f800::/32;
   set_real_ip_from 2405:b500::/32;
   set_real_ip_from 2405:8100::/32;
   real_ip_header CF-Connecting-IP;

   # load config files from the /etc/nginx/conf.d directory
   # the default server is in conf.d/default.conf
   # virtual servers are in conf.d/virtual.conf
   include sites-enabled/*;
}
EOF
echo "/etc/nginx/nginx.conf has been configured"

# sites-available/domain.com
echo
read -p "Press enter to configure /etc/nginx/sites-available/..."
mkdir -p /etc/nginx/sites-available
echo "made directory: $_"
cat << EOF > /etc/nginx/sites-available/$WORDPRESS_DOMAIN
server {
   # website name
   server_name $WORDPRESS_DOMAIN;

   # the only path reference
   root /var/www/$WORDPRESS_DOMAIN/public_html;

   access_log /var/log/nginx/wordpress.access.log;
   access_log /var/log/nginx/wordpress.cache.log caching;
   error_log  /var/log/nginx/wordpress.error.log;

   # configuration files for WordPress
   include /etc/nginx/wordpress/*;
}
EOF
echo "/etc/nginx/sites-available/$WORDPRESS_DOMAIN.conf has been configured"

# wordpress/restrictions.conf
echo
read -p "Press enter to configure /etc/nginx/wordpress/restrictions.conf..."
mkdir -p /etc/nginx/wordpress
echo "made directory: $_"
cat << 'EOF' > /etc/nginx/wordpress/restrictions.conf
   # WordPress restrictions configuration file
   # Designed to be included in any server {} block.

   location = /favicon.ico {
      log_not_found off;
      access_log off;
   }

   location = /robots.txt {
      allow all;
      log_not_found off;
      access_log off;
   }

   # deny all attempts to access hidden files such as .htaccess, .htpasswd, .DS_Store (Mac).
   location ~ /\. {
      deny all;
      log_not_found off;
      access_log off;
   }

   # deny access to any files with a .php extension in the uploads directory
   # works in sub-directory installs and also in multisite network
   # keep logging the requests to parse later (or to pass to firewall utilities such as fail2ban)
   location ~* /(?:uploads|files)/.*\.php$ {
      deny all;
   }
EOF
echo "/etc/nginx/wordpress/restrictions.conf has been configured"

# wordpress/cache.conf
echo
read -p "Press enter to configure /etc/nginx/wordpress/cache.conf..."
cat << 'EOF' > /etc/nginx/wordpress/cache.conf
   # WordPress cache configuration file
   # Designed to be included in any server {} block.

   #fastcgi_cache start
   set $no_cache 0;

   # POST requests and urls with a query string should always go to PHP
   if ($request_method = POST) {
      set $no_cache 1;
   }   

   if ($query_string != "") {
      set $no_cache 1;
   }   

   # don't cache uris containing the following segments
   if ($request_uri ~* "/wp-admin/|/xmlrpc.php|/wp-(app|cron|login|register|mail).php|wp-.*.php|/feed/|index.php|wp-comments-popup.php|wp-links-opml.php|wp-locations.php|sitemap(_index)?.xml|[a-z0-9_-]+-sitemap([0-9]+)?.xml") {
#	if ($request_uri ~* "/wp-admin/|/xmlrpc.php|wp-.*.php|/feed/|index.php|sitemap(_index)?.xml") {
      set $no_cache 1;
   }   

   # don't use the cache for logged in users or recent commenters
   if ($http_cookie ~* "PHPSESSID|comment_author|wordpress_[a-f0-9]+|wp-postpass|wordpress_no_cache|wordpress_logged_in") {
      set $no_cache 1;
   }
EOF
echo "/etc/nginx/wordpress/cache.conf has been configured"

# wordpress/locations.conf
echo
read -p "Press enter to configure /etc/nginx/wordpress/locations.conf..."
cat << 'EOF' > /etc/nginx/wordpress/locations.conf
   # WordPress default configuration file
   # Designed to be included in any server {} block.

    # add nginx support for WordPress SEO plugin by Yoast sitemaps
#   rewrite ^/sitemap_index\.xml$ /index.php?sitemap=1 last;
#   rewrite ^/([^/]+?)-sitemap([0-9]+)?\.xml$ /index.php?sitemap=$1&sitemap_n=$2 last;

   # add nginx support for Google XML Sitemaps plugin
   rewrite ^/sitemap(-+([a-zA-Z0-9_-]+))?\.xml$ "/index.php?xml_sitemap=params=$2" last;
   rewrite ^/sitemap(-+([a-zA-Z0-9_-]+))?\.xml\.gz$ "/index.php?xml_sitemap=params=$2;zip=true" last;
   rewrite ^/sitemap(-+([a-zA-Z0-9_-]+))?\.html$ "/index.php?xml_sitemap=params=$2;html=true" last;
   rewrite ^/sitemap(-+([a-zA-Z0-9_-]+))?\.html.gz$ "/index.php?xml_sitemap=params=$2;html=true;zip=true" last;

   # add trailing slash to */wp-admin requests
   rewrite /wp-admin$ $scheme$request_method$host$request_uri/ permanent;

   location / {
      # This is cool because no php is touched for static content. 
      # include the "?$args" part so non-default permalinks doesn't break when using query string
      try_files $uri $uri/ /index.php?$args;
   }

   # directives to send expires headers and turn off 404 error logging
   location ~* ^.+\.(ogg|ogv|svg|svgz|eot|otf|woff|mp4|ttf|rss|atom|js|css|jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|ppt|tar|mid|midi|wav|bmp|rtf)$ {
      access_log off;
      log_not_found off;
      expires max;
   }

   # provides pseudo-streaming server-side support for Flash Video (FLV) files
   location ~ \.flv$ {
      flv;
   }

   # provides pseudo-streaming server-side support for MP4 files
   location /video/ {
      mp4;
      mp4_buffer_size       1m;
      mp4_max_buffer_size   5m;
      # commercial subscription only
      #mp4_limit_rate        on;
      #mp4_limit_rate_after  30s;
      aio            on;
      directio       512;
      output_buffers 1 128k;
   }

   # provides the ability to get some status from nginx
   location /nginx_status {
      allow 127.0.0.1;
      deny all;
      stub_status  on;
      access_log   off;
   }

   # pass all .php files onto a php-fpm server
#   location ~ \.php$ {
   location ~ [^/]\.php(/|$) {
      # Zero-day exploit defense.
      # http://forum.nginx.org/read.php?2,88845,page=3
      try_files $uri =404;

      #fastcgi_split_path_info ^(.+\.php)(/.*)$;
   	fastcgi_split_path_info ^(.+?\.php)(/.*)$;
      #NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini

#      if (!-f $document_root$fastcgi_script_name) {
#         return 404;
#      }
    
      fastcgi_pass unix:/run/php-fpm.sock;
      #fastcgi_pass php;
      include /etc/nginx/fastcgi.conf;
      fastcgi_index index.php;

      fastcgi_cache_bypass $no_cache;
      fastcgi_no_cache $no_cache;

      fastcgi_cache WORDPRESS;
      fastcgi_cache_valid 404 60m;
      fastcgi_cache_valid 200 60m;

#      fastcgi_buffer_size 16k;
#      fastcgi_buffers 4 16k;
   }

   location ~ /purge(/.*) {
      allow 127.0.0.1;
      deny all;
      fastcgi_cache_purge WORDPRESS "$scheme$request_method$host$1";
    }
EOF
echo "/etc/nginx/wordpress/locations.conf has been configured"

# symlink to enable sites-available/*
echo
read -p "Press enter to create symlinks from sites-available to sites-enabled (activate sites in nginx)..."
mkdir -p /etc/nginx/sites-enabled
echo "made directory: $_"
ln -s /etc/nginx/sites-available/$WORDPRESS_DOMAIN /etc/nginx/sites-enabled/$WORDPRESS_DOMAIN
echo
echo "symlinked: /etc/nginx/sites-available/$WORDPRESS_DOMAIN to /etc/nginx/sites-enabled/$WORDPRESS_DOMAIN"

# symlink nginx logs to WordPress logs
echo
read -p "Press enter to create symlinks from nginx logs to wordpress logs..."
mkdir -p /var/www/$WORDPRESS_DOMAIN/logs
echo "made directory: $_"
touch /var/log/nginx/wordpress.access.log
touch /var/log/nginx/wordpress.cache.log
touch /var/log/nginx/wordpress.error.log
ln -s /var/log/nginx/wordpress.access.log /var/www/$WORDPRESS_DOMAIN/logs/access.log
echo "symlinked: /var/log/nginx/wordpress.access.log to $_"
ln -s /var/log/nginx/wordpress.cache.log /var/www/$WORDPRESS_DOMAIN/logs/cache.log
echo "symlinked: /var/log/nginx/wordpress.cache.log to $_"
ln -s /var/log/nginx/wordpress.error.log /var/www/$WORDPRESS_DOMAIN/logs/error.log
echo "symlinked: /var/log/nginx/wordpress.error.log to $_"

echo
read -p "Press enter to restart nginx and php-fpm..."
systemctl nginx restart
systemctl php-fpm restart

echo "done with nginx_config.sh"

