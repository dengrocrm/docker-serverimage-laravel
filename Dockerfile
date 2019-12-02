FROM alpine:edge
MAINTAINER dandengro
LABEL maintainer="dandengro"
LABEL com.circleci.preserve-entrypoint=true

# Set version for s6 overlay.
ARG OVERLAY_VERSION="v1.21.7.0"
ARG OVERLAY_ARCH="amd64"

# Environment variables.
ENV PS1="$(whoami)@$(hostname):$(pwd)$ " \
    HOME="/app" \
    TERM="xterm"

RUN \
    # Install build packages.
    apk add --no-cache --virtual=build-dependencies \
        curl \
        tar && \
    # Install runtime packages.
    apk add --no-cache \
        bash \
        ca-certificates \
        coreutils \
        shadow \
        tzdata \
        apache2-utils \
        composer \
        freetype \
        git \
        gnu-libiconv \
        libressl \
        logrotate \
        nginx \
        nodejs \
        npm \
        libpng \
        libjpeg-turbo \
        freetype-dev \
        libpng-dev \
        libjpeg-turbo-dev \
        openssh \
        openssl \
        php7 \
        php7-bcmath \
        php7-cli \
        php7-common \
        php7-curl \
        php7-ctype \
        php7-dev \
        php7-dom \
        php7-fileinfo \
        php7-fpm \
        php7-gd \
        php7-iconv \
        php7-intl \
        php7-json \
        php7-mbstring \
        php7-mcrypt \
        php7-opcache \
        php7-openssl \
        php7-pdo \
        php7-pdo_mysql \
        php7-pgsql \
        php7-session \
        php7-simplexml \
        php7-soap \
        php7-sqlite3 \
        php7-tokenizer \
        php7-xml \
        php7-xmlreader \
        php7-xmlwriter \
        php7-zip \
        php7-zlib \
        php7-pdo_sqlite \
        php7-sqlite3 \
        php7-xdebug \
        redis \
        sqlite \
        yarn && \
    # Add s6 overlay.
    curl -o \
        /tmp/s6-overlay.tar.gz -L \
        "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz" && \
    tar xfz \
        /tmp/s6-overlay.tar.gz -C / && \
    # Create abc user and make our folders.
    groupmod -g 1000 users && \
    useradd -u 911 -U -d /config -s /bin/false abc && \
    usermod -G users abc && \
    mkdir -p \
        /app/src \
        /config \
        /data \
        /defaults && \
    # Configure Nginx.
    echo 'fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;' >> /etc/nginx/fastcgi_params && \
    rm -f /etc/nginx/conf.d/default.conf && \
    # Fix logrotate.
    sed -i "s#/var/log/messages {}.*# #g" /etc/logrotate.conf && \
    # Cleanup.
    apk del --purge \
        build-dependencies && \
    rm -rf \
        /tmp/*

# Copy local files.
COPY root/ /

# Expose ports.
EXPOSE 80 443

WORKDIR /app/src

# ENTRYPOINT ["/init"]