#!/bin/bash
# Simple MVP script to check if your site and static files are served correctly
# Usage: bash check_site.sh [domain] (default: macaulay2.fun)

DOMAIN=${1:-macaulay2.fun}

# Check HTTP root
STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$DOMAIN/)
echo "HTTP / status: $STATUS"

# Check HTTP index.html
STATUS_INDEX=$(curl -s -o /dev/null -w "%{http_code}" http://$DOMAIN/index.html)
echo "HTTP /index.html status: $STATUS_INDEX"

# Check HTTPS root
STATUS_HTTPS=$(curl -k -s -o /dev/null -w "%{http_code}" https://$DOMAIN/)
echo "HTTPS / status: $STATUS_HTTPS"

# Check HTTPS index.html
STATUS_HTTPS_INDEX=$(curl -k -s -o /dev/null -w "%{http_code}" https://$DOMAIN/index.html)
echo "HTTPS /index.html status: $STATUS_HTTPS_INDEX"

# Check /admin/stats endpoint
STATUS_STATS=$(curl -s -o /dev/null -w "%{http_code}" http://$DOMAIN/admin/stats)
echo "HTTP /admin/stats status: $STATUS_STATS"

STATUS_STATS_HTTPS=$(curl -k -s -o /dev/null -w "%{http_code}" https://$DOMAIN/admin/stats)
echo "HTTPS /admin/stats status: $STATUS_STATS_HTTPS"

# Show a sample of the index.html content
echo -e "\nSample of index.html (HTTP):"
curl -s http://$DOMAIN/index.html | head -20
