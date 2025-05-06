FROM mediawiki:1.43

# Install required packages
RUN apt-get update && apt-get install -y \
    apache2-utils \
    unzip \
    git \
    curl \
    && a2enmod headers \
    && rm -rf /var/lib/apt/lists/*

# Configure Apache security
COPY mediawiki-security.conf /etc/apache2/conf-available/
RUN a2enconf mediawiki-security

# Set up base directory 
WORKDIR /var/www/html
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Create a known good directory structure for images
RUN mkdir -p /var/www/html/images \
    && rm -f /var/www/html/images/.htaccess \
    && chown -R www-data:www-data /var/www/html/images \
    && chmod -R 755 /var/www/html/images

# Setup initialization script for container startup
COPY container-init.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/container-init.sh

ENTRYPOINT ["/usr/local/bin/container-init.sh"]
CMD ["apache2-foreground"]
