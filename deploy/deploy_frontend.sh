#!/bin/bash
# Deploy Frontend Script

set -e

FRONTEND_DIR="/var/www/m2-interface/frontend"

echo "Deploying Frontend"
echo ""



cd "$FRONTEND_DIR"
echo "Checking out main branch and pulling latest code..."
git fetch origin main
git checkout main
git pull origin main

# Safety check: abort if not on main branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
	echo "ERROR: Not on main branch! Aborting deployment."
	exit 1
fi

echo "Installing Node.js dependencies..."
npm install -q

echo "Building frontend for production..."
npm run build

echo "Deploying to web server..."
sudo rm -rf /var/www/html/m2/*
sudo cp -r dist/* /var/www/html/m2/

echo ""
echo "Frontend deployed successfully"
