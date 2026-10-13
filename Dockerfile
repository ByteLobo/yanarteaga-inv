FROM node:22-alpine AS frontend
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY resources ./resources
COPY vite.config.js ./
RUN npm run build

FROM php:8.4-apache
RUN apt-get update && apt-get install -y libpq-dev libzip-dev libicu-dev libonig-dev unzip git && docker-php-ext-install pdo_pgsql intl zip mbstring opcache && a2enmod rewrite && rm -rf /var/lib/apt/lists/*
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
WORKDIR /var/www/html
COPY . .
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader --no-scripts
COPY --from=frontend /app/public/build ./public/build
COPY docker/apache.conf /etc/apache2/sites-available/000-default.conf
RUN chown -R www-data:www-data storage bootstrap/cache
COPY docker/php-production.ini /usr/local/etc/php/conf.d/production.ini
COPY docker/entrypoint.sh /usr/local/bin/yanarteaga-entrypoint
RUN chmod +x /usr/local/bin/yanarteaga-entrypoint
ENTRYPOINT ["yanarteaga-entrypoint"]
CMD ["apache2-foreground"]
EXPOSE 80
