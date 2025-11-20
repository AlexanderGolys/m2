#!/bin/bash
## Demo: This comment was added as part of a CLI-based PR/merge workflow demonstration.
set -e

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
