#!/bin/bash
# Deploy Frontend Script

set -e

FRONTEND_DIR="/var/www/m2-interface/frontend"

echo "Deploying Frontend"
echo ""



cd "$FRONTEND_DIR"
echo "Resetting to origin/main..."
git fetch origin
git reset --hard origin/main

echo "Installing Node.js dependencies..."
npm install

echo "Building frontend for production..."
npm run build

echo "Deploying to web server..."
# Ensure target directory exists
sudo mkdir -p /var/www/html/m2
# Sync files
sudo rsync -av --delete dist/ /var/www/html/m2/

echo ""
echo "Frontend deployed successfully"
