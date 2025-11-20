#!/bin/bash
# Deploy Backend Script

set -e

BACKEND_DIR="/var/www/m2-interface/backend"

echo "Deploying Backend"
echo ""



cd "$BACKEND_DIR"
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

echo ""
echo "Backend deployed successfully"
