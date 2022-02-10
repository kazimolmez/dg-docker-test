FROM php:7.2-apache

# Set working directory
WORKDIR /var/www/html

# Copy composer.json
COPY /www/composer.json .

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    mcrypt \
    unzip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
#zip
RUN docker-php-ext-install zip \
    && docker-php-ext-enable zip

# mcrypt
RUN apt-get update && apt-get install -y libmcrypt-dev \
    && pecl install mcrypt-1.0.4 \
    && docker-php-ext-enable mcrypt

#other
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd bcmath
RUN docker-php-ext-enable pdo_mysql
RUN docker-php-ext-enable mbstring
RUN docker-php-ext-enable exif
RUN docker-php-ext-enable pcntl
RUN docker-php-ext-enable bcmath
RUN docker-php-ext-enable gd
RUN docker-php-ext-enable bcmath
RUN a2enmod rewrite

#imagick
RUN apt-get update && apt-get install -y \
    libmagickwand-dev --no-install-recommends \
    && pecl install imagick \
	&& docker-php-ext-enable imagick

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
COPY ./www .

# Copy existing application directory permissions
COPY --chown=www:www ./www .

# Change current user to www
USER www

EXPOSE 80
