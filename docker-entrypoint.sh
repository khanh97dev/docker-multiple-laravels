#!/bin/bash
# Exit immediately if a command exits with a non-zero status, or if a variable is unset.
set -eo pipefail

# --- Helper Function ---
# Function to safely configure and start an openrc service
start_openrc_service() {
    local service_name=$1
    echo "Configuring and starting $service_name..."
    # Ensure openrc environment is ready
    openrc > /dev/null 2>&1 || true
    touch /run/openrc/softlevel || true
    
    # Add to default runlevel if not already added
    if ! rc-update show | grep -q "$service_name"; then
        rc-update add "$service_name" default > /dev/null 2>&1
    fi
    rc-service "$service_name" start
}

# --- 1. Environment and System Setup ---
echo "Sourcing environment variables..."
source /.env

# Configure reliable DNS resolvers to prevent network issues
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf

# NOTE on Composer: Running 'composer install' here is ambiguous in a multi-site setup
# as the WORKDIR is typically only one location. Dependencies should usually be 
# installed during the Docker build or handled per-app in a separate script.

# --- 2. Dynamic Cron Job Configuration ---
APP_ROOT="/var/www/sources"
CRON_SCHEDULE_COMMAND="php artisan schedule:run >> /dev/null 2>&1"
CRONTABS_FILE="/etc/crontabs/root"

echo "Configuring dynamic cron jobs for applications in $APP_ROOT..."

# Clear existing crontabs for root user
> "$CRONTABS_FILE"

# Find all applications with an 'artisan' file and add their schedule runner to cron
# -mindepth 2 -maxdepth 2 ensures we look exactly one level down from APP_ROOT
find "$APP_ROOT" -mindepth 2 -maxdepth 2 -type f -name "artisan" | while read -r ARTISAN_PATH; do
    # Get the parent directory (e.g., /var/www/web1.com)

    APP_DIR=$(dirname "$ARTISAN_PATH")
    chmod +x "$ARTISAN_PATH"
    echo "-> Found application: $APP_DIR"
    
    # Cron job: change directory (cd) and run command
    CRON_JOB="* * * * * cd $APP_DIR && $CRON_SCHEDULE_COMMAND"
    
    echo "$CRON_JOB" >> "$CRONTABS_FILE"
    echo "   - Added cron job: $CRON_JOB"
done

# If no apps found, log it
if [ ! -s "$CRONTABS_FILE" ]; then
    echo "No 'artisan' applications found to configure scheduled tasks."
fi

# --- 3. Service Startup ---
start_openrc_service dcron

# --- 4. Execute Primary Process ---
echo "Starting PHP-FPM in foreground..."
# Use exec to replace the current shell process with php-fpm, 
# ensuring signals (like SIGTERM) are correctly passed to the main application.
exec php-fpm82 --nodaemonize