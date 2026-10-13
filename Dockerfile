FROM node:22-alpine AS frontend
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY resources ./resources
COPY vite.config.js ./
RUN npm run build

FROM php:8.4-apache
RUN apt-get update && apt-get install -y libpq-dev libzip-dev libicu-dev unzip git && docker-php-ext-install pdo_pgsql intl zip && a2enmod rewrite && rm -rf /var/lib/apt/lists/*
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
WORKDIR /var/www/html
COPY . .
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader --no-scripts
COPY --from=frontend /app/public/build ./public/build
COPY docker/apache.conf /etc/apache2/sites-available/000-default.conf
RUN chown -R www-data:www-data storage bootstrap/cache
EXPOSE 80
