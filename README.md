# php-apache-dev
PHP Development Enviroment featuring:

 - PHP 7.4  
 - Apache 2.4
 - Composer

extension of webdevops/php-apache-dev:7.4 image

cfr: https://github.com/webdevops/Dockerfile/tree/master/docker/php-apache-dev/7.4

## docker-compose.yml example

    version: '3'

    services:
        web-app:
            image: powerapp/php-apache-dev:latest
            ports:
                - "80:80"
            depends_on:
                - dbserver
            links:
                - dbserver
                - pma
                - mailhog
            volumes:
                - "./docroot:/app"
            environment:
                WEB_DOCUMENT_ROOT: "/app/public"
                PHP_IDE_CONFIG: "serverName=localhost"
                POSTFIX_RELAYHOST: "mailhog:1025"

        dbserver:
            image: mariadb:latest
            ports:
                - "3306:3306"
            environment:
                MYSQL_DATABASE: my_project
                MYSQL_ROOT_PASSWORD: root
                MYSQL_USER: my_project_usr
                MYSQL_PASSWORD: my_project_pwd

        mailhog:
            image: mailhog/mailhog:latest
            ports:
                - "1025:1025"
                - "8025:8025"

        pma:
            image: phpmyadmin/phpmyadmin:latest
            environment:
                PMA_HOST: dbserver
                PMA_USER: my_project_usr
                PMA_PASSWORD: my_project_pwd
                PHP_UPLOAD_MAX_FILESIZE: 1G
                PHP_MAX_INPUT_VARS: 1G
            ports:
                - "8080:80"
