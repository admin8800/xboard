FROM phpswoole/swoole:php8.2-alpine AS builder

ARG XBOARD_REPO=https://github.com/cedar2025/Xboard.git
ARG XBOARD_BRANCH=master

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN CFLAGS="-O0" install-php-extensions pcntl \
    && CFLAGS="-O0 -g0" install-php-extensions bcmath \
    && install-php-extensions zip redis

WORKDIR /build

RUN apk add --no-cache git patch \
    && git clone --depth=1 -b ${XBOARD_BRANCH} ${XBOARD_REPO} xboard

WORKDIR /build/xboard

RUN git submodule update --init --recursive --force \
    && sed -i 's/^REDIS_HOST=.*/REDIS_HOST=redis/' .env.example \
    && composer install --no-cache --no-dev --no-security-blocking \
    && php artisan storage:link \
    && rm -rf .git .github tests


FROM phpswoole/swoole:php8.2-alpine

ENV TZ=Asia/Shanghai

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN CFLAGS="-O0" install-php-extensions pcntl \
    && CFLAGS="-O0 -g0" install-php-extensions bcmath \
    && install-php-extensions zip redis \
    && apk add --no-cache \
        nginx \
        supervisor \
        mysql-client \
        shadow \
        sqlite \
        tzdata \
    && ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo Asia/Shanghai > /etc/timezone \
    && addgroup -S -g 1000 www \
    && adduser -S -G www -u 1000 www

COPY --from=builder /build/xboard /www

COPY XboardInstall.php /www/app/Console/Commands/XboardInstall.php

WORKDIR /www

RUN mkdir -p \
    /run/nginx \
    /var/log/supervisor \
    /www/storage/app \
    /www/storage/logs \
    /www/bootstrap/cache \
    /www/sqlite-data \
    && chown -R www:www /www \
    && chmod -R 775 /www/storage /www/bootstrap/cache /www/sqlite-data

COPY nginx.conf /etc/nginx/http.d/default.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
