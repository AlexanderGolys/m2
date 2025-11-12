#!/bin/bash
# Deploy Script - Run this to deploy all changes (backend and/or frontend)

set -e

APP_DIR="/var/www/m2-interface"
BACKEND_DIR="$APP_DIR/backend"
FRONTEND_DIR="$APP_DIR/frontend"

echo "Deploying Macaulay2 Interface"
echo ""

# Update repository
if [ -d "$APP_DIR/.git" ]; then
	echo "Pulling latest code from git..."
	git -C "$APP_DIR" pull --ff-only
else
	echo "Git metadata not found, skipping git pull"
fi

# Check if backend or frontend changed
BACKEND_CHANGED=false
FRONTEND_CHANGED=false

if git -C "$APP_DIR" diff HEAD~1 HEAD --name-only | grep -q "^backend/"; then
	BACKEND_CHANGED=true
fi

if git -C "$APP_DIR" diff HEAD~1 HEAD --name-only | grep -q "^frontend/"; then
	FRONTEND_CHANGED=true
fi

# Deploy backend if changed
if [ "$BACKEND_CHANGED" = true ] || [ $# -eq 1 ] && [ "$1" = "--backend" ]; then
	echo ""
	echo "Deploying backend..."
	cd "$BACKEND_DIR"
	
	if [ ! -d "venv" ]; then
		echo "Creating Python virtual environment..."
		python3 -m venv venv
	fi
	
	source venv/bin/activate
	echo "Installing Python dependencies..."
	pip install -q --upgrade pip
	pip install -q -r requirements.txt
	
	echo "Restarting backend service..."
	sudo systemctl restart m2-backend
	echo "Backend deployed successfully"
fi

# Deploy frontend if changed
if [ "$FRONTEND_CHANGED" = true ] || [ $# -eq 1 ] && [ "$1" = "--frontend" ]; then
	echo ""
	echo "Deploying frontend..."
	cd "$FRONTEND_DIR"
	
	echo "Installing Node.js dependencies..."
	npm install -q
	
	echo "Building frontend for production..."
	npm run build
	
	echo "Deploying to web server..."
	sudo rm -rf /var/www/html/m2/*
	sudo cp -r dist/* /var/www/html/m2/
	echo "Frontend deployed successfully"
fi

if [ "$BACKEND_CHANGED" = false ] && [ "$FRONTEND_CHANGED" = false ] && [ $# -eq 0 ]; then
	echo ""
	echo "No changes detected in backend or frontend"
	echo "To force deployment: $0 --backend or $0 --frontend"
fi

echo ""
echo "Deployment complete"
