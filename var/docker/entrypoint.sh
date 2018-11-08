#!/bin/bash
#
# Docker Entrypoint
#
# Configures the application
# Runs nginx by default

# Default ENV variables
: ${ENVIRONMENT:="dev"}
: ${MAINTENANCE:="0"}
: ${HTTP_CACHE:="0"}
: ${TRUSTED_HOSTS:=""}
: ${TRUSTED_PROXIES:="127.0.0.1"}
: ${NEWRELIC_LICENSE:=""}
: ${NEWRELIC_APPNAME:="PHP Application"}
: ${NEWRELIC_FRAMEWORK:="laravel"}
: ${NGINX_SERVER_NAME:="aniqma.dev"}
: ${AWS_REGION:="us-east-1"}
: ${AWS_S3_BUCKET:="default"}

export ENVIRONMENT
export MAINTENANCE
export HTTP_CACHE
export TRUSTED_HOSTS
export TRUSTED_PROXIES

export NEWRELIC_LICENSE
export NEWRELIC_APPNAME
export NEWRELIC_FRAMEWORK

export NGINX_SERVER_NAME
export NGINX_LARAVEL_HOST
export NGINX_LARAVEL_PORT

echo "Usage:"
echo "    command [options] [arguments]"
echo ""
echo "The default behavior of this container is to start basic services with supervisor."
echo "It is the same as running:"
echo ""
echo "Supported commands are:"
echo "    bash"
echo "    nginx"
echo "    php-fpm7.1"
echo "    supervisord"
echo ""
echo "Support environment variables are:"
echo "    ENVIRONMENT=${ENVIRONMENT} - Environment to use (prod, dev, test)"
echo "    MAINTENANCE=${MAINTENANCE} - Currently makes nginx display maintenance page. (0,1)"
echo "    HTTP_CACHE=${HTTP_CACHE} - Enables Laravel built in HTTP cache. (0,1)"
echo "    TRUSTED_HOSTS=${TRUSTED_HOSTS} - Trusted HTTP hosts header to answer to. (example.com)"
echo "    TRUSTED_PROXIES=${TRUSTED_PROXIES} - IP ranges of proxies to trust. (127.0.0.1/32)"
echo "    NEWRELIC_LICENSE=${NEWRELIC_LICENSE} - License to use with NewRelic"
echo "    NEWRELIC_APPNAME=${NEWRELIC_APPNAME} - App name to use with NewRelic (PHP Application)"
echo "    NEWRELIC_FRAMEWORK=${NEWRELIC_FRAMEWORK} - PHP Framework (Laravel)"
echo "    NGINX_SERVER_NAME=${NGINX_SERVER_NAME} - Enables Laravel to trust proxies. (0,1)"
echo "    NGINX_LARAVEL_HOST=${NGINX_LARAVEL_HOST} - Nginx fastcgi server host for Laravel. (127.0.0.1)"
echo "    NGINX_LARAVEL_PORT=${NGINX_LARAVEL_PORT} - Nginx fastcgi server port for Laravel. (80)"
echo ""

# Check if environment is dev
if [ "$ENVIRONMENT" == "dev" ]
then
    # PHP Settings
    sed -i 's/display_errors = Off/display_errors = On/' /etc/php/7.1/cli/php.ini
    sed -i 's/display_errors = Off/display_errors = On/' /etc/php/7.1/fpm/php.ini

    # Enable xdebug
    echo "zend_extension=xdebug.so"            > "/etc/php/7.1/mods-available/xdebug.ini"
    echo "xdebug.cli_color = 1"               >> "/etc/php/7.1/mods-available/xdebug.ini"
    echo "xdebug.remote_connect_back = 1"     >> "/etc/php/7.1/mods-available/xdebug.ini"
    echo "xdebug.coverage_enable = 0"         >> "/etc/php/7.1/mods-available/xdebug.ini"
    echo "xdebug.profiler_enable_trigger = 1" >> "/etc/php/7.1/mods-available/xdebug.ini"
    echo "xdebug.coverage_enable = 1"         >> "/etc/php/7.1/mods-available/xdebug.ini"
else
    # Disable xdebug
    echo ";zend_extension=xdebug.so" > "/etc/php/7.1/mods-available/xdebug.ini"

    # Disable assetic-watch
    if [ -f /etc/supervisor/conf.d/assetic.conf ]; then
        rm /etc/supervisor/conf.d/assetic.conf
    fi
fi

# Ensure proper permissions for Laravel
chmod -R 775 $PROJECT_DIR/storage/logs

# Generate configuration by looping through .dist files in /etc/nginx/conf.d/default.conf
for f in /etc/nginx/conf.d/*.conf.dist
do
    # Replace ${VAR} with variables set in environment.
    # Specify defaults for vars with :- syntax ${VAR:-DEFAULTVALUE}
    # foo.xml.dist will have vars replaced and created as foo.xml
    #
    # $ x="/foo/fizzbuzz.bar.quux"
    # $ y=${x%.*}
    # $ echo $y
    # /foo/fizzbuzz.bar
    perl -p -e 's/\$\{([^}^:^-^\s]+)(\s?\:-\s?)?[''"]?(.*?)[''"]?[\s]*\}/defined $ENV{$1} ? $ENV{$1} : $3/eg' $f > ${f%.*}
done

# Generate configuration by looping through .dist files in /etc/php/7.1/mods-available
for f in /etc/php/7.1/mods-available/*.ini.dist
do
    # Replace ${VAR} with variables set in environment.
    # Specify defaults for vars with :- syntax ${VAR:-DEFAULTVALUE}
    # foo.xml.dist will have vars replaced and created as foo.xml
    #
    # $ x="/foo/fizzbuzz.bar.quux"
    # $ y=${x%.*}
    # $ echo $y
    # /foo/fizzbuzz.bar
    perl -p -e 's/\$\{([^}^:^-^\s]+)(\s?\:-\s?)?[''"]?(.*?)[''"]?[\s]*\}/defined $ENV{$1} ? $ENV{$1} : $3/eg' $f > ${f%.*}
done

# If ENV MAINTENANCE then enable maintenance mode on Nginx
if [ "$MAINTENANCE" == "1" ]
then
    # Create maintenance file in project dir
    touch $PROJECT_DIR/web/maintenance
else
    # Remove maintenance file in project dir if exists
    if [ -f $PROJECT_DIR/web/maintenance ]
    then
        rm $PROJECT_DIR/web/maintenance
    fi
fi

# Install Composer Dependencies... Should have
cd $PROJECT_DIR
composer dump --no-interaction

# Run Artisan Commands.
#php artisan migrate --force
php artisan cache:clear

# Ensure proper permissions for Laravel
chown -R www-data.www-data $PROJECT_DIR/storage/logs

# Export cron
cp /var/docker/cron/artisan-schedule /etc/cron.d/cronartisan
# touch /var/log/cron.log

chmod 777 $PROJECT_DIR/storage/logs/ -R

# Run CMD from docker
exec "$@"