#!/bin/bash
# Deploy Frontend Script

set -e

FRONTEND_DIR="/var/www/m2-interface/frontend"

echo "Deploying Frontend"
echo ""

cd "$FRONTEND_DIR"

echo "Installing Node.js dependencies..."
npm install -q

echo "Building frontend for production..."
npm run build

echo "Deploying to web server..."
sudo rm -rf /var/www/html/m2/*
sudo cp -r dist/* /var/www/html/m2/

echo ""
echo "Frontend deployed successfully"
