FROM docker-base:latest
MAINTAINER Danis Yogaswara <danis@aniqma.com>

# App Install Directory
ENV PROJECT_DIR /srv

# Set node environment to production to prevent installing dev depedencies
ENV NODE_ENV production

# set locale environtment
ENV SET_LOCALE en_US.UTF-8

# Change working directory to the project
WORKDIR ${PROJECT_DIR}

# Install depedencies when docker build
ENV COMPOSER_ALLOW_SUPERUSER 1
COPY composer.* ${PROJECT_DIR}/

# Copy php.ini
COPY var/docker/php.ini /etc/php/7.1/cli/php.ini
COPY var/docker/php.ini /etc/php/7.1/fpm/php.ini

# Copy php7.1 modules config
COPY var/docker/php/mods-available/* /etc/php/7.1/mods-available/

# Copy php-fpm
COPY var/docker/php-fpm.conf /etc/php/7.1/fpm/php-fpm.conf

# Copy Nginx Config
COPY var/docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY var/docker/nginx/conf.d/default.conf.dist /etc/nginx/conf.d/default.conf.dist
COPY var/docker/nginx/html /usr/share/nginx/html

#copy supervisor config
COPY var/docker/supervisor/conf.d /etc/supervisor/conf.d/

# Copy Scheduler cron
COPY var/docker/cron/* /var/docker/cron/

# Copy Telegraf Config
# COPY var/docker/telegraf/telegraf.conf /etc/telegraf/telegraf.conf

# copy the project to the docker project directory
COPY . ${PROJECT_DIR}

# Copy Entrypoint
COPY var/docker/entrypoint.sh /entrypoint.sh

# Copy .env
COPY .env.docker /srv/.env

# Set Locale
RUN apt-get install --reinstall locales -yqq \
	&& dpkg-reconfigure locales \
	&& locale-gen en_US.UTF-8 \
	&& locale-gen --no-purge --lang en_US.UTF-8


# installing depedencies
RUN composer install --no-progress

# remove git folder
RUN find vendor/ -type d -name .git -exec rm -rf {} + \
	#Configure var permissions
	&& chown -R www-data:www-data storage \
	# Forward laravel.log and lumen.log to Docker log collector
	&& ln -sf /dev/stdout ${PROJECT_DIR}/storage/logs/lumen.log \
	&& ln -sf /dev/stdout ${PROJECT_DIR}/storage/logs/laravel.log

# Set volume
VOLUME ${PROJECT_DIR}

# Set Entry Point
ENTRYPOINT [ "/entrypoint.sh" ]

# Run supervisord
CMD [ "supervisord" ]