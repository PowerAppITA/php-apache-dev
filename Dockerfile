FROM webdevops/php-apache-dev:7.3

LABEL maintainer="emanuel@powerapp.it"

# Environment variables
ENV APPLICATION_PATH=/app \
    WEB_DOCUMENT_ROOT=index.php \
    PHP_DEBUGGER=xdebug  \
    PHP_MEMORY_LIMIT=1024M \
    PHP_DATE_TIMEZONE=Europe/Rome \
    PHP_DISPLAY_ERRORS=1 \
    XDEBUG_REMOTE_HOST=host.docker.internal \
    XDEBUG_REMOTE_PORT=9000

# Commont tools
RUN apt-get update && apt-get dist-upgrade -y && apt-get install -y \
      sudo \
      gettext \
      libfreetype6-dev \
      libjpeg62-turbo-dev \
      libpng-dev \
      mysql-client \
      nano

# Reconfigure GD
RUN docker-php-ext-configure gd \
    --with-gd \
    --with-freetype-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/

# Add application user to sudoers
RUN usermod -aG sudo ${APPLICATION_USER} \
    && echo "${APPLICATION_USER} ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers.d/${APPLICATION_USER}

# Xdebug custom variables
RUN echo 'xdebug.remote_autostart=1\nxdebug.remote_connect_back=0\nxdebug.remote_handler="dbgp"' >> /opt/docker/etc/php/php.ini

# Finalize installation and clean up
RUN docker-run-bootstrap \
    && docker-image-cleanup \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Change user
USER ${APPLICATION_USER}

# Composer parallel install plugin
RUN composer global require hirak/prestissimo

# Add bash aliases and terminal conf
RUN { \
      echo ' '; \
      echo '# Add bash aliases.'; \
      echo 'if [ -f $APPLICATION_PATH/.aliases ]; then' | envsubst; \
      echo '    source $APPLICATION_PATH/.aliases' | envsubst; \
      echo 'fi'; \
      echo ' '; \
      echo '# Add terminal config.'; \
      echo 'stty rows 80; stty columns 160;'; \
    } >> ~/.bashrc

# Container must start as root user
USER root

# Default work dir
WORKDIR ${APPLICATION_PATH}
