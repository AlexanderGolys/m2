#!/bin/bash
## Demo: This comment was added as part of a CLI-based PR/merge workflow demonstration.
set -e

# --- Deployment Safety Checks ---
FRONTEND_DIST="/var/www/html/m2"
NGINX_CONF="/etc/nginx/sites-available/macaulay2.fun"

NGINX_ROOT=$(awk '/root / {print $2}' "$NGINX_CONF" | tr -d ';')

# Check if frontend build directory exists
if [ ! -d "$FRONTEND_DIST" ]; then
	echo "ERROR: Frontend build directory $FRONTEND_DIST does not exist. Run 'npm run build' and deploy dist/ first."
	exit 1
fi

# Check if index.html exists
if [ ! -f "$FRONTEND_DIST/index.html" ]; then
	echo "ERROR: index.html not found in $FRONTEND_DIST. Build may have failed."
	exit 1
fi

# Check if Nginx root matches frontend build directory
if [ "$FRONTEND_DIST" != "$NGINX_ROOT" ]; then
	echo "WARNING: Nginx root ($NGINX_ROOT) does not match frontend build directory ($FRONTEND_DIST)."
	echo "Update your Nginx config or deployment paths."
	exit 1
fi

# Path to your config in the repo
REPO_CONF="$(dirname "$0")/nginx/macaulay2.fun"
# Path on the server
SERVER_CONF="/etc/nginx/sites-available/macaulay2.fun"

# Copy config
sudo cp "$REPO_CONF" "$SERVER_CONF"

# Enable site (if not already enabled)
sudo ln -sf "$SERVER_CONF" /etc/nginx/sites-enabled/macaulay2.fun

# Test config
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx

echo "Nginx config deployed and reloaded successfully."
