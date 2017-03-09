#!/bin/sh

apt-get update -q && \
    apt-get install --no-install-recommends -qy wget ca-certificates && \

    # PHP7.0 Dotdeb repository
    sh -c 'echo deb http://packages.dotdeb.org jessie all >> /etc/apt/sources.list.d/dotdeb.list' && \
    wget --quiet -O- https://www.dotdeb.org/dotdeb.gpg | apt-key add - && \

    apt-get update -q && \
    apt-get install --no-install-recommends -qy wget ca-certificates \
        htop curl vim git zip unzip sqlite3 mysql-client netcat \
        php7.0-fpm php7.0-cli php7.0-curl php7.0-json php7.0-mysql \
        php7.0-odbc php7.0-sybase php7.0-pgsql php7.0-pspell php7.0-readline php7.0-sqlite php7.0-tidy \
        php7.0-xmlrpc php7.0-xml php7.0-xsl php7.0-mcrypt php7.0-mbstring && \


    # Remove apt-get filse to save space
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \

    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add timezone to php.ini
cliphpfile='/etc/php/7.0/cli/php.ini'
fpmphpfile='/etc/php/7.0/fpm/php.ini'
cp -f $cliphpfile $cliphpfile.input
cp -f $fpmphpfile $fpmphpfile.input
perl -p -e 's/^(;?)date\.timezone.*/$1.date\.timezone = UTC/eg' $cliphpfile.input > $cliphpfile
perl -p -e 's/^(;?)date\.timezone.*/$1.date\.timezone = UTC/eg' $fpmphpfile.input > $fpmphpfile
rm $cliphpfile.input
rm $fpmphpfile.input


# Add php-fpm.conf
echo "; This file was initially adapated from the output of: (on PHP 5.6)
;   grep -vE '^;|^ *$' /usr/local/etc/php-fpm.conf.default

[global]

error_log = /proc/self/fd/2
daemonize = no

[www]

; if we send this to /proc/self/fd/1, it never appears
access.log = /proc/self/fd/2

user = www-data
group = www-data

listen = /var/run/php-fpm.socket

pm = dynamic
pm.max_children = 20
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
"> "/etc/php/7.0/fpm/php-fpm.conf"
