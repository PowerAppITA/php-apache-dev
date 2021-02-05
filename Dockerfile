FROM webdevops/php-apache-dev:7.4

LABEL maintainer="emanuel@powerapp.it"

# Environment variables
ENV APPLICATION_USER=application \
    APPLICATION_GROUP=application \
    APPLICATION_PATH=/app \
    WEB_DOCUMENT_ROOT=/app \
    PHP_DEBUGGER=xdebug  \
    PHP_MEMORY_LIMIT=1024M \
    PHP_DATE_TIMEZONE=Europe/Rome \
    PHP_DISPLAY_ERRORS=1 \
    XDEBUG_DISCOVER_CLIENT_HOST=0 \
    XDEBUG_MODE=debug \
    XDEBUG_START_WITH_REQUEST=1 \
    XDEBUG_CLIENT_HOST=host.docker.internal \
    XDEBUG_CLIENT_PORT=9000

# Commont tools
RUN apt-get update && apt-get dist-upgrade -y && apt-get install -y \
      sudo \
      gettext \
      libfreetype6-dev \
      libjpeg62-turbo-dev \
      libpng-dev \
      default-mysql-client \
      nano

# Reconfigure GD
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg; \
    docker-php-ext-install -j "$(nproc)" gd

# Add application user to sudoers
RUN usermod -aG sudo ${APPLICATION_USER} \
    && echo "${APPLICATION_USER} ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers.d/${APPLICATION_USER}

# Finalize installation and clean up
RUN docker-run-bootstrap \
    && docker-image-cleanup \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Change user
USER ${APPLICATION_USER}

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
