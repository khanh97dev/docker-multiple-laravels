#!/bin/sh

# Directory where your source code directories (e.g., web1.com) are mounted
SOURCES_DIR="/app/sources"

# Check if the sources directory exists and is readable
if [ ! -d "$SOURCES_DIR" ]; then
  echo "Error: Sources directory $SOURCES_DIR not found."
  exit 1
fi

# Find all subdirectories in SOURCES_DIR that contain a 'public' folder
# This ensures we only try to generate certs for valid application directories.
# The `basename` command extracts just the directory name (e.g., "web1.com").
DOMAINS=$(find "$SOURCES_DIR" -mindepth 2 -maxdepth 2 -type d -name "public" | xargs -n 1 dirname | xargs -n 1 basename)

if [ -z "$DOMAINS" ]; then
    echo "No domains found in $SOURCES_DIR to process."
else
    echo "Found domains: $DOMAINS"
fi

if [ "$SSL_ON" = "true" ]; then
  echo "Generating SSL certificates for found domains..."
  
  # Loop through the dynamically found domains
  for domain in $DOMAINS; do
    echo "Generating SSL for $domain..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout /etc/nginx/ssl/$domain.key \
      -out /etc/nginx/ssl/$domain.crt \
      -subj "/CN=$domain"
  done
else
  echo "Skipping SSL generation (SSL_ON=$SSL_ON)"
fi

# Start Nginx
nginx -g "daemon off;"