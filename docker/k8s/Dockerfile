# Multi-stage Laravel Dockerfile for Kubernetes
# PHP 8.4 + PHP-FPM only (without Nginx/Supervisor)

# =============================================================================
# Build stage - Install dependencies and build assets
# =============================================================================
FROM php:8.4-fpm-alpine as build

# Install system dependencies for building
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libwebp-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    oniguruma-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    postgresql-dev \
    npm \
    nodejs

# Install PHP extensions
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    --with-webp

RUN docker-php-ext-install \
    pdo \
    pdo_pgsql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    zip \
    opcache \
    intl \
    soap

# Install Redis extension
RUN apk add --no-cache --virtual .build-deps autoconf g++ make php-pear && \
    pecl install redis && docker-php-ext-enable redis && \
    apk del .build-deps

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy composer files first for better layer caching
COPY composer.json composer.lock ./

# Install PHP dependencies
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist

# Copy package.json and install Node.js dependencies
COPY package.json package-lock.json* ./
RUN npm ci --only=production --platform=linux --arch=x64

# Copy source code
COPY . .

# Generate optimized autoloader
RUN composer dump-autoload --optimize --classmap-authoritative

# Build frontend assets
RUN npm run build || (rm -rf node_modules package-lock.json && npm install && npm run build)

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache

# =============================================================================
# Production stage - Runtime environment with PHP-FPM only
# =============================================================================
FROM php:8.4-fpm-alpine as production

# Install runtime dependencies
RUN apk add --no-cache \
    curl \
    libpng \
    libwebp \
    libjpeg-turbo \
    freetype \
    oniguruma \
    libxml2 \
    libzip \
    postgresql-libs \
    zlib-dev \
    libpng-dev \
    libwebp-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    oniguruma-dev \
    libxml2-dev \
    libzip-dev \
    postgresql-dev

# Install PHP extensions (same as build stage)
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    --with-webp

RUN docker-php-ext-install \
    pdo \
    pdo_pgsql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    zip \
    opcache \
    intl \
    soap

# Install Redis extension
RUN apk add --no-cache --virtual .build-deps autoconf g++ make php-pear && \
    pecl install redis && docker-php-ext-enable redis && \
    apk del .build-deps

# Create www-data user with specific UID/GID for Kubernetes
RUN addgroup -g 1000 -S www-data || true && \
    adduser -u 1000 -D -S -G www-data www-data || true

# Copy PHP configuration
COPY docker/k8s/php.ini /usr/local/etc/php/conf.d/99-custom.ini
COPY docker/k8s/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf

# Set working directory
WORKDIR /var/www/html

# Copy application from build stage
COPY --from=build --chown=www-data:www-data /var/www/html /var/www/html

# Create necessary directories and set permissions
RUN mkdir -p \
    /var/www/html/storage/logs \
    /var/www/html/storage/framework/sessions \
    /var/www/html/storage/framework/views \
    /var/www/html/storage/framework/cache \
    /var/www/html/storage/app/public \
    && chown -R www-data:www-data /var/www/html/storage \
    && chown -R www-data:www-data /var/www/html/bootstrap/cache \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache

# Create health check endpoint
RUN echo '<?php' > /var/www/html/public/health.php \
    && echo 'http_response_code(200);' >> /var/www/html/public/health.php \
    && echo 'echo json_encode(["status" => "healthy", "timestamp" => date("c"), "service" => "php-fpm"]);' >> /var/www/html/public/health.php

# Switch to www-data user
USER www-data

# Expose PHP-FPM port
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]

# =============================================================================
# Development stage (optional)
# =============================================================================
FROM production as development

# Switch back to root for installing dev tools
USER root

# Install Xdebug for development
RUN apk add --no-cache --virtual .build-deps autoconf g++ make linux-headers && \
    pecl install xdebug && docker-php-ext-enable xdebug && \
    apk del .build-deps

# Copy development PHP configuration
COPY docker/k8s/php-dev.ini /usr/local/etc/php/conf.d/99-dev.ini

# Install Composer for development
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Switch back to www-data
USER www-data

# Start PHP-FPM in development mode
CMD ["php-fpm"] 