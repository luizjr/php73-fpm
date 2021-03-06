FROM phpdockerio/php73-fpm:latest
WORKDIR /application

# Fix debconf warnings upon build
ARG DEBIAN_FRONTEND=noninteractive

# Install selected extensions and other stuff
RUN apt-get update \
    && apt-get -y --no-install-recommends install  php7.3-mysql php7.3-pgsql php-redis php7.3-sqlite3 php-xdebug php7.3-bcmath php7.3-gd php-imagick php7.3-imap php-mongodb php7.3-soap php7.3-xmlrpc php-yaml \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Install git
RUN apt-get update \
    && apt-get -y install git \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Condig PHP
RUN echo 'upload_max_filesize = 300M' >> /etc/php/7.3/fpm/conf.d/99-overrides.ini \
    && echo 'post_max_size = 308M' >> /etc/php/7.3/fpm/conf.d/99-overrides.ini \
    && echo 'memory_limit = -1' >> /etc/php/7.3/fpm/conf.d/99-overrides.ini \
    && echo 'max_input_vars = 3000' >> /etc/php/7.3/fpm/conf.d/99-overrides.ini

RUN cd /tmp \
    && curl -o ioncube.tar.gz http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    && tar -xvvzf ioncube.tar.gz \
    && mv ioncube/ioncube_loader_lin_7.3.so /usr/local/lib/php/extensions/* \
    && rm -Rf ioncube.tar.gz ioncube \
    && echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20151012/ioncube_loader_lin_7.3.so" > /usr/local/etc/php/conf.d/00_docker-php-ext-ioncube_loader_lin_7.0.ini

# Change uid and gid of apache to docker user uid/gid
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data
