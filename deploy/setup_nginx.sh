#!/bin/bash
# Setup Nginx Configuration

set -e

# Get domain name from user
read -p "Enter your domain name (e.g., yourdomain.com): " DOMAIN

if [ -z "$DOMAIN" ]; then
    echo "Error: Domain name is required"
    exit 1
fi

echo "==================================="
echo "Configuring Nginx for $DOMAIN"
echo "==================================="

# Create Nginx configuration
sudo tee /etc/nginx/sites-available/m2-interface > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    # Frontend
    location / {
        root /var/www/html/m2;
        index index.html;
        try_files \$uri \$uri/ /index.html;
    }

    # Backend API
    location /api/ {
        proxy_pass http://localhost:8000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # Timeout settings for long-running computations
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json;
}
EOF

# Enable site
sudo ln -sf /etc/nginx/sites-available/m2-interface /etc/nginx/sites-enabled/

# Remove default site if exists
sudo rm -f /etc/nginx/sites-enabled/default

# Test nginx configuration
echo "Testing Nginx configuration..."
sudo nginx -t

# Restart nginx
echo "Restarting Nginx..."
sudo systemctl restart nginx

echo "==================================="
echo "Nginx configured successfully!"
echo "==================================="
echo ""
echo "Next steps:"
echo "1. Make sure your domain DNS A record points to this server's IP"
echo "2. Wait for DNS propagation (can take up to 48 hours)"
echo "3. Run setup_ssl.sh to enable HTTPS"
echo ""
echo "Your site should now be accessible at http://$DOMAIN"
