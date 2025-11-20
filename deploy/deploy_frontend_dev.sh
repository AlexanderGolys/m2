#!/bin/bash
# Deploy Frontend Script (Dev)

set -e

FRONTEND_DIR="/var/www/m2-dev-interface/frontend"

echo "Deploying Frontend (Dev)"
echo ""



cd "$FRONTEND_DIR"
echo "Checking out dev branch and pulling latest code..."
git fetch origin dev
git checkout dev
git pull origin dev

# Safety check: abort if not on dev branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "dev" ]; then
	echo "ERROR: Not on dev branch! Aborting deployment."
	exit 1
fi

echo "Installing Node.js dependencies..."
npm install -q

echo "Building frontend for production..."
npm run build

echo "Deploying to dev web server..."
sudo rm -rf /var/www/html/m2-dev/*
sudo cp -r dist/* /var/www/html/m2-dev/

echo ""
echo "Frontend (Dev) deployed successfully"
