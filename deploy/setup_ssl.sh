#!/bin/bash
# Setup SSL with Let's Encrypt

set -e

# Get domain name from user
read -p "Enter your domain name (e.g., yourdomain.com): " DOMAIN
read -p "Enter your email address: " EMAIL

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    echo "Error: Domain name and email are required"
    exit 1
fi

echo "==================================="
echo "Setting up SSL for $DOMAIN"
echo "==================================="

# Obtain SSL certificate
sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos --email $EMAIL --redirect

# Test automatic renewal
echo "Testing automatic renewal..."
sudo certbot renew --dry-run

echo "==================================="
echo "SSL configured successfully!"
echo "==================================="
echo ""
echo "Your site is now accessible at https://$DOMAIN"
echo "Certificates will auto-renew via cron job"
