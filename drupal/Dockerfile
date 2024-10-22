FROM php:8.3-apache

RUN  apt-get update && apt-get install --fix-missing -y \
        zlib1g-dev \
        libzip-dev \          
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libldb-dev \
        libldap2-dev \
        libwebp-dev \
    && docker-php-ext-configure gd --with-jpeg --with-webp \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install -j$(nproc) gd pdo_mysql zip ldap opcache

ENV APACHE_DOCUMENT_ROOT=/var/www/html/web
# COPY .backend/vhost.conf /etc/apache2/sites-available/000-default.conf

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Install Composer
# RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy Drupal codebase
# COPY . /var/www/

# Set environment variables (adjust as needed)
# ENV PHP_MEMORY_LIMIT=128M
# ENV DRUPAL_DB_NAME=drupal
# ENV DRUPAL_DB_USER=root
# ENV DRUPAL_DB_PASS=password
# ENV DRUPAL_DB_HOST=db

# Expose Drupal port
EXPOSE 80

# Start Apache
# CMD ["apache2", "start"]