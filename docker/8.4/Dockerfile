# Multi-stage Laravel Dockerfile for Development
# PHP 8.4 + All development tools

# =============================================================================
# Base stage - PHP 8.4 with extensions
# =============================================================================
FROM php:8.4-fpm-alpine as base

# Install system dependencies
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
    nodejs \
    bash \
    vim \
    nano \
    htop \
    supervisor

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

# Create www-data user with specific UID/GID
RUN addgroup -g 1000 -S www-data || true && \
    adduser -u 1000 -D -S -G www-data www-data || true

# Set working directory
WORKDIR /var/www/html

# =============================================================================
# Development stage - All development tools
# =============================================================================
FROM base as development

# Switch to root for installing dev tools
USER root

# Install Xdebug for development
RUN apk add --no-cache --virtual .build-deps autoconf g++ make linux-headers && \
    pecl install xdebug && docker-php-ext-enable xdebug && \
    apk del .build-deps

# Install additional development tools
RUN apk add --no-cache \
    python3 \
    py3-pip

# Copy PHP configuration
COPY docker/8.4/php.ini /usr/local/etc/php/conf.d/99-custom.ini
COPY docker/8.4/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf

# Copy Supervisor configuration
COPY docker/8.4/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create supervisor log directory
RUN mkdir -p /var/log/supervisor && \
    chown -R www-data:www-data /var/log/supervisor && \
    chmod -R 755 /var/log/supervisor

# Create PHP-FPM log directory
RUN mkdir -p /var/log && \
    touch /var/log/php-fpm-access.log /var/log/php-fpm-slow.log /var/log/php-fpm-error.log && \
    chown -R www-data:www-data /var/log && \
    chmod -R 755 /var/log

# Create necessary directories and set permissions
RUN mkdir -p \
    /var/www/html/storage/logs \
    /var/www/html/storage/framework/sessions \
    /var/www/html/storage/framework/views \
    /var/www/html/storage/framework/cache \
    /var/www/html/storage/app/public \
    /var/www/html/bootstrap/cache \
    /var/www/html/public \
    && chown -R www-data:www-data /var/www/html/storage \
    && chown -R www-data:www-data /var/www/html/bootstrap/cache \
    && chown -R www-data:www-data /var/www/html/public \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache \
    && chmod -R 755 /var/www/html/public

# Create health check endpoint
RUN echo '<?php' > /var/www/html/public/health.php \
    && echo 'http_response_code(200);' >> /var/www/html/public/health.php \
    && echo 'echo json_encode(["status" => "healthy", "timestamp" => date("c"), "service" => "php-fpm-dev-8.4"]);' >> /var/www/html/public/health.php

# Switch to www-data user
USER www-data

# Configure git to allow working with mounted repositories
RUN git config --global --add safe.directory /var/www/html

# Expose PHP-FPM port
EXPOSE 9000

# Start Supervisor (which will start PHP-FPM)
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# =============================================================================
# Production stage - Runtime environment
# =============================================================================
FROM base as production

# Copy PHP configuration
COPY docker/8.4/php.ini /usr/local/etc/php/conf.d/99-custom.ini
COPY docker/8.4/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf

# Create necessary directories and set permissions
RUN mkdir -p \
    /var/www/html/storage/logs \
    /var/www/html/storage/framework/sessions \
    /var/www/html/storage/framework/views \
    /var/www/html/storage/framework/cache \
    /var/www/html/storage/app/public \
    /var/www/html/bootstrap/cache \
    /var/www/html/public \
    && chown -R www-data:www-data /var/www/html/storage \
    && chown -R www-data:www-data /var/www/html/bootstrap/cache \
    && chown -R www-data:www-data /var/www/html/public \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache \
    && chmod -R 755 /var/www/html/public

# Create health check endpoint
RUN echo '<?php' > /var/www/html/public/health.php \
    && echo 'http_response_code(200);' >> /var/www/html/public/health.php \
    && echo 'echo json_encode(["status" => "healthy", "timestamp" => date("c"), "service" => "php-fpm"]);' >> /var/www/html/public/health.php

# Switch to www-data user
USER www-data

# Configure git to allow working with mounted repositories
RUN git config --global --add safe.directory /var/www/html

# Expose PHP-FPM port
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]

# =============================================================================
# Nginx stage for development
# =============================================================================
FROM nginx:alpine as nginx-dev

COPY docker/8.4/nginx.conf /etc/nginx/conf.d/default.conf

# Логи в stdout/stderr для удобства
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

WORKDIR /var/www/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

# =============================================================================
# Combined stage - Nginx + PHP-FPM for Laravel
# =============================================================================
FROM development as laravel-app

# Switch to root for installing nginx
USER root

# Install nginx
RUN apk add --no-cache nginx

# Copy nginx configuration
COPY docker/8.4/nginx.conf /etc/nginx/http.d/default.conf

# Configure nginx logs
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Create nginx user and set permissions
RUN addgroup -g 101 -S nginx || true && \
    adduser -u 101 -D -S -G nginx nginx || true

# Copy startup script
COPY docker/8.4/start-container /usr/local/bin/start-container
RUN chmod +x /usr/local/bin/start-container

# Expose both ports
EXPOSE 80 9000

# Start container with our script
CMD ["/usr/local/bin/start-container"]
