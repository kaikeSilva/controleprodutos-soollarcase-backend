FROM php:8.2-apache

# install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# install php extensions
RUN apt-get update && apt-get install -y libpq-dev \
    && docker-php-ext-install pdo_mysql pdo_pgsql pgsql mbstring exif pcntl bcmath gd

# enable apache modules
RUN a2enmod rewrite

# copy apache config
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

# copy app to container
COPY . /var/www/html

# set working directory
WORKDIR /var/www/html

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# install dependencies
RUN composer install --no-dev --optimize-autoloader

# set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# generate application key
RUN php artisan key:generate

# expose port
EXPOSE 80
