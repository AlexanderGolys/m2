#!/usr/bin/env bash
set -euo pipefail

# Create and enable a new Nginx site on this server.
# Supports static sites and optional backend API proxy.
# Requires: sudo permissions, nginx, (optional) certbot
#
# Usage examples:
#   ./scripts/new_site.sh --domain example.com --root /var/www/prod/m2 --api-port 8000 --ssl --www
#   ./scripts/new_site.sh --domain dev.example.com --root /var/www/dev/m2 --api-port 8001
#   ./scripts/new_site.sh --domain static.example.com --root /var/www/static --ssl
#
# Flags:
#   --domain <name>        primary domain (required)
#   --root <path>          document root (required)
#   --api-port <port>      add /api/ proxy to 127.0.0.1:<port> (optional)
#   --www                  include www.<domain> in server_name and SSL
#   --ssl                  obtain/enable SSL via certbot (assumes DNS already points to this server)
#

DOMAIN=""
ROOT=""
API_PORT=""
WITH_WWW=0
WITH_SSL=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --domain)
      DOMAIN="$2"; shift 2;;
    --root)
      ROOT="$2"; shift 2;;
    --api-port)
      API_PORT="$2"; shift 2;;
    --www)
      WITH_WWW=1; shift;;
    --ssl)
      WITH_SSL=1; shift;;
    *)
      echo "Unknown argument: $1" >&2; exit 1;;
  esac
done

if [[ -z "$DOMAIN" || -z "$ROOT" ]]; then
  echo "Error: --domain and --root are required." >&2
  exit 1
fi

if [[ ! -d "$ROOT" ]]; then
  echo "Creating root directory: $ROOT"
  sudo mkdir -p "$ROOT"
  sudo chown -R "$USER":"$USER" "$ROOT"
fi

SERVER_NAMES="$DOMAIN"
if [[ $WITH_WWW -eq 1 ]]; then
  SERVER_NAMES="$DOMAIN www.$DOMAIN"
fi

CONF_PATH="/etc/nginx/sites-available/$DOMAIN"
ENABLED_LINK="/etc/nginx/sites-enabled/$DOMAIN"

# Create HTTP server block (port 80). For SSL, certbot will modify and add 443 block.
TMP_CONF=$(mktemp)
cat > "$TMP_CONF" <<CONF
server {
    listen 80;
    server_name $SERVER_NAMES;

    root $ROOT;
    index index.html;

    # Static files + SPA fallback
    location / {
        try_files \$uri \$uri/ /index.html;
    }
CONF

if [[ -n "$API_PORT" ]]; then
  cat >> "$TMP_CONF" <<CONF

    # API proxy
    location /api/ {
        proxy_pass http://127.0.0.1:$API_PORT/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
CONF
fi

cat >> "$TMP_CONF" <<CONF
}
CONF

sudo cp "$TMP_CONF" "$CONF_PATH"
rm "$TMP_CONF"

sudo ln -sf "$CONF_PATH" "$ENABLED_LINK"

# Test Nginx config
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx

echo "Site enabled: $DOMAIN -> root $ROOT"

if [[ $WITH_SSL -eq 1 ]]; then
  if command -v certbot >/dev/null 2>&1; then
    if [[ $WITH_WWW -eq 1 ]]; then
      sudo certbot --nginx -d "$DOMAIN" -d "www.$DOMAIN" --redirect --non-interactive --agree-tos -m "admin@$DOMAIN" || true
    else
      sudo certbot --nginx -d "$DOMAIN" --redirect --non-interactive --agree-tos -m "admin@$DOMAIN" || true
    fi
    sudo systemctl reload nginx || true
    echo "SSL attempted via certbot. Verify certificates and HTTPS operation."
  else
    echo "certbot not installed; skipping SSL. Install and run manually if needed." >&2
  fi
fi

echo "Done."
