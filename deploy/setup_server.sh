#!/bin/bash
# Server Setup Script for Macaulay2 Web Interface
# Run this on your Ubuntu server

set -e  # Exit on error

echo "==================================="
echo "Macaulay2 Web Interface Setup"
echo "==================================="

# Update system
echo "Updating system packages..."
sudo apt update
sudo apt upgrade -y

# Install Macaulay2
echo "Installing Macaulay2..."
sudo apt install -y macaulay2

# Verify Macaulay2 installation
echo "Verifying Macaulay2 installation..."
M2 --version

# Install Python and pip
echo "Installing Python and pip..."
sudo apt install -y python3 python3-pip python3-venv

# Install Node.js and npm (for frontend build)
echo "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Install nginx
echo "Installing Nginx..."
sudo apt install -y nginx

# Install certbot for SSL
echo "Installing Certbot..."
sudo apt install -y certbot python3-certbot-nginx

# Create application directory
echo "Creating application directory..."
sudo mkdir -p /var/www/m2-interface
sudo chown $USER:$USER /var/www/m2-interface

# Install UFW firewall
echo "Setting up firewall..."
sudo apt install -y ufw
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw --force enable

echo "==================================="
echo "Base setup complete!"
echo "==================================="
echo ""
echo "Next steps:"
echo "1. Clone/upload your application to /var/www/m2-interface"
echo "2. Run deploy_backend.sh to set up the backend"
echo "3. Run deploy_frontend.sh to build and deploy the frontend"
echo "4. Run setup_nginx.sh to configure the web server"
