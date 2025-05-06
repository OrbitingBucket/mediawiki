#!/bin/bash
set -e

echo "MediaWiki container starting..."

# Output MediaWiki version for logs
php -r 'include_once "/var/www/html/includes/DefaultSettings.php"; echo "Running MediaWiki version: " . $wgVersion . "\n";' 2>/dev/null || echo "Could not determine MediaWiki version"

# Ensure images directory exists with proper permissions
echo "Setting up images directory..."
mkdir -p /var/www/html/images

# Handle .htaccess file
if [ -f /var/www/html/images/.htaccess ]; then
    echo "Found restrictive .htaccess file, backing it up..."
    mv /var/www/html/images/.htaccess /var/www/html/images/.htaccess.bak
fi

# Set proper permissions
chown -R www-data:www-data /var/www/html/images
chmod -R 755 /var/www/html/images

# In production, we may not want these test files
if [ "${ENVIRONMENT:-production}" = "development" ]; then
    # Create a test file to verify we can access the directory
    echo "<h1>Directory Access Test</h1>" > /var/www/html/images/test.html
    chown www-data:www-data /var/www/html/images/test.html
    echo "Test files created for development environment."
fi

# Create an index file for the images directory
cat > /var/www/html/images/index.html << 'INDEX'
<!DOCTYPE html>
<html>
<head>
    <title>MediaWiki Images Directory</title>
    <meta http-equiv="X-Content-Type-Options" content="nosniff">
</head>
<body>
    <h1>MediaWiki Images Directory</h1>
    <p>This is the images directory for MediaWiki.</p>
</body>
</html>
INDEX
chown www-data:www-data /var/www/html/images/index.html

echo "Directory setup complete. Starting Apache..."

# Run the default entrypoint command
exec "$@"
