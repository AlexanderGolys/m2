#!/bin/bash
# Deploy Backend Script (Dev)

set -e

BACKEND_DIR="/var/www/m2-dev-interface/backend"

echo "Deploying Backend (Dev)"
echo ""



cd "$BACKEND_DIR"
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

if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
fi

source venv/bin/activate
echo "Installing Python dependencies..."
pip install -q --upgrade pip
pip install -q -r requirements.txt

echo "Restarting backend service..."
sudo systemctl restart m2-backend-dev

echo ""
echo "Backend (Dev) deployed successfully"
