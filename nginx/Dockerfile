FROM nginx:1.29-alpine

# Set default value for F (can be overridden at build or runtime)
ARG SSL_ON=false
ENV SSL_ON=$SSL_ON

# Install OpenSSL
RUN apk add --no-cache openssl

# Create SSL directory
RUN mkdir -p /etc/nginx/ssl

# Copy custom entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Copy Nginx config
COPY ./conf.d /etc/nginx/conf.d

# Entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]