#!/bin/sh
set -eu
mkdir -p storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs storage/app/private bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
if [ "${1:-}" = apache2-foreground ] && [ "${APP_ENV:-}" = production ]; then
    su -s /bin/sh www-data -c 'php artisan optimize'
fi
exec docker-php-entrypoint "$@"
