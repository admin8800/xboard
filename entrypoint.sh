#!/bin/sh
set -e

mkdir -p \
  /run/nginx \
  /var/log/supervisor \
  /www/storage/app \
  /www/storage/logs \
  /www/sqlite-data \
  /www/bootstrap/cache

chown -R www:www /www/storage /www/bootstrap/cache /www/sqlite-data

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
