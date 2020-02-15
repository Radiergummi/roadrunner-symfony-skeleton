FROM php:7.4-cli AS builder

# See https://github.com/spiral/roadrunner/releases
ENV ROADRUNNER_VERSION 1.6.0

# Install libzip and unzip required by the zip extension
RUN apt-get update && apt-get install -y --no-install-recommends \
    libzip-dev \
    unzip

# Install ZIP extension required by composer
RUN docker-php-ext-install zip

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php -r "if (hash_file('SHA384', 'composer-setup.php') === rtrim(file_get_contents('https://composer.github.io/installer.sig'))) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Download RoadRunner
RUN mkdir /tmp/rr \
  && cd /tmp/rr \
  && echo "{\"require\":{\"spiral/roadrunner\":\"${ROADRUNNER_VERSION}\"}}" >> composer.json \
  && composer install \
  && vendor/bin/rr get-binary

FROM php:7.4-cli

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
  procps \
  inotify-tools
  # Add dependencies for extensions to this list

# Install extensions
# See below for a list of other available extensions:
# https://gist.github.com/giansalex/2776a4206666d940d014792ab4700d80

# The sockets extension is required for the roadrunner bridge to work
RUN docker-php-ext-install sockets

#RUN docker-php-ext-install opcache
#RUN docker-php-ext-install pdo
#RUN docker-php-ext-install pdo_mysql

# Copy the roadrunner binary
COPY --from=builder /tmp/rr/rr /usr/local/bin/rr

# Copy the PHP configuration file
COPY php.ini /usr/local/etc/php/php.ini

# Copy the application files
# You should add additional folders (templates, translations, assets etc.) to
# this list. Take care of the order you add things in: Put those directories
# that change most often to the bottom of the list.
COPY ./bin /var/www/bin
COPY ./public /var/www/public
COPY ./vendor /var/www/vendor
COPY ./config /var/www/config
COPY ./src /var/www/src
COPY ./var /var/www/var
COPY ./.env /var/www/.env

# Change the working directory to the web files
WORKDIR /var/www

# We want the container to run in a production environment by default
ENV APP_ENV=prod

# Warm up the Symfony cache
RUN php bin/console cache:warmup

# Run roadrunner
ENTRYPOINT ["/usr/local/bin/rr", "serve", "-c", ".rr.yaml"]
