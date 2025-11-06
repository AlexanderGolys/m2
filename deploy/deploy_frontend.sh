#!/bin/bash
# Deploy Frontend Script

set -e

APP_DIR="/var/www/m2-interface"
FRONTEND_DIR="$APP_DIR/frontend"

echo "==================================="
echo "Deploying Frontend"
echo "==================================="

# Update repository if git metadata exists
if [ -d "$APP_DIR/.git" ]; then
	echo "Updating project from git..."
	git -C "$APP_DIR" pull --ff-only
else
	echo "Git metadata not found, skipping git pull"
fi

cd $FRONTEND_DIR

# Install dependencies
echo "Installing Node.js dependencies..."
npm install

# Build frontend
echo "Building frontend for production..."
npm run build

# Copy build to nginx directory
echo "Deploying to web server..."
sudo rm -rf /var/www/html/m2
sudo mkdir -p /var/www/html/m2
sudo cp -r dist/* /var/www/html/m2/

echo "==================================="
echo "Frontend deployed successfully!"
echo "==================================="
echo "Frontend files are in /var/www/html/m2"
